<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.campusconnect.web.Document" %>
<%! private String esc(Object value) { if (value == null) return ""; return String.valueOf(value).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); } %>
<%
    String module = (String) request.getAttribute("module");
    Document item = (Document) request.getAttribute("item");
    String title = item.getString("title");
    if (title == null || title.isBlank()) title = item.getString("name");
    if (title == null || title.isBlank()) title = "Campus contribution";
    String description = item.getString("description");
    if (description == null || description.isBlank()) description = "No additional description was provided.";
    String category = item.getString("category");
    if (category == null || category.isBlank()) category = "Campus contribution";
    String moduleLabel = module == null ? "workspace" : module.replace("-", " ");
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= esc(title) %> · Campus Connect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/campus.css" rel="stylesheet">
</head>
<body>
<% request.setAttribute("activeModule", module); %>
<%@ include file="_app-nav.jsp" %>
<div class="layout">
    <main class="content detail-page">
        <a class="back-link" href="${pageContext.request.contextPath}/<%= esc(module) %>">← Back to <%= esc(moduleLabel) %></a>
        <section class="detail-card panel">
            <span class="badge text-bg-light"><%= esc(category) %></span>
            <h1><%= esc(title) %></h1>
            <p class="detail-description"><%= esc(description) %></p>
            <div class="detail-facts">
                <% if (item.getString("status") != null) { %><span><b>Status</b><%= esc(item.getString("status")) %></span><% } %>
                <% if (item.getString("deadline") != null) { %><span><b>Deadline</b><%= esc(item.getString("deadline")) %></span><% } %>
                <% if (item.getString("subject") != null) { %><span><b>Subject</b><%= esc(item.getString("subject")) %></span><% } %>
                <% if (item.getString("format") != null) { %><span><b>Format</b><%= esc(item.getString("format")) %></span><% } %>
                <% if (item.getString("schedule") != null) { %><span><b>Schedule</b><%= esc(item.getString("schedule")) %></span><% } %>
                <% if (item.getString("createdAt") != null) { %><span><b>Published</b><%= esc(item.getString("createdAt")) %></span><% } %>
            </div>
        </section>
        <section class="detail-info-grid">
            <section class="panel detail-info-card">
                <p class="eyebrow">ABOUT THIS CONTRIBUTION</p>
                <h2>More information</h2>
                <% if (item.getString("skills") != null) { %><p><strong>Skills:</strong> <%= esc(item.getString("skills")) %></p><% } %>
                <% if (item.getString("tags") != null) { %><p><strong>Tags:</strong> <%= esc(item.getString("tags")) %></p><% } %>
                <% if (item.getString("milestone") != null) { %><p><strong>Next milestone:</strong> <%= esc(item.getString("milestone")) %></p><% } %>
                <% if (item.getString("resourceUrl") != null && !item.getString("resourceUrl").isBlank()) { %>
                    <a class="btn btn-primary mt-2" target="_blank" rel="noopener" href="<%= esc(item.getString("resourceUrl")) %>">Open shared resource ↗</a>
                <% } else if ("note-requests".equals(module)) { %>
                    <p class="text-secondary">This request is waiting for a classmate to share the requested notes.</p>
                <% } else { %>
                    <p class="text-secondary">Use the workspace to continue the discussion or contact the contributor.</p>
                <% } %>
            </section>
            <aside class="panel detail-info-card">
                <p class="eyebrow">NEXT STEP</p>
                <h2>Keep collaborating</h2>
                <p class="text-secondary">Return to the <%= esc(moduleLabel) %> workspace to search, respond, or add your own contribution.</p>
                <a class="btn btn-outline-primary w-100" href="${pageContext.request.contextPath}/<%= esc(module) %>">Return to <%= esc(moduleLabel) %></a>
            </aside>
        </section>
    </main>
</div>
</body>
</html>
