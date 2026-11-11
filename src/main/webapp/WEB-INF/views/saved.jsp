<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.campusconnect.web.Document" %>
<%@ page import="java.util.List" %>
<%!
    private String savedSafe(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    List<Document> savedItems = (List<Document>) request.getAttribute("savedItems");
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Saved items · Campus Connect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/campus.css" rel="stylesheet">
</head>
<body>
<% request.setAttribute("activeModule", "saved"); %><%@ include file="_app-nav.jsp" %>
<div class="layout"><main class="content cc-workspace">
    <section class="module-banner cc-saved-banner mb-4">
        <div><p class="eyebrow">YOUR PERSONAL COLLECTION</p><h1>Keep the good finds close.</h1><p class="text-secondary">Save useful notes, questions, project spaces, and marketplace finds for when you need them.</p></div>
        <div class="module-orb" aria-hidden="true">☆</div>
    </section>
    <div class="d-flex flex-wrap justify-content-between align-items-end gap-2 mb-3">
        <div><p class="cc-kicker mb-1">YOUR BOOKMARKS</p><h2 class="h3 mb-0">Saved for later</h2></div>
        <span class="badge rounded-pill text-bg-light px-3 py-2"><%= savedItems.size() %> saved</span>
    </div>
    <% if ("removed".equals(request.getParameter("saved"))) { %><div class="alert alert-success">Removed from your saved items.</div><% } %>
    <% if (savedItems.isEmpty()) { %>
        <section class="cc-saved-empty text-center">
            <span class="cc-empty-symbol">☆</span>
            <h3 class="h4 mt-3">Make your own campus shortlist.</h3>
            <p class="text-secondary">Save a resource, question, project, or listing and it will be waiting here.</p>
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/discover">Discover something useful</a>
        </section>
    <% } else { %>
        <div class="row g-3">
            <% for (Document item : savedItems) { %>
                <div class="col-md-6 col-xl-4">
                    <article class="card cc-result-card cc-saved-card h-100">
                        <div class="card-body d-flex flex-column">
                            <span class="badge cc-result-kind align-self-start mb-3"><%= savedSafe(item.getString("savedLabel")) %></span>
                            <h3 class="h5"><%= savedSafe(item.getString("savedTitle")) %></h3>
                            <p class="text-secondary flex-grow-1"><%= savedSafe(item.getString("savedDescription")) %></p>
                            <small class="text-secondary mb-3">Saved <%= savedSafe(item.getString("savedAt")) %></small>
                            <div class="d-flex gap-2">
                                <a class="btn btn-primary flex-grow-1" href="<%= savedSafe(item.getString("savedUrl")) %>">Open item <span aria-hidden="true">→</span></a>
                                <form method="post" action="${pageContext.request.contextPath}/saved">
                                    <input type="hidden" name="module" value="<%= savedSafe(item.getString("savedModule")) %>">
                                    <input type="hidden" name="id" value="<%= savedSafe(item.getObjectId("_id")) %>">
                                    <input type="hidden" name="returnTo" value="saved">
                                    <button class="btn btn-outline-secondary" type="submit" aria-label="Remove from saved items">Remove</button>
                                </form>
                            </div>
                        </div>
                    </article>
                </div>
            <% } %>
        </div>
    <% } %>
</main></div>
</body>
</html>
