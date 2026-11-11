package com.campusconnect.web;

import jakarta.mail.MessagingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

public class AuthServlet extends HttpServlet {
    private static final Duration VERIFICATION_LIFETIME = Duration.ofHours(24);
    private static final int MAX_LOGIN_ATTEMPTS = 10;
    private static final Duration LOGIN_WINDOW = Duration.ofMinutes(15);
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private static final ConcurrentHashMap<String, LoginAttempts> LOGIN_ATTEMPTS = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, LoginAttempts> REGISTRATION_ATTEMPTS = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, Instant> VERIFICATION_EMAIL_ATTEMPTS = new ConcurrentHashMap<>();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("verify".equals(action)) {
            verifyEmail(req, resp);
            return;
        }
        if ("logout".equals(action)) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Sign out using the account menu.");
            return;
        }

        String view = "register".equals(action)
                ? "/WEB-INF/views/register.jsp"
                : "/WEB-INF/views/auth.jsp";
        req.getRequestDispatcher(view).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("logout".equals(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }
        if ("resendVerification".equals(action)) {
            resendVerification(req, resp);
            return;
        }
        if (!"login".equals(action) && !"register".equals(action)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown authentication action.");
            return;
        }

        String email = normalizeEmail(req.getParameter("email"));
        String password = req.getParameter("password");
        if (email == null || password == null || password.isBlank()) {
            fail(req, resp, "Email and password are required.");
            return;
        }

        if ("register".equals(action)) {
            register(req, resp, email, password);
        } else {
            login(req, resp, email, password);
        }
    }

    private void register(HttpServletRequest req, HttpServletResponse resp, String email, String password)
            throws ServletException, IOException {
        String name = trim(req.getParameter("name"));
        String course = trim(req.getParameter("course"));
        String year = trim(req.getParameter("year"));
        String confirmation = req.getParameter("confirmPassword");

        if (name.isBlank() || name.length() > 100 || course.isBlank() || course.length() > 120 || year.isBlank()) {
            fail(req, resp, "Enter your name, department, and year. Keep your name and department under 120 characters.");
            return;
        }
        if (password.length() < 12 || password.getBytes(StandardCharsets.UTF_8).length > 72) {
            fail(req, resp, "Choose a password with at least 12 characters and no more than 72 UTF-8 bytes.");
            return;
        }
        if (!password.equals(confirmation)) {
            fail(req, resp, "Passwords do not match.");
            return;
        }
        if (MySqlStore.collection("users").find(new Document("email", email)).first() != null) {
            fail(req, resp, "That email is already registered. Sign in or request another verification link.");
            return;
        }
        String remoteAddress = req.getRemoteAddr() == null ? "unknown" : req.getRemoteAddr();
        if (isRateLimited(REGISTRATION_ATTEMPTS, remoteAddress)) {
            resp.setHeader("Retry-After", Long.toString(Duration.ofMinutes(15).toSeconds()));
            fail(req, resp, "Too many account requests from this network. Wait 15 minutes and try again.");
            return;
        }
        recordAttempt(REGISTRATION_ATTEMPTS, remoteAddress);

        Document account = new Document("name", name)
                .append("email", email)
                .append("password", BCrypt.hashpw(password, BCrypt.gensalt(12)))
                .append("role", "STUDENT")
                .append("course", course)
                .append("year", year)
                .append("bio", "")
                .append("skills", "")
                .append("interests", "")
                .append("active", true)
                .append("emailVerified", false);
        MySqlStore.collection("users").insertOne(account);

        if (sendVerification(account, req.getContextPath())) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&verification=sent");
        } else {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&verification=setup");
        }
    }

    private void login(HttpServletRequest req, HttpServletResponse resp, String email, String password)
            throws ServletException, IOException {
        String attemptKey = req.getRemoteAddr() == null ? "unknown" : req.getRemoteAddr();
        if (isRateLimited(LOGIN_ATTEMPTS, attemptKey)) {
            resp.setHeader("Retry-After", Long.toString(LOGIN_WINDOW.toSeconds()));
            fail(req, resp, "Too many sign-in attempts. Wait 15 minutes before trying again.");
            return;
        }

        Document user = MySqlStore.collection("users").find(new Document("email", email)).first();
        if (user == null || !matchesPassword(password, user.getString("password"))) {
            recordAttempt(LOGIN_ATTEMPTS, attemptKey);
            fail(req, resp, "Invalid email or password.");
            return;
        }
        if (Boolean.FALSE.equals(user.getBoolean("emailVerified"))) {
            req.setAttribute("error", "Verify your email address before signing in. Check your inbox or request a new link.");
            req.setAttribute("resendEmail", email);
            req.setAttribute("showResend", true);
            req.getRequestDispatcher("/WEB-INF/views/auth.jsp").forward(req, resp);
            return;
        }

        LOGIN_ATTEMPTS.remove(attemptKey);
        user.remove("verificationTokenHash");
        user.remove("verificationExpiresAt");
        HttpSession previous = req.getSession(false);
        if (previous != null) previous.invalidate();
        req.getSession(true).setAttribute("user", user);
        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }

    private void verifyEmail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String rawToken = req.getParameter("token");
        if (rawToken == null || rawToken.length() > 128) {
            req.setAttribute("error", "This verification link is invalid or has expired. Request a new one.");
        } else {
            Document user = MySqlStore.collection("users")
                    .find(new Document("verificationTokenHash", hashToken(rawToken))).first();
            if (user == null || !isValidExpiry(user.getString("verificationExpiresAt"))) {
                req.setAttribute("error", "This verification link is invalid or has expired. Request a new one.");
                if (user != null) req.setAttribute("resendEmail", user.getString("email"));
                req.setAttribute("showResend", true);
            } else {
                MySqlStore.SqlUpdateResult result = MySqlStore.collection("users").updateOne(
                        new Document("_id", user.getObjectId("_id"))
                                .append("verificationTokenHash", hashToken(rawToken)),
                        new Document("$set", new Document("emailVerified", true)
                                .append("verificationTokenHash", "")
                                .append("verificationExpiresAt", "")));
                if (result.getMatchedCount() == 1) {
                    req.setAttribute("verificationSuccess", true);
                } else {
                    req.setAttribute("error", "This verification link is invalid or has expired. Request a new one.");
                }
            }
        }
        req.getRequestDispatcher("/WEB-INF/views/auth.jsp").forward(req, resp);
    }

    private void resendVerification(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = normalizeEmail(req.getParameter("email"));
        if (email == null) {
            req.setAttribute("error", "Enter a valid email address.");
            req.setAttribute("showResend", true);
            req.getRequestDispatcher("/WEB-INF/views/auth.jsp").forward(req, resp);
            return;
        }
        String remoteAddress = req.getRemoteAddr() == null ? "unknown" : req.getRemoteAddr();
        if (!allowOnce(VERIFICATION_EMAIL_ATTEMPTS, remoteAddress + ":" + hashToken(email),
                Duration.ofMinutes(1))) {
            req.setAttribute("error", "For security, wait a minute before requesting another verification email.");
            req.setAttribute("resendEmail", email);
            req.setAttribute("showResend", true);
            req.getRequestDispatcher("/WEB-INF/views/auth.jsp").forward(req, resp);
            return;
        }
        Document account = MySqlStore.collection("users").find(new Document("email", email)).first();
        if (account != null && Boolean.FALSE.equals(account.getBoolean("emailVerified"))) {
            if (sendVerification(account, req.getContextPath())) {
                resp.sendRedirect(req.getContextPath() + "/auth?action=login&verification=resent");
            } else {
                req.setAttribute("error", "Email could not be sent. Check the SMTP setup and try again later.");
                req.setAttribute("resendEmail", email);
                req.setAttribute("showResend", true);
                req.getRequestDispatcher("/WEB-INF/views/auth.jsp").forward(req, resp);
            }
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/auth?action=login&verification=resent");
    }

    private boolean sendVerification(Document account, String contextPath) {
        String rawToken = newVerificationToken();
        String tokenHash = hashToken(rawToken);
        String expiresAt = Instant.now().plus(VERIFICATION_LIFETIME).toString();
        MySqlStore.collection("users").updateOne(new Document("_id", account.getObjectId("_id")),
                new Document("$set", new Document("verificationTokenHash", tokenHash)
                        .append("verificationExpiresAt", expiresAt)));
        try {
            VerificationEmailService.send(account.getString("email"), account.getString("name"),
                    rawToken, contextPath);
            return true;
        } catch (MessagingException | IllegalStateException exception) {
            getServletContext().log("Campus Connect verification email could not be sent.", exception);
            return false;
        }
    }

    private boolean isValidExpiry(String expiresAt) {
        if (expiresAt == null || expiresAt.isBlank()) return false;
        try {
            return Instant.parse(expiresAt).isAfter(Instant.now());
        } catch (java.time.format.DateTimeParseException exception) {
            return false;
        }
    }

    private void fail(HttpServletRequest req, HttpServletResponse resp, String message)
            throws ServletException, IOException {
        req.setAttribute("error", message);
        String view = "register".equals(req.getParameter("action"))
                ? "/WEB-INF/views/register.jsp"
                : "/WEB-INF/views/auth.jsp";
        req.getRequestDispatcher(view).forward(req, resp);
    }

    private boolean isRateLimited(ConcurrentHashMap<String, LoginAttempts> limits, String key) {
        LoginAttempts attempts = limits.get(key);
        if (attempts == null) return false;
        if (attempts.startedAt.plus(LOGIN_WINDOW).isBefore(Instant.now())) {
            limits.remove(key, attempts);
            return false;
        }
        return attempts.count.get() >= MAX_LOGIN_ATTEMPTS;
    }

    private void recordAttempt(ConcurrentHashMap<String, LoginAttempts> limits, String key) {
        limits.compute(key, (ignored, attempts) -> {
            if (attempts == null || attempts.startedAt.plus(LOGIN_WINDOW).isBefore(Instant.now())) {
                return new LoginAttempts(Instant.now());
            }
            attempts.count.incrementAndGet();
            return attempts;
        });
        if (limits.size() > 10_000) {
            Instant now = Instant.now();
            limits.entrySet().removeIf(entry ->
                    entry.getValue().startedAt.plus(LOGIN_WINDOW.multipliedBy(2)).isBefore(now));
        }
    }

    private String newVerificationToken() {
        byte[] bytes = new byte[32];
        SECURE_RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String hashToken(String rawToken) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest(rawToken.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(digest);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is not available.", exception);
        }
    }

    private String normalizeEmail(String email) {
        if (email == null) return null;
        String normalized = email.trim().toLowerCase(Locale.ROOT);
        if (normalized.length() > 254) return null;
        try {
            jakarta.mail.internet.InternetAddress address =
                    new jakarta.mail.internet.InternetAddress(normalized, true);
            address.validate();
            return normalized;
        } catch (jakarta.mail.internet.AddressException exception) {
            return null;
        }
    }

    private boolean allowOnce(ConcurrentHashMap<String, Instant> limits, String key, Duration interval) {
        Instant now = Instant.now();
        Instant allowedAfter = limits.compute(key, (ignored, previous) ->
                previous == null || !previous.plus(interval).isAfter(now) ? now : previous);
        if (!allowedAfter.equals(now)) return false;
        if (limits.size() > 10_000) {
            limits.entrySet().removeIf(entry -> entry.getValue().plus(interval.multipliedBy(2)).isBefore(now));
        }
        return true;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean matchesPassword(String password, String storedHash) {
        if (storedHash == null || storedHash.isBlank() || password.getBytes(StandardCharsets.UTF_8).length > 72) {
            return false;
        }
        try {
            String compatibleHash = storedHash.startsWith("$2b$") || storedHash.startsWith("$2y$")
                    ? "$2a$" + storedHash.substring(4)
                    : storedHash;
            if (!compatibleHash.matches("^\\$2a\\$\\d{2}\\$[./A-Za-z0-9]{53}$")) return false;
            return BCrypt.checkpw(password, compatibleHash);
        } catch (IllegalArgumentException ex) {
            return false;
        }
    }

    private record LoginAttempts(Instant startedAt, AtomicInteger count) {
        private LoginAttempts(Instant startedAt) {
            this(startedAt, new AtomicInteger(1));
        }
    }
}
