<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.campusconnect.web.Document" %>
<%
Document product = (Document) request.getAttribute("product");
String image = product.getString("imageUrl");
String title = product.getString("title");
if (title == null || title.isBlank()) title = product.getString("name");
boolean unavailable = product.getBoolean("sold", false) || product.get("buyerId") != null;
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title><%= title %> · Marketplace</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/assets/campus.css" rel="stylesheet">
</head>
<body class="module-marketplace"><% request.setAttribute("activeModule", "marketplace"); %><%@ include file="_app-nav.jsp" %><div class="layout">
<main class="content">
  <a class="back-link" href="${pageContext.request.contextPath}/marketplace">← Back to marketplace</a>
  <% if ("true".equals(request.getParameter("ordered"))) { %><div class="alert alert-success mt-3">Order created. Contact the seller using your selected payment method.</div><% } %>
  <% if ("sold".equals(request.getParameter("error")) || "reserved".equals(request.getParameter("error")) || unavailable) { %><div class="alert alert-warning mt-3">This listing is no longer available.</div><% } %>
  <% if ("own".equals(request.getParameter("error"))) { %><div class="alert alert-danger mt-3">You cannot order your own listing.</div><% } %>
  <section class="product-detail panel">
    <div class="product-gallery"><% if (image != null && !image.isBlank()) { %><img src="<%= image %>" alt="<%= title %>"><% } else { %><div class="product-placeholder">▣</div><% } %></div>
    <div class="product-copy">
      <span class="badge text-bg-light"><%= product.getString("category") == null ? "Academic item" : product.getString("category") %></span>
      <h1><%= title %></h1>
      <p class="lead"><%= product.getString("description") == null ? "A useful academic item shared by the campus community." : product.getString("description") %></p>
      <div class="product-price">₹<%= product.get("price", 0) %></div>
      <div class="product-facts"><span><b>Condition</b><%= product.getString("condition") == null ? "Not specified" : product.getString("condition") %></span><span><b>Author / edition</b><%= product.getString("author") == null ? "Community listing" : product.getString("author") %> · <%= product.getString("edition") == null ? "—" : product.getString("edition") %></span><span><b>Listing</b><%= product.getString("listingType") == null ? "Direct sale" : product.getString("listingType") %></span></div>
      <% if (!unavailable) { %><form method="post" action="${pageContext.request.contextPath}/marketplace"><input type="hidden" name="action" value="order"><input type="hidden" name="id" value="<%= product.get("_id") %>"><label>Direct payment method<select class="form-select" name="paymentMethod"><option>UPI</option><option>Cash on campus</option><option>Bank transfer</option></select></label><label>Payment reference / meeting note<input class="form-control" name="paymentReference" placeholder="Optional reference or pickup note"></label><button class="btn btn-primary btn-lg w-100">Place order · ₹<%= product.get("price", 0) %></button><small class="text-secondary d-block mt-2">Payment is handled directly with the seller. Campus Connect never stores card or bank credentials.</small></form><% } else { %><div class="unavailable-state">This listing has already been reserved or sold.</div><% } %>
    </div>
  </section>
</main></div>
</body>
</html>
