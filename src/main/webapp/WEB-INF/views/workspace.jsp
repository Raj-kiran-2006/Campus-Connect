<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.campusconnect.web.Document" %>
<%@ page import="java.util.List" %>
<%
  String module = (String) request.getAttribute("module");
  List<Document> items = (List<Document>) request.getAttribute("items");
  String title = "Campus Workspace";
  String kicker = "CAMPUS CONNECT";
  String icon = "bi-grid";
  if ("notes".equals(module)) { title = "Resource Library"; kicker = "LEARN TOGETHER"; icon = "bi-journal-bookmark-fill"; }
  else if ("questions".equals(module)) { title = "Questions & Answers"; kicker = "ASK THE CAMPUS"; icon = "bi-chat-left-text-fill"; }
  else if ("assignments".equals(module)) { title = "Peer Support"; kicker = "PEER COLLABORATION"; icon = "bi-people-fill"; }
  else if ("teaching-offers".equals(module)) { title = "Teach a Peer"; kicker = "FREE PEER TEACHING"; icon = "bi-mortarboard-fill"; }
  else if ("marketplace".equals(module)) { title = "Campus Marketplace"; kicker = "BUY · SELL · SHARE"; icon = "bi-shop"; }
  else if ("projects".equals(module)) { title = "Project Spaces"; kicker = "COLLABORATE & BUILD"; icon = "bi-kanban-fill"; }
  else if ("notifications".equals(module)) { title = "Campus Notices"; kicker = "STAY IN THE LOOP"; icon = "bi-bell-fill"; }
  else if ("note-requests".equals(module)) { title = "Note Requests"; kicker = "REQUEST · SHARE · LEARN"; icon = "bi-file-earmark-plus-fill"; }
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title><%= title %> · Campus Connect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/campus.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/premium-ui.css" rel="stylesheet">
</head>
<body class="module-<%= module %>">
<% request.setAttribute("activeModule", module); %>
<%@ include file="_app-nav.jsp" %>
<div class="layout">
<main class="content cc-workspace">
    <!-- MODULE HERO BANNER -->
    <div class="module-banner">
        <div>
            <p class="eyebrow"><%= kicker %></p>
            <h1><%= title %></h1>
            <p class="text-secondary">
                <% if ("notes".equals(module)) { %>
                    Discover verified course notes, cheat sheets, and study guides shared by peers in your department.
                <% } else if ("note-requests".equals(module)) { %>
                    Can't find what you need? Request specific study materials and help classmates fulfil theirs.
                <% } else if ("questions".equals(module)) { %>
                    Get unstuck with clear, step-by-step peer explanations and searchable campus solutions.
                <% } else if ("assignments".equals(module)) { %>
                    Peer tutoring, conceptual feedback, and collaborative learning without copying.
                <% } else if ("teaching-offers".equals(module)) { %>
                    Offer your skills, coding experience, and mentorship to classmates freely.
                <% } else if ("marketplace".equals(module)) { %>
                    Buy, sell, or rent textbooks, scientific calculators, and hardware with students on your campus.
                <% } else if ("projects".equals(module)) { %>
                    Find project partners, assemble hackathon squads, and build your engineering portfolio together.
                <% } else { %>
                    Stay updated with all campus announcements, event deadlines, and club meetups.
                <% } %>
            </p>
        </div>
        <div class="module-orb">
            <i class="bi <%= icon %>"></i>
        </div>
    </div>

    <!-- NOTIFICATION ALERTS -->
    <% if ("true".equals(request.getParameter("fulfilled"))) { %><div class="alert alert-success alert-dismissible fade show"><i class="bi bi-check-circle-fill me-2"></i>Note added to the library and linked to the request.<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><% } %>
    <% if ("true".equals(request.getParameter("created"))) { %><div class="alert alert-success alert-dismissible fade show"><i class="bi bi-check-circle-fill me-2"></i>Published successfully to campus.<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><% } %>
    <% if ("true".equals(request.getParameter("deleted"))) { %><div class="alert alert-info alert-dismissible fade show"><i class="bi bi-info-circle-fill me-2"></i>Contribution removed successfully.<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><% } %>
    <% if ("added".equals(request.getParameter("saved"))) { %><div class="alert alert-success alert-dismissible fade show"><i class="bi bi-bookmark-check-fill me-2"></i>Saved to your collection. <a href="${pageContext.request.contextPath}/saved" class="alert-link">View saved items</a>.<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><% } %>
    <% if ("removed".equals(request.getParameter("saved"))) { %><div class="alert alert-info alert-dismissible fade show"><i class="bi bi-bookmark-dash me-2"></i>Removed from your saved items.<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div><% } %>

    <!-- TOOLBAR & VIEW CONTROLS -->
    <div class="cc-workspace-toolbar-card mb-4">
        <form class="toolbar" method="get" action="${pageContext.request.contextPath}/<%= module %>">
            <div class="input-group">
                <span class="input-group-text bg-transparent border-end-0"><i class="bi bi-search text-secondary"></i></span>
                <input class="form-control border-start-0" id="liveSearchInput" name="q" value="<%= request.getAttribute("query") == null ? "" : request.getAttribute("query") %>" placeholder="Instant search by title, subject, or keywords…">
            </div>
            <input class="form-control cc-category-input" name="category" value="<%= request.getAttribute("categoryFilter") == null ? "" : request.getAttribute("categoryFilter") %>" placeholder="Filter category">
            <button class="btn btn-primary px-3" type="submit">Search</button>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/<%= module %>">Reset</a>
        </form>

        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mt-3 pt-3 border-top">
            <div class="filter-pills">
                <a class="<%= request.getParameter("sort") == null ? "active" : "" %>" href="${pageContext.request.contextPath}/<%= module %>">All</a>
                <a class="<%= "recent".equals(request.getParameter("sort")) ? "active" : "" %>" href="${pageContext.request.contextPath}/<%= module %>?sort=recent">Recent</a>
                <a class="<%= "popular".equals(request.getParameter("sort")) ? "active" : "" %>" href="${pageContext.request.contextPath}/<%= module %>?sort=popular">Popular</a>
            </div>

            <div class="d-flex align-items-center gap-2">
                <!-- FEATURE: Grid / Compact List Layout Switcher -->
                <div class="btn-group btn-group-sm cc-view-switcher" role="group" aria-label="Layout view switcher">
                    <button type="button" class="btn btn-outline-secondary active" id="viewModeGrid" title="Grid View"><i class="bi bi-grid-fill"></i></button>
                    <button type="button" class="btn btn-outline-secondary" id="viewModeList" title="Compact List View"><i class="bi bi-list-ul"></i></button>
                </div>

                <% if ("marketplace".equals(module)) { %>
                    <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/marketplace/orders">
                        <i class="bi bi-receipt me-1"></i> Seller Orders
                    </a>
                <% } %>

                <button class="btn btn-sm btn-primary cc-create-btn" data-bs-toggle="modal" data-bs-target="#createModal">
                    <i class="bi bi-plus-lg me-1"></i> <%= "marketplace".equals(module) ? "List an item" : "Create New" %>
                </button>
            </div>
        </div>
    </div>

    <!-- CARDS CONTAINER (GRID OR LIST) -->
    <div id="cards" class="card-grid">
        <% for (Document item : items) {
            String category = item.getString("category");
            String status = item.getString("status");
            String cardTitle = item.getString("title");
            if (cardTitle == null || cardTitle.isBlank()) cardTitle = item.getString("name");
            if (cardTitle == null || cardTitle.isBlank()) cardTitle = "Untitled Contribution";
            String description = item.getString("description");
            if (description == null || description.isBlank()) description = "Campus community activity";
            Object rawId = item.get("_id");
            String id = rawId == null ? "" : rawId.toString();
        %>
            <article class="item-card searchable" data-search-text="<%= (cardTitle + " " + (category != null ? category : "") + " " + description).toLowerCase() %>">
                <% if ("marketplace".equals(module)) { %>
                    <a class="card-link" href="${pageContext.request.contextPath}/marketplace/detail?id=<%= id %>">
                <% } %>

                <div class="item-card-top">
                    <div class="item-icon">
                        <i class="bi <%= "marketplace".equals(module) ? "bi-bag" : "questions".equals(module) ? "bi-question-circle" : "projects".equals(module) ? "bi-code-square" : "bi-journal-check" %>"></i>
                    </div>
                    <div class="d-flex align-items-center gap-1">
                        <span class="badge text-bg-light border">
                            <%= category == null || category.isBlank() ? (status == null || status.isBlank() ? "ACTIVE" : status) : category %>
                        </span>
                        <!-- Quick Share Button -->
                        <button type="button" class="btn btn-sm btn-link text-secondary p-1 cc-share-card-btn" title="Copy shareable link" onclick="event.preventDefault(); event.stopPropagation(); window.copyCardLink('<%= module %>', '<%= id %>')">
                            <i class="bi bi-share"></i>
                        </button>
                    </div>
                </div>

                <h3><%= cardTitle %></h3>

                <% if (Boolean.TRUE.equals(item.getBoolean("ownerVerified"))) { %>
                    <span class="verified-badge"><i class="bi bi-patch-check-fill me-1"></i> Verified Student</span>
                <% } %>
                <% if (item.getString("ownerAvailability") != null && !item.getString("ownerAvailability").isBlank()) { %>
                    <small class="availability-label"><i class="bi bi-clock me-1"></i>Available: <%= item.getString("ownerAvailability") %></small>
                <% } %>
                <% if ("activity".equals(module) && "FEEDBACK".equals(item.getString("action")) && item.getString("projectName") != null && !item.getString("projectName").isBlank()) { %>
                    <div class="feedback-project-name">Completed Project: <strong><%= item.getString("projectName") %></strong></div>
                <% } %>

                <p><%= description %></p>

                <% if ("activity".equals(module) && item.getString("githubUrl") != null && !item.getString("githubUrl").isBlank()) { %>
                    <a class="resource-link feedback-repo" target="_blank" rel="noopener" href="<%= item.getString("githubUrl") %>">
                        <i class="bi bi-github me-1"></i> View Project on GitHub <i class="bi bi-box-arrow-up-right ms-1"></i>
                    </a>
                <% } %>
                <% if ("activity".equals(module) && "FEEDBACK".equals(item.getString("action"))) { %>
                    <small class="feedback-label">Peer feedback<% if (item.get("score") != null) { %> · <%= item.get("score") %>/5 rating<% } %></small>
                <% } %>

                <% if ("assignments".equals(module)) { %>
                    <div class="detail-row"><span>Deadline</span><strong><%= item.getString("deadline") == null ? "Flexible" : item.getString("deadline") %></strong></div>
                    <div class="detail-row"><span>Support Model</span><strong>Free Peer Exchange</strong></div>
                <% } else if ("teaching-offers".equals(module)) { %>
                    <div class="detail-row"><span>Format</span><strong><%= item.getString("format") == null ? "Flexible" : item.getString("format") %></strong></div>
                    <div class="detail-row"><span>Schedule</span><strong><%= item.getString("schedule") == null ? "Arrange a time" : item.getString("schedule") %></strong></div>
                    <a class="btn btn-sm btn-outline-primary mt-2" href="${pageContext.request.contextPath}/messages?with=<%= item.get("ownerId") %>">
                        <i class="bi bi-chat-dots me-1"></i> Contact Teacher
                    </a>
                <% } else if ("notes".equals(module) && item.getString("resourceUrl") != null && !item.getString("resourceUrl").isBlank()) { %>
                    <a class="resource-link" target="_blank" rel="noopener" href="<%= item.getString("resourceUrl") %>">
                        <i class="bi bi-box-arrow-up-right me-1"></i> Open <%= item.getString("resourceType") == null ? "Resource" : item.getString("resourceType") %>
                    </a>
                <% } %>

                <div class="card-meta">
                    <span><i class="bi bi-calendar3 me-1"></i><%= item.getString("createdAt") == null ? "Recently" : item.getString("createdAt").substring(0, Math.min(10, item.getString("createdAt").length())) %></span>
                    <strong><%= "marketplace".equals(module) ? "&#8377;" + item.get("price", 0) + " · View Details" : "" %></strong>
                </div>

                <% if (!"marketplace".equals(module)) { %>
                    <a class="detail-link" href="${pageContext.request.contextPath}/<%= module %>/detail?id=<%= id %>">
                        View details <i class="bi bi-arrow-right ms-1"></i>
                    </a>
                <% } %>
                <% if ("marketplace".equals(module)) { %>
                    </a>
                    <a class="btn btn-primary btn-sm card-buy w-100 mt-2" href="${pageContext.request.contextPath}/marketplace/detail?id=<%= id %>">
                        View &amp; Purchase
                    </a>
                <% } %>

                <% if ("notes".equals(module) || "questions".equals(module) || "projects".equals(module) || "marketplace".equals(module)) { %>
                    <form method="post" action="${pageContext.request.contextPath}/saved" class="cc-save-form mt-2">
                        <input type="hidden" name="module" value="<%= module %>">
                        <input type="hidden" name="id" value="<%= id %>">
                        <button class="btn btn-sm btn-outline-secondary w-100" type="submit">
                            <i class="bi bi-bookmark me-1"></i> Save for later
                        </button>
                    </form>
                <% } %>

                <% if ("note-requests".equals(module) && !"FULFILLED".equals(status)) { %>
                    <form method="post" action="${pageContext.request.contextPath}/note-requests" class="mt-3 p-2 bg-light rounded border">
                        <input type="hidden" name="action" value="fulfill">
                        <input type="hidden" name="id" value="<%= id %>">
                        <label class="form-label small fw-bold">Fulfil this request:</label>
                        <input class="form-control form-control-sm mb-2" type="url" name="resourceUrl" placeholder="https://link-to-your-notes" required>
                        <input class="form-control form-control-sm mb-2" name="description" placeholder="Short description (optional)">
                        <button class="btn btn-sm btn-success w-100"><i class="bi bi-upload me-1"></i> Fulfil with this note</button>
                    </form>
                <% } %>
            </article>
        <% } %>

        <% if (items.isEmpty()) { %>
            <div class="empty">
                <i class="bi bi-inbox fs-2 text-secondary mb-2 d-block"></i>
                <strong>Nothing here yet.</strong>
                <p class="text-secondary small mb-3">Be the first to create a valuable contribution for your campus peers.</p>
                <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#createModal">
                    <i class="bi bi-plus-lg me-1"></i> Create first entry
                </button>
            </div>
        <% } %>
    </div>

    <!-- MODULE FOOTER TIP -->
    <div class="module-footer-card">
        <div>
            <span class="eyebrow">CAMPUS PRO TIP</span>
            <h3><%= "notes".equals(module) ? "Make your notes easy to discover" : "Thoughtful contributions compound" %></h3>
            <p><%= "notes".equals(module) ? "Add clear subject tags, course codes, and descriptive summaries so peers find your study guides instantly." : "A well-formulated question, structured listing, or clear project vision helps dozens of students across semesters." %></p>
        </div>
        <span class="tip-mark"><i class="bi bi-lightbulb-fill"></i></span>
    </div>
