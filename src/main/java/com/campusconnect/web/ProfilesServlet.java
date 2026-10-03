package com.campusconnect.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/** Directory and private, user-to-user message threads. */
public class ProfilesServlet extends HttpServlet {
    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Document me = current(req);
        String q = value(req, "q"), course = value(req, "course");
        var filter = q.isBlank() ? new Document() : SqlFilters.or(
                SqlFilters.regex("name", Pattern.quote(q), "i"),
                SqlFilters.regex("course", Pattern.quote(q), "i"),
                SqlFilters.regex("skills", Pattern.quote(q), "i"),
                SqlFilters.regex("bio", Pattern.quote(q), "i"));
        List<Document> people = new ArrayList<>();
        MySqlStore.collection("users").find(SqlFilters.and(SqlFilters.ne("_id", me.getObjectId("_id")), filter))
                .sort(new Document("name", 1)).into(people);
        if (!course.isBlank()) people.removeIf(u -> !course.equalsIgnoreCase(u.getString("course")));
        people.forEach(u -> u.remove("password"));
        req.setAttribute("people", people);
        req.setAttribute("profiles", people);
        req.setAttribute("query", q);
        req.setAttribute("course", course);
        ObjectId selected = id(value(req, "with"));
        if (selected != null) {
            Document other = MySqlStore.collection("users").find(SqlFilters.eq("_id", selected)).first();
            if (other != null) {
                other.remove("password");
                req.setAttribute("selected", other);
                List<Document> thread = new ArrayList<>();
                MySqlStore.collection("messages").find(SqlFilters.or(
                        SqlFilters.and(SqlFilters.eq("senderId", me.getObjectId("_id")), SqlFilters.eq("recipientId", selected)),
                        SqlFilters.and(SqlFilters.eq("senderId", selected), SqlFilters.eq("recipientId", me.getObjectId("_id")))))
                        .sort(new Document("createdAt", 1)).into(thread);
                req.setAttribute("messages", thread);
                MySqlStore.collection("messages").updateMany(
                        SqlFilters.and(SqlFilters.eq("senderId", selected), SqlFilters.eq("recipientId", me.getObjectId("_id"))),
                        new Document("$set", new Document("read", true)));
            }
        }
        req.getRequestDispatcher("/WEB-INF/views/profiles.jsp").forward(req, resp);
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Document me = current(req);
        ObjectId recipient = id(value(req, "recipientId"));
        String body = value(req, "body");
        if (recipient == null || body.isBlank() || body.length() > 2000
                || recipient.equals(me.getObjectId("_id"))
                || MySqlStore.collection("users").countDocuments(SqlFilters.eq("_id", recipient)) == 0) {
            resp.sendRedirect(req.getContextPath() + "/messages?error=message"); return;
        }
        MySqlStore.collection("messages").insertOne(new Document("senderId", me.getObjectId("_id"))
                .append("senderName", me.getString("name")).append("recipientId", recipient)
                .append("body", body).append("read", false).append("createdAt", Instant.now().toString()));
        MySqlStore.collection("notifications").insertOne(new Document("recipientId", recipient)
                .append("actorId", me.getObjectId("_id")).append("actorName", me.getString("name"))
                .append("type", "PRIVATE_MESSAGE").append("title", me.getString("name") + " sent you a message")
                .append("description", body.length() > 120 ? body.substring(0, 120) + "…" : body)
                .append("link", "/messages?with=" + recipient.toHexString()).append("read", false)
                .append("createdAt", Instant.now().toString()));
        resp.sendRedirect(req.getContextPath() + "/messages?with=" + recipient.toHexString() + "&sent=true");
    }

    private Document current(HttpServletRequest req) { return (Document) req.getSession(false).getAttribute("user"); }
    private String value(HttpServletRequest req, String name) { String v = req.getParameter(name); return v == null ? "" : v.trim(); }
    private ObjectId id(String value) { try { return value.isBlank() ? null : new ObjectId(value); } catch (IllegalArgumentException ex) { return null; } }
}
