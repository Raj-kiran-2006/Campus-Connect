<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Create account · Campus Connect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/campus.css" rel="stylesheet">
</head>
<body class="auth-page">
<main class="auth-card register-card">
    <section class="auth-brand">
        <span class="brand-mark">C</span>
        <p class="eyebrow">WELCOME TO CAMPUS CONNECT</p>
        <h1>Make your campus network useful.</h1>
        <p>Join classmates, mentors, project teams, and campus communities in one focused workspace.</p>
        <div class="feature-list">
            <span>● Learn from peers and seniors</span>
            <span>● Build projects with real collaborators</span>
            <span>● Share resources that move people forward</span>
        </div>
    </section>
    <section class="auth-form">
        <p class="eyebrow">SET UP YOUR PROFILE</p>
        <h2>Create your account</h2>
        <p class="text-secondary">Use your college identity so people can recognise and trust your contributions.</p>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>
        <form method="post" action="${pageContext.request.contextPath}/auth">
            <input type="hidden" name="action" value="register">
            <label class="form-label">Full name</label>
            <input class="form-control mb-3" name="name" placeholder="e.g. Ananya Sharma" required>
            <label class="form-label">College email</label>
            <input class="form-control mb-3" type="email" name="email" placeholder="you@college.edu" required>
            <div class="row g-3">
                <div class="col-md-8">
                    <label class="form-label">Department</label>
                    <input class="form-control" name="course" placeholder="Computer Science" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Year</label>
                    <select class="form-select" name="year" required>
                        <option value="">Select</option><option>1</option><option>2</option><option>3</option><option>4</option><option>Postgraduate</option>
                    </select>
                </div>
            </div>
            <label class="form-label mt-3">Password</label>
            <input class="form-control mb-3" type="password" name="password" minlength="8" placeholder="At least 8 characters" required>
            <label class="form-label">Confirm password</label>
            <input class="form-control mb-4" type="password" name="confirmPassword" minlength="8" placeholder="Re-enter your password" required>
            <button class="btn btn-primary w-100">Create account</button>
        </form>
        <hr>
        <p class="text-center small mb-0">Already have an account?
            <a href="${pageContext.request.contextPath}/auth?action=login">Sign in</a>
        </p>
    </section>
</main>
</body>
</html>
