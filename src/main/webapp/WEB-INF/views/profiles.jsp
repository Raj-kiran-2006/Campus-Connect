<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.campusconnect.web.Document,java.util.List" %>
<%!
private String esc(Object v) {
    return v == null ? "" : String.valueOf(v).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
}
private String text(Object v) {
    if (v instanceof java.util.List) {
        StringBuilder out = new StringBuilder();
        for (Object item : (java.util.List) v) {
            if (out.length() > 0) out.append(", ");
            out.append(String.valueOf(item));
        }
        return out.toString();
    }
    return v == null ? "" : String.valueOf(v);
}
%>
<%
List<Document> people = (List<Document>) request.getAttribute("people");
List<Document> messages = (List<Document>) request.getAttribute("messages");
Document selected = (Document) request.getAttribute("selected");
Document me = (Document) session.getAttribute("user");
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>People &amp; Messages · Campus Connect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/campus.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/premium-ui.css">
</head>
<body>
<% request.setAttribute("activeModule", "profiles"); %>
<%@ include file="_app-nav.jsp" %>
<div class="layout">
<main class="content people-page">
    <div class="page-head mb-4">
        <p class="eyebrow"><i class="bi bi-person-lines-fill me-1"></i> CAMPUS NETWORK</p>
        <h1 class="display-6 fw-bold">People &amp; Direct Messages</h1>
        <p class="text-secondary">Discover classmates, project partners, and mentors across departments, then connect instantly.</p>
    </div>

    <!-- ADVANCED DIRECTORY TOOLBAR WITH INSTANT FILTERS -->
    <div class="cc-workspace-toolbar-card mb-4">
        <form class="toolbar profile-search m-0" method="get">
            <div class="input-group">
                <span class="input-group-text bg-transparent border-end-0"><i class="bi bi-search text-secondary"></i></span>
                <input class="form-control border-start-0" id="peopleFilterInput" name="q" value="<%=esc(request.getAttribute("query"))%>" placeholder="Instant search by name, skill, interest, or bio…">
            </div>
            <input class="form-control cc-category-input" name="course" value="<%=esc(request.getAttribute("course"))%>" placeholder="Filter by department">
            <button class="btn btn-primary px-4" type="submit"><i class="bi bi-search me-1"></i> Search</button>
            <a class="clear-filter" href="${pageContext.request.contextPath}/profiles">Clear</a>
        </form>
    </div>

    <div class="people-messages-layout">
        <!-- DIRECTORY SECTION -->
        <section class="people-panel">
            <div class="section-head mb-3">
                <div>
                    <p class="eyebrow mb-1">STUDENT ROSTER</p>
                    <h2 class="h4 fw-bold mb-0">Find your circle</h2>
                </div>
                <span class="count-badge"><i class="bi bi-people-fill me-1"></i> <%= people.size() %> students</span>
            </div>

            <div class="profile-directory" id="peopleDirectoryGrid">
                <% for (Document p : people) {
                    String name = p.getString("name");
                    String initial = name == null ? "?" : name.substring(0, 1).toUpperCase();
                    String skills = text(p.get("skills"));
                    String github = text(p.get("githubUrl"));
                    boolean isSelected = selected != null && selected.getObjectId("_id").equals(p.getObjectId("_id"));
                %>
                    <article class="panel directory-card searchable-person <%= isSelected ? "active-person" : "" %>" data-person-text="<%= (name + " " + p.getString("course") + " " + skills + " " + p.getString("bio")).toLowerCase() %>">
                        <div class="directory-avatar"><%= esc(initial) %></div>
                        <div class="directory-card-body">
                            <div class="person-heading">
                                <h3><%= esc(name) %>
                                    <% if (p.getBoolean("verified", false)) { %>
                                        <span class="verified-badge"><i class="bi bi-patch-check-fill me-1"></i>Verified</span>
                                    <% } %>
                                </h3>
                                <span class="availability-dot <%= esc(p.getString("availability")) %>">
                                    <i class="bi bi-circle-fill me-1"></i><%= esc(p.getString("availability") == null ? "Available" : p.getString("availability")) %>
                                </span>
                            </div>
                            <p class="text-secondary small mb-1"><i class="bi bi-mortarboard me-1"></i><%= esc(p.getString("course")) %> &middot; Year <%= esc(p.getString("year")) %></p>
                            <p class="mb-2"><%= esc(p.getString("bio")) %></p>

                            <% if (!skills.isBlank()) { %>
                                <div class="tag-list mb-3">
                                    <% for (String skill : skills.split(",")) { %>
                                        <span><%= esc(skill.trim()) %></span>
                                    <% } %>
                                </div>
                            <% } %>

                            <div class="directory-actions">
                                <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/profiles?with=<%= p.getObjectId("_id") %>">
                                    <i class="bi bi-chat-dots-fill me-1"></i> Message
                                </a>
                                <% if (!github.isBlank()) { %>
                                    <a class="btn btn-sm btn-outline-dark" href="<%= esc(github) %>" target="_blank" rel="noopener">
                                        <i class="bi bi-github me-1"></i> GitHub <i class="bi bi-box-arrow-up-right ms-1"></i>
                                    </a>
                                <% } %>
                            </div>
                        </div>
                    </article>
                <% } %>

                <% if (people.isEmpty()) { %>
                    <div class="empty">
                        <i class="bi bi-search fs-2 text-secondary mb-2 d-block"></i>
                        <strong>No peers found.</strong>
                        <p class="text-secondary small mb-0">Try clearing filters or searching for other skills or departments.</p>
                    </div>
                <% } %>
            </div>
        </section>

        <!-- CHAT / THREAD PANEL -->
        <section class="panel thread-panel combined-thread">
            <% if ("true".equals(request.getParameter("sent"))) { %>
                <div class="alert alert-success alert-dismissible fade show"><i class="bi bi-check-circle-fill me-2"></i>Message sent securely.<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } else if ("message".equals(request.getParameter("error"))) { %>
                <div class="alert alert-danger alert-dismissible fade show"><i class="bi bi-exclamation-triangle-fill me-2"></i>Enter a valid message body and select a recipient.<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>

            <% if (selected == null) { %>
                <div class="thread-empty my-auto text-center py-5">
                    <div class="thread-empty-icon mb-3"><i class="bi bi-chat-quote-fill fs-1 text-primary"></i></div>
                    <h2 class="h5 fw-bold">Select a classmate to chat</h2>
                    <p class="text-secondary small">Pick any student from the directory to start a direct message thread.</p>
                </div>
            <% } else {
                String selectedName = selected.getString("name");
            %>
                <div class="thread-header d-flex align-items-center gap-3 pb-3 mb-3 border-bottom">
                    <div class="directory-avatar"><%= esc(selectedName == null ? "?" : selectedName.substring(0, 1).toUpperCase()) %></div>
                    <div class="thread-person">
                        <h2 class="h5 fw-bold mb-0"><%= esc(selectedName) %></h2>
                        <small class="text-secondary"><%= esc(selected.getString("course")) %></small>
                    </div>
                    <a class="thread-close ms-auto btn btn-sm btn-light rounded-circle" href="${pageContext.request.contextPath}/profiles" title="Close Thread">&times;</a>
                </div>

                <div class="message-list flex-grow-1 overflow-auto pe-2 mb-3">
                    <% if (messages != null && !messages.isEmpty()) {
                        for (Document m : messages) {
                            boolean mine = me != null && me.getObjectId("_id").equals(m.getObjectId("senderId"));
                    %>
                        <div class="message-bubble <%= mine ? "mine" : "" %> mb-2">
                            <p class="mb-1"><%= esc(m.getString("body")) %></p>
                            <small class="text-white-50"><%= esc(m.getString("createdAt")) %></small>
                        </div>
                    <%  }
                    } else { %>
                        <div class="empty text-center my-auto py-4">
                            <i class="bi bi-chat-left-dots fs-3 text-secondary mb-2 d-block"></i>
                            <strong>No previous messages.</strong>
                            <p class="text-secondary small mb-0">Say hello and introduce yourself to <%= esc(selectedName) %>!</p>
                        </div>
                    <% } %>
                </div>

                <form class="message-compose mt-auto" method="post" action="${pageContext.request.contextPath}/messages">
                    <input type="hidden" name="recipientId" value="<%= selected.getObjectId("_id") %>">
                    <div class="input-group">
                        <textarea name="body" class="form-control" rows="2" maxlength="2000" required placeholder="Type a thoughtful message to <%= esc(selectedName) %>…"></textarea>
                        <button class="btn btn-primary px-4" type="submit"><i class="bi bi-send-fill me-1"></i> Send</button>
                    </div>
                </form>
            <% } %>
        </section>
    </div>
</main>
</div>

<script>
(() => {
    // Instant client filter for student directory
    const input = document.getElementById('peopleFilterInput');
    const cards = document.querySelectorAll('.searchable-person');
    if (input) {
        input.addEventListener('input', e => {
            const query = e.target.value.trim().toLowerCase();
            cards.forEach(card => {
                const text = card.dataset.personText || card.textContent.toLowerCase();
                card.style.display = (!query || text.includes(query)) ? '' : 'none';
            });
        });
    }
})();
</script>
</body>
</html>
