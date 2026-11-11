<%@ page pageEncoding="UTF-8" %>
<%@ page import="com.campusconnect.web.Document" %>
<%@ page import="com.campusconnect.web.MySqlStore" %>
<%! private String navSafe(String value) { if (value == null) return ""; return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;"); } %>
<%
String activeModule = (String) request.getAttribute("activeModule");
if (activeModule == null) activeModule = "";
Document navUser = (Document) session.getAttribute("user");
String navName = navUser == null || navUser.getString("name") == null ? "Student" : navUser.getString("name");
long navUnread = navUser == null ? 0 : MySqlStore.unreadNotificationCount(navUser.getObjectId("_id"));
%>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Space+Grotesk:wght@500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
<link href="${pageContext.request.contextPath}/assets/campus.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/assets/premium-ui.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/assets/security.css" rel="stylesheet">
<script>
(() => {
    try {
        const theme = localStorage.getItem('campus-connect-theme') || 'light';
        document.documentElement.dataset.theme = theme;
    } catch (e) {
        document.documentElement.dataset.theme = 'light';
    }
})();
</script>

<nav class="topbar">
    <button class="mobile-nav-toggle" type="button" aria-label="Open navigation" aria-expanded="false"><span></span><span></span></button>
    <a class="brand" href="${pageContext.request.contextPath}/dashboard">
        <span class="brand-mark">C<span class="brand-spark">✦</span></span>
        <span>Campus Connect<small>STUDENT HUB &middot; ENTERPRISE GRADE</small></span>
    </a>

    <!-- Advanced Command Palette Launcher Trigger -->
    <button class="cc-omnibar-btn" type="button" id="openCommandPaletteBtn" title="Press Ctrl+K or Cmd+K to launch command palette">
        <i class="bi bi-search"></i>
        <span>Quick search, actions, commands…</span>
        <kbd><span class="cc-kbd-mod">⌘</span>K</kbd>
    </button>

    <div class="top-actions">
        <!-- Live Focus / Study Timer pill in header -->
        <button class="cc-focus-pill" type="button" id="topbarFocusBtn" title="Campus Study & Focus Timer" aria-label="Study Timer">
            <span class="cc-focus-dot"></span>
            <span id="topbarFocusDisplay">25:00</span>
            <i class="bi bi-stopwatch"></i>
        </button>

        <button class="cc-theme-toggle" type="button" aria-label="Switch theme" aria-pressed="false" title="Switch theme">
            <i class="bi bi-moon-stars" aria-hidden="true"></i>
        </button>

        <a class="cc-notice-shortcut" href="${pageContext.request.contextPath}/notifications" aria-label="Campus notices" title="Campus notifications">
            <i class="bi bi-bell" aria-hidden="true"></i>
            <% if (navUnread > 0) { %><span><%= navUnread > 99 ? "99+" : navUnread %></span><% } %>
        </a>

        <span class="nav-greeting">Welcome, <strong><%= navSafe(navName) %></strong></span>

        <a class="cc-profile-shortcut" href="${pageContext.request.contextPath}/profile" aria-label="Open your profile" title="Your student profile">
            <%= navSafe(navName.substring(0, 1).toUpperCase()) %>
        </a>

        <form method="post" action="${pageContext.request.contextPath}/auth" class="logout-form">
            <input type="hidden" name="action" value="logout">
            <button class="logout-link" type="submit" aria-label="Sign out">
                <span>Sign out</span> <i class="bi bi-box-arrow-right"></i>
            </button>
        </form>
    </div>
</nav>

<aside class="sidebar">
    <div class="cc-side-workspace">
        <span class="cc-workspace-avatar">C</span>
        <span><strong>Campus Connect</strong><small>Active Workspace</small></span>
        <span class="cc-status-indicator" title="Connected"></span>
    </div>

    <!-- Study Focus Widget inside Sidebar -->
    <div class="cc-sidebar-focus-widget" id="sidebarFocusWidget">
        <div class="cc-focus-header">
            <span><i class="bi bi-lightning-charge-fill text-warning"></i> <strong>Study Sprint</strong></span>
            <span class="badge bg-primary-subtle text-primary cc-badge-sm" id="focusModeLabel">25m Focus</span>
        </div>
        <div class="cc-focus-timer-body">
            <div class="cc-focus-digits" id="sidebarTimerDigits">25:00</div>
            <div class="cc-focus-controls">
                <button type="button" class="btn btn-sm btn-primary cc-focus-play-btn" id="focusStartBtn" title="Start Timer">
                    <i class="bi bi-play-fill" id="focusPlayIcon"></i>
                </button>
                <button type="button" class="btn btn-sm btn-outline-secondary" id="focusResetBtn" title="Reset">
                    <i class="bi bi-arrow-counterclockwise"></i>
                </button>
            </div>
        </div>
    </div>

    <div class="cc-side-label">MAIN WORKSPACE</div>
    <a class="<%= "dashboard".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/dashboard">
        <span><i class="bi bi-grid-1x2"></i></span> Home Dashboard
    </a>
    <a class="<%= "discover".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/discover">
        <span><i class="bi bi-compass"></i></span> Discover Campus
    </a>

    <div class="cc-side-label cc-side-label-spaced">LEARNING &amp; PEERS</div>
    <a class="<%= "notes".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/notes">
        <span><i class="bi bi-journal-bookmark"></i></span> Resource Library
    </a>
    <a class="<%= "questions".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/questions">
        <span><i class="bi bi-chat-left-dots"></i></span> Questions &amp; Q&amp;A
    </a>
    <a class="<%= "assignments".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/assignments">
        <span><i class="bi bi-people"></i></span> Peer Support
    </a>
    <a class="<%= "projects".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/projects">
        <span><i class="bi bi-kanban"></i></span> Project Hub
    </a>

    <div class="cc-side-label cc-side-label-spaced">CAMPUS LIFE</div>
    <a class="<%= "marketplace".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/marketplace">
        <span><i class="bi bi-shop"></i></span> Marketplace
    </a>
    <a class="<%= "profiles".equals(activeModule) || "messages".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/profiles">
        <span><i class="bi bi-person-lines-fill"></i></span> People &amp; Messages
    </a>
    <a class="<%= "activity".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/activity">
        <span><i class="bi bi-activity"></i></span> Activity &amp; Feedback
    </a>
    <a class="<%= "note-requests".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/note-requests">
        <span><i class="bi bi-file-earmark-plus"></i></span> Note Requests
    </a>

    <div class="cc-side-label cc-side-label-spaced">PERSONAL COLLECTION</div>
    <a class="<%= "saved".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/saved">
        <span><i class="bi bi-bookmark-star"></i></span> Saved Items
    </a>
    <a class="<%= "profile".equals(activeModule) ? "active" : "" %>" href="${pageContext.request.contextPath}/profile">
        <span><i class="bi bi-sliders"></i></span> Profile &amp; Settings
    </a>

    <div class="cc-sidebar-bottom">
        <div class="cc-sidebar-bottom-mark">✦</div>
        <strong>Campus Connect Pro</strong>
        <p>Premium student collaboration platform designed for high performance.</p>
    </div>
</aside>

<!-- ADVANCED GLOBAL COMMAND PALETTE MODAL (Ctrl+K / Cmd+K) -->
<div class="cc-palette-overlay" id="ccCommandPalette" aria-hidden="true" role="dialog" aria-modal="true">
    <div class="cc-palette-card">
        <div class="cc-palette-header">
            <i class="bi bi-search cc-palette-search-icon"></i>
            <input type="text" id="ccPaletteInput" placeholder="Type a command, page, or search term…" autocomplete="off" spellcheck="false">
            <kbd class="cc-palette-esc" id="ccPaletteCloseBtn">ESC</kbd>
        </div>
        <div class="cc-palette-results" id="ccPaletteResults">
            <!-- Dynamically populated or default options -->
            <div class="cc-palette-group-title">NAVIGATION JUMP</div>
            <a class="cc-palette-item active" href="${pageContext.request.contextPath}/dashboard">
                <i class="bi bi-grid-1x2 cc-palette-item-icon"></i>
                <div class="cc-palette-item-text">
                    <strong>Dashboard Home</strong>
                    <small>Campus pulse, feed, and high-priority updates</small>
                </div>
                <span class="cc-palette-badge">Page</span>
            </a>
            <a class="cc-palette-item" href="${pageContext.request.contextPath}/notes">
                <i class="bi bi-journal-bookmark cc-palette-item-icon"></i>
                <div class="cc-palette-item-text">
                    <strong>Study Resource Library</strong>
                    <small>Shared lecture notes, slides, and cheat sheets</small>
                </div>
                <span class="cc-palette-badge">Library</span>
            </a>
            <a class="cc-palette-item" href="${pageContext.request.contextPath}/projects">
                <i class="bi bi-kanban cc-palette-item-icon"></i>
                <div class="cc-palette-item-text">
                    <strong>Project Spaces &amp; Teams</strong>
                    <small>Find collaborators, build apps, hackathons</small>
                </div>
                <span class="cc-palette-badge">Teams</span>
            </a>
            <a class="cc-palette-item" href="${pageContext.request.contextPath}/questions">
                <i class="bi bi-chat-left-dots cc-palette-item-icon"></i>
                <div class="cc-palette-item-text">
                    <strong>Campus Questions &amp; Answers</strong>
                    <small>Ask questions, give peer explanations</small>
                </div>
                <span class="cc-palette-badge">Q&amp;A</span>
            </a>
            <a class="cc-palette-item" href="${pageContext.request.contextPath}/marketplace">
                <i class="bi bi-shop cc-palette-item-icon"></i>
                <div class="cc-palette-item-text">
                    <strong>Campus Marketplace</strong>
                    <small>Textbooks, hardware, notes &amp; student supplies</small>
                </div>
                <span class="cc-palette-badge">Market</span>
            </a>
            <a class="cc-palette-item" href="${pageContext.request.contextPath}/profiles">
                <i class="bi bi-person-lines-fill cc-palette-item-icon"></i>
                <div class="cc-palette-item-text">
                    <strong>Student Directory &amp; Messages</strong>
                    <small>Connect with peers and direct message</small>
                </div>
                <span class="cc-palette-badge">Network</span>
            </a>

            <div class="cc-palette-group-title">QUICK ACTIONS</div>
            <button class="cc-palette-item" type="button" onclick="window.triggerPaletteAction('theme')">
                <i class="bi bi-palette cc-palette-item-icon"></i>
                <div class="cc-palette-item-text">
                    <strong>Toggle Dark / Light Theme</strong>
                    <small>Switch interface color theme instantly</small>
                </div>
                <span class="cc-palette-badge">Action</span>
            </button>
            <button class="cc-palette-item" type="button" onclick="window.triggerPaletteAction('timer')">
                <i class="bi bi-stopwatch cc-palette-item-icon"></i>
                <div class="cc-palette-item-text">
                    <strong>Toggle Focus Pomodoro Timer</strong>
                    <small>Start or pause 25-minute study focus interval</small>
                </div>
                <span class="cc-palette-badge">Focus</span>
            </button>
            <button class="cc-palette-item" type="button" onclick="window.triggerPaletteAction('share')">
                <i class="bi bi-link-45deg cc-palette-item-icon"></i>
                <div class="cc-palette-item-text">
                    <strong>Copy Current Page Link</strong>
                    <small>Copy clean shareable link to clipboard</small>
                </div>
                <span class="cc-palette-badge">Tool</span>
            </button>
        </div>
        <div class="cc-palette-footer">
            <span><kbd>&uarr;</kbd> <kbd>&darr;</kbd> Navigate</span>
            <span><kbd>&crarr;</kbd> Select</span>
            <span><kbd>ESC</kbd> Close</span>
        </div>
    </div>
</div>

<!-- TOAST NOTIFICATION HOST -->
<div class="cc-toast-container" id="ccToastContainer" aria-live="polite" aria-atomic="true"></div>

<script>
(() => {
    // 1. Toast Notification Utility
    window.showCampusToast = (message, title = 'Notification', type = 'info') => {
        const container = document.getElementById('ccToastContainer');
        if (!container) return;
        const toast = document.createElement('div');
        toast.className = 'cc-toast cc-toast-' + type;
        const icon = type === 'success' ? 'check-circle-fill text-success' :
                     type === 'warning' ? 'exclamation-triangle-fill text-warning' :
                     type === 'danger' ? 'x-circle-fill text-danger' : 'info-circle-fill text-primary';
        toast.innerHTML = `
            <i class="bi bi-${icon} cc-toast-icon"></i>
            <div class="cc-toast-content">
                <strong>${title}</strong>
                <p>${message}</p>
            </div>
            <button type="button" class="cc-toast-close" aria-label="Close">&times;</button>
        `;
        container.appendChild(toast);
        requestAnimationFrame(() => toast.classList.add('is-visible'));
        const close = () => {
            toast.classList.remove('is-visible');
            setTimeout(() => toast.remove(), 250);
        };
        toast.querySelector('.cc-toast-close').addEventListener('click', close);
        setTimeout(close, 4000);
    };

    // 2. Command Palette Logic
    const palette = document.getElementById('ccCommandPalette');
    const paletteInput = document.getElementById('ccPaletteInput');
    const openBtn = document.getElementById('openCommandPaletteBtn');
    const closeBtn = document.getElementById('ccPaletteCloseBtn');
    const resultsContainer = document.getElementById('ccPaletteResults');

    const openPalette = () => {
        if (!palette) return;
        palette.classList.add('is-open');
        palette.setAttribute('aria-hidden', 'false');
        if (paletteInput) {
            paletteInput.value = '';
            filterPaletteItems('');
            setTimeout(() => paletteInput.focus(), 50);
        }
    };

    const closePalette = () => {
        if (!palette) return;
        palette.classList.remove('is-open');
        palette.setAttribute('aria-hidden', 'true');
    };

    if (openBtn) openBtn.addEventListener('click', openPalette);
    if (closeBtn) closeBtn.addEventListener('click', closePalette);
    if (palette) {
        palette.addEventListener('click', e => {
            if (e.target === palette) closePalette();
        });
    }

    const filterPaletteItems = query => {
        const q = query.trim().toLowerCase();
        const items = resultsContainer.querySelectorAll('.cc-palette-item');
        let first = true;
        items.forEach(item => {
            const text = item.textContent.toLowerCase();
            const matches = !q || text.includes(q);
            item.style.display = matches ? 'flex' : 'none';
            if (matches && first) {
                item.classList.add('active');
                first = false;
            } else {
                item.classList.remove('active');
            }
        });
    };

    if (paletteInput) {
        paletteInput.addEventListener('input', e => filterPaletteItems(e.target.value));
        paletteInput.addEventListener('keydown', e => {
            const visible = [...resultsContainer.querySelectorAll('.cc-palette-item')].filter(el => el.style.display !== 'none');
            const currentIndex = visible.findIndex(el => el.classList.contains('active'));
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                const next = (currentIndex + 1) % visible.length;
                visible.forEach(el => el.classList.remove('active'));
                if (visible[next]) {
                    visible[next].classList.add('active');
                    visible[next].scrollIntoView({ block: 'nearest' });
                }
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                const prev = (currentIndex - 1 + visible.length) % visible.length;
                visible.forEach(el => el.classList.remove('active'));
                if (visible[prev]) {
                    visible[prev].classList.add('active');
                    visible[prev].scrollIntoView({ block: 'nearest' });
                }
            } else if (e.key === 'Enter') {
                e.preventDefault();
                const active = visible[currentIndex] || visible[0];
                if (active) {
                    if (active.tagName === 'A') {
                        window.location.href = active.href;
                    } else {
                        active.click();
                        closePalette();
                    }
                }
            } else if (e.key === 'Escape') {
                closePalette();
            }
        });
    }

    // 3. Quick Palette Actions
    window.triggerPaletteAction = action => {
        closePalette();
        if (action === 'theme') {
            const current = document.documentElement.dataset.theme;
            const next = current === 'dark' ? 'light' : 'dark';
            setTheme(next);
            window.showCampusToast(`Theme changed to ${next} mode`, 'Theme Updated', 'success');
        } else if (action === 'timer') {
            toggleFocusTimer();
        } else if (action === 'share') {
            if (navigator.clipboard) {
                navigator.clipboard.writeText(window.location.href).then(() => {
                    window.showCampusToast('Current page link copied to clipboard!', 'Link Copied', 'success');
                }).catch(() => {
                    window.showCampusToast(window.location.href, 'Page URL');
                });
            } else {
                window.showCampusToast(window.location.href, 'Page URL');
            }
        }
    };

    // Global Keydown Shortcut
    document.addEventListener('keydown', e => {
        if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
            e.preventDefault();
            if (palette && palette.classList.contains('is-open')) closePalette();
            else openPalette();
        } else if (e.key === 'Escape') {
            closePalette();
            if (sidebar) sidebar.classList.remove('open');
            document.body.classList.remove('cc-nav-open');
        }
    });

    // 4. Focus Pomodoro Study Timer Implementation
    let focusMinutes = 25;
    let focusSeconds = 0;
    let focusInterval = null;
    let isFocusRunning = false;

    const topbarDisplay = document.getElementById('topbarFocusDisplay');
    const sidebarDigits = document.getElementById('sidebarTimerDigits');
    const focusPlayIcon = document.getElementById('focusPlayIcon');
    const focusStartBtn = document.getElementById('focusStartBtn');
    const focusResetBtn = document.getElementById('focusResetBtn');
    const topbarFocusBtn = document.getElementById('topbarFocusBtn');

    const updateTimerDisplays = () => {
        const text = String(focusMinutes).padStart(2, '0') + ':' + String(focusSeconds).padStart(2, '0');
        if (topbarDisplay) topbarDisplay.textContent = text;
        if (sidebarDigits) sidebarDigits.textContent = text;
    };

    const toggleFocusTimer = () => {
        if (isFocusRunning) {
            clearInterval(focusInterval);
            isFocusRunning = false;
            if (focusPlayIcon) focusPlayIcon.className = 'bi bi-play-fill';
            if (topbarFocusBtn) topbarFocusBtn.classList.remove('is-running');
            window.showCampusToast('Study focus timer paused.', 'Timer Paused', 'info');
        } else {
            isFocusRunning = true;
            if (focusPlayIcon) focusPlayIcon.className = 'bi bi-pause-fill';
            if (topbarFocusBtn) topbarFocusBtn.classList.add('is-running');
            window.showCampusToast('25m Study sprint started! Stay focused.', 'Focus Started', 'success');
            focusInterval = setInterval(() => {
                if (focusSeconds === 0) {
                    if (focusMinutes === 0) {
                        clearInterval(focusInterval);
                        isFocusRunning = false;
                        if (focusPlayIcon) focusPlayIcon.className = 'bi bi-play-fill';
                        if (topbarFocusBtn) topbarFocusBtn.classList.remove('is-running');
                        window.showCampusToast('Great job! 25-minute study sprint complete. Take a 5-minute break!', 'Sprint Complete!', 'success');
                        focusMinutes = 25;
                        focusSeconds = 0;
                        updateTimerDisplays();
                        return;
                    }
                    focusMinutes--;
                    focusSeconds = 59;
                } else {
                    focusSeconds--;
                }
                updateTimerDisplays();
            }, 1000);
        }
    };

    if (focusStartBtn) focusStartBtn.addEventListener('click', toggleFocusTimer);
    if (topbarFocusBtn) topbarFocusBtn.addEventListener('click', toggleFocusTimer);
    if (focusResetBtn) {
        focusResetBtn.addEventListener('click', () => {
            clearInterval(focusInterval);
            isFocusRunning = false;
            focusMinutes = 25;
            focusSeconds = 0;
            if (focusPlayIcon) focusPlayIcon.className = 'bi bi-play-fill';
            if (topbarFocusBtn) topbarFocusBtn.classList.remove('is-running');
            updateTimerDisplays();
            window.showCampusToast('Timer reset to 25:00', 'Reset');
        });
    }

    // 5. Sidebar & Theme Toggle
    const sidebar = document.querySelector('.sidebar');
    const menuButton = document.querySelector('.mobile-nav-toggle');
    const themeButton = document.querySelector('.cc-theme-toggle');

    if (menuButton && sidebar) {
        menuButton.addEventListener('click', () => {
            const isOpen = sidebar.classList.toggle('open');
            document.body.classList.toggle('cc-nav-open', isOpen);
            menuButton.setAttribute('aria-expanded', String(isOpen));
        });
    }

    document.addEventListener('click', event => {
        if (sidebar && sidebar.classList.contains('open')
                && !sidebar.contains(event.target)
                && !(menuButton && menuButton.contains(event.target))) {
            sidebar.classList.remove('open');
            document.body.classList.remove('cc-nav-open');
            if (menuButton) menuButton.setAttribute('aria-expanded', 'false');
        }
    });

    const setTheme = theme => {
        document.documentElement.dataset.theme = theme;
        if (themeButton) {
            const dark = theme === 'dark';
            themeButton.setAttribute('aria-pressed', String(dark));
            themeButton.setAttribute('aria-label', dark ? 'Switch to light theme' : 'Switch to dark theme');
            themeButton.innerHTML = dark
                ? '<i class="bi bi-sun" aria-hidden="true"></i>'
                : '<i class="bi bi-moon-stars" aria-hidden="true"></i>';
        }
        try {
            localStorage.setItem('campus-connect-theme', theme);
        } catch (e) {}
    };

    if (themeButton) {
        setTheme(document.documentElement.dataset.theme === 'dark' ? 'dark' : 'light');
        themeButton.addEventListener('click', () => {
            setTheme(document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark');
        });
    }

    // Smooth Reveal Animations
    document.addEventListener('DOMContentLoaded', () => {
        const revealTargets = document.querySelectorAll(
            '.cc-welcome-panel, .cc-preview-notice, .cc-quick-action, .cc-overview-stat, ' +
            '.cc-home-section, .cc-home-side-card, .cc-workspace .item-card'
        );
        if (!('IntersectionObserver' in window) || window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
        const revealObserver = new IntersectionObserver(entries => {
            entries.forEach(entry => {
                if (!entry.isIntersecting) return;
                entry.target.classList.add('cc-reveal-visible');
                revealObserver.unobserve(entry.target);
            });
        }, { threshold: 0.08, rootMargin: '0px 0px -20px 0px' });
        revealTargets.forEach((element, index) => {
            element.style.setProperty('--cc-reveal-delay', (Math.min(index % 4, 3) * 45) + 'ms');
            element.classList.add('cc-reveal');
            revealObserver.observe(element);
        });
    });
})();
</script>
