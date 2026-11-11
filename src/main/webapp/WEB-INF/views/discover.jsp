<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.campusconnect.web.Document" %>
<%@ page import="java.util.List" %>
<%!
    private String discoverSafe(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String query = (String) request.getAttribute("query");
    List<Document> results = (List<Document>) request.getAttribute("results");
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Discover · Campus Connect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/campus.css" rel="stylesheet">
</head>
<body>
<% request.setAttribute("activeModule", "discover"); %><%@ include file="_app-nav.jsp" %>
<div class="layout"><main class="content cc-page">
    <section class="cc-discover-head mb-4">
        <p class="cc-kicker mb-2">CAMPUS CONNECT · DISCOVER</p>
        <h1 class="display-6 fw-bold mb-2">Find your next useful thing.</h1>
        <p class="text-secondary mb-0">Search study resources, questions, project spaces, and marketplace listings in one place.</p>
        <form class="row g-2 mt-4" method="get" action="${pageContext.request.contextPath}/discover" role="search">
            <div class="col"><label class="visually-hidden" for="discover-query">Search campus resources</label>
                <input id="discover-query" class="form-control form-control-lg" name="q" value="<%= discoverSafe(query) %>" maxlength="100" placeholder="Try “database systems” or “design team”" required></div>
            <div class="col-auto"><button class="btn btn-primary btn-lg px-4" type="submit">Search</button></div>
        </form>
    </section>
    <% if ("added".equals(request.getParameter("saved"))) { %><div class="alert alert-success">Saved to your collection. <a href="${pageContext.request.contextPath}/saved">View saved items</a>.</div><% } else if ("removed".equals(request.getParameter("saved"))) { %><div class="alert alert-info">Removed from your saved items.</div><% } %>
    <% if (query == null || query.isBlank()) { %>
        <section class="row g-3">
            <div class="col-md-6"><a class="cc-discover-category h-100" href="${pageContext.request.contextPath}/notes"><span class="cc-category-icon">01</span><span><strong>Study resources</strong><small>Notes shared by your campus</small></span><span class="ms-auto">→</span></a></div>
            <div class="col-md-6"><a class="cc-discover-category h-100" href="${pageContext.request.contextPath}/questions"><span class="cc-category-icon">02</span><span><strong>Questions &amp; answers</strong><small>Learn from peer explanations</small></span><span class="ms-auto">→</span></a></div>
            <div class="col-md-6"><a class="cc-discover-category h-100" href="${pageContext.request.contextPath}/projects"><span class="cc-category-icon">03</span><span><strong>Project teams</strong><small>Find collaborators and ideas</small></span><span class="ms-auto">→</span></a></div>
            <div class="col-md-6"><a class="cc-discover-category h-100" href="${pageContext.request.contextPath}/marketplace"><span class="cc-category-icon">04</span><span><strong>Campus marketplace</strong><small>Useful things, nearby</small></span><span class="ms-auto">→</span></a></div>
        </section>
    <% } else { %>
        <div class="d-flex flex-wrap justify-content-between align-items-end gap-2 mb-3">
            <div><p class="cc-kicker mb-1">SEARCH RESULTS</p><h2 class="h4 mb-0">Matches for “<%= discoverSafe(query) %>”</h2></div>
            <span class="badge rounded-pill text-bg-light px-3 py-2"><%= results.size() %> results · up to 8 per category</span>
        </div>
        <% if (results.isEmpty()) { %>
            <div class="cc-empty-state text-center"><div class="cc-empty-symbol">⌕</div><h3 class="h5">No matches just yet</h3><p class="text-secondary mb-0">Try a shorter phrase or search another topic.</p></div>
        <% } else { %>
            <div class="row g-3">
                <% for (Document item : results) { %>
                    <div class="col-md-6 col-xl-4"><article class="card cc-result-card h-100">
                        <div class="card-body d-flex flex-column">
                            <span class="badge cc-result-kind align-self-start mb-3"><%= discoverSafe(item.getString("kind")) %></span>
                            <h3 class="h5"><%= discoverSafe(item.getString("title")) %></h3>
                            <p class="text-secondary flex-grow-1"><%= discoverSafe(item.getString("description")) %></p>
                            <div class="d-flex justify-content-between align-items-center mt-2">
                                <small class="text-secondary"><%= discoverSafe(item.getString("createdAt")) %></small>
                                <a class="btn btn-sm btn-outline-primary" href="<%= discoverSafe(item.getString("url")) %>">Open result <span aria-hidden="true">→</span></a>
                            </div>
                            <form method="post" action="${pageContext.request.contextPath}/saved" class="cc-save-form mt-3">
                                <input type="hidden" name="module" value="<%= discoverSafe(item.getString("targetModule")) %>">
                                <input type="hidden" name="id" value="<%= discoverSafe(item.getString("targetId")) %>">
                                <input type="hidden" name="returnTo" value="discover">
                                <button class="btn btn-sm btn-outline-secondary" type="submit"><span aria-hidden="true">☆</span> Save for later</button>
                            </form>
                        </div>
                    </article></div>
                <% } %>
            </div>
        <% } %>
    <% } %>
</main></div>
<script>document.querySelectorAll('.sidebar a').forEach(link=>link.addEventListener('click',()=>document.querySelector('.sidebar').classList.remove('open')))</script>
</body>
</html>
