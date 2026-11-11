package com.campusconnect.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

public class DiscoverServlet extends HttpServlet {
    private static final List<SearchArea> AREAS = List.of(
            new SearchArea("notes", "notes", "Study resource"),
            new SearchArea("questions", "questions", "Question"),
            new SearchArea("projects", "projects", "Project"),
            new SearchArea("marketplace", "products", "Marketplace item"));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String query = request.getParameter("q");
        query = query == null ? "" : query.trim();
        if (query.length() > 100) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Search terms must be 100 characters or fewer.");
            return;
        }

        List<Document> results = new ArrayList<>();
        if (!query.isBlank()) {
            Pattern pattern = Pattern.compile(Pattern.quote(query), Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
            for (SearchArea area : AREAS) {
                MySqlStore.collection(area.collection()).find(SqlFilters.or(
                                SqlFilters.regex("title", pattern),
                                SqlFilters.regex("name", pattern),
                                SqlFilters.regex("description", pattern),
                                SqlFilters.regex("tags", pattern),
                                SqlFilters.regex("subject", pattern)))
                        .sort(new Document("createdAt", -1))
                        .limit(8)
                        .into(new ArrayList<>())
                        .forEach(item -> results.add(searchResult(item, area, request.getContextPath())));
            }
            results.sort((left, right) -> value(right, "createdAt").compareTo(value(left, "createdAt")));
        }

        request.setAttribute("query", query);
        request.setAttribute("results", results);
        request.getRequestDispatcher("/WEB-INF/views/discover.jsp").forward(request, response);
    }

    private Document searchResult(Document item, SearchArea area, String contextPath) {
        Object rawId = item.get("_id");
        String id = rawId == null ? "" : rawId.toString();
        String route = "notes".equals(area.module()) ? "notes/detail"
                : "marketplace".equals(area.module()) ? "marketplace/detail" : area.module() + "/detail";
        String title = value(item, "title");
        if (title.isBlank()) title = value(item, "name");
        if (title.isBlank()) title = area.label();
        String description = value(item, "description");
        if (description.isBlank()) description = value(item, "subject");
        return new Document("kind", area.label())
                .append("title", title)
                .append("description", description)
                .append("createdAt", displayDate(value(item, "createdAt")))
                .append("targetId", id)
                .append("targetModule", area.module())
                .append("url", contextPath + "/" + route + "?id=" + id);
    }

    private String displayDate(String value) {
        return value.length() > 10 ? value.substring(0, 10) : value;
    }

    private String value(Document document, String field) {
        String value = document.getString(field);
        return value == null ? "" : value;
    }

    private record SearchArea(String module, String collection, String label) {
    }
}
