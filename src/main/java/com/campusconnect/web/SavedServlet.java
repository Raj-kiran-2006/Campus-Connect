package com.campusconnect.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Map;

public class SavedServlet extends HttpServlet {
    private static final Map<String, SavedType> TYPES = Map.of(
            "notes", new SavedType("notes", "notes", "Study resource"),
            "questions", new SavedType("questions", "questions", "Question"),
            "projects", new SavedType("projects", "projects", "Project"),
            "marketplace", new SavedType("marketplace", "products", "Marketplace item"));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Document user = currentUser(request);
        ArrayList<Document> entries = new ArrayList<>();
        MySqlStore.collection("saved_items")
                .find(SqlFilters.eq("ownerId", user.getObjectId("_id")))
                .sort(new Document("savedAt", -1))
                .into(entries);

        ArrayList<Document> savedItems = new ArrayList<>();
        for (Document entry : entries) {
            SavedType type = TYPES.get(entry.getString("targetModule"));
            ObjectId targetId = entry.getObjectId("targetId");
            if (type == null || targetId == null) continue;

            Document item = MySqlStore.collection(type.collection())
                    .find(SqlFilters.eq("_id", targetId)).first();
            if (item == null) continue;
            String title = value(item, "title");
            if (title.isBlank()) title = value(item, "name");
            if (title.isBlank()) title = type.label();
            String description = value(item, "description");
            if (description.isBlank()) description = value(item, "subject");

            item.put("savedTitle", title);
            item.put("savedDescription", description);
            item.put("savedModule", type.module());
            item.put("savedLabel", type.label());
            item.put("savedAt", value(entry, "savedAt"));
            item.put("savedUrl", request.getContextPath() + "/" + type.module()
                    + "/detail?id=" + targetId.toHexString());
            item.put("savedRecordId", entry.get("_id"));
            savedItems.add(item);
        }

        request.setAttribute("savedItems", savedItems);
        request.getRequestDispatcher("/WEB-INF/views/saved.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Document user = currentUser(request);
        String module = value(request, "module");
        ObjectId targetId = objectId(value(request, "id"));
        SavedType type = TYPES.get(module);
        if (type == null || targetId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Choose a valid campus item to save.");
            return;
        }

        Document target = MySqlStore.collection(type.collection())
                .find(SqlFilters.eq("_id", targetId)).first();
        if (target == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "That campus item is no longer available.");
            return;
        }

        ObjectId ownerId = user.getObjectId("_id");
        Document match = SqlFilters.and(
                SqlFilters.eq("ownerId", ownerId),
                SqlFilters.eq("targetModule", type.module()),
                SqlFilters.eq("targetId", targetId));
        MySqlStore.SqlCollection saved = MySqlStore.collection("saved_items");
        String returnTo = "saved".equals(value(request, "returnTo")) ? "saved" : type.module();
        if (saved.countDocuments(match) > 0) {
            saved.deleteMany(match);
            response.sendRedirect(request.getContextPath() + "/" + returnTo + "?saved=removed");
            return;
        }

        saved.insertOne(new Document("ownerId", ownerId)
                .append("targetModule", type.module())
                .append("targetId", targetId)
                .append("savedAt", Instant.now().toString()));
        response.sendRedirect(request.getContextPath() + "/" + returnTo + "?saved=added");
    }

    private Document currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object user = session == null ? null : session.getAttribute("user");
        if (!(user instanceof Document document)) throw new IllegalStateException("Signed-in user is missing.");
        return document;
    }

    private String value(Document document, String field) {
        String value = document.getString(field);
        return value == null ? "" : value.trim();
    }

    private String value(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }

    private ObjectId objectId(String value) {
        try {
            return value.isBlank() ? null : new ObjectId(value);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    private record SavedType(String module, String collection, String label) {
    }
}
