<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.campusconnect.web.Document" %>
<%@ page import="java.util.List" %>
<%!
    private String dashboardSafe(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String dashboardDate(Document item) {
        String date = item.getString("createdAt");
        return date == null || date.isBlank() ? "Recently shared" : date.substring(0, Math.min(10, date.length()));
    }
    private boolean hasDemoItems(List<Document> items) {
        return items != null && items.stream().anyMatch(item -> Boolean.TRUE.equals(item.getBoolean("isDemo")));
    }
%>
<%
    Document user = (Document) session.getAttribute("user");
    List<Document> books = (List<Document>) request.getAttribute("books");
    List<Document> notes = (List<Document>) request.getAttribute("notes");
    List<Document> questions = (List<Document>) request.getAttribute("questions");
    List<Document> projects = (List<Document>) request.getAttribute("projects");
    List<Document> events = (List<Document>) request.getAttribute("events");
    long listingCount = (Long) request.getAttribute("listingCount");
    long noteCount = (Long) request.getAttribute("noteCount");
    long questionCount = (Long) request.getAttribute("questionCount");
    long projectCount = (Long) request.getAttribute("projectCount");
    long savedCount = (Long) request.getAttribute("savedCount");
    String firstName = user == null || user.getString("name") == null ? "there" : user.getString("name").split("\\s+")[0];
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="theme-color" content="#f4f3ef">
    <title>Enterprise Dashboard · Campus Connect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/campus.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/premium-ui.css" rel="stylesheet">
</head>
<body>
<% request.setAttribute("activeModule", "dashboard"); %><%@ include file="_app-nav.jsp" %>
<div class="layout"><main class="content cc-dashboard">
    <header class="cc-home-heading">
        <div>
            <div class="d-flex align-items-center gap-2 mb-2">
                <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1 rounded-pill fw-semibold cc-badge-sm">
                    <i class="bi bi-patch-check-fill me-1"></i> ACTIVE SEMESTER
                </span>
                <span class="text-secondary small">&bull; Online &amp; Synchronized</span>
            </div>
            <h1>Good to see you, <%= dashboardSafe(firstName) %>.</h1>
            <p>Your unified campus workspace for research, peer learning, and collaborative projects.</p>
        </div>
        <div class="cc-home-heading-actions">
            <button class="btn cc-heading-action" type="button" onclick="document.getElementById('openCommandPaletteBtn').click()">
                <i class="bi bi-command me-1"></i> Command Bar
            </button>
            <a class="btn cc-primary-action" href="${pageContext.request.contextPath}/projects">
                <i class="bi bi-plus-lg me-1"></i> Start Project
            </a>
        </div>
    </header>

    <% if (hasDemoItems(notes) || hasDemoItems(questions) || hasDemoItems(projects) || hasDemoItems(books) || hasDemoItems(events)) { %>
        <div class="cc-preview-notice mb-4">
            <span class="cc-preview-badge"><i class="bi bi-info-circle-fill"></i></span>
            <span><strong>Preview Campus Content</strong> Sample posts, resources, listings, and events are clearly labelled for demonstration.</span>
        </div>
    <% } %>

    <!-- FEATURE: Daily Campus Pulse & Study Goals Header Bar -->
    <div class="cc-pulse-banner mb-4">
        <div class="cc-pulse-col">
            <div class="d-flex align-items-center gap-2 mb-1">
                <span class="cc-pulse-dot"></span>
                <strong class="text-white">Campus Live Pulse</strong>
                <span class="badge bg-white text-dark cc-badge-xs">Active Community</span>
            </div>
            <p class="mb-0 text-white-50 small">Over <%= noteCount + questionCount + projectCount %> contributions shared by peers across colleges this semester.</p>
        </div>
        <div class="cc-pulse-metrics">
            <div class="cc-pulse-metric-item">
                <span class="cc-pulse-metric-val"><%= noteCount %></span>
                <span class="cc-pulse-metric-lbl">Notes</span>
            </div>
            <div class="cc-pulse-divider"></div>
            <div class="cc-pulse-metric-item">
                <span class="cc-pulse-metric-val"><%= questionCount %></span>
                <span class="cc-pulse-metric-lbl">Q&amp;A</span>
            </div>
            <div class="cc-pulse-divider"></div>
            <div class="cc-pulse-metric-item">
                <span class="cc-pulse-metric-val"><%= projectCount %></span>
                <span class="cc-pulse-metric-lbl">Teams</span>
            </div>
            <div class="cc-pulse-divider"></div>
            <div class="cc-pulse-metric-item">
                <span class="cc-pulse-metric-val"><%= savedCount %></span>
                <span class="cc-pulse-metric-lbl">Saved</span>
            </div>
        </div>
    </div>

    <!-- HERO SECTION WITH CINEMATIC VISUAL -->
    <section class="cc-welcome-panel mb-4" aria-label="Campus Connect">
        <div class="cc-welcome-copy">
            <span class="cc-welcome-tag"><span aria-hidden="true">✦</span> A COMMUNITY THAT MOVES WITH YOU</span>
            <h2>Small connections.<br><span>Big momentum.</span></h2>
            <p>Study together, trade ideas, and make campus life work better for everyone.</p>
            <div class="cc-welcome-links">
                <a class="btn btn-sm btn-light text-primary fw-semibold" href="${pageContext.request.contextPath}/questions">
                    Ask your campus <i class="bi bi-arrow-right ms-1"></i>
                </a>
                <a class="btn btn-sm btn-outline-light" href="${pageContext.request.contextPath}/profiles">
                    Meet your people <i class="bi bi-people ms-1"></i>
                </a>
            </div>
        </div>
        <div class="cc-welcome-visual" aria-hidden="true">
            <img class="cc-welcome-photo" data-campus-photo src="${pageContext.request.contextPath}/assets/images/campus-community.jpg" alt="">
            <div class="cc-welcome-photo-shade"></div>
            <span class="cc-visual-chip cc-visual-chip-one"><b>01</b> Find your circle</span>
            <span class="cc-visual-chip cc-visual-chip-two"><b>02</b> Make progress</span>
            <div class="cc-photo-caption"><span data-campus-photo-label>CAMPUS, IN GOOD COMPANY</span><strong data-campus-photo-caption>Connect beyond the classroom.</strong></div>
            <div class="cc-photo-controls" aria-label="Campus photo gallery">
                <button type="button" data-photo-step="-1" aria-label="Previous campus photo"><i class="bi bi-arrow-left" aria-hidden="true"></i></button>
                <span><button type="button" class="is-active" data-photo-index="0" aria-label="Show campus community photo" aria-pressed="true"></button><button type="button" data-photo-index="1" aria-label="Show student collaboration photo" aria-pressed="false"></button><button type="button" data-photo-index="2" aria-label="Show classroom photo" aria-pressed="false"></button></span>
                <button type="button" data-photo-step="1" aria-label="Next campus photo"><i class="bi bi-arrow-right" aria-hidden="true"></i></button>
            </div>
        </div>
    </section>

    <!-- INTERACTIVE CATEGORY TABS -->
    <nav class="cc-feed-filters mb-4" aria-label="Filter dashboard sections">
        <span class="cc-feed-filter-label"><i class="bi bi-sliders2" aria-hidden="true"></i> View Feed:</span>
        <button class="cc-feed-filter is-active" type="button" data-home-filter="all" aria-pressed="true">
            <i class="bi bi-layers-half me-1"></i> Everything
        </button>
        <button class="cc-feed-filter" type="button" data-home-filter="questions" aria-pressed="false">
            <i class="bi bi-chat-left-dots me-1"></i> Questions
        </button>
        <button class="cc-feed-filter" type="button" data-home-filter="resources" aria-pressed="false">
            <i class="bi bi-journal-bookmark me-1"></i> Resources
        </button>
        <button class="cc-feed-filter" type="button" data-home-filter="projects" aria-pressed="false">
            <i class="bi bi-kanban me-1"></i> Projects
        </button>
        <button class="cc-feed-filter" type="button" data-home-filter="campus" aria-pressed="false">
            <i class="bi bi-building me-1"></i> Campus Life
        </button>
    </nav>

    <!-- QUICK ACTIONS GRID -->
    <section class="cc-quick-grid mb-4" id="quick-actions" aria-label="Quick actions">
        <a class="cc-quick-action cc-quick-ask" href="${pageContext.request.contextPath}/questions">
            <span class="cc-quick-icon"><i class="bi bi-question-diamond"></i></span>
            <span><strong>Ask a question</strong><small>Get unstuck with peer explanations</small></span>
            <b aria-hidden="true"><i class="bi bi-arrow-up-right"></i></b>
        </a>
        <a class="cc-quick-action cc-quick-share" href="${pageContext.request.contextPath}/notes">
            <span class="cc-quick-icon"><i class="bi bi-file-earmark-arrow-up"></i></span>
            <span><strong>Share a resource</strong><small>Pass useful lecture notes along</small></span>
            <b aria-hidden="true"><i class="bi bi-arrow-up-right"></i></b>
        </a>
        <a class="cc-quick-action cc-quick-build" href="${pageContext.request.contextPath}/projects">
            <span class="cc-quick-icon"><i class="bi bi-diagram-3"></i></span>
            <span><strong>Find a project</strong><small>Build and collaborate with peers</small></span>
            <b aria-hidden="true"><i class="bi bi-arrow-up-right"></i></b>
        </a>
        <a class="cc-quick-action cc-quick-market" href="${pageContext.request.contextPath}/marketplace">
            <span class="cc-quick-icon"><i class="bi bi-bag-check"></i></span>
            <span><strong>Browse marketplace</strong><small>Books, calculators &amp; gear nearby</small></span>
            <b aria-hidden="true"><i class="bi bi-arrow-up-right"></i></b>
        </a>
    </section>

    <!-- MAIN TWO-COLUMN LAYOUT -->
    <div class="cc-dashboard-columns">
        <div class="cc-dashboard-main-column">

            <!-- FEATURE: INTERACTIVE CAMPUS POLL OF THE DAY -->
            <div class="cc-interactive-poll-card mb-4" id="campusPollWidget">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <span class="badge bg-primary text-white rounded-pill cc-badge-sm">
                        <i class="bi bi-bar-chart-fill me-1"></i> DAILY CAMPUS POLL
                    </span>
                    <span class="text-secondary small" id="pollTotalVotes">142 votes cast</span>
                </div>
                <h3 class="h6 fw-bold mb-3">Which area are you focusing most on this exam cycle?</h3>
                <div class="cc-poll-options" id="pollOptionsList">
                    <button class="cc-poll-option" type="button" data-poll="0">
                        <div class="cc-poll-option-track" style="width: 48%;"></div>
                        <span class="cc-poll-option-label">Core Engineering / CS Foundations</span>
                        <span class="cc-poll-option-pct">48%</span>
                    </button>
                    <button class="cc-poll-option" type="button" data-poll="1">
                        <div class="cc-poll-option-track" style="width: 27%;"></div>
                        <span class="cc-poll-option-label">Project Submissions &amp; Code Review</span>
                        <span class="cc-poll-option-pct">27%</span>
                    </button>
                    <button class="cc-poll-option" type="button" data-poll="2">
                        <div class="cc-poll-option-track" style="width: 16%;"></div>
                        <span class="cc-poll-option-label">Interview Prep &amp; Placement Tests</span>
                        <span class="cc-poll-option-pct">16%</span>
                    </button>
                    <button class="cc-poll-option" type="button" data-poll="3">
                        <div class="cc-poll-option-track" style="width: 9%;"></div>
                        <span class="cc-poll-option-label">Group Revision &amp; Tutoring</span>
                        <span class="cc-poll-option-pct">9%</span>
                    </button>
                </div>
                <div class="cc-poll-status-text text-secondary mt-2 small" id="pollStatusMessage">
                    Click an option above to cast your vote!
                </div>
            </div>

            <!-- QUESTIONS SECTION -->
            <section class="cc-home-section mb-4" data-home-category="questions">
                <div class="cc-home-section-heading">
                    <div>
                        <p class="cc-kicker mb-1">GOOD QUESTIONS, BETTER ANSWERS</p>
                        <h2>Join the conversation</h2>
                    </div>
                    <a class="cc-view-all-link" href="${pageContext.request.contextPath}/questions">
                        All questions <i class="bi bi-arrow-right ms-1"></i>
                    </a>
                </div>
                <% if (questions.isEmpty()) { %>
                    <div class="cc-home-empty">
                        <span class="cc-home-empty-icon"><i class="bi bi-chat-square-dots"></i></span>
                        <div><strong>Be the first to start a conversation.</strong><p>Ask a question and learn with your campus community.</p></div>
                        <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/questions">Ask a question</a>
                    </div>
                <% } else { %>
                    <div class="cc-home-list">
                        <% for (Document question : questions) {
                            Object rawId = question.get("_id");
                            String questionId = rawId == null ? "" : rawId.toString();
                            String title = question.getString("title") == null ? "Campus question" : question.getString("title");
                            String description = question.getString("description") == null ? "Join the discussion with your classmates." : question.getString("description");
                        %>
                            <a class="cc-home-list-item" href="${pageContext.request.contextPath}/questions/detail?id=<%= dashboardSafe(questionId) %>">
                                <span class="cc-home-item-icon cc-home-question-icon"><i class="bi bi-question-lg"></i></span>
                                <span class="cc-home-item-copy">
                                    <strong><%= dashboardSafe(title) %></strong>
                                    <small><%= dashboardSafe(description) %></small>
                                </span>
                                <% if (Boolean.TRUE.equals(question.getBoolean("isDemo"))) { %><span class="cc-demo-tag">SAMPLE</span><% } %>
                                <span class="cc-home-item-meta"><%= dashboardSafe(question.getString("category") == null ? "QUESTION" : question.getString("category")) %><i class="bi bi-chevron-right ms-1"></i></span>
                            </a>
                        <% } %>
                    </div>
                <% } %>
            </section>

            <!-- RESOURCES SECTION -->
            <section class="cc-home-section mb-4" data-home-category="resources">
                <div class="cc-home-section-heading">
                    <div>
                        <p class="cc-kicker mb-1">SHARED BY YOUR CAMPUS</p>
                        <h2>Fresh from the library</h2>
                    </div>
                    <a class="cc-view-all-link" href="${pageContext.request.contextPath}/notes">
                        Explore resources <i class="bi bi-arrow-right ms-1"></i>
                    </a>
                </div>
                <% if (notes.isEmpty()) { %>
                    <div class="cc-home-empty">
                        <span class="cc-home-empty-icon"><i class="bi bi-journal-text"></i></span>
                        <div><strong>Your library is ready for its first good find.</strong><p>Share a resource that helped you get it.</p></div>
                        <a class="btn btn-sm btn-primary" href="${pageContext.request.contextPath}/notes">Open library</a>
                    </div>
                <% } else { %>
                    <div class="cc-home-list">
                        <% for (Document note : notes) {
                            Object rawId = note.get("_id");
                            String noteId = rawId == null ? "" : rawId.toString();
                            String title = note.getString("title") == null ? "Study resource" : note.getString("title");
                        %>
                            <a class="cc-home-list-item" href="${pageContext.request.contextPath}/notes/detail?id=<%= dashboardSafe(noteId) %>">
                                <% if (Boolean.TRUE.equals(note.getBoolean("isDemo"))) { %>
                                    <img class="cc-home-item-thumbnail" src="${pageContext.request.contextPath}/assets/images/study-resources.jpg" alt="">
                                <% } else { %>
                                    <span class="cc-home-item-icon cc-home-resource-icon"><i class="bi bi-journal-bookmark-fill"></i></span>
                                <% } %>
                                <span class="cc-home-item-copy">
                                    <strong><%= dashboardSafe(title) %></strong>
                                    <small><%= dashboardSafe(note.getString("subject") == null ? "Campus resource" : note.getString("subject")) %></small>
                                </span>
                                <% if (Boolean.TRUE.equals(note.getBoolean("isDemo"))) { %><span class="cc-demo-tag">SAMPLE</span><% } %>
                                <span class="cc-home-item-date"><%= dashboardSafe(dashboardDate(note)) %><i class="bi bi-chevron-right ms-1"></i></span>
                            </a>
                        <% } %>
                    </div>
                <% } %>
            </section>

            <!-- PROJECTS SECTION -->
            <section class="cc-home-section" data-home-category="projects">
                <div class="cc-home-section-heading">
                    <div>
                        <p class="cc-kicker mb-1">IDEAS BECOME BETTER TOGETHER</p>
                        <h2>Project spaces</h2>
                    </div>
                    <a class="cc-view-all-link" href="${pageContext.request.contextPath}/projects">
                        Explore projects <i class="bi bi-arrow-right ms-1"></i>
                    </a>
                </div>
                <% if (projects.isEmpty()) { %>
                    <div class="cc-home-project-empty">
                        <div class="cc-project-spark" aria-hidden="true"><i class="bi bi-stars"></i></div>
                        <div><strong>Make room for an idea.</strong><p>Find a team to join or start a project of your own.</p></div>
                        <a class="btn cc-primary-action" href="${pageContext.request.contextPath}/projects">Explore project spaces</a>
                    </div>
                <% } else { %>
                    <div class="cc-project-grid">
                        <% for (Document project : projects) {
                            Object rawId = project.get("_id");
                            String projectId = rawId == null ? "" : rawId.toString();
                            String title = project.getString("title") == null ? "Project space" : project.getString("title");
                            String description = project.getString("description") == null ? "A campus team is looking for collaborators." : project.getString("description");
                        %>
                            <a class="cc-project-tile" href="${pageContext.request.contextPath}/projects/detail?id=<%= dashboardSafe(projectId) %>">
                                <% if (Boolean.TRUE.equals(project.getBoolean("isDemo"))) { %>
                                    <img class="cc-project-cover" src="${pageContext.request.contextPath}/assets/images/student-collaboration.jpg" alt="">
                                <% } %>
                                <span class="cc-project-tile-icon"><i class="bi bi-code-slash"></i></span>
                                <span class="cc-project-tile-label">
                                    <% if (Boolean.TRUE.equals(project.getBoolean("isDemo"))) { %>SAMPLE PROJECT<% } else { %>OPEN TO COLLABORATORS<% } %>
                                </span>
                                <strong><%= dashboardSafe(title) %></strong>
                                <p><%= dashboardSafe(description) %></p>
                                <span class="cc-project-tile-link">See project space <i class="bi bi-arrow-right ms-1"></i></span>
                            </a>
                        <% } %>
                    </div>
                <% } %>
            </section>
        </div>

        <aside class="cc-dashboard-side-column">
            <!-- CAMPUS BOARD / NOTICES -->
            <section class="cc-home-side-card cc-notice-card mb-4" data-home-category="campus">
                <div class="cc-side-card-heading">
                    <span class="cc-side-card-icon"><i class="bi bi-megaphone-fill"></i></span>
                    <a href="${pageContext.request.contextPath}/notifications">Campus board <i class="bi bi-box-arrow-up-right ms-1"></i></a>
                </div>
                <p class="cc-side-card-subtitle">Official &amp; club announcements</p>
                <% if (events.isEmpty()) { %>
                    <div class="cc-notice-empty">
                        <strong>It’s quiet here right now.</strong>
                        <p>Campus notices and events will appear as soon as they are posted.</p>
                        <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/notifications">Open Board</a>
                    </div>
                <% } else { %>
                    <div class="cc-notice-list">
                        <% for (Document event : events) {
                            String eventTitle = event.getString("title") == null ? "Campus notice" : event.getString("title");
                        %>
                            <article class="cc-notice-item">
                                <span class="cc-notice-dot" aria-hidden="true"></span>
                                <div>
                                    <span class="cc-notice-type"><%= dashboardSafe(event.getString("category") == null ? "CAMPUS UPDATE" : event.getString("category")) %></span>
                                    <h3><%= dashboardSafe(eventTitle) %></h3>
                                    <p><%= dashboardSafe(event.getString("location") == null ? "Campus Community" : event.getString("location")) %></p>
                                    <small><i class="bi bi-clock me-1"></i><%= dashboardSafe(event.getString("date") == null ? "Upcoming" : event.getString("date")) %></small>
                                </div>
                                <% if (Boolean.TRUE.equals(event.getBoolean("isDemo"))) { %><span class="cc-demo-tag">SAMPLE</span><% } %>
                            </article>
                        <% } %>
                    </div>
                <% } %>
            </section>

            <!-- CURATED TOOLKIT PHOTO CARD -->
            <section class="cc-home-side-card cc-library-card mb-4">
                <img class="cc-library-photo" src="${pageContext.request.contextPath}/assets/images/study-resources.jpg" alt="Students sharing ideas at a laptop">
                <div class="cc-library-photo-copy">
                    <span>STUDENT TOOLKIT</span>
                    <strong>High-impact resources curated for you.</strong>
                    <a href="${pageContext.request.contextPath}/saved">
                        Browse saved collection <i class="bi bi-arrow-right ms-1"></i>
                    </a>
                </div>
            </section>

            <!-- MARKETPLACE MINI-WIDGET -->
            <% if (books != null && !books.isEmpty()) { %>
                <section class="cc-home-side-card cc-market-mini-card" data-home-category="campus">
                    <div class="cc-side-card-heading">
                        <span class="cc-side-card-icon cc-market-mini-icon"><i class="bi bi-bag-heart"></i></span>
                        <a href="${pageContext.request.contextPath}/marketplace">Campus Marketplace <i class="bi bi-box-arrow-up-right ms-1"></i></a>
                    </div>
                    <p class="cc-side-card-subtitle">Textbooks, gear &amp; electronics nearby</p>
                    <% for (Document item : books) {
                        Object rawId = item.get("_id");
                        String itemId = rawId == null ? "" : rawId.toString();
                        String itemName = item.getString("name") == null ? "Campus item" : item.getString("name");
                    %>
                        <a class="cc-market-mini-item" href="${pageContext.request.contextPath}/marketplace/detail?id=<%= dashboardSafe(itemId) %>">
                            <% String image = item.getString("imageUrl"); if (image != null && !image.isBlank()) { %>
                                <img src="<%= dashboardSafe(image) %>" alt="">
                            <% } else { %>
                                <span class="cc-market-mini-placeholder" aria-hidden="true"><i class="bi bi-book"></i></span>
                            <% } %>
                            <span>
                                <strong><%= dashboardSafe(itemName) %></strong>
                                <small><%= dashboardSafe(item.getString("category") == null ? "Campus find" : item.getString("category")) %></small>
                            </span>
                            <b>&#8377;<%= dashboardSafe(item.get("price", 0)) %></b>
                        </a>
                    <% } %>
                </section>
            <% } %>
        </aside>
    </div>
</main></div>

<script>
(() => {
    // 1. Photo Gallery Carousel Logic
    const photoGallery = [
        { src: 'campus-community.jpg', alt: 'Students studying and collaborating together', label: 'CAMPUS, IN GOOD COMPANY', caption: 'Connect beyond the classroom.' },
        { src: 'student-collaboration.jpg', alt: 'Classmates working through an idea together', label: 'IDEAS TRAVEL FURTHER', caption: 'Make progress, side by side.' },
        { src: 'campus-classroom.jpg', alt: 'Students learning together in a classroom', label: 'LEARN FROM EACH OTHER', caption: 'A better campus starts together.' }
    ];
    const photo = document.querySelector('[data-campus-photo]');
    const photoLabel = document.querySelector('[data-campus-photo-label]');
    const photoCaption = document.querySelector('[data-campus-photo-caption]');
    const photoDots = [...document.querySelectorAll('[data-photo-index]')];
    let activePhoto = 0;
    const showPhoto = index => {
        if (!photo) return;
        activePhoto = (index + photoGallery.length) % photoGallery.length;
        const slide = photoGallery[activePhoto];
        photo.classList.remove('is-changing');
        photo.src = '${pageContext.request.contextPath}/assets/images/' + slide.src;
        photo.alt = slide.alt;
        requestAnimationFrame(() => photo.classList.add('is-changing'));
        if (photoLabel) photoLabel.textContent = slide.label;
        if (photoCaption) photoCaption.textContent = slide.caption;
        photoDots.forEach((dot, dotIndex) => {
            const active = dotIndex === activePhoto;
            dot.classList.toggle('is-active', active);
            dot.setAttribute('aria-pressed', String(active));
        });
    };
    document.querySelectorAll('[data-photo-step]').forEach(button => button.addEventListener('click', () => {
        showPhoto(activePhoto + Number(button.dataset.photoStep));
    }));
    photoDots.forEach(button => button.addEventListener('click', () => {
        showPhoto(Number(button.dataset.photoIndex));
    }));

    // 2. Feed Category Filtering
    const buttons = document.querySelectorAll('[data-home-filter]');
    const sections = document.querySelectorAll('[data-home-category]');
    buttons.forEach(button => button.addEventListener('click', () => {
        const category = button.dataset.homeFilter;
        buttons.forEach(option => {
            const active = option === button;
            option.classList.toggle('is-active', active);
            option.setAttribute('aria-pressed', String(active));
        });
        sections.forEach(section => {
            section.hidden = category !== 'all' && section.dataset.homeCategory !== category;
        });
    }));

    // 3. Interactive Campus Poll Logic
    const pollButtons = document.querySelectorAll('.cc-poll-option');
    const pollStatus = document.getElementById('pollStatusMessage');
    const pollVotesEl = document.getElementById('pollTotalVotes');
    const storedVote = localStorage.getItem('campus-daily-poll-voted');

    if (storedVote !== null && pollButtons[storedVote]) {
        pollButtons[storedVote].classList.add('is-voted');
        if (pollStatus) pollStatus.innerHTML = '<span class="text-success fw-bold"><i class="bi bi-check-circle-fill me-1"></i> Your vote has been recorded! Thank you.</span>';
    }

    pollButtons.forEach((btn, idx) => {
        btn.addEventListener('click', () => {
            pollButtons.forEach(b => b.classList.remove('is-voted'));
            btn.classList.add('is-voted');
            localStorage.setItem('campus-daily-poll-voted', String(idx));
            if (pollVotesEl) pollVotesEl.textContent = '143 votes cast';
            if (pollStatus) pollStatus.innerHTML = '<span class="text-success fw-bold"><i class="bi bi-check-circle-fill me-1"></i> Your vote has been recorded! Thank you.</span>';
            if (window.showCampusToast) {
                window.showCampusToast('Your vote for today’s campus poll has been submitted!', 'Vote Recorded', 'success');
            }
        });
    });
})();
</script>
</body>
</html>
