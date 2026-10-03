<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.campusconnect.web.Document" %>
<%@ page import="java.util.List" %>
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
%>
<!doctype html><html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Dashboard · Campus Connect</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/assets/campus.css" rel="stylesheet"></head>
<body><% request.setAttribute("activeModule", "dashboard"); %><%@ include file="_app-nav.jsp" %><div class="layout">
<main class="content"><section class="hero"><div><p class="eyebrow">YOUR CAMPUS, CONNECTED</p><h1>Make progress together.</h1><p>Discover people, resources, and opportunities around you.</p></div><a class="btn btn-light" href="${pageContext.request.contextPath}/marketplace">Explore marketplace →</a></section>
<section class="quick-grid section"><div class="quick-card"><span class="quick-icon">✦</span><div><p class="eyebrow">TODAY'S FOCUS</p><h3>Make one useful contribution</h3><p>Answer a question, share a resource, or help a peer move forward.</p></div><a href="${pageContext.request.contextPath}/questions">Start helping →</a></div><div class="quick-card lavender"><span class="quick-icon">◇</span><div><p class="eyebrow">FIND YOUR PEOPLE</p><h3>Join an active project</h3><p>Use your skills beyond the classroom and meet motivated collaborators.</p></div><a href="${pageContext.request.contextPath}/projects">Explore projects →</a></div></section>
<div class="metric-grid"><div class="metric"><span>Marketplace listings</span><strong><%= listingCount %></strong></div><div class="metric"><span>Shared resources</span><strong><%= noteCount %></strong></div><div class="metric"><span>Open questions</span><strong><%= questionCount %></strong></div><div class="metric"><span>Project spaces</span><strong><%= projectCount %></strong></div></div>
<section id="marketplace" class="section"><div class="section-head"><div><p class="eyebrow">MARKETPLACE</p><h2>Useful things, nearby</h2></div><a class="btn btn-primary" href="${pageContext.request.contextPath}/marketplace">List an item</a></div><div class="card-grid">
<% for (Document item : books) { String image = item.getString("imageUrl"); Object rawProductId = item.get("_id"); String productId = rawProductId == null ? "" : rawProductId.toString(); %><article class="item-card marketplace-card"><% if (image != null && !image.isBlank()) { %><img class="market-image" src="<%= image %>" alt="Campus listing"><% } else { %><div class="item-icon">▣</div><% } %><div class="marketplace-card-body"><h3><%= item.getString("name") == null ? "Campus item" : item.getString("name") %></h3><p><%= item.getString("description") == null ? "Shared by a student" : item.getString("description") %></p><div class="marketplace-card-footer"><strong>₹<%= item.get("price", 0) %></strong><a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/marketplace/detail?id=<%= productId %>">View details</a></div></div></article><% } %>
<% if (books.isEmpty()) { %><div class="empty">No listings yet. Be the first to share something useful.</div><% } %></div></section>
<section id="learning" class="section"><div class="section-head"><div><p class="eyebrow">LEARNING HUB</p><h2>What students are exploring</h2></div></div><div class="row g-3"><div class="col-md-6"><div class="panel"><h3>Notes library</h3><p class="text-secondary"><%= notes.size() %> resources ready to discover.</p><a href="${pageContext.request.contextPath}/notes" class="link-primary">Browse notes →</a></div></div><div class="col-md-6"><div class="panel"><h3>Questions & answers</h3><p class="text-secondary"><%= questions.size() %> conversations are active.</p><a href="${pageContext.request.contextPath}/questions" class="link-primary">Join a discussion →</a></div></div></div></section>
<section id="projects" class="section"><div class="section-head"><div><p class="eyebrow">COLLABORATION</p><h2>Build something meaningful</h2></div></div><div class="panel"><p class="text-secondary"><%= projects.size() %> project spaces are looking for contributors.</p><a class="btn btn-dark" href="${pageContext.request.contextPath}/projects">Find a project</a></div></section>
<section class="section"><div class="section-head"><div><p class="eyebrow">CAMPUS PULSE</p><h2>What is happening around campus</h2></div><a class="link-primary" href="${pageContext.request.contextPath}/notifications">View all notices →</a></div><div class="event-grid"><% for (Document event : events) { %><article class="event-card"><span class="event-date"><%= event.getString("date") == null ? "SOON" : event.getString("date") %></span><h3><%= event.getString("title") == null ? "Campus notice" : event.getString("title") %></h3><p><%= event.getString("location") == null ? "Campus community" : event.getString("location") %></p><span class="badge text-bg-light"><%= event.getString("category") == null ? "Notice" : event.getString("category") %></span></article><% } %><% if (events.isEmpty()) { %><div class="empty">No campus notices have been published yet.</div><% } %></div></section>
</main></div><script>document.querySelectorAll('.sidebar a').forEach(a=>a.addEventListener('click',()=>document.querySelector('.sidebar').classList.remove('open')))</script></body></html>