</main>
</div>

<!-- MODAL FOR CREATION -->
<div class="modal fade" id="createModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-xl">
        <div class="modal-content workspace-create-modal">
            <div class="modal-header">
                <h2 class="modal-title">Create in <%= title %></h2>
                <button class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/<%= module %>">
                <div class="modal-body">
                    <label>Title
                        <input class="form-control" name="title" maxlength="140" required placeholder="Clear and concise title">
                    </label>
                    <% if ("note-requests".equals(module)) { %>
                        <label>Subject
                            <input class="form-control" name="subject" maxlength="120" required placeholder="e.g. Distributed Systems">
                        </label>
                    <% } else { %>
                        <% if ("activity".equals(module)) { %>
                            <label>Feedback Type
                                <select class="form-select" name="targetType">
                                    <option value="PROJECT">Completed project review</option>
                                    <option value="ASSIGNMENT">Assignment peer feedback</option>
                                </select>
                            </label>
                            <label>Project Name
                                <input class="form-control" name="projectName" maxlength="140" placeholder="e.g. Campus Connect Study Hub">
                            </label>
                            <label>Rating Score
                                <select class="form-select" name="score" required>
                                    <option value="">Choose a rating</option>
                                    <option value="5">5 / 5 - Exceptional</option>
                                    <option value="4">4 / 5 - Very Good</option>
                                    <option value="3">3 / 5 - Good</option>
                                    <option value="2">2 / 5 - Needs Improvement</option>
                                    <option value="1">1 / 5 - Major Rework Needed</option>
                                </select>
                            </label>
                        <% } else { %>
                            <label>Category / Domain
                                <input class="form-control" name="category" placeholder="e.g. Computer Science, AI, Mechanical">
                            </label>
                        <% } %>

                        <label><%= "activity".equals(module) ? "Your review & suggestions" : "Description" %>
                            <textarea class="form-control" name="description" rows="4" maxlength="5000" required placeholder="<%= "activity".equals(module) ? "Share what worked well and what could be improved..." : "Provide clear details for your peers..." %>"></textarea>
                        </label>

                        <% if ("activity".equals(module)) { %>
                            <label>GitHub Repository <span class="optional-label">(optional)</span>
                                <input class="form-control" type="url" name="githubUrl" pattern="https://github.com/.*" placeholder="https://github.com/username/project">
                            </label>
                        <% } %>
                        <% if ("notifications".equals(module)) { %>
                            <label>Notice Type
                                <select class="form-select" name="eventType">
                                    <option value="NOTICE">Official Campus Notice</option>
                                    <option value="EVENT">Campus Event / Hackathon</option>
                                </select>
                            </label>
                            <label>Date &amp; Time
                                <input class="form-control" type="datetime-local" name="startsAt">
                            </label>
                            <label>Location / Venue
                                <input class="form-control" name="location" placeholder="Auditorium, Lab 4, or Virtual Link">
                            </label>
                        <% } %>
                        <% if ("teaching-offers".equals(module)) { %>
                            <label>Skills &amp; Topics
                                <input class="form-control" name="skills" required placeholder="e.g. Python, Algorithms, System Design">
                            </label>
                            <label>Format
                                <input class="form-control" name="format" placeholder="Online, Campus Library, or Discord">
                            </label>
                            <label>Schedule &amp; Availability
                                <input class="form-control" name="schedule" placeholder="e.g. Tuesdays 5–7 PM">
                            </label>
                        <% } %>
                        <% if ("assignments".equals(module)) { %>
                            <label>Target Review Date
                                <input class="form-control" type="date" name="deadline" required>
                            </label>
                            <div class="form-hint">Peer review is completely free. Exchange code reviews and conceptual walkthroughs — never completed graded submissions.</div>
                        <% } %>
                        <% if ("notes".equals(module)) { %>
                            <label>Direct Resource Link
                                <input class="form-control" type="url" name="resourceUrl" placeholder="https://drive.google.com/... or GitHub link">
                            </label>
                            <label>File Format
                                <select class="form-select" name="resourceType">
                                    <option>PDF</option>
                                    <option>PPT / Slides</option>
                                    <option>GitHub Repository</option>
                                    <option>Web Link</option>
                                </select>
                            </label>
                        <% } %>
                        <% if ("marketplace".equals(module)) { %>
                            <label>Price (&#8377;)
                                <input class="form-control" type="number" min="0" name="price" placeholder="0 for free / exchange">
                            </label>
                            <label>Book / Item Author
                                <input class="form-control" name="author" placeholder="Author name or brand">
                            </label>
                            <label>Edition / Serial
                                <input class="form-control" name="edition" placeholder="Edition, ISBN, or specs">
                            </label>
                            <label>Physical Condition
                                <select class="form-select" name="condition">
                                    <option>Like New</option>
                                    <option>Gently Used</option>
                                    <option>Fair Condition</option>
                                </select>
                            </label>
                            <label>Photo Upload
                                <input id="listingPhoto" class="form-control" type="file" accept="image/png,image/jpeg,image/webp">
                                <input type="hidden" id="imageUrl" name="imageUrl">
                            </label>
                            <label>Listing Type
                                <select class="form-select" name="listingType">
                                    <option value="BOOK_SELL">Sell Textbook</option>
                                    <option value="BOOK_RENT">Rent Textbook</option>
                                    <option value="EQUIPMENT_RENT">Rent Lab / Tech Gear</option>
                                </select>
                            </label>
                        <% } %>
                        <% if ("questions".equals(module)) { %>
                            <label>Topic Tags
                                <input class="form-control" name="tags" placeholder="e.g. algorithms, react, databases">
                            </label>
                        <% } %>
                        <% if ("projects".equals(module)) { %>
                            <label>GitHub Repository
                                <input class="form-control" type="url" name="githubUrl" pattern="https://github.com/.*" placeholder="https://github.com/org/repo">
                            </label>
                            <label>Required Skills
                                <input class="form-control" name="skills" placeholder="Java, TypeScript, UI/UX, Cloud">
                            </label>
                            <label>Tags
                                <input class="form-control" name="tags" placeholder="web, ai, robotics, open-source">
                            </label>
                            <label>Milestone Target
                                <input class="form-control" name="milestone" placeholder="e.g. MVP Review · Nov 20">
                            </label>
                            <label>Collaboration Type
                                <select class="form-select" name="collaborationType">
                                    <option value="TEAM_PROJECT">Team Project</option>
                                    <option value="HACKATHON">Hackathon Squad</option>
                                    <option value="RESEARCH">Research Paper</option>
                                </select>
                            </label>
                            <label class="form-check mt-3">
                                <input class="form-check-input" type="checkbox" name="mentorNeeded">
                                <span class="form-check-label">Open to a senior student mentor</span>
                            </label>
                        <% } %>
                    <% } %>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button class="btn btn-primary px-4" type="submit">Publish to Campus</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
(() => {
    // 1. Instant Client-Side Live Filter
    const searchInput = document.getElementById('liveSearchInput');
    const cards = document.querySelectorAll('.searchable');
    if (searchInput) {
        searchInput.addEventListener('input', e => {
            const query = e.target.value.trim().toLowerCase();
            cards.forEach(card => {
                const text = card.dataset.searchText || card.textContent.toLowerCase();
                card.style.display = (!query || text.includes(query)) ? '' : 'none';
            });
        });
    }

    // 2. Grid vs List View Mode Switcher
    const gridBtn = document.getElementById('viewModeGrid');
    const listBtn = document.getElementById('viewModeList');
    const cardsContainer = document.getElementById('cards');
    const savedMode = localStorage.getItem('campus-view-mode') || 'grid';

    const setViewMode = mode => {
        if (!cardsContainer) return;
        if (mode === 'list') {
            cardsContainer.classList.add('is-list-view');
            if (listBtn) listBtn.classList.add('active');
            if (gridBtn) gridBtn.classList.remove('active');
        } else {
            cardsContainer.classList.remove('is-list-view');
            if (gridBtn) gridBtn.classList.add('active');
            if (listBtn) listBtn.classList.remove('active');
        }
        localStorage.setItem('campus-view-mode', mode);
    };

    setViewMode(savedMode);
    if (gridBtn) gridBtn.addEventListener('click', () => setViewMode('grid'));
    if (listBtn) listBtn.addEventListener('click', () => setViewMode('list'));

    // 3. Quick Copy Link Helper
    window.copyCardLink = (mod, id) => {
        const url = window.location.origin + '${pageContext.request.contextPath}/' + mod + '/detail?id=' + id;
        if (navigator.clipboard) {
            navigator.clipboard.writeText(url).then(() => {
                if (window.showCampusToast) window.showCampusToast('Item link copied to clipboard!', 'Share Link', 'success');
            }).catch(() => {
                prompt('Copy this link:', url);
            });
        } else {
            prompt('Copy this link:', url);
        }
    };

    // 4. Photo upload encoder
    const photo = document.querySelector('#listingPhoto');
    const image = document.querySelector('#imageUrl');
    if (photo && image) {
        photo.onchange = () => {
            const f = photo.files[0];
            if (!f || f.size > 2097152) {
                alert('Choose an image smaller than 2 MB');
                photo.value = '';
                return;
            }
            const r = new FileReader();
            r.onload = () => { image.value = r.result; };
            r.readAsDataURL(f);
        };
    }
})();
</script>
</body>
</html>
