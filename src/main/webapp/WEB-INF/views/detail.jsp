<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="com.campusconnect.web.Document,java.util.List" %>
        <%! private String esc(Object value) { if (value==null) return ""; return String.valueOf(value).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); } %>
            <% String module=(String)request.getAttribute("module"); Document
                item=(Document)request.getAttribute("item"); List<Document> answers=(List<Document>
                    )request.getAttribute("answers"); List<Document> projectComments=(List<Document>
                            )request.getAttribute("projectComments"); List<Document> projectMembers=(List<Document>
                                    )request.getAttribute("projectMembers"); Document
                                    projectMembership=(Document)request.getAttribute("projectMembership"); boolean
                                    projectOwner=Boolean.TRUE.equals(request.getAttribute("projectOwner")); String
                                    title=item.getString("title"); if(title==null||title.isBlank())
                                    title=item.getString("name"); if(title==null) title="Campus contribution"; %>
                                    <!doctype html>
                                    <html lang="en">

                                    <head>
                                        <meta charset="UTF-8">
                                        <meta name="viewport" content="width=device-width,initial-scale=1">
                                        <title>
                                            <%= esc(title) %> · Campus Connect
                                        </title>
                                        <link
                                            href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                                            rel="stylesheet">
                                        <link href="${pageContext.request.contextPath}/assets/campus.css"
                                            rel="stylesheet">
                                    </head>

                                    <body>
                                        <% request.setAttribute("activeModule", module); %>
                                            <%@ include file="_app-nav.jsp" %>
                                                <div class="layout">
                                                    <main class="content detail-page"><a class="back-link"
                                                            href="${pageContext.request.contextPath}/<%= module %>">←
                                                            Back to <%= esc(module) %></a>
                                                        <section class="detail-card panel"><span
                                                                class="badge text-bg-light">
                                                                <%= esc(item.getString("category")) %>
                                                            </span>
                                                            <h1>
                                                                <%= esc(title) %>
                                                            </h1>
                                                            <p class="detail-description">
                                                                <%= esc(item.getString("description")) %>
                                                            </p>
                                                            <% if ("projects".equals(module) &&
                                                                item.getString("githubUrl") !=null &&
                                                                !item.getString("githubUrl").isBlank()) { %>
                                                                <p class="project-repo"><a class="btn btn-outline-dark"
                                                                        target="_blank" rel="noopener"
                                                                        href="<%= esc(item.getString("githubUrl"))
                                                                        %>">View GitHub repository ↗</a></p>
                                                                <% } %>
                                                                    <% if
                                                                        (Boolean.TRUE.equals(item.getBoolean("ownerVerified")))
                                                                        { %><span class="verified-badge">? Verified
                                                                            contributor</span>
                                                                        <% } %>
                                                                            <% if (item.getString("ownerAvailability")
                                                                                !=null &&
                                                                                !item.getString("ownerAvailability").isBlank())
                                                                                { %><span
                                                                                    class="availability-label">Available:
                                                                                    <%= esc(item.getString("ownerAvailability"))
                                                                                        %></span>
                                                                                <% } %>
                                                                                    <div class="detail-facts">
                                                                                        <% if(item.getString("deadline")!=null){
                                                                                            %><span><b>Deadline</b>
                                                                                                <%= esc(item.getString("deadline"))
                                                                                                    %>
                                                                                            </span>
                                                                                            <% } %>
                                                                                                <% if("assignments".equals(module)){
                                                                                                    %><span><b>Support
                                                                                                            model</b>Free
                                                                                                        peer
                                                                                                        exchange</span>
                                                                                                    <% } else
                                                                                                        if(item.get("budget")!=null){
                                                                                                        %><span><b>Budget</b>₹
                                                                                                            <%= esc(item.get("budget"))
                                                                                                                %>
                                                                                                                </span>
                                                                                                        <% } %><span><b>Published</b>
                                                                                                                <%= esc(item.getString("createdAt"))
                                                                                                                    %>
                                                                                                            </span>
                                                                                    </div>
                                                        </section>
                                                        <% if ("questions".equals(module)) { %>
                                                            <section class="panel answers-panel">
                                                                <div class="section-head">
                                                                    <div>
                                                                        <p class="eyebrow">DISCUSSION</p>
                                                                        <h2>Answers</h2>
                                                                    </div>
                                                                </div>
                                                                <% if("true".equals(request.getParameter("answered"))){
                                                                    %>
                                                                    <div class="alert alert-success">Answer published.
                                                                    </div>
                                                                    <% } %>
                                                                        <% if(answers!=null&&!answers.isEmpty()){
                                                                            for(Document answer:answers){ %>
                                                                            <article class="answer-card">
                                                                                <p>
                                                                                    <%= esc(answer.getString("body")) %>
                                                                                </p><small>
                                                                                    <%= esc(answer.getString("authorName"))
                                                                                        %> · <%=
                                                                                            esc(answer.getString("createdAt"))
                                                                                            %>
                                                                                </small>
                                                                            </article>
                                                                            <% }} else { %>
                                                                                <div class="empty">No answers yet. Be
                                                                                    the first helpful classmate.</div>
                                                                                <% } %>
                                                                                    <form class="answer-form"
                                                                                        method="post"
                                                                                        action="${pageContext.request.contextPath}/questions">
                                                                                        <input type="hidden"
                                                                                            name="action"
                                                                                            value="answer"><input
                                                                                            type="hidden" name="id"
                                                                                            value="<%= esc(item.get("_id")) %>"><textarea
                                                                                            class="form-control"
                                                                                            name="answer"
                                                                                            maxlength="5000" rows="4"
                                                                                            required
                                                                                            placeholder="Share an explanation or useful reference"></textarea><button
                                                                                            class="btn btn-primary mt-3">Post
                                                                                            answer</button></form>
                                                            </section>
                                                            <% } else if ("projects".equals(module)) { %>
                                                                <section class="project-collab-grid">
                                                                    <section class="panel">
                                                                        <p class="eyebrow">PROJECT DETAILS</p>
                                                                        <div class="detail-facts">
                                                                            <% if(item.getString("skills")!=null&&!item.getString("skills").isBlank())
                                                                                { %><span><b>Skills</b>
                                                                                    <%= esc(item.getString("skills")) %>
                                                                                </span>
                                                                                <% } %>
                                                                                    <% if(item.getString("milestone")!=null&&!item.getString("milestone").isBlank())
                                                                                        { %><span><b>Next milestone</b>
                                                                                            <%= esc(item.getString("milestone"))
                                                                                                %>
                                                                                        </span>
                                                                                        <% } %><span><b>Collaboration</b>
                                                                                                <%= esc(item.getString("collaborationType")==null?"TEAM_PROJECT":item.getString("collaborationType"))
                                                                                                    %>
                                                                                            </span><span><b>Members</b>
                                                                                                <%= esc(item.get("memberCount")==null?"1":item.get("memberCount"))
                                                                                                    %>
                                                                                            </span>
                                                                        </div>
                                                                        <div class="project-progress"
                                                                            aria-label="Project progress">
                                                                            <div class="project-progress-head">
                                                                                <b>Project progress</b><span>
                                                                                    <%= esc(item.getString("status")==null
                                                                                        ? "RECRUITING" :
                                                                                        item.getString("status")) %>
                                                                                </span></div>
                                                                            <div class="progress">
                                                                                <div class="progress-bar"
                                                                                    style="width:<%= item.get("progress", 35) %>%"></div>
                                                                            </div><small>Based on the current project
                                                                                status and milestone.</small>
                                                                        </div>
                                                                        <% if("true".equals(request.getParameter("applied")))
                                                                            { %>
                                                                            <div class="alert alert-success">Application
                                                                                sent. The project owner can review your
                                                                                request.</div>
                                                                            <% } else
                                                                                if("true".equals(request.getParameter("approved")))
                                                                                { %>
                                                                                <div class="alert alert-success">
                                                                                    Application approved. This
                                                                                    collaborator is now active.</div>
                                                                                <% } else
                                                                                    if("true".equals(request.getParameter("rejected")))
                                                                                    { %>
                                                                                    <div class="alert alert-info">
                                                                                        Application rejected.</div>
                                                                                    <% } else
                                                                                        if("applied".equals(request.getParameter("error")))
                                                                                        { %>
                                                                                        <div class="alert alert-info">
                                                                                            You already applied to this
                                                                                            project.</div>
                                                                                        <% } else
                                                                                            if("owner".equals(request.getParameter("error")))
                                                                                            { %>
                                                                                            <div
                                                                                                class="alert alert-warning">
                                                                                                You own this project.
                                                                                            </div>
                                                                                            <% } %>
                                                                                                <% if(projectMembership==null)
                                                                                                    { %>
                                                                                                    <form method="post"
                                                                                                        action="${pageContext.request.contextPath}/projects">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="action"
                                                                                                            value="apply"><input
                                                                                                            type="hidden"
                                                                                                            name="id"
                                                                                                            value="<%= esc(item.get("_id")) %>"><button
                                                                                                            class="btn btn-primary">Apply
                                                                                                            to
                                                                                                            join</button>
                                                                                                    </form>
                                                                                                    <% } else { %><span
                                                                                                            class="badge text-bg-light">Membership:
                                                                                                            <%= esc(projectMembership.getString("status"))
                                                                                                                %>
                                                                                                                </span>
                                                                                                        <% } %>
                                                                    </section>
                                                                    <section class="panel">
                                                                        <p class="eyebrow">PROJECT MEMBERS</p>
                                                                        <% if(projectMembers!=null&&!projectMembers.isEmpty()){
                                                                            for(Document member:projectMembers){ String
                                                                            memberStatus=member.getString("status"); %>
                                                                            <div class="member-row"><strong>
                                                                                    <%= esc(member.getString("userName"))
                                                                                        %>
                                                                                </strong><span>
                                                                                    <%= "ACTIVE" .equals(memberStatus)
                                                                                        ? "Active collaborator" :
                                                                                        esc(memberStatus) %>
                                                                                </span>
                                                                                <% if(projectOwner && "PENDING"
                                                                                    .equals(memberStatus)) { %><span
                                                                                        class="member-actions">
                                                                                        <form method="post"
                                                                                            action="${pageContext.request.contextPath}/projects">
                                                                                            <input type="hidden"
                                                                                                name="action"
                                                                                                value="approve"><input
                                                                                                type="hidden" name="id"
                                                                                                value="<%= esc(item.get("_id")) %>"><input
                                                                                                type="hidden"
                                                                                                name="memberId"
                                                                                                value="<%= esc(member.get("_id")) %>"><button
                                                                                                class="btn btn-sm btn-primary">Approve</button>
                                                                                        </form>
                                                                                        <form method="post"
                                                                                            action="${pageContext.request.contextPath}/projects">
                                                                                            <input type="hidden"
                                                                                                name="action"
                                                                                                value="reject"><input
                                                                                                type="hidden" name="id"
                                                                                                value="<%= esc(item.get("_id")) %>"><input
                                                                                                type="hidden"
                                                                                                name="memberId"
                                                                                                value="<%= esc(member.get("_id")) %>"><button
                                                                                                class="btn btn-sm btn-outline-danger">Reject</button>
                                                                                        </form>
                                                                                    </span>
                                                                                    <% } %>
                                                                            </div>
                                                                            <% }} else { %>
                                                                                <p class="text-secondary">No
                                                                                    applications yet.</p>
                                                                                <% } %>
                                                                    </section>
                                                                </section>
                                                                <section class="panel answers-panel">
                                                                    <div class="section-head">
                                                                        <div>
                                                                            <p class="eyebrow">COLLABORATION</p>
                                                                            <h2>Discussion & mentor help</h2>
                                                                        </div>
                                                                    </div>
                                                                    <% if("true".equals(request.getParameter("commented"))){
                                                                        %>
                                                                        <div class="alert alert-success">Comment posted.
                                                                        </div>
                                                                        <% } else
                                                                            if("true".equals(request.getParameter("requested"))){
                                                                            %>
                                                                            <div class="alert alert-success">Mentor
                                                                                request posted.</div>
                                                                            <% } %>
                                                                                <% if(projectComments!=null&&!projectComments.isEmpty()){
                                                                                    for(Document
                                                                                    comment:projectComments){ %>
                                                                                    <article class="answer-card"><span
                                                                                            class="badge text-bg-light">
                                                                                            <%= esc("MENTOR_REQUEST".equals(comment.getString("type")) ? "MENTOR HELP" : "DISCUSSION") %>
                                                                                        </span>
                                                                                        <p>
                                                                                            <%= esc(comment.getString("body"))
                                                                                                %>
                                                                                        </p><small>
                                                                                            <%= esc(comment.getString("authorName"))
                                                                                                %> · <%=
                                                                                                    esc(comment.getString("createdAt"))
                                                                                                    %>
                                                                                        </small>
                                                                                    </article>
                                                                                    <% }} else { %>
                                                                                        <div class="empty">Start the
                                                                                            project conversation or ask
                                                                                            an experienced student for
                                                                                            guidance.</div>
                                                                                        <% } %>
                                                                                            <form class="answer-form"
                                                                                                method="post"
                                                                                                action="${pageContext.request.contextPath}/projects">
                                                                                                <input type="hidden"
                                                                                                    name="id"
                                                                                                    value="<%= esc(item.get("_id")) %>"><textarea
                                                                                                    class="form-control"
                                                                                                    name="body"
                                                                                                    maxlength="5000"
                                                                                                    rows="3" required
                                                                                                    placeholder="Share an update or question"></textarea>
                                                                                                <div
                                                                                                    class="d-flex gap-2 mt-3">
                                                                                                    <button
                                                                                                        class="btn btn-primary"
                                                                                                        name="action"
                                                                                                        value="comment">Post
                                                                                                        discussion</button><button
                                                                                                        class="btn btn-outline-primary"
                                                                                                        name="action"
                                                                                                        value="mentor">Ask
                                                                                                        for mentor
                                                                                                        guidance</button>
                                                                                                </div>
                                                                                            </form>
                                                                </section>
                                                                <% } else if ("assignments".equals(module)) { boolean
                                                                    assignmentOwner=Boolean.TRUE.equals(request.getAttribute("assignmentOwner"));
                                                                    List<Document> supportMessages=(List<Document>
                                                                        )request.getAttribute("supportMessages"); %>
                                                                        <section class="peer-request-summary panel">
                                                                            <div>
                                                                                <p class="eyebrow">REQUEST DETAILS</p>
                                                                                <h2>What this student needs</h2>
                                                                                <p>
                                                                                    <%= esc(item.getString("description"))
                                                                                        %>
                                                                                </p>
                                                                            </div>
                                                                            <div class="peer-summary-facts">
                                                                                <span><b>Subject</b>
                                                                                    <%= esc(item.getString("category"))
                                                                                        %>
                                                                                </span><span><b>Deadline</b>
                                                                                    <%= esc(item.getString("deadline"))
                                                                                        %>
                                                                                </span><span><b>Posted by</b>
                                                                                    <%= esc(item.getString("ownerName")==null
                                                                                        ? "Campus student" :
                                                                                        item.getString("ownerName")) %>
                                                                                </span><span><b>Availability</b>
                                                                                    <%= esc(item.getString("ownerAvailability")==null
                                                                                        ? "Ask in chat" :
                                                                                        item.getString("ownerAvailability"))
                                                                                        %>
                                                                                </span></div>
                                                                        </section>
                                                                        <section class="peer-detail-layout">
                                                                            <section class="panel peer-support-panel">
                                                                                <div class="section-head">
                                                                                    <div>
                                                                                        <p class="eyebrow">PEER SUPPORT
                                                                                        </p>
                                                                                        <h2>Support conversation</h2>
                                                                                        <p class="text-secondary mb-0">
                                                                                            Ask a question or offer
                                                                                            guidance without payments or
                                                                                            bidding.</p>
                                                                                    </div><span
                                                                                        class="badge text-bg-light">
                                                                                        <%= esc(item.getString("status"))
                                                                                            %>
                                                                                    </span>
                                                                                </div>
                                                                                <% if
                                                                                    ("true".equals(request.getParameter("message")))
                                                                                    { %>
                                                                                    <div class="alert alert-success">
                                                                                        Message sent.</div>
                                                                                    <% } %>
                                                                                        <div class="support-thread">
                                                                                            <% if (supportMessages
                                                                                                !=null &&
                                                                                                !supportMessages.isEmpty())
                                                                                                { for (Document message
                                                                                                : supportMessages) { %>
                                                                                                <article
                                                                                                    class="answer-card">
                                                                                                    <div
                                                                                                        class="d-flex justify-content-between gap-3">
                                                                                                        <strong>
                                                                                                            <%= esc(message.getString("senderName"))
                                                                                                                %>
                                                                                                        </strong><small>
                                                                                                            <%= esc(message.getString("createdAt"))
                                                                                                                %>
                                                                                                        </small></div>
                                                                                                    <p>
                                                                                                        <%= esc(message.getString("body"))
                                                                                                            %>
                                                                                                    </p>
                                                                                                </article>
                                                                                                <% } } else { %>
                                                                                                    <div class="empty">
                                                                                                        No messages yet.
                                                                                                        Start the
                                                                                                        peer-support
                                                                                                        conversation.
                                                                                                    </div>
                                                                                                    <% } %>
                                                                                        </div>
                                                                                        <form method="post"
                                                                                            action="${pageContext.request.contextPath}/assignments"
                                                                                            class="support-composer">
                                                                                            <input type="hidden"
                                                                                                name="action"
                                                                                                value="message"><input
                                                                                                type="hidden" name="id"
                                                                                                value="<%= esc(item.get("_id")) %>"><textarea
                                                                                                class="form-control"
                                                                                                name="body" rows="3"
                                                                                                maxlength="2000"
                                                                                                required
                                                                                                placeholder="Share an explanation, study tip, or question"></textarea><button
                                                                                                class="btn btn-primary">Send
                                                                                                message</button></form>
                                                                            </section>
                                                                            <aside class="panel peer-detail-side">
                                                                                <p class="eyebrow">HOW IT WORKS</p>
                                                                                <h3>Learn together</h3>
                                                                                <ul class="peer-guidelines">
                                                                                    <li>Keep help focused on learning
                                                                                        and feedback.</li>
                                                                                    <li>Coordinate a time in the
                                                                                        conversation.</li>
                                                                                    <li>No fees, bids, or completed
                                                                                        graded work.</li>
                                                                                </ul>
                                                                                <% if (assignmentOwner) { %>
                                                                                    <form method="post"
                                                                                        action="${pageContext.request.contextPath}/assignments"
                                                                                        class="status-form"><input
                                                                                            type="hidden" name="action"
                                                                                            value="status"><input
                                                                                            type="hidden" name="id"
                                                                                            value="<%= esc(item.get("_id")) %>"><label>Update
                                                                                            status<select
                                                                                                class="form-select"
                                                                                                name="status">
                                                                                                <% for (String option :
                                                                                                    new
                                                                                                    String[]{"OPEN","IN_PROGRESS","COMPLETED","CANCELLED"})
                                                                                                    { %>
                                                                                                    <option
                                                                                                        value="<%= option %>"
                                                                                                        <%=option.equals(item.getString("status"))
                                                                                                        ? "selected"
                                                                                                        : "" %>><%=
                                                                                                            option %>
                                                                                                    </option>
                                                                                                    <% } %>
                                                                                            </select></label><button
                                                                                            class="btn btn-outline-primary mt-2 w-100">Save
                                                                                            status</button></form>
                                                                                    <% } %>
                                                                            </aside>
                                                                        </section>
                                                                        <% } else if ("notes".equals(module)) {
                                                                            List<Document> noteComments=(List<Document>
                                                                                )request.getAttribute("noteComments");
                                                                                List<Document> noteVersions=(List
                                                                                    <Document>
                                                                                        )request.getAttribute("noteVersions");
                                                                                        %><section
                                                                                            class="panel answers-panel advanced-panel">
                                                                                            <div class="section-head">
                                                                                                <div>
                                                                                                    <p class="eyebrow">
                                                                                                        NOTE DISCUSSION
                                                                                                    </p>
                                                                                                    <h2>Comments &
                                                                                                        revisions</h2>
                                                                                                </div><span
                                                                                                    class="badge text-bg-light">Version
                                                                                                    <%= esc(item.get("version",
                                                                                                        1)) %></span>
                                                                                            </div>
                                                                                            <% if
                                                                                                ("true".equals(request.getParameter("commented")))
                                                                                                { %>
                                                                                                <div
                                                                                                    class="alert alert-success">
                                                                                                    Comment posted.
                                                                                                </div>
                                                                                                <% } %>
                                                                                                    <% if (noteComments
                                                                                                        !=null &&
                                                                                                        !noteComments.isEmpty())
                                                                                                        { for (Document
                                                                                                        comment :
                                                                                                        noteComments) {
                                                                                                        %>
                                                                                                        <article
                                                                                                            class="answer-card">
                                                                                                            <p>
                                                                                                                <%= esc(comment.getString("body"))
                                                                                                                    %>
                                                                                                            </p><small>
                                                                                                                <%= esc(comment.getString("authorName"))
                                                                                                                    %> �
                                                                                                                    <%= esc(comment.getString("createdAt"))
                                                                                                                        %>
                                                                                                            </small>
                                                                                                        </article>
                                                                                                        <% } } else { %>
                                                                                                            <div
                                                                                                                class="empty">
                                                                                                                No
                                                                                                                comments
                                                                                                                yet.
                                                                                                                Help
                                                                                                                improve
                                                                                                                this
                                                                                                                resource.
                                                                                                            </div>
                                                                                                            <% } %>
                                                                                                                <form
                                                                                                                    method="post"
                                                                                                                    action="${pageContext.request.contextPath}/notes"
                                                                                                                    class="answer-form">
                                                                                                                    <input
                                                                                                                        type="hidden"
                                                                                                                        name="action"
                                                                                                                        value="comment"><input
                                                                                                                        type="hidden"
                                                                                                                        name="id"
                                                                                                                        value="<%= esc(item.get("_id")) %>"><label>Comment<textarea
                                                                                                                            class="form-control"
                                                                                                                            name="body"
                                                                                                                            maxlength="2000"
                                                                                                                            rows="3"
                                                                                                                            required
                                                                                                                            placeholder="Ask a question or suggest an improvement"></textarea></label><button
                                                                                                                        class="btn btn-primary mt-3">Post
                                                                                                                        comment</button>
                                                                                                                </form>
                                                                                                                <% if
                                                                                                                    (noteVersions
                                                                                                                    !=null
                                                                                                                    &&
                                                                                                                    !noteVersions.isEmpty())
                                                                                                                    { %>
                                                                                                                    <div
                                                                                                                        class="version-history">
                                                                                                                        <h3>Version
                                                                                                                            history
                                                                                                                        </h3>
                                                                                                                        <% for
                                                                                                                            (Document
                                                                                                                            version
                                                                                                                            :
                                                                                                                            noteVersions)
                                                                                                                            {
                                                                                                                            %>
                                                                                                                            <div
                                                                                                                                class="version-row">
                                                                                                                                <strong>Version
                                                                                                                                    <%= esc(version.get("version"))
                                                                                                                                        %>
                                                                                                                                        </strong><span>
                                                                                                                                    <%= esc(version.getString("createdAt"))
                                                                                                                                        %>
                                                                                                                                </span>
                                                                                                                                <p>
                                                                                                                                    <%= esc(version.getString("description"))
                                                                                                                                        %>
                                                                                                                                </p>
                                                                                                                            </div>
                                                                                                                            <% }
                                                                                                                                %>
                                                                                                                    </div>
                                                                                                                    <% }
                                                                                                                        %>
                                                                                        </section>
                                                                                        <% } else if ("activity".equals(module)) { %>
                                                                                            <section class="activity-detail-grid">
                                                                                                <section class="panel activity-detail-main">
                                                                                                    <p class="eyebrow">PROJECT FEEDBACK</p>
                                                                                                    <h2><%= esc("FEEDBACK".equals(item.getString("action")) ? "Community opinion" : "Campus activity") %></h2>
                                                                                                    <div class="activity-opinion">
                                                                                                        <p><%= esc(item.getString("description")) %></p>
                                                                                                    </div>
                                                                                                    <% if (item.get("score") != null) { %>
                                                                                                        <div class="activity-rating"><span>Rating</span><strong><%= esc(item.get("score")) %>/5</strong></div>
                                                                                                    <% } %>
                                                                                                </section>
                                                                                                <aside class="panel activity-detail-side">
                                                                                                    <p class="eyebrow">POST DETAILS</p>
                                                                                                    <div class="activity-meta-list">
                                                                                                        <div><span>Project</span><strong><%= esc(item.getString("projectName") == null || item.getString("projectName").isBlank() ? title : item.getString("projectName")) %></strong></div>
                                                                                                        <div><span>Shared by</span><strong><%= esc(item.getString("actorName") == null ? "Campus student" : item.getString("actorName")) %></strong></div>
                                                                                                        <div><span>Posted</span><strong><%= esc(item.getString("createdAt")) %></strong></div>
                                                                                                    </div>
                                                                                                    <% if (item.getString("githubUrl") != null && !item.getString("githubUrl").isBlank()) { %>
                                                                                                        <a class="btn btn-primary activity-github-button" target="_blank" rel="noopener" href="<%= esc(item.getString("githubUrl")) %>">View project on GitHub ↗</a>
                                                                                                    <% } else { %>
                                                                                                        <div class="empty activity-no-link">No GitHub link was added.</div>
                                                                                                    <% } %>
                                                                                                </aside>
                                                                                            </section>
                                                                                        <% } else { %>
                                                                                            <section
                                                                                                class="panel detail-cta">
                                                                                                <h2>Ready to contribute?
                                                                                                </h2>
                                                                                                <p>Use the shared
                                                                                                    workspace to find
                                                                                                    collaborators,
                                                                                                    respond, or publish
                                                                                                    another useful
                                                                                                    contribution.</p><a
                                                                                                    class="btn btn-primary"
                                                                                                    href="${pageContext.request.contextPath}/<%= module %>">Return
                                                                                                    to workspace</a>
                                                                                            </section>
                                                                                            <% } %>
                                                    </main>
                                                </div>
                                    </body>

                                    </html>