<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%!
    private String registerSafe(Object value) {
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
    <title>Create account · Campus Connect</title>
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
                <p class="cc-eyebrow">YOUR NEXT CHAPTER STARTS HERE</p>
                <h1 class="display-5 fw-semibold text-white mb-3">Your campus has more to offer.</h1>
                <p class="cc-aside-copy mb-4">Meet collaborators, get unstuck, exchange knowledge, and find the small opportunities that make student life better.</p>
                <div class="d-grid gap-3">
                    <div class="cc-value-row"><span>01</span><div><strong>Find a clearer answer</strong><small>Learn from notes, Q&amp;A, and peer support</small></div></div>
                    <div class="cc-value-row"><span>02</span><div><strong>Meet your next collaborators</strong><small>Bring different skills into one project</small></div></div>
                    <div class="cc-value-row"><span>03</span><div><strong>Share what already helps</strong><small>Make knowledge and useful items go further</small></div></div>
                </div>
            </div>
            <p class="cc-aside-foot mb-0">A student community built around useful connections.</p>
        </aside>
        <section class="col-lg-7 cc-auth-main p-4 p-md-5">
            <div class="cc-auth-form-wrap mx-auto">
                <div class="mb-4"><p class="cc-eyebrow text-primary mb-2">CREATE YOUR ACCOUNT</p><h2 class="display-6 fw-semibold mb-2">Join your campus.</h2><p class="text-secondary mb-0">A few details, then you’re in.</p></div>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger" role="alert"><%= registerSafe(request.getAttribute("error")) %></div>
                <% } %>
                <form method="post" action="${pageContext.request.contextPath}/auth" class="cc-form" id="register-form">
                    <input type="hidden" name="action" value="register">
                    <div class="mb-3">
                        <label class="form-label" for="register-name">Full name</label>
                        <input class="form-control" id="register-name" name="name" maxlength="100" autocomplete="name" placeholder="e.g. Ananya Sharma" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="register-email">Campus email</label>
                        <input class="form-control" id="register-email" type="email" name="email" maxlength="254" autocomplete="email" placeholder="you@college.edu" required>
                        <div class="form-text">We’ll send a one-time verification link before your first sign-in.</div>
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-sm-8">
                            <label class="form-label" for="register-course">Department or course</label>
                            <input class="form-control" id="register-course" name="course" maxlength="120" autocomplete="organization-title" placeholder="Computer Science" required>
                        </div>
                        <div class="col-sm-4">
                            <label class="form-label" for="register-year">Year</label>
                            <select class="form-select" id="register-year" name="year" required>
                                <option value="">Select</option><option>1</option><option>2</option><option>3</option><option>4</option><option>Postgraduate</option>
                            </select>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label" for="register-password">Create password</label>
                        <div class="input-group">
                            <input class="form-control" id="register-password" type="password" name="password" minlength="12" maxlength="72" autocomplete="new-password" placeholder="At least 12 characters" aria-describedby="password-guidance" required>
                            <button class="btn btn-outline-secondary cc-password-toggle" type="button" data-password-toggle="register-password" aria-label="Show password">Show</button>
                        </div>
                        <div class="cc-password-meter mt-2" aria-hidden="true"><span id="password-meter"></span></div>
                        <div class="form-text" id="password-guidance">Use at least 12 characters. Avoid a password you use elsewhere.</div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label" for="register-confirm">Confirm password</label>
                        <input class="form-control" id="register-confirm" type="password" name="confirmPassword" minlength="12" maxlength="72" autocomplete="new-password" placeholder="Enter it once more" required>
                        <div class="invalid-feedback">Passwords must match.</div>
                    </div>
                    <button class="btn btn-primary btn-lg w-100 cc-submit" type="submit">Create my account <span aria-hidden="true">→</span></button>
                </form>
                <p class="small text-secondary text-center mt-4 mb-0">Already part of the community? <a class="fw-semibold" href="${pageContext.request.contextPath}/auth?action=login">Sign in</a></p>
            </div>
        </section>
    </div>
</main>
<script>
const password = document.getElementById('register-password');
const confirmPassword = document.getElementById('register-confirm');
const meter = document.getElementById('password-meter');
function validatePasswordMatch() {
    const mismatch = confirmPassword.value.length > 0 && password.value !== confirmPassword.value;
    confirmPassword.setCustomValidity(mismatch ? 'Passwords must match.' : '');
    confirmPassword.classList.toggle('is-invalid', mismatch);
}
password.addEventListener('input', () => {
    const value = password.value;
    const score = Math.min(100, Math.round((Math.min(value.length, 16) / 16) * 65
        + (/[A-Z]/.test(value) ? 10 : 0) + (/[0-9]/.test(value) ? 10 : 0)
        + (/[^A-Za-z0-9]/.test(value) ? 15 : 0)));
    meter.style.width = score + '%';
    meter.dataset.strength = score < 40 ? 'low' : score < 70 ? 'medium' : 'high';
    validatePasswordMatch();
});
confirmPassword.addEventListener('input', validatePasswordMatch);
document.querySelectorAll('[data-password-toggle]').forEach(button => button.addEventListener('click', () => {
    const input = document.getElementById(button.dataset.passwordToggle);
    const reveal = input.type === 'password';
    input.type = reveal ? 'text' : 'password';
    button.textContent = reveal ? 'Hide' : 'Show';
    button.setAttribute('aria-label', reveal ? 'Hide password' : 'Show password');
}));
document.getElementById('register-form').addEventListener('submit', validatePasswordMatch);
</script>
</body>
</html>
