package com.campusconnect.web;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletResponseWrapper;

import java.io.IOException;
import java.net.URI;
import java.util.Locale;

public class SecurityHeadersFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        httpResponse.setHeader("X-Content-Type-Options", "nosniff");
        httpResponse.setHeader("X-Frame-Options", "DENY");
        httpResponse.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
        httpResponse.setHeader("Permissions-Policy", "camera=(), microphone=(), geolocation=()");
        httpResponse.setHeader("X-XSS-Protection", "0");

        if (isUnsafeMethod(httpRequest.getMethod()) && !isSameOriginRequest(httpRequest)) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Request origin could not be verified.");
            return;
        }

        chain.doFilter(request, new SameSiteCookieResponse(httpResponse, httpRequest.isSecure()));
    }

    private boolean isSameOriginRequest(HttpServletRequest request) {
        String origin = request.getHeader("Origin");
        if (origin != null && !origin.isBlank()) {
            try {
                URI candidate = URI.create(origin);
                return candidate.getScheme() != null
                        && candidate.getScheme().equalsIgnoreCase(request.getScheme())
                        && candidate.getHost() != null
                        && candidate.getHost().equalsIgnoreCase(request.getServerName())
                        && effectivePort(candidate.getScheme(), candidate.getPort())
                        == effectivePort(request.getScheme(), request.getServerPort());
            } catch (IllegalArgumentException exception) {
                return false;
            }
        }

        String referer = request.getHeader("Referer");
        if (referer == null || referer.isBlank()) return false;
        try {
            URI candidate = URI.create(referer);
            return candidate.getScheme() != null
                    && candidate.getScheme().equalsIgnoreCase(request.getScheme())
                    && candidate.getHost() != null
                    && candidate.getHost().equalsIgnoreCase(request.getServerName())
                    && effectivePort(candidate.getScheme(), candidate.getPort())
                    == effectivePort(request.getScheme(), request.getServerPort());
        } catch (IllegalArgumentException exception) {
            return false;
        }
    }

    private boolean isUnsafeMethod(String method) {
        return !("GET".equalsIgnoreCase(method) || "HEAD".equalsIgnoreCase(method)
                || "OPTIONS".equalsIgnoreCase(method) || "TRACE".equalsIgnoreCase(method));
    }

    private int effectivePort(String scheme, int port) {
        if (port > 0) return port;
        return "https".equalsIgnoreCase(scheme) ? 443 : 80;
    }

    private static final class SameSiteCookieResponse extends HttpServletResponseWrapper {
        private final boolean secure;

        private SameSiteCookieResponse(HttpServletResponse response, boolean secure) {
            super(response);
            this.secure = secure;
        }

        @Override
        public void addCookie(Cookie cookie) {
            if ("JSESSIONID".equals(cookie.getName())) {
                cookie.setHttpOnly(true);
                cookie.setAttribute("SameSite", "Lax");
                if (secure) cookie.setSecure(true);
            }
            super.addCookie(cookie);
        }

        @Override
        public void addHeader(String name, String value) {
            super.addHeader(name, protectCookie(name, value));
        }

        @Override
        public void setHeader(String name, String value) {
            super.setHeader(name, protectCookie(name, value));
        }

        private String protectCookie(String name, String value) {
            if (!"set-cookie".equalsIgnoreCase(name) || value == null
                    || !value.startsWith("JSESSIONID=")) return value;
            String protectedValue = value;
            if (!protectedValue.toLowerCase(Locale.ROOT).contains("; httponly")) {
                protectedValue += "; HttpOnly";
            }
            if (!protectedValue.toLowerCase(Locale.ROOT).contains("samesite=")) {
                protectedValue += "; SameSite=Lax";
            }
            if (secure && !protectedValue.toLowerCase(Locale.ROOT).contains("; secure")) {
                protectedValue += "; Secure";
            }
            return protectedValue;
        }
    }
}
