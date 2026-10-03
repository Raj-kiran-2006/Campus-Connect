package com.campusconnect.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import org.mindrot.jbcrypt.BCrypt;

public class ProfileServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Document user = (Document) request.getSession(false).getAttribute("user");
        if ("password".equals(request.getParameter("action"))) {
            String current = value(request, "currentPassword");
            String next = value(request, "newPassword");
            String confirm = value(request, "confirmPassword");
            if (!matches(current, user.getString("password")) || next.length() < 8 || !next.equals(confirm)) {
                response.sendRedirect(request.getContextPath() + "/profile?error=password");
                return;
            }
            String hash = BCrypt.hashpw(next, BCrypt.gensalt());
            MySqlStore.collection("users").updateOne(SqlFilters.eq("_id", user.getObjectId("_id")),
                    new Document("$set", new Document("password", hash)));
            user.put("password", hash);
            response.sendRedirect(request.getContextPath() + "/profile?saved=password");
            return;
        }
        Document update = new Document("name", value(request, "name"))
                .append("course", value(request, "course"))
                .append("year", value(request, "year"))
                .append("bio", value(request, "bio"))
                .append("skills", csv(request, "skills", 12))
                .append("interests", csv(request, "interests", 12))
                .append("availability", value(request, "availability"))
                .append("availableForPeerSupport", "on".equals(request.getParameter("availableForPeerSupport")));
        String github = value(request, "githubUrl");
        if (!github.isBlank() && !github.matches("https://github\\.com/[A-Za-z0-9_.-]+/?")) {
            response.sendRedirect(request.getContextPath() + "/profile?error=github");
            return;
        }
        update.append("githubUrl", github);
        String avatar = value(request, "avatar");
        if (!avatar.isBlank()) {
            if (!avatar.matches("^data:image/(png|jpeg|webp);base64,[A-Za-z0-9+/=\\r\\n]+$")
                    || avatar.length() > 3_000_000) {
                response.sendRedirect(request.getContextPath() + "/profile?error=image");
                return;
            }

            update.append("avatar", avatar);
        }

        MySqlStore.collection("users").updateOne(
                SqlFilters.eq("_id", user.getObjectId("_id")), new Document("$set", update));
        user.putAll(update);
        response.sendRedirect(request.getContextPath() + "/profile?saved=true");
    }

    private String value(HttpServletRequest request, String name) {
        return request.getParameter(name) == null ? "" : request.getParameter(name).trim();
    }

    private java.util.List<String> csv(HttpServletRequest request, String name, int limit) {
        return java.util.Arrays.stream(value(request, name).split(","))
                .map(String::trim)
                .filter(item -> !item.isBlank())
                .map(item -> item.length() > 40 ? item.substring(0, 40) : item)
                .distinct()
                .limit(limit)
                .toList();
    }

    private boolean matches(String password, String hash) {
        try {
            if (hash == null) return false;
            if (hash.startsWith("$2b$") || hash.startsWith("$2y$")) hash = "$2a$" + hash.substring(4);
            return BCrypt.checkpw(password, hash);
        } catch (IllegalArgumentException ex) {
            return false;
        }
    }
}
