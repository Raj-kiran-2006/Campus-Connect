<%@ page contentType="text/html;charset=UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Campus Connect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/campus.css" rel="stylesheet">
</head>
<body class="auth-page">
<main class="auth-card">
    <section class="auth-brand">
        <span class="brand-mark">C</span>
        <p class="eyebrow">STUDENT COLLABORATION PLATFORM</p>
        <h1>Build your campus network.</h1>
        <p>Find trusted peers, share knowledge, and make student life easier in one focused workspace.</p>
        <div class="feature-list"><span>● Peer learning</span><span>● Safe marketplace</span><span>● Project teams</span></div>
    </section>
    <section class="auth-form">
        <h2>Welcome back</h2><p class="text-secondary">Sign in to your campus workspace.</p>
        <% if (request.getAttribute("error") != null) { %><div class="alert alert-danger">${error}</div><% } %>
        <form method="post" action="${pageContext.request.contextPath}/auth">
            <input type="hidden" name="action" value="login">
            <label class="form-label">Email</label><input class="form-control mb-3" type="email" name="email" required>
            <label class="form-label">Password</label><input class="form-control mb-4" type="password" name="password" required>
            <button class="btn btn-primary w-100">Sign in</button>
        </form>
        <hr><p class="text-center small">New to Campus Connect? <a href="${pageContext.request.contextPath}/auth?action=register">Create a new account</a></p>
    </section>
</main>
</body></html>
