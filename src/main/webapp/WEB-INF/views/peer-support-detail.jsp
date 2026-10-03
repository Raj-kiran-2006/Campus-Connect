<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.campusconnect.web.Document,java.util.List" %>
<%! private String esc(Object value) { if (value == null) return ""; return String.valueOf(value).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); } %>
<%
    Document item = (Document) request.getAttribute("item");
    List<Document> messages = (List<Document>) request.getAttribute("supportMessages");
    boolean owner = Boolean.TRUE.equals(request.getAttribute("assignmentOwner"));
    String title = item.getString("title");
    if (title == null || title.isBlank()) title = "Peer-support request";
    String description = item.getString("description");
    if (description == null || description.isBlank()) description = "The student has not added a detailed description yet.";
    String category = item.getString("category");
    if (category == null || category.isBlank()) category = "General help";
    String status = item.getString("status");
    if (status == null || status.isBlank()) status = "OPEN";
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
<% request.setAttribute("activeModule", "assignments"); %>
<%@ include file="_app-nav.jsp" %>
<div class="layout">
    <main class="content detail-page">
        <a class="back-link" href="${pageContext.request.contextPath}/assignments">← Back to peer support</a>
        <section class="detail-card panel">
            <span class="badge text-bg-light"><%= esc(category) %></span>
            <h1><%= esc(title) %></h1>
            <p class="detail-description"><%= esc(description) %></p>
            <div class="detail-facts">
                <span><b>Status</b><%= esc(status) %></span>
                <span><b>Deadline</b><%= esc(item.getString("deadline") == null ? "Flexible" : item.getString("deadline")) %></span>
                <span><b>Support model</b>Free peer exchange</span>
                <span><b>Published</b><%= esc(item.getString("createdAt") == null ? "Recently" : item.getString("createdAt")) %></span>
            </div>
        </section>
        <section class="peer-detail-layout">
            <section class="panel peer-support-panel">
                <div class="section-head">
                    <div>
                        <p class="eyebrow">PEER SUPPORT</p>
                        <h2>Support conversation</h2>
                        <p class="text-secondary mb-0">Ask questions, share explanations, and coordinate study time.</p>
                    </div>
                    <span class="badge text-bg-light"><%= esc(status) %></span>
                </div>
                <% if ("true".equals(request.getParameter("message"))) { %>
                    <div class="alert alert-success">Message sent.</div>
                <% } else if ("message".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-warning">Write a message before sending.</div>
                <% } %>
                <div class="support-thread">
                    <% if (messages != null && !messages.isEmpty()) { for (Document message : messages) { %>
                        <article class="answer-card">
                            <div class="d-flex justify-content-between gap-3">
                                <strong><%= esc(message.getString("senderName")) %></strong>
                                <small><%= esc(message.getString("createdAt")) %></small>
                            </div>
                            <p><%= esc(message.getString("body")) %></p>
                        </article>
                    <% } } else { %>
                        <div class="empty">No messages yet. Start the peer-support conversation.</div>
                    <% } %>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/assignments" class="support-composer">
                    <input type="hidden" name="action" value="message">
                    <input type="hidden" name="id" value="<%= esc(item.get("_id")) %>">
                    <textarea class="form-control" name="body" rows="3" maxlength="2000" required placeholder="Share an explanation, study tip, or question"></textarea>
                    <button class="btn btn-primary">Send message</button>
                </form>
            </section>
            <aside class="panel peer-detail-side">
                <p class="eyebrow">HOW IT WORKS</p>
                <h3>Learn together</h3>
                <ul class="peer-guidelines">
                    <li>Keep help focused on learning and feedback.</li>
                    <li>Coordinate a time in the conversation.</li>
                    <li>No fees, bids, or completed graded work.</li>
                </ul>
                <% if (owner) { %>
                    <form method="post" action="${pageContext.request.contextPath}/assignments" class="status-form">
                        <input type="hidden" name="action" value="status">
                        <input type="hidden" name="id" value="<%= esc(item.get("_id")) %>">
                        <label>Update status
                            <select class="form-select" name="status">
                                <% for (String option : new String[]{"OPEN","IN_PROGRESS","COMPLETED","CANCELLED"}) { %>
                                    <option value="<%= option %>" <%= option.equals(status) ? "selected" : "" %>><%= option %></option>
                                <% } %>
                            </select>
                        </label>
                        <button class="btn btn-outline-primary mt-2 w-100">Save status</button>
                    </form>
                <% } %>
            </aside>
        </section>
    </main>
</div>
</body>
</html>
