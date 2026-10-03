# Campus-Connect

Campus Connect is a student collaboration platform built with **Java 17,
Jakarta Servlets, JSP, Maven, Bootstrap, and MySQL**. The runtime is a
traditional Servlet application packaged as a WAR; Spring Boot is not used.

## Run with Tomcat

1. Install Java 17+, Maven, MySQL 8+, and Apache Tomcat 10.1+.
2. Build the WAR:

   ```powershell
   mvn -q clean package
   ```

3. Copy `target\campus-connect.war` into Tomcat's `webapps` directory.
4. Start Tomcat and open:
   `http://localhost:8080/campus-connect/`

The application reads:

* `MYSQL_URL` – JDBC URL, default
  `jdbc:mysql://localhost:3306/campus_connect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC`
* `MYSQL_USERNAME` – MySQL username, default `root`
* `MYSQL_PASSWORD` – MySQL password, default empty

## Application structure

* `src/main/java/com/campusconnect/web` contains the Servlet controllers,
  authentication filter, MySQL-backed document store, and session handling.
* `src/main/webapp/WEB-INF/views` contains JSP views.
* `src/main/webapp/assets` contains responsive CSS.
* `src/main/webapp/WEB-INF/web.xml` defines Servlet mappings and authentication.

The application uses Jakarta Servlets, JSP, Maven WAR packaging, and MySQL.
There is no Spring Boot runtime or source layer.

Authentication uses `HttpSession` and BCrypt password hashes. Protected
requests are redirected to the login view by `CampusFilter`. The MySQL tables used by the dashboard and API include `users`, `products`,
`notes`, `questions`, `assignments`, and `projects`.

## Servlet routes

* `/auth` – login, registration, and logout
* `/dashboard` – authenticated dashboard
* `/api/profile` – profile read/update
* `/api/marketplace` – marketplace listing read/create
* `/api/notes`, `/api/questions`, `/api/assignments`, `/api/projects` –
  collection read/create
* `/api/stats` – dashboard counts

JSON request bodies are accepted by the API routes. Profile and listing images
are stored as validated data URLs in database fields (`avatar` and `imageUrl`)
with a 2 MB client-side limit. In production, object storage should be used
for large media.

The product intentionally supports peer tutoring, explanations, code review,
and project collaboration; it does not support completing or submitting
assessed work on another student's behalf.

The application does not automatically create demonstration accounts or
sample content. Existing database records are preserved; remove test/demo
records explicitly if you want a completely empty database.
