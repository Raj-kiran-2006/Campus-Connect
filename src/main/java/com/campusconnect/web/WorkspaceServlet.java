package com.campusconnect.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

public class WorkspaceServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String module = module(request);
        String pathInfo = request.getPathInfo() == null ? "" : request.getPathInfo().replaceFirst("^/", "");
        if ("marketplace".equals(module) && "orders".equals(pathInfo)) {
            request.setAttribute("orders", MySqlStore.collection("orders")
                    .find(SqlFilters.eq("sellerId", userId(request))).sort(new Document("createdAt", -1))
                    .into(new ArrayList<>()));
            request.getRequestDispatcher("/WEB-INF/views/orders.jsp").forward(request, response);
            return;
        }

        if ("marketplace".equals(module) && "detail".equals(pathInfo)) {
            showProduct(request, response);
            return;
        }
        if ("detail".equals(pathInfo)) {
            showDetail(request, response, module);
            return;
        }
        String collection = collection(module);
        List<Document> items = new ArrayList<>();
        String query = value(request, "q");
        String category = value(request, "category");
        MySqlStore.SqlFindIterable<Document> results = MySqlStore.collection(collection).find();
        if ("notifications".equals(module)) {
            results = MySqlStore.collection(collection).find(SqlFilters.or(
                    SqlFilters.eq("recipientId", userId(request)), SqlFilters.exists("recipientId", false)));
        }
        if ("activity".equals(module)) {
            results = MySqlStore.collection("activity").find();
        } else if ("note-requests".equals(module)) {
            results = MySqlStore.collection("note_requests").find();
        }
        if (!query.isBlank()) {
            Pattern pattern = Pattern.compile(Pattern.quote(query), Pattern.CASE_INSENSITIVE);
            results = results.filter(SqlFilters.or(
                    SqlFilters.regex("title", pattern), SqlFilters.regex("name", pattern),
                    SqlFilters.regex("description", pattern), SqlFilters.regex("tags", pattern)));
        }
        if (!category.isBlank()) results = results.filter(SqlFilters.eq("category", category));
        String statusFilter = value(request, "status");
        if (!statusFilter.isBlank()) results = results.filter(SqlFilters.eq("status", statusFilter));
        String subject = value(request, "subject");
        if (!subject.isBlank()) results = results.filter(SqlFilters.regex("subject", Pattern.quote(subject), "i"));
        if ("verified".equals(value(request, "author"))) {
            List<Object> ids = MySqlStore.collection("users").find(SqlFilters.eq("verified", true))
                    .map(d -> d.get("_id")).into(new ArrayList<>());
            results = results.filter(SqlFilters.in("authorId", ids));
        }
        String sort = value(request, "sort");
        Document sortOrder = "popular".equals(sort)
                ? new Document("score", -1).append("createdAt", -1)
                : new Document("createdAt", -1);
        results.sort(sortOrder).limit(100).into(items);
        enrichPeople(items);
        request.setAttribute("module", module);
        request.setAttribute("items", items);
        request.setAttribute("query", query);
        request.setAttribute("categoryFilter", category);
        request.setAttribute("currentUserId", userId(request));
        request.getRequestDispatcher("/WEB-INF/views/workspace.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String module = module(request);
        Document user = (Document) request.getSession(false).getAttribute("user");
        if ("marketplace".equals(module) && "order".equals(request.getParameter("action"))) {
            placeOrder(request, response, user);
            return;
        }
        if ("questions".equals(module) && "answer".equals(request.getParameter("action"))) {
            addAnswer(request, response, user);
            return;
        }
        if ("delete".equals(value(request, "action"))) {
            deleteOwned(request, response, user, module);
            return;
        }
        if ("deleteAnswer".equals(value(request, "action"))) {
            deleteChild(request, response, user, "answers", "authorId", "questionId", "questions");
            return;
        }
        if ("deleteComment".equals(value(request, "action"))) {
            deleteChild(request, response, user, "note_comments", "authorId", "noteId", "notes");
            return;
        }
        if ("activity".equals(module)) {
            if ("comment".equals(value(request, "action"))) {
                addActivityComment(request, response, user);
                return;
            }
            createFeedback(request, response, user);
            return;
        }
        if ("assignments".equals(module)) {
            String action = value(request, "action");
            if ("message".equals(action)) { supportMessage(request, response, user); return; }
            if ("status".equals(action)) { updateAssignmentStatus(request, response, user); return; }
        }
        if ("teaching-offers".equals(module)) {
            // Teaching offers are intentionally standalone: they are free peer-to-peer
            // offers, not paid assignments and cannot be edited by another user.
        }
        if ("notes".equals(module)) {
            String action = value(request, "action");
            if ("comment".equals(action)) { noteComment(request, response, user); return; }
            if ("version".equals(action)) { noteVersion(request, response, user); return; }
        }
        if ("note-requests".equals(module)) {
            if ("fulfill".equals(value(request, "action"))) {
                fulfillNoteRequest(request, response, user);
                return;
            }
            createNoteRequest(request, response, user); return;
        }
        if ("projects".equals(module)) {
            String action = value(request, "action");
            if ("apply".equals(action)) { applyToProject(request, response, user); return; }
            if ("approve".equals(action) || "reject".equals(action)) {
                updateProjectApplication(request, response, user, "approve".equals(action));
                return;
            }
            if ("notifications".equals(module)) {
                String eventType = valueOr(request, "eventType", "NOTICE");
                if (!Set.of("NOTICE", "EVENT").contains(eventType)) eventType = "NOTICE";
            }
            if ("comment".equals(action)) { addProjectComment(request, response, user, "DISCUSSION"); return; }
            if ("mentor".equals(action)) { addProjectComment(request, response, user, "MENTOR_REQUEST"); return; }
        }
        String title = value(request, "title");
        String description = value(request, "description");
        String projectName = value(request, "projectName");
        int score = (int) number(request, "score");
        if (title.isBlank() || description.isBlank() || title.length() > 140 || description.length() > 5000) {
            response.sendRedirect(request.getContextPath() + "/" + module + "?error=required");
            return;
        }

        Document item = new Document("title", title)
                .append("name", title)
                .append("description", description)
                .append("category", value(request, "category"))
                .append("subject", value(request, "subject"))
                .append("tags", value(request, "tags"))
                .append("price", number(request, "price"))
                .append("status", status(module))
                .append("createdAt", Instant.now().toString())
                .append("ownerId", user.getObjectId("_id"))
                .append("authorId", user.getObjectId("_id"));
        if ("notifications".equals(module)) {
            String eventType = valueOr(request, "eventType", "NOTICE");
            if (!Set.of("NOTICE", "EVENT").contains(eventType)) eventType = "NOTICE";
            item.append("eventType", eventType).append("startsAt", value(request, "startsAt"))
                    .append("location", value(request, "location"));
        }
        if ("assignments".equals(module)) {
            String deadline = value(request, "deadline");
            if (deadline.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/" + module + "?error=assignment");
                return;
            }
            item.append("deadline", deadline)
                    .append("amount", 0)
                    .append("currency", "INR")
                    .append("supportMode", "PEER_EXCHANGE")
                    .append("impactPoints", 10)
                    .append("status", "OPEN");
        }

        if ("notes".equals(module)) {
            item.append("resourceType", valueOr(request, "resourceType", "LINK"))
                    .append("resourceUrl", value(request, "resourceUrl"));
        }
        if ("projects".equals(module)) {
            item.append("skills", value(request, "skills"))
                    .append("tags", value(request, "tags"))
                    .append("milestone", value(request, "milestone"))
                    .append("collaborationType", valueOr(request, "collaborationType", "TEAM_PROJECT"))
                    .append("mentorNeeded", "on".equals(request.getParameter("mentorNeeded")))
                    .append("memberCount", 1);
            String github = value(request, "githubUrl");
            if (!github.isBlank() && !github.matches("https://github\\.com/[A-Za-z0-9_.-]+(?:/[^\\s]*)?")) {
                response.sendRedirect(request.getContextPath() + "/projects?error=github");
                return;
            }
            item.append("githubUrl", github);
        }
        if ("teaching-offers".equals(module)) {
            String skills = value(request, "skills");
            if (skills.isBlank() || skills.length() > 500) {
                response.sendRedirect(request.getContextPath() + "/teaching-offers?error=required");
                return;
            }
            item.append("skills", skills).append("format", value(request, "format"))
                    .append("schedule", value(request, "schedule"))
                    .append("free", true).append("status", "AVAILABLE");
        }
        if ("marketplace".equals(module)) {
            double price = number(request, "price");
            if (price < 0 || price > 1_000_000) {
                response.sendRedirect(request.getContextPath() + "/" + module + "?error=price");
                return;
            }
            item.append("sellerId", user.getObjectId("_id"))
                    .append("author", value(request, "author"))
                    .append("edition", value(request, "edition"))
                    .append("condition", value(request, "condition"))
                    .append("listingType", valueOr(request, "listingType", "BOOK_SELL"))
                    .append("imageUrl", value(request, "imageUrl"))
                    .append("sold", false);
        }
        MySqlStore.collection(collection(module)).insertOne(item);
        if ("notes".equals(module)) {
            broadcastNotification(user, "NOTE_CREATED", user.getString("name") + " shared a new note: " + title,
                    "/notes/detail?id=" + item.getObjectId("_id"));
        }
        logActivity(user, "CREATED", module, item);
        response.sendRedirect(request.getContextPath() + "/" + module + "?created=true");
    }

    private void createFeedback(HttpServletRequest request, HttpServletResponse response, Document user)
            throws IOException {
        String title = value(request, "title");
        String description = value(request, "description");
        String targetType = valueOr(request, "targetType", "PROJECT");
        String github = value(request, "githubUrl");
        String projectName = value(request, "projectName");
        int score = (int) number(request, "score");
        if (title.isBlank() || description.isBlank() || ("PROJECT".equals(targetType) && projectName.isBlank())
                || score < 1 || score > 5
                || !Set.of("PROJECT", "ASSIGNMENT").contains(targetType)
                || title.length() > 140 || description.length() > 5000) {
            response.sendRedirect(request.getContextPath() + "/activity?error=required");
            return;
        }
        if (!github.isBlank() && !github.matches("https://github\\.com/[A-Za-z0-9_.-]+(?:/[^\\s]*)?")) {
            response.sendRedirect(request.getContextPath() + "/activity?error=github");
            return;
        }
        Document feedback = new Document("title", title).append("name", title)
                .append("description", description).append("category", targetType)
                .append("targetType", targetType).append("action", "FEEDBACK")
                .append("projectName", projectName)
                .append("githubUrl", github).append("score", score).append("actorId", user.getObjectId("_id"))
                .append("actorName", user.getString("name")).append("createdAt", Instant.now().toString());
        MySqlStore.collection("activity").insertOne(feedback);
        response.sendRedirect(request.getContextPath() + "/activity?created=true");
    }

    private void addActivityComment(HttpServletRequest request, HttpServletResponse response, Document user)
            throws IOException {
        String activityId = value(request, "id");
        String detail = request.getContextPath() + "/activity/detail?id=" + activityId;
        Document activity = findById("activity", activityId);
        String body = value(request, "body");
        if (activity == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Activity not found");
            return;
        }
        if (body.isBlank() || body.length() > 2000) {
            response.sendRedirect(detail + "&error=comment");
            return;
        }
        MySqlStore.collection("activity_comments").insertOne(new Document("activityId", activity.get("_id"))
                .append("authorId", user.getObjectId("_id"))
                .append("authorName", user.getString("name"))
                .append("body", body)
                .append("createdAt", Instant.now().toString()));
        response.sendRedirect(detail + "&commented=true");
    }

    private void deleteOwned(HttpServletRequest req, HttpServletResponse resp, Document user, String module)
            throws IOException {
        String id = value(req, "id");
        String collection = collection(module);
        Document item = findById(collection, id);
        Object owner = item == null ? null : (item.get("ownerId") != null ? item.get("ownerId") : item.get("authorId"));
        if (item == null || !sameId(owner, user.getObjectId("_id"))) { resp.sendError(403); return; }
        MySqlStore.collection(collection).deleteOne(SqlFilters.eq("_id", item.get("_id")));
        resp.sendRedirect(req.getContextPath() + "/" + module + "?deleted=true");
    }

    private void deleteChild(HttpServletRequest req, HttpServletResponse resp, Document user,
            String collection, String ownerField, String parentField, String parentModule) throws IOException {
        Document child = findById(collection, value(req, "id"));
        if (child == null || !sameId(child.get(ownerField), user.getObjectId("_id"))) {
            resp.sendError(403); return;
        }
        MySqlStore.collection(collection).deleteOne(SqlFilters.eq("_id", child.get("_id")));
        resp.sendRedirect(req.getContextPath() + "/" + parentModule + "/detail?id=" + idText(child.get(parentField)));
    }

    private void supportMessage(HttpServletRequest req, HttpServletResponse resp, Document user) throws IOException {
        Document assignment = findById("assignments", value(req, "id"));
        String body = value(req, "body");
        String detail = req.getContextPath() + "/assignments/detail?id=" + value(req, "id");
        if (assignment == null || body.isBlank() || body.length() > 2000) {
            resp.sendRedirect(detail + "&error=message"); return;
        }
        Object uid = user.getObjectId("_id");
        MySqlStore.collection("support_messages").insertOne(new Document("assignmentId", assignment.get("_id"))
                .append("senderId", uid).append("senderName", user.getString("name"))
                .append("body", body).append("createdAt", Instant.now().toString()));
        broadcastNotification(user, "SUPPORT_MESSAGE", user.getString("name") + " sent a peer-support message",
                "/assignments/detail?id=" + idText(assignment.get("_id")));
        resp.sendRedirect(detail+"&message=true");
    }

    private void updateAssignmentStatus(HttpServletRequest req,HttpServletResponse resp,Document user)throws IOException{
        Document a=findById("assignments",value(req,"id")); String status=value(req,"status");
        if(a==null||!sameId(a.get("ownerId"),user.getObjectId("_id"))||!Set.of("OPEN","ASSIGNED","IN_PROGRESS","COMPLETED","CANCELLED").contains(status)){resp.sendError(403);return;}
        MySqlStore.collection("assignments").updateOne(SqlFilters.eq("_id",a.get("_id")),new Document("$set",new Document("status",status)));
        resp.sendRedirect(req.getContextPath()+"/assignments/detail?id="+value(req,"id"));
    }

    private void noteComment(HttpServletRequest req,HttpServletResponse resp,Document user)throws IOException{
        Document n=findById("notes",value(req,"id")); String body=value(req,"body"); String d=req.getContextPath()+"/notes/detail?id="+value(req,"id");
        if(n==null||body.isBlank()||body.length()>2000){resp.sendRedirect(d+"&error=comment");return;}
        MySqlStore.collection("note_comments").insertOne(new Document("noteId",n.get("_id")).append("authorId",user.getObjectId("_id")).append("authorName",user.getString("name")).append("body",body).append("createdAt",Instant.now().toString()));
        resp.sendRedirect(d+"&commented=true");
    }

    private void noteVersion(HttpServletRequest req,HttpServletResponse resp,Document user)throws IOException{
        Document n=findById("notes",value(req,"id")); String body=value(req,"description"); String d=req.getContextPath()+"/notes/detail?id="+value(req,"id");
        if(n==null||!sameId(n.get("ownerId"),user.getObjectId("_id"))||body.isBlank()){resp.sendRedirect(d+"&error=version");return;}
        int version=n.getInteger("version",1)+1;
        MySqlStore.collection("note_versions").insertOne(new Document("noteId",n.get("_id")).append("version",version).append("description",body).append("resourceUrl",value(req,"resourceUrl")).append("editorId",user.getObjectId("_id")).append("createdAt",Instant.now().toString()));
        MySqlStore.collection("notes").updateOne(SqlFilters.eq("_id",n.get("_id")),new Document("$set",new Document("description",body).append("resourceUrl",value(req,"resourceUrl")).append("version",version).append("updatedAt",Instant.now().toString())));
        resp.sendRedirect(d+"&versioned=true");
    }

    private void createNoteRequest(HttpServletRequest req,HttpServletResponse resp,Document user)throws IOException{
        String title=value(req,"title"), desc=value(req,"description"); if(title.isBlank()||desc.isBlank()){resp.sendRedirect(req.getContextPath()+"/note-requests?error=required");return;}
        MySqlStore.collection("note_requests").insertOne(new Document("title",title).append("description",desc).append("subject",value(req,"subject")).append("status","OPEN").append("requesterId",user.getObjectId("_id")).append("requesterName",user.getString("name")).append("createdAt",Instant.now().toString()));
        resp.sendRedirect(req.getContextPath()+"/note-requests?created=true");
    }

    private void fulfillNoteRequest(HttpServletRequest req, HttpServletResponse resp, Document user)
            throws IOException {
        Document request = findById("note_requests", value(req, "id"));
        String url = value(req, "resourceUrl");
        if (request == null || url.isBlank() || !url.matches("https?://\\S+")) {
            resp.sendRedirect(req.getContextPath() + "/note-requests?error=fulfill");
            return;
        }
        Document note = new Document("title", request.getString("title"))
                .append("name", request.getString("title"))
                .append("description", valueOr(req, "description", request.getString("description")))
                .append("subject", request.getString("subject"))
                .append("category", request.getString("subject"))
                .append("resourceType", valueOr(req, "resourceType", "LINK"))
                .append("resourceUrl", url).append("status", "ACTIVE")
                .append("ownerId", user.getObjectId("_id")).append("authorId", user.getObjectId("_id"))
                .append("createdAt", Instant.now().toString());
        MySqlStore.collection("notes").insertOne(note);
        broadcastNotification(user, "NOTE_CREATED", user.getString("name") + " fulfilled a note request",
                "/notes/detail?id=" + note.getObjectId("_id"));
        MySqlStore.collection("note_requests").updateOne(SqlFilters.eq("_id", request.get("_id")),
                new Document("$set", new Document("status", "FULFILLED")
                        .append("fulfilledBy", user.getObjectId("_id"))
                        .append("fulfilledNoteId", note.get("_id"))
                        .append("fulfilledAt", Instant.now().toString())));
        resp.sendRedirect(req.getContextPath() + "/note-requests?fulfilled=true");
    }

    private void logActivity(Document user,String action,String module,Document item){
        MySqlStore.collection("activity").insertOne(new Document("action",action).append("module",module).append("title",item.getString("title")).append("actorId",user.getObjectId("_id")).append("actorName",user.getString("name")).append("createdAt",Instant.now().toString()));
    }

    private void broadcastNotification(Document actor, String type, String message, String link) {
        List<Document> notices = new ArrayList<>();
        MySqlStore.collection("users").find().projection(new Document("_id", 1)).into(notices);
        List<Document> notifications = new ArrayList<>();
        for (Document recipient : notices) {
            notifications.add(new Document("recipientId", recipient.get("_id"))
                    .append("actorId", actor.getObjectId("_id")).append("actorName", actor.getString("name"))
                    .append("type", type).append("title", message).append("description", message)
                    .append("link", link).append("read", false).append("createdAt", Instant.now().toString()));
        }
        if (!notifications.isEmpty()) MySqlStore.collection("notifications").insertMany(notifications);
    }

    private void enrichPeople(List<Document> items) {
        for (Document item : items) {
            Object owner = item.get("ownerId") != null ? item.get("ownerId") : item.get("authorId");
            if (owner == null) continue;
            Document person = MySqlStore.collection("users").find(SqlFilters.eq("_id", owner)).first();
            if (person != null) {
                item.put("ownerName", person.getString("name"));
                item.put("ownerVerified", person.getBoolean("verified", false));
                item.put("ownerAvailability", person.getString("availability"));
            }
        }
    }

    private void showProduct(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Document product = findProduct(request.getParameter("id"));
        if (product == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Listing not found");
            return;
        }

        request.setAttribute("product", product);
        request.getRequestDispatcher("/WEB-INF/views/product.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response, String module)
            throws ServletException, IOException {
        Document item = findById(collection(module), request.getParameter("id"));
        if (item == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Contribution not found");
            return;
        }
        request.setAttribute("module", module);
        request.setAttribute("item", item);
        enrichPeople(List.of(item));
        if ("activity".equals(module)) {
            request.setAttribute("activityComments", MySqlStore.collection("activity_comments")
                    .find(SqlFilters.eq("activityId", item.get("_id")))
                    .sort(new Document("createdAt", 1)).into(new ArrayList<>()));
            request.getRequestDispatcher("/WEB-INF/views/activity-detail.jsp").forward(request, response);
            return;
        }
        if (Set.of("notes", "teaching-offers", "note-requests").contains(module)) {
            request.getRequestDispatcher("/WEB-INF/views/contribution-detail.jsp").forward(request, response);
            return;
        }
        if ("questions".equals(module)) {
            List<Document> answers = MySqlStore.collection("answers")
                    .find(SqlFilters.eq("questionId", item.get("_id")))
                    .sort(new Document("createdAt", 1)).into(new ArrayList<>());
            request.setAttribute("answers", answers);
        }
        if ("projects".equals(module)) {
            List<Document> comments = MySqlStore.collection("project_comments")
                    .find(SqlFilters.eq("projectId", item.get("_id")))
                    .sort(new Document("createdAt", 1)).into(new ArrayList<>());
            List<Document> members = MySqlStore.collection("project_members")
                    .find(SqlFilters.eq("projectId", item.get("_id")))
                    .sort(new Document("createdAt", 1)).into(new ArrayList<>());
            request.setAttribute("projectComments", comments);
            request.setAttribute("projectMembers", members);
            request.setAttribute("projectMembership", MySqlStore.collection("project_members")
                    .find(SqlFilters.and(SqlFilters.eq("projectId", item.get("_id")),
                            SqlFilters.eq("userId", userId(request)))).first());
            Object currentUserId = userId(request);
            request.setAttribute("projectOwner", currentUserId instanceof ObjectId
                    && sameId(item.get("ownerId"), (ObjectId) currentUserId));
        }
        if ("assignments".equals(module)) {
            Object currentUserId = userId(request);
            request.setAttribute("assignmentOwner", currentUserId instanceof ObjectId
                    && sameId(item.get("ownerId"), (ObjectId) currentUserId));
            request.setAttribute("supportMessages", MySqlStore.collection("support_messages")
                    .find(SqlFilters.eq("assignmentId", item.get("_id"))).sort(new Document("createdAt", 1))
                    .into(new ArrayList<>()));
            request.getRequestDispatcher("/WEB-INF/views/peer-support-detail.jsp").forward(request, response);
            return;
        }
        if ("notes".equals(module)) {
            request.setAttribute("noteVersions", MySqlStore.collection("note_versions")
                    .find(SqlFilters.eq("noteId", item.get("_id"))).sort(new Document("version", -1))
                    .into(new ArrayList<>()));
            request.setAttribute("noteComments", MySqlStore.collection("note_comments")
                    .find(SqlFilters.eq("noteId", item.get("_id"))).sort(new Document("createdAt", 1))
                    .into(new ArrayList<>()));
        }
        request.getRequestDispatcher("/WEB-INF/views/detail.jsp").forward(request, response);
    }

    private void applyToProject(HttpServletRequest request, HttpServletResponse response, Document user)
            throws IOException {
        Document project = findById("projects", value(request, "id"));
        String detail = request.getContextPath() + "/projects/detail?id=" + value(request, "id");
        if (project == null) { response.sendError(404, "Project not found"); return; }
        Object userId = user.getObjectId("_id");
        if (sameId(project.get("ownerId"), user.getObjectId("_id"))) {
            response.sendRedirect(detail + "&error=owner"); return;
        }
        MySqlStore.SqlUpdateResult result = MySqlStore.collection("project_members").updateOne(
                SqlFilters.and(SqlFilters.eq("projectId", project.get("_id")), SqlFilters.eq("userId", userId)),
                new Document("$setOnInsert", new Document("projectId", project.get("_id"))
                        .append("userId", userId).append("userName", user.getString("name"))
                        .append("status", "PENDING").append("createdAt", Instant.now().toString())),
                true);
        response.sendRedirect(detail + (result.getUpsertedId() == null ? "&error=applied" : "&applied=true"));
    }

    private void updateProjectApplication(HttpServletRequest request, HttpServletResponse response,
            Document user, boolean approve) throws IOException {
        String projectId = value(request, "id");
        Document project = findById("projects", projectId);
        String detail = request.getContextPath() + "/projects/detail?id=" + projectId;
        if (project == null) { response.sendError(404, "Project not found"); return; }
        if (!sameId(project.get("ownerId"), user.getObjectId("_id"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only the project owner can manage applications");
            return;
        }
        Object memberId = memberId(value(request, "memberId"));
        if (memberId == null) { response.sendRedirect(detail + "&error=application"); return; }
        MySqlStore.SqlUpdateResult updated = MySqlStore.collection("project_members").updateOne(
                SqlFilters.and(SqlFilters.eq("_id", memberId), SqlFilters.eq("projectId", project.get("_id")),
                        SqlFilters.eq("status", "PENDING")),
                new Document("$set", new Document("status", approve ? "ACTIVE" : "REJECTED")
                        .append("reviewedAt", Instant.now().toString())
                        .append("reviewedBy", user.getObjectId("_id"))));
        if (updated.getModifiedCount() == 1) {
            long activeCount = MySqlStore.collection("project_members").countDocuments(
                    SqlFilters.and(SqlFilters.eq("projectId", project.get("_id")), SqlFilters.eq("status", "ACTIVE")));
            MySqlStore.collection("projects").updateOne(SqlFilters.eq("_id", project.get("_id")),
                    new Document("$set", new Document("memberCount", activeCount + 1)));
        }
        response.sendRedirect(detail + (approve ? "&approved=true" : "&rejected=true"));
    }

    private Object memberId(String value) {
        if (value == null || value.isBlank()) return null;
        try { return new ObjectId(value); } catch (IllegalArgumentException ex) { return value; }
    }

    private void addProjectComment(HttpServletRequest request, HttpServletResponse response, Document user, String type)
            throws IOException {
        Document project = findById("projects", value(request, "id"));
        String body = value(request, "body");
        String detail = request.getContextPath() + "/projects/detail?id=" + value(request, "id");
        if (project == null) { response.sendError(404, "Project not found"); return; }
        if (body.isBlank() || body.length() > 5000) {
            response.sendRedirect(detail + "&error=comment"); return;
        }
        MySqlStore.collection("project_comments").insertOne(new Document("projectId", project.get("_id"))
                .append("authorId", user.getObjectId("_id")).append("authorName", user.getString("name"))
                .append("type", type).append("body", body).append("createdAt", Instant.now().toString()));
        response.sendRedirect(detail + ("MENTOR_REQUEST".equals(type) ? "&requested=true" : "&commented=true"));
    }

    private void addAnswer(HttpServletRequest request, HttpServletResponse response, Document user)
            throws IOException {
        Document question = findById("questions", request.getParameter("id"));
        String answer = value(request, "answer");
        if (question == null || answer.isBlank() || answer.length() > 5000) {
            response.sendRedirect(request.getContextPath() + "/questions/detail?id=" + value(request, "id") + "&error=answer");
            return;
        }
        MySqlStore.collection("answers").insertOne(new Document("questionId", question.get("_id"))
                .append("body", answer)
                .append("authorId", user.getObjectId("_id"))
                .append("authorName", user.getString("name"))
                .append("createdAt", Instant.now().toString()));
        response.sendRedirect(request.getContextPath() + "/questions/detail?id=" + idText(question.get("_id")) + "&answered=true");
    }

    private Document findById(String collection, String id) {
        if (id == null || id.isBlank()) return null;
        try {
            Document result = MySqlStore.collection(collection).find(SqlFilters.eq("_id", new ObjectId(id))).first();
            return result == null ? MySqlStore.collection(collection).find(SqlFilters.eq("_id", id)).first() : result;
        } catch (IllegalArgumentException ex) {
            return MySqlStore.collection(collection).find(SqlFilters.eq("_id", id)).first();
        }
    }

    private void placeOrder(HttpServletRequest request, HttpServletResponse response, Document user)
            throws IOException {
        Document product = findProduct(request.getParameter("id"));
        if (product == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Listing not found");
            return;
        }
        Object productId = product.get("_id");
        Object sellerId = product.get("sellerId");
        String detailUrl = request.getContextPath() + "/marketplace/detail?id=" + idText(productId);
        if (sameId(sellerId, user.getObjectId("_id"))) {
            response.sendRedirect(detailUrl + "&error=own");
            return;
        }
        if (Boolean.TRUE.equals(product.getBoolean("sold", false))) {
            response.sendRedirect(detailUrl + "&error=sold");
            return;
        }
        if (product.get("buyerId") != null) {
            response.sendRedirect(detailUrl + "&error=reserved");
            return;
        }
        ObjectId orderId = new ObjectId();
        Document order = new Document("_id", orderId)
                .append("productId", productId)
                .append("buyerId", user.getObjectId("_id"))
                .append("sellerId", sellerId)
                .append("amount", product.get("price", 0))
                .append("paymentMethod", valueOr(request, "paymentMethod", "UPI"))
                .append("paymentReference", value(request, "paymentReference"))
                .append("status", "DIRECT_PAYMENT_PENDING")
                .append("createdAt", Instant.now().toString());
        MySqlStore.SqlUpdateResult reservation = MySqlStore.collection("products").updateOne(
                SqlFilters.and(SqlFilters.eq("_id", productId),
                        SqlFilters.exists("buyerId", false),
                        SqlFilters.ne("sold", true)),
                new Document("$set", new Document("buyerId", user.getObjectId("_id"))
                        .append("orderId", orderId).append("paymentStatus", "DIRECT_PAYMENT_PENDING")));
        if (reservation.getModifiedCount() != 1) {
            response.sendRedirect(detailUrl + "&error=reserved");
            return;
        }
        MySqlStore.collection("orders").insertOne(order);
        response.sendRedirect(detailUrl + "&ordered=true");
    }

    private Document findProduct(String id) {
        try {
            if (id == null || id.isBlank()) return null;
            Document product = MySqlStore.collection("products")
                    .find(SqlFilters.eq("_id", new ObjectId(id))).first();
            return product == null
                    ? MySqlStore.collection("products").find(SqlFilters.eq("_id", id)).first()
                    : product;
        } catch (IllegalArgumentException ex) {
            return MySqlStore.collection("products").find(SqlFilters.eq("_id", id)).first();
        }
    }

    private String idText(Object value) {
        return value instanceof ObjectId ? ((ObjectId) value).toHexString() : String.valueOf(value);
    }

    private boolean sameId(Object left, ObjectId right) {
        return left != null && right != null && right.toHexString().equals(left instanceof ObjectId
                ? ((ObjectId) left).toHexString() : left.toString());
    }

    private Object userId(HttpServletRequest request) {
        Document user = (Document) request.getSession(false).getAttribute("user");
        return user == null ? null : user.getObjectId("_id");
    }

    private String module(HttpServletRequest request) {
        String path = request.getServletPath();
        return path == null || path.length() < 2 ? "dashboard" : path.substring(1).split("/")[0];
    }

    private String collection(String module) {
        return switch (module) {
            case "marketplace" -> "products";
            case "notes" -> "notes";
            case "questions" -> "questions";
            case "assignments" -> "assignments";
            case "projects" -> "projects";
            case "notifications" -> "notifications";
            case "activity" -> "activity";
            case "note-requests" -> "note_requests";
            case "teaching-offers" -> "teaching_offers";
            default -> "projects";
        };
    }

    private String status(String module) {
        return switch (module) {
            case "questions" -> "OPEN";
            case "assignments" -> "OPEN";
            case "projects" -> "RECRUITING";
            case "teaching-offers" -> "ACTIVE";
            default -> "ACTIVE";
        };
    }

    private String value(HttpServletRequest request, String name) {
        return valueOr(request, name, "");
    }

    private String valueOr(HttpServletRequest request, String name, String fallback) {
        String value = request.getParameter(name);
        return value == null ? fallback : value.trim();
    }

    private double number(HttpServletRequest request, String name) {
        try {
            return Double.parseDouble(value(request, name).isBlank() ? "0" : value(request, name));
        } catch (NumberFormatException ex) {
            return 0;
        }
    }
}
