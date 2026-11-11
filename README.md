# Campus Connect

Campus Connect is a student collaboration platform built with Java 17,
Jakarta Servlets, JSP, Maven, Bootstrap, MySQL, and SMTP. The application is
packaged as a traditional WAR for Apache Tomcat.

## Run with Tomcat

1. Install Java 17+, Maven, MySQL 8+, and Apache Tomcat 10.1+.
2. Set `MYSQL_URL`, `MYSQL_USERNAME`, and `MYSQL_PASSWORD` for your database.
3. Configure email using the SMTP settings below before allowing new students
   to register.
4. Build the WAR:

   ```powershell
   mvn -q clean package
   ```

5. Copy `target\campus-connect.war` into Tomcat's `webapps` directory, start
   Tomcat, then open `http://localhost:8080/campus-connect/`.

The database defaults are:

* `MYSQL_URL`:
  `jdbc:mysql://localhost:3306/campus_connect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC`
* `MYSQL_USERNAME`: `root`
* `MYSQL_PASSWORD`: empty

## Email verification

Set these environment variables for the Tomcat process:

* `SMTP_HOST` and `SMTP_PORT` (default port `587`)
* `SMTP_USERNAME` and `SMTP_PASSWORD` (use a provider/app password)
* `SMTP_FROM` (a sender address verified with your provider)
* `SMTP_STARTTLS` (`true` by default)
* `CAMPUS_PUBLIC_URL` (public origin, for example `https://campus.example.edu`; Tomcat's context path is added automatically)

New accounts receive a single-use verification link that expires after 24
hours. A new account cannot sign in until its link is used. Verification
tokens are random, and only their SHA-256 hashes and expiry times are stored.
Resend requests are rate limited. If SMTP is missing or unavailable, the
account remains pending, the failure is logged, and the page explains that
email delivery needs to be configured before another link can be sent.
Accounts created before email verification was introduced remain accessible.

## Security

New and changed passwords must be at least 12 characters and no more than 72
UTF-8 bytes; BCrypt cost 12 hashes new passwords. Sign-in and registration
attempts are rate limited. Sessions use HttpOnly, SameSite=Lax cookies,
cookie-only session tracking, and a 30-minute idle timeout. State-changing
browser requests must have a matching Origin or Referer. Security response
headers are set for the application; run the site behind HTTPS in production
so session cookies receive the Secure flag.

The platform preserves the original collaboration modules: student profiles
and private messages, peer-support requests, notes and note requests,
questions and answers, marketplace listings and orders, project collaboration,
activity, ratings/feedback, and campus notices.

The workspace dashboard brings recent campus content and common actions
together in a responsive campus workspace with left-side navigation, a
focused search header, expressive visual cards, and animated activity sections.
Its light indigo-and-lilac visual language keeps Campus Connect's own identity
while giving community content clear hierarchy. It includes quick links, campus activity,
questions, shared resources, projects, notices, and saved items. Use
**Discover** or the navigation search to search study resources, questions,
project spaces, and marketplace listings at once; each category shows up to
eight recent matches. Save resources, questions, projects, and marketplace
items to **Saved items** to keep a personal collection across sessions. The
authentication and workspace screens use Bootstrap 5 components and
responsive layouts.

The authenticated workspace defaults to its light theme and also includes a
saved light/dark theme preference,
mobile sidebar control, dashboard content filters, and a manually controlled
campus-photo gallery. Locally bundled campus photos use subtle, reduced-motion-
aware transitions and slow cinematic movement; gallery controls remain manual.
Local photo assets in `src/main/webapp/assets/images` are sourced from Unsplash.
A small preview-only example content set is
available in `database/preview-seed.sql`; it targets the isolated
`campus_connect_preview` database, marks all records as samples, and is not run
automatically. Never point that script at a production campus database.

## Application structure

* `src/main/java/com/campusconnect/web` contains servlet controllers,
  authentication and security filters, and the MySQL-backed document store.
* `src/main/webapp/WEB-INF/views` contains the responsive Bootstrap views.
* `src/main/webapp/assets` contains the shared visual system and page styles.
* `src/main/webapp/WEB-INF/web.xml` defines servlet mappings, cookie settings,
  and filters.

The product supports peer tutoring, explanations, code review, and project
collaboration. It does not support completing or submitting assessed work on
another student's behalf.

The application does not automatically create demo accounts or sample
content. Existing database records are preserved; remove test/demo records
explicitly if you want an empty database.
