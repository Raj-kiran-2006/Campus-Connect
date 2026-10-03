package com.campusconnect.web;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import org.mindrot.jbcrypt.BCrypt;

public class AuthServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if ("logout".equals(req.getParameter("action"))) {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }
        String view = "register".equals(req.getParameter("action"))
                ? "/WEB-INF/views/register.jsp"
                : "/WEB-INF/views/auth.jsp";
        req.getRequestDispatcher(view).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        if (email == null || password == null || email.isBlank() || password.isBlank()) {
            req.setAttribute("error", "Email and password are required.");
            doGet(req, resp);
            return;
        }
        email = email.trim().toLowerCase(java.util.Locale.ROOT);
        if ("register".equals(action) && password.length() < 8) {
            req.setAttribute("error", "Password must contain at least 8 characters.");
            doGet(req, resp);
            return;
        }
        if ("register".equals(action)) {
            String name = req.getParameter("name");
            String course = req.getParameter("course");
            String year = req.getParameter("year");
            String confirmation = req.getParameter("confirmPassword");
            if (name == null || name.isBlank() || course == null || course.isBlank()
                    || year == null || year.isBlank()) {
                req.setAttribute("error", "Name, department, and year are required.");
                doGet(req, resp);
                return;
            }
            if (!password.equals(confirmation)) {
                req.setAttribute("error", "Passwords do not match.");
                doGet(req, resp);
                return;
            }
            if (MySqlStore.collection("users").find(new Document("email", email)).first() != null) {
                req.setAttribute("error", "That email is already registered.");
                doGet(req, resp);
                return;
            }
            MySqlStore.collection("users").insertOne(new Document("name", name.trim())
                    .append("email", email).append("password", BCrypt.hashpw(password, BCrypt.gensalt()))
                    .append("role", "STUDENT").append("course", req.getParameter("course"))
                    .append("year", year.trim()).append("bio", "")
                    .append("skills", "").append("interests", "").append("active", true));
        }
        Document user = MySqlStore.collection("users").find(new Document("email", email)).first();
        if (user == null || !matchesPassword(password, user.getString("password"))) {
            req.setAttribute("error", "Invalid email or password.");
            doGet(req, resp);
            return;
        }
        HttpSession previous = req.getSession(false);
        if (previous != null) previous.invalidate();
        req.getSession(true).setAttribute("user", user);
        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }

    private boolean matchesPassword(String password, String storedHash) {
        if (storedHash == null || storedHash.isBlank()) return false;
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
}
