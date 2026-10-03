<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.campusconnect.web.Document,java.util.List,java.util.Collections" %>
<%!
private String safe(Object value) {
    if (value == null) return "";
    return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
}
private List<String> listValue(Document user, String field) {
    Object value = user.get(field);
    if (value instanceof List<?>) {
        java.util.ArrayList<String> result = new java.util.ArrayList<>();
        for (Object item : (List<?>) value) if (item != null) result.add(String.valueOf(item));
        return result;
    }
    if (value == null || String.valueOf(value).isBlank()) return Collections.emptyList();
    return java.util.List.of(String.valueOf(value));
}
private String joined(List<String> values) {
    return String.join(", ", values);
}
%>
<%
Document user = (Document) session.getAttribute("user");
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/auth?action=login");
    return;
}
String displayName = user.getString("name");
if (displayName == null || displayName.isBlank()) displayName = "Student";
String avatar = user.getString("avatar");
List<String> skills = listValue(user, "skills");
List<String> interests = listValue(user, "interests");
String initial = displayName.substring(0, 1).toUpperCase(java.util.Locale.ROOT);
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Profile · Campus Connect</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/campus.css" rel="stylesheet">
</head>
<body>
<% request.setAttribute("activeModule", "profile"); %>
<%@ include file="_app-nav.jsp" %>
<div class="layout">
    <main class="content profile-page">
        <div class="page-head">
            <p class="eyebrow">ACCOUNT CENTER</p>
            <h1>Your profile</h1>
            <p class="text-secondary">Control how your campus community sees and works with you.</p>
        </div>
        <% if ("true".equals(request.getParameter("saved"))) { %>
            <div class="alert alert-success">Profile updated successfully.</div>
        <% } else if ("password".equals(request.getParameter("saved"))) { %>
            <div class="alert alert-success">Password changed successfully.</div>
        <% } else if ("image".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">Choose a valid PNG, JPEG, or WebP image smaller than 2 MB.</div>
        <% } else if ("password".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">Password change failed. Check your current password and confirmation.</div>
        <% } %>
        <div class="profile-layout">
            <section class="panel profile-main">
                <div class="profile-hero mb-4">
                    <% if (avatar != null && !avatar.isBlank()) { %>
                        <img id="avatarPreview" class="avatar large avatar-photo" src="<%= safe(avatar) %>" alt="Profile photo">
                    <% } else { %>
                        <div id="avatarPreview" class="avatar large"><%= safe(initial) %></div>
                    <% } %>
                    <div>
                        <h2><%= safe(displayName) %></h2>
                        <p class="text-secondary"><%= safe(user.getString("email")) %></p>
                        <label class="photo-picker">Upload profile photo
                            <input id="photo" type="file" accept="image/png,image/jpeg,image/webp">
                        </label>
                    </div>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/profile">
                    <input type="hidden" name="avatar" id="avatarForm">
                    <label>Full name
                        <input class="form-control" name="name" required value="<%= safe(displayName) %>">
                    </label>
                    <label>Department
                        <input class="form-control" name="course" required value="<%= safe(user.getString("course")) %>">
                    </label>
                    <label>Year
                        <input class="form-control" name="year" required value="<%= safe(user.getString("year")) %>">
                    </label>
                    <label>Skills <small class="text-secondary">comma separated</small>
                        <input class="form-control" name="skills" value="<%= safe(joined(skills)) %>" placeholder="Java, UI design, Public speaking">
                    </label>
                    <label>Interests <small class="text-secondary">comma separated</small>
                        <input class="form-control" name="interests" value="<%= safe(joined(interests)) %>" placeholder="Robotics, Events, Startups">
                    </label>
                    <label>Availability
                        <input class="form-control" name="availability" value="<%= safe(user.getString("availability")) %>" placeholder="Weekday evenings">
                    </label>
                    <label>GitHub profile
                        <input class="form-control" type="url" name="githubUrl" pattern="https://github.com/[A-Za-z0-9_.-]+/?" value="<%= safe(user.getString("githubUrl")) %>" placeholder="https://github.com/your-handle">
                        <small class="text-secondary">Use your public GitHub profile URL.</small>
                    </label>
                    <label class="form-check mb-3"><input class="form-check-input" type="checkbox" name="availableForPeerSupport" <%= Boolean.TRUE.equals(user.getBoolean("availableForPeerSupport")) ? "checked" : "" %>> <span class="form-check-label">Available for peer support</span></label>
                    <label>Bio
                        <textarea class="form-control" name="bio" rows="4" maxlength="1000" placeholder="Tell peers what you enjoy building"><%= safe(user.getString("bio")) %></textarea>
                    </label>
                    <button class="btn btn-primary" type="submit">Save profile</button>
                </form>
            </section>
            <aside class="profile-side-stack">
                <section class="panel profile-tags">
                    <span class="eyebrow">COLLABORATION PROFILE</span>
                    <h3>What you bring</h3>
                    <div class="tag-list">
                        <% for (String skill : skills) { %><span><%= safe(skill) %></span><% } %>
                        <% if (skills.isEmpty()) { %><small class="text-secondary">Add skills to help classmates find you.</small><% } %>
                    </div>
                    <p class="eyebrow mt-3">INTERESTS</p>
                    <div class="tag-list interest-tags">
                        <% for (String interest : interests) { %><span><%= safe(interest) %></span><% } %>
                        <% if (interests.isEmpty()) { %><small class="text-secondary">Add interests to discover relevant projects.</small><% } %>
                    </div>
                </section>
                <section class="panel">
                    <span class="eyebrow">SECURITY</span>
                    <h3>Change password</h3>
                    <form method="post" action="${pageContext.request.contextPath}/profile">
                        <input type="hidden" name="action" value="password">
                        <label>Current password<input class="form-control" type="password" name="currentPassword" required></label>
                        <label>New password<input class="form-control" type="password" name="newPassword" minlength="8" required></label>
                        <label>Confirm password<input class="form-control" type="password" name="confirmPassword" minlength="8" required></label>
                        <button class="btn btn-dark w-100" type="submit">Update password</button>
                    </form>
                </section>
                <section class="panel">
                    <span class="eyebrow">CAMPUS IDENTITY</span>
                    <h3>Build trust</h3>
                    <p class="text-secondary">Add your department, interests, and a clear profile photo so peers know who they are working with.</p>
                    <div class="profile-status">● <%= user.getBoolean("verified", false) ? "Verified campus profile" : "Profile not verified" %></div>
                </section>
            </aside>
        </div>
    </main>
</div>
<script>
const photo = document.querySelector('#photo');
const preview = document.querySelector('#avatarPreview');
const avatar = document.querySelector('#avatarForm');
if (photo) {
    photo.addEventListener('change', () => {
        const file = photo.files[0];
        if (!file || file.size > 2097152) {
            alert('Choose an image smaller than 2 MB');
            photo.value = '';
            return;
        }
        const reader = new FileReader();
        reader.onload = () => {
            avatar.value = reader.result;
            preview.outerHTML = '<img id="avatarPreview" class="avatar large avatar-photo" src="' + reader.result + '" alt="Profile preview">';
        };
        reader.readAsDataURL(file);
    });
}
</script>
</body>
</html>
