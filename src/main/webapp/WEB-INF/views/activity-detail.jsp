<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.campusconnect.web.Document,java.util.List" %>
<%! private String esc(Object value) { if (value == null) return ""; return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;"); } %>
<%
    Document item = (Document) request.getAttribute("item");
    String title = item.getString("title");
    if (title == null || title.isBlank()) title = item.getString("name");
    if (title == null || title.isBlank()) title = "Campus activity";
    String projectName = item.getString("projectName");
    if (projectName == null || projectName.isBlank()) projectName = title;
    String actorName = item.getString("actorName");
    if (actorName == null || actorName.isBlank()) actorName = "Campus student";
    String githubUrl = item.getString("githubUrl");
    List<Document> comments = (List<Document>) request.getAttribute("activityComments");
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
<% request.setAttribute("activeModule", "activity"); %>
<%@ include file="_app-nav.jsp" %>
<div class="layout">
    <main class="content detail-page">
        <a class="back-link" href="${pageContext.request.contextPath}/activity">← Back to activity</a>
        <section class="detail-card panel activity-detail-hero">
            <span class="badge text-bg-light"><%= esc(item.getString("category") == null ? "CAMPUS ACTIVITY" : item.getString("category")) %></span>
            <h1><%= esc(title) %></h1>
            <p class="detail-description">Community feedback and details shared by students across Campus Connect.</p>
        </section>
        <section class="activity-detail-grid">
            <section class="panel activity-detail-main">
                <p class="eyebrow"><%= "FEEDBACK".equals(item.getString("action")) ? "PROJECT FEEDBACK" : "ACTIVITY DETAILS" %></p>
                <h2><%= esc("FEEDBACK".equals(item.getString("action")) ? "Community opinion" : title) %></h2>
                <% if ("FEEDBACK".equals(item.getString("action"))) { %>
                    <div class="feedback-project-name">Completed project: <strong><%= esc(projectName) %></strong></div>
                <% } %>
                <div class="activity-opinion">
                    <p><%= esc(item.getString("description") == null ? "No additional description was provided." : item.getString("description")) %></p>
                </div>
                <% if (item.get("score") != null) { %>
                    <div class="activity-rating"><span>Project rating</span><strong><%= esc(item.get("score")) %>/5</strong></div>
                <% } %>
            </section>
            <aside class="panel activity-detail-side">
                <p class="eyebrow">POST DETAILS</p>
                <div class="activity-meta-list">
                    <div><span>Project</span><strong><%= esc(projectName) %></strong></div>
                    <div><span>Shared by</span><strong><%= esc(actorName) %></strong></div>
                    <div><span>Posted</span><strong><%= esc(item.getString("createdAt") == null ? "Recently" : item.getString("createdAt")) %></strong></div>
                </div>
                <% if (githubUrl != null && !githubUrl.isBlank()) { %>
                    <a class="btn btn-primary activity-github-button" target="_blank" rel="noopener" href="<%= esc(githubUrl) %>">View project on GitHub ↗</a>
                <% } else { %>
                    <div class="empty activity-no-link">No GitHub link was added.</div>
                <% } %>
            </aside>
        </section>
        <section class="panel answers-panel activity-comments-panel">
            <div class="section-head">
                <div>
                    <p class="eyebrow">DISCUSSION</p>
                    <h2>Comments</h2>
                </div>
            </div>
            <% if ("true".equals(request.getParameter("commented"))) { %>
                <div class="alert alert-success">Comment posted.</div>
            <% } else if ("comment".equals(request.getParameter("error"))) { %>
                <div class="alert alert-warning">Write a comment before posting.</div>
            <% } %>
            <div class="activity-comments">
                <% if (comments != null && !comments.isEmpty()) { for (Document comment : comments) { %>
                    <article class="answer-card">
                        <div class="d-flex justify-content-between gap-3">
                            <strong><%= esc(comment.getString("authorName")) %></strong>
                            <small><%= esc(comment.getString("createdAt")) %></small>
                        </div>
                        <p><%= esc(comment.getString("body")) %></p>
                    </article>
                <% } } else { %>
                    <div class="empty">No comments yet. Start the discussion.</div>
                <% } %>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/activity" class="answer-form">
                <input type="hidden" name="action" value="comment">
                <input type="hidden" name="id" value="<%= esc(item.get("_id")) %>">
                <textarea class="form-control" name="body" rows="3" maxlength="2000" required
                    placeholder="Share your feedback or ask a question"></textarea>
                <button class="btn btn-primary mt-3">Post comment</button>
            </form>
        </section>
    </main>
</div>
</body>
</html>
