package com.campusconnect.web;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public class CampusFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest http = (HttpServletRequest) request;
        String path = http.getRequestURI().substring(http.getContextPath().length());
        if (path.startsWith("/auth") || path.startsWith("/assets") || path.endsWith(".css")
                || path.endsWith(".js") || path.endsWith(".png") || path.endsWith(".ico")) {
            chain.doFilter(request, response);
            return;
        }
        HttpSession session = http.getSession(false);
        if (session != null && session.getAttribute("user") instanceof Document user) {
            MySqlStore.normalizeObjectIds(user);
        }
        if (http.getSession(false) == null || http.getSession(false).getAttribute("user") == null) {
            HttpServletResponse output = (HttpServletResponse) response;
            if (path.startsWith("/api/")) {
                output.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Sign in required");
            } else {
                output.sendRedirect(http.getContextPath() + "/auth?action=login");
            }
            return;
        }
        chain.doFilter(request, response);
    }
}
