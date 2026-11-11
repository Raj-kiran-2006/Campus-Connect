<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%!
    private String authSafe(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="theme-color" content="#f4f3ef">
    <title>Sign in · Campus Connect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/premium-ui.css" rel="stylesheet">
</head>
<body class="cc-auth-page">
<main class="container py-4 py-lg-5">
    <div class="cc-auth-shell row g-0 overflow-hidden mx-auto">
        <aside class="col-lg-5 cc-auth-aside p-4 p-md-5 d-flex flex-column">
            <a class="cc-auth-brand text-decoration-none" href="${pageContext.request.contextPath}/auth?action=login">
                <span class="cc-brand-mark">C</span><span>Campus Connect<small>STUDENT COLLABORATION, REIMAGINED</small></span>
            </a>
            <div class="my-auto py-5">
                <p class="cc-eyebrow">YOUR CAMPUS, CLOSER</p>
                <h1 class="display-5 fw-semibold text-white mb-3">Good things happen when students connect.</h1>
                <p class="cc-aside-copy mb-4">One thoughtful place to learn from peers, find your people, and move ideas forward.</p>
                <div class="d-grid gap-3">
                    <div class="cc-value-row"><span>01</span><div><strong>Learn from each other</strong><small>Notes, answers, and peer support</small></div></div>
                    <div class="cc-value-row"><span>02</span><div><strong>Build with your community</strong><small>Projects, people, and shared skills</small></div></div>
                    <div class="cc-value-row"><span>03</span><div><strong>Make campus life easier</strong><small>A safer way to share useful things</small></div></div>
                </div>
            </div>
            <p class="cc-aside-foot mb-0">A more connected campus starts with you.</p>
        </aside>
        <section class="col-lg-7 cc-auth-main p-4 p-md-5">
            <div class="cc-auth-form-wrap mx-auto">
                <p class="cc-eyebrow text-primary mb-2">WELCOME BACK</p>
                <h2 class="display-6 fw-semibold mb-2">Sign in to your campus.</h2>
                <p class="text-secondary mb-4">Pick up where your community left off.</p>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger" role="alert"><%= authSafe(request.getAttribute("error")) %></div>
                <% } %>
                <% if (Boolean.TRUE.equals(request.getAttribute("verificationSuccess"))) { %>
                    <div class="alert alert-success" role="status">Your email is verified. Sign in to join your campus workspace.</div>
                <% } %>
                <% if ("sent".equals(request.getParameter("verification")) || "resent".equals(request.getParameter("verification"))) { %>
                    <div class="alert alert-success" role="status">If your account needs verification, a fresh link has been sent to your inbox.</div>
                <% } %>
                <% if ("setup".equals(request.getParameter("verification"))) { %>
                    <div class="alert alert-warning" role="status">Your account is saved, but email delivery is not configured yet. Ask your campus administrator to configure SMTP, then request a new verification email here.</div>
                <% } %>
                <% if (Boolean.TRUE.equals(request.getAttribute("showResend"))
                        || "sent".equals(request.getParameter("verification"))
                        || "resent".equals(request.getParameter("verification"))
                        || "setup".equals(request.getParameter("verification"))) { %>
                    <form method="post" action="${pageContext.request.contextPath}/auth" class="cc-verification-panel mb-4">
                        <input type="hidden" name="action" value="resendVerification">
                        <label class="form-label fw-semibold" for="resend-email">Campus email</label>
                        <div class="input-group">
                            <input class="form-control" id="resend-email" type="email" name="email" value="<%= authSafe(request.getAttribute("resendEmail")) %>" autocomplete="email" required>
                            <button class="btn btn-outline-primary" type="submit">Resend link</button>
                        </div>
                    </form>
                <% } %>
                <form method="post" action="${pageContext.request.contextPath}/auth" class="cc-form">
                    <input type="hidden" name="action" value="login">
                    <div class="mb-3">
                        <label class="form-label" for="login-email">Campus email</label>
                        <input class="form-control form-control-lg" id="login-email" type="email" name="email" autocomplete="email" placeholder="you@college.edu" required>
                    </div>
                    <div class="mb-4">
                        <label class="form-label" for="login-password">Password</label>
                        <div class="input-group input-group-lg">
                            <input class="form-control" id="login-password" type="password" name="password" autocomplete="current-password" placeholder="Enter your password" required>
                            <button class="btn btn-outline-secondary cc-password-toggle" type="button" data-password-toggle="login-password" aria-label="Show password">Show</button>
                        </div>
                    </div>
                    <button class="btn btn-primary btn-lg w-100 cc-submit" type="submit">Continue to your workspace <span aria-hidden="true">→</span></button>
                </form>
                <div class="cc-auth-divider"><span>NEW TO CAMPUS CONNECT?</span></div>
                <a class="btn btn-outline-dark btn-lg w-100" href="${pageContext.request.contextPath}/auth?action=register">Create your student account</a>
                <p class="small text-secondary text-center mt-4 mb-0">By continuing, you agree to keep your campus community respectful and safe.</p>
            </div>
        </section>
    </div>
</main>
<script>
document.querySelectorAll('[data-password-toggle]').forEach(button => button.addEventListener('click', () => {
    const input = document.getElementById(button.dataset.passwordToggle);
    const reveal = input.type === 'password';
    input.type = reveal ? 'text' : 'password';
    button.textContent = reveal ? 'Hide' : 'Show';
    button.setAttribute('aria-label', reveal ? 'Hide password' : 'Show password');
}));
</script>
</body>
</html>
