package com.campusconnect.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class DashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("books", latest("products", 6));
        req.setAttribute("notes", latest("notes", 6));
        req.setAttribute("questions", latest("questions", 6));
        req.setAttribute("projects", latest("projects", 6));
        req.setAttribute("events", latest("campus_events", 4));
        req.setAttribute("listingCount", MySqlStore.collection("products").countDocuments());
        req.setAttribute("noteCount", MySqlStore.collection("notes").countDocuments());
        req.setAttribute("questionCount", MySqlStore.collection("questions").countDocuments(SqlFilters.eq("status", "OPEN")));
        req.setAttribute("projectCount", MySqlStore.collection("projects").countDocuments());
        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }

    private List<Document> latest(String collection, int limit) {
        List<Document> result = new ArrayList<>();
        MySqlStore.collection(collection).find().sort(new Document("createdAt", -1)).limit(limit).into(result);
        return result;
    }
}
