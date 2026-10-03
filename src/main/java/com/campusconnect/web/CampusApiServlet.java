package com.campusconnect.web;

import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

public class CampusApiServlet extends HttpServlet {
    private static final Set<String> READABLE = Set.of(
            "marketplace", "notes", "questions", "assignments", "projects", "notifications", "campus-events", "stats", "profile");
    private static final Set<String> WRITABLE = Set.of(
            "marketplace", "notes", "questions", "assignments", "projects");
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String resource = resource(request);
        if (!READABLE.contains(resource)) { response.sendError(404, "Unknown API resource"); return; }
        String collection = switch (resource) {
            case "marketplace" -> "products";
            case "profile" -> "users";
            case "stats" -> "users";
            case "campus-events" -> "campus_events";
            default -> resource;
        };
        List<Document> documents = new ArrayList<>();
        if ("profile".equals(resource)) {
            Document user = currentUser(request);
            if (user != null) documents.add(publicUser(user));
        } else if ("stats".equals(resource)) {
            Document stats = new Document("users", MySqlStore.collection("users").countDocuments())
                    .append("notes", MySqlStore.collection("notes").countDocuments())
                    .append("questions", MySqlStore.collection("questions").countDocuments())
                    .append("projects", MySqlStore.collection("projects").countDocuments());
            documents.add(stats);
        } else {
            MySqlStore.collection(collection).find().limit(100).into(documents);
        }
        json(response, documents);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String resource = resource(request);
        if (!WRITABLE.contains(resource)) { response.sendError(404, "Resource cannot be created"); return; }
        Document body = parseBody(request);
        Document user = currentUser(request);
        if (user == null) { response.sendError(401, "Sign in required"); return; }
        String collection = "marketplace".equals(resource) ? "products" : resource;
        body.remove("password"); body.remove("role"); body.remove("active"); body.remove("_id");
        body.put("ownerId", user.getObjectId("_id"));
        if ("marketplace".equals(resource)) body.put("sellerId", user.getObjectId("_id"));
        body.put("createdAt", Instant.now().toString());
        MySqlStore.collection(collection).insertOne(body);
        if ("notes".equals(resource)) {
            List<Document> users = new ArrayList<>();
            MySqlStore.collection("users").find().projection(new Document("_id", 1)).into(users);
            List<Document> notifications = new ArrayList<>();
            for (Document recipient : users) {
                notifications.add(new Document("recipientId", recipient.get("_id"))
                        .append("actorId", user.getObjectId("_id")).append("actorName", user.getString("name"))
                        .append("type", "NOTE_CREATED").append("title", user.getString("name") + " shared a new note: " + body.getString("title"))
                        .append("description", "A new note is available in the notes library.")
                        .append("link", "/notes/detail?id=" + body.getObjectId("_id"))
                        .append("read", false).append("createdAt", Instant.now().toString()));
            }
            if (!notifications.isEmpty()) MySqlStore.collection("notifications").insertMany(notifications);
        }
        json(response, List.of(body));
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!"profile".equals(resource(request))) { response.sendError(404); return; }
        Document user = currentUser(request);
        if (user == null) { response.sendError(401); return; }
        Document body = parseBody(request);
        body.remove("password"); body.remove("email"); body.remove("_id");
        MySqlStore.collection("users").updateOne(SqlFilters.eq("_id", user.getObjectId("_id")), new Document("$set", body));
        user.putAll(body);
        json(response, List.of(publicUser(user)));
    }

    private String resource(HttpServletRequest request) {
        String path = request.getPathInfo();
        return path == null || path.length() < 2 ? "" : path.substring(1).split("/")[0];
    }

    private Document currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (Document) session.getAttribute("user");
    }

    private Document publicUser(Document user) {
        Document copy = new Document(user);
        copy.remove("password");
        return copy;
    }

    private Document parseBody(HttpServletRequest request) throws IOException {
        String body = new String(request.getInputStream().readAllBytes(), java.nio.charset.StandardCharsets.UTF_8);
        if (body.isBlank()) return new Document();
        try {
            return Document.parse(body);
        } catch (IllegalArgumentException ex) {
            throw new IOException("Request body must be valid JSON", ex);
        }
    }

    private void json(HttpServletResponse response, List<Document> documents) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().print("[" + documents.stream()
                .map(Document::toJson)
                .collect(Collectors.joining(",")) + "]");
    }
}
