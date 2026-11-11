package com.campusconnect.web;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;

public final class VerificationEmailService {
    private VerificationEmailService() {
    }

    public static boolean isConfigured() {
        return hasValue("SMTP_HOST") && hasValue("SMTP_FROM");
    }

    public static void send(String recipient, String name, String rawToken, String contextPath)
            throws MessagingException {
        String host = required("SMTP_HOST");
        String from = required("SMTP_FROM");
        String username = System.getenv().getOrDefault("SMTP_USERNAME", "");
        String password = System.getenv().getOrDefault("SMTP_PASSWORD", "");
        int port = parsePort(System.getenv().getOrDefault("SMTP_PORT", "587"));
        boolean auth = !username.isBlank();
        boolean startTls = Boolean.parseBoolean(System.getenv().getOrDefault("SMTP_STARTTLS", "true"));
        String publicUrl = System.getenv().getOrDefault("CAMPUS_PUBLIC_URL", "http://localhost:8080")
                .replaceAll("/+$", "");
        String verifyUrl = publicUrl + contextPath + "/auth?action=verify&token=" + rawToken;

        Properties properties = new Properties();
        properties.put("mail.smtp.host", host);
        properties.put("mail.smtp.port", Integer.toString(port));
        properties.put("mail.smtp.auth", Boolean.toString(auth));
        properties.put("mail.smtp.starttls.enable", Boolean.toString(startTls));
        properties.put("mail.smtp.connectiontimeout", "10000");
        properties.put("mail.smtp.timeout", "10000");
        properties.put("mail.smtp.writetimeout", "10000");

        Session session = Session.getInstance(properties, auth ? new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        } : null);

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(from));
        message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipient));
        message.setSubject("Verify your Campus Connect email", "UTF-8");
        message.setText("""
                Hi %s,

                Welcome to Campus Connect. Verify your email address to activate your account:
                %s

                This single-use link expires in 24 hours. If you did not create an account, you can ignore this message.
                """.formatted(name, verifyUrl), "UTF-8");
        Transport.send(message);
    }

    private static String required(String key) {
        String value = System.getenv(key);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException(key + " must be configured before email verification can be sent.");
        }
        return value.trim();
    }

    private static boolean hasValue(String key) {
        String value = System.getenv(key);
        return value != null && !value.isBlank();
    }

    private static int parsePort(String value) {
        try {
            int port = Integer.parseInt(value);
            if (port < 1 || port > 65535) throw new NumberFormatException();
            return port;
        } catch (NumberFormatException exception) {
            throw new IllegalStateException("SMTP_PORT must be a valid TCP port.", exception);
        }
    }
}
