
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String contextPath = request.getContextPath();
    String errorMessage = (String) request.getAttribute("error");

    String logoutParam = request.getParameter("logout");
    String setupParam = request.getParameter("setup");

    boolean loggedOut = "1".equals(logoutParam);
    boolean setupSuccess = "success".equals(setupParam);
%>

<%!
    private String esc(Object value) {
        if (value == null) {
            return "";
        }

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">
    <title>Sign In | MediGuard</title>

    <link rel="stylesheet"
          href="<%= contextPath %>/css/mediguard.css">

    <style>
        .login-page {
            min-height: 100vh;
            display: grid;
            place-items: center;
            padding: 28px 16px;
            background:
                radial-gradient(ellipse at 10% 10%, rgba(13, 148, 136, .12), transparent 36%),
                radial-gradient(ellipse at 90% 85%, rgba(59, 130, 246, .11), transparent 38%),
                #f4f7fb;
        }

        .login-layout {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(350px, 440px);
            width: min(100%, 1000px);
            min-height: 580px;
            overflow: hidden;
            border: 1px solid #e1e8f1;
            border-radius: 24px;
            background: #fff;
            box-shadow: 0 24px 75px rgba(22, 49, 82, .11);
        }

        .login-intro {
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            overflow: hidden;
            padding: 42px;
            background:
                radial-gradient(circle at 85% 12%, rgba(13, 148, 136, .18), transparent 30%),
                linear-gradient(145deg, #173b63, #102b49);
            color: #fff;
        }

        .login-intro::before,
        .login-intro::after {
            position: absolute;
            border: 1px solid rgba(255, 255, 255, .09);
            border-radius: 50%;
            content: "";
            pointer-events: none;
        }

        .login-intro::before {
            right: -130px;
            bottom: 55px;
            width: 350px;
            height: 350px;
        }

        .login-intro::after {
            right: -70px;
            bottom: 115px;
            width: 230px;
            height: 230px;
        }

        .login-intro-content,
        .login-intro-footer {
            position: relative;
            z-index: 1;
        }

        .login-brand {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            color: #fff;
            text-decoration: none;
        }

        .login-brand-mark {
            display: grid;
            width: 47px;
            height: 47px;
            place-items: center;
            border: 1px solid rgba(255, 255, 255, .18);
            border-radius: 14px;
            background: rgba(255, 255, 255, .11);
            color: #99f6e4;
            font-size: 27px;
            font-weight: 700;
        }

        .login-brand-name {
            font-size: 23px;
            font-weight: 800;
            letter-spacing: -.6px;
        }

        .login-brand-caption {
            display: block;
            margin-top: 1px;
            color: #cbdced;
            font-size: 11px;
            font-weight: 500;
            letter-spacing: .7px;
        }

        .login-hero {
            margin: 65px 0 45px;
        }

        .login-eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 7px 11px;
            border: 1px solid rgba(153, 246, 228, .22);
            border-radius: 30px;
            background: rgba(13, 148, 136, .15);
            color: #b9fff1;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .8px;
            text-transform: uppercase;
        }

        .login-eyebrow-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: #5eead4;
        }

        .login-hero h1 {
            max-width: 450px;
            margin: 22px 0 15px;
            color: #fff;
            font-size: clamp(31px, 4vw, 43px);
            font-weight: 800;
            letter-spacing: -1.5px;
            line-height: 1.15;
        }

        .login-hero p {
            max-width: 410px;
            margin: 0;
            color: #d2dfed;
            font-size: 14px;
            line-height: 1.85;
        }

        .login-feature-list {
            display: grid;
            gap: 15px;
            margin-top: 29px;
        }

        .login-feature {
            display: flex;
            align-items: center;
            gap: 12px;
            color: #edf5ff;
            font-size: 13px;
        }

        .login-feature-icon {
            display: grid;
            flex-shrink: 0;
            width: 31px;
            height: 31px;
            place-items: center;
            border: 1px solid rgba(255, 255, 255, .13);
            border-radius: 10px;
            background: rgba(255, 255, 255, .08);
            color: #99f6e4;
            font-weight: 800;
        }

        .login-intro-footer {
            padding-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, .13);
            color: #bdcde0;
            font-size: 11px;
            line-height: 1.7;
        }

        .login-form-panel {
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 42px 36px;
        }

        .login-form-heading {
            margin-bottom: 28px;
        }

        .login-form-kicker {
            margin: 0 0 8px;
            color: #0d9488;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }

        .login-form-heading h2 {
            margin: 0;
            color: #172b4d;
            font-size: 29px;
            font-weight: 800;
            letter-spacing: -.9px;
        }

        .login-form-heading p {
            margin: 9px 0 0;
            color: #718096;
            font-size: 13px;
            line-height: 1.7;
        }

        .login-notice {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            margin-bottom: 18px;
            padding: 12px 13px;
            border: 1px solid;
            border-radius: 10px;
            font-size: 12px;
            line-height: 1.6;
        }

        .login-notice-icon {
            flex-shrink: 0;
            font-weight: 800;
        }

        .login-notice-error {
            border-color: #fecaca;
            background: #fff1f2;
            color: #991b1b;
        }

        .login-notice-success {
            border-color: #bbf7d0;
            background: #f0fdf4;
            color: #166534;
        }

        .login-notice-info {
            border-color: #bfdbfe;
            background: #eff6ff;
            color: #1d4ed8;
        }

        .login-form {
            display: grid;
            gap: 19px;
            margin: 0;
        }

        .login-field {
            min-width: 0;
        }

        .login-label-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            margin-bottom: 8px;
        }

        .login-label {
            margin: 0;
            color: #344861;
            font-size: 12px;
            font-weight: 750;
        }

        .login-input-wrap {
            position: relative;
        }

        .login-input {
            width: 100%;
            min-height: 47px;
            padding: 12px 13px;
            border: 1px solid #d8e1ec;
            border-radius: 10px;
            outline: none;
            background: #fff;
            color: #263e5b;
            font-family: inherit;
            font-size: 13px;
            transition: border-color .2s ease, box-shadow .2s ease;
        }

        .login-input::placeholder {
            color: #9aa6b6;
        }

        .login-input:focus {
            border-color: #0d9488;
            box-shadow: 0 0 0 3px rgba(13, 148, 136, .12);
        }

        .login-password-input {
            padding-right: 73px;
        }

        .login-password-toggle {
            position: absolute;
            top: 50%;
            right: 9px;
            min-height: auto;
            padding: 6px 7px;
            transform: translateY(-50%);
            border: 0;
            border-radius: 6px;
            background: transparent;
            color: #64748b;
            font-size: 11px;
            font-weight: 750;
            cursor: pointer;
        }

        .login-password-toggle:hover {
            background: #f1f5f9;
            color: #173b63;
        }

        .login-submit {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            width: 100%;
            min-height: 48px;
            margin-top: 3px;
            padding: 12px 18px;
            border: 0;
            border-radius: 10px;
            background: #173b63;
            color: #fff;
            font-family: inherit;
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
            transition: background .2s ease, transform .2s ease;
        }

        .login-submit:hover {
            background: #245582;
        }

        .login-submit:active {
            transform: translateY(1px);
        }

        .login-submit:focus-visible,
        .login-password-toggle:focus-visible {
            outline: 3px solid rgba(13, 148, 136, .4);
            outline-offset: 3px;
        }

        .login-security-note {
            display: flex;
            align-items: flex-start;
            gap: 9px;
            margin-top: 23px;
            padding-top: 18px;
            border-top: 1px solid #edf1f6;
            color: #8491a3;
            font-size: 11px;
            line-height: 1.65;
        }

        .login-security-icon {
            flex-shrink: 0;
            color: #0d9488;
            font-weight: 800;
        }

        .login-bottom {
            margin-top: 28px;
            color: #a0aabc;
            text-align: center;
            font-size: 10px;
            line-height: 1.7;
        }

        @media (max-width: 760px) {
            .login-layout {
                grid-template-columns: 1fr;
                width: min(100%, 470px);
                min-height: auto;
            }

            .login-intro {
                padding: 27px;
            }

            .login-hero {
                margin: 35px 0 15px;
            }

            .login-hero h1 {
                font-size: 32px;
            }

            .login-feature-list {
                grid-template-columns: 1fr;
                gap: 11px;
                margin-top: 20px;
            }

            .login-intro-footer {
                margin-top: 25px;
            }

            .login-form-panel {
                padding: 32px 27px;
            }
        }

        @media (max-width: 380px) {
            .login-intro,
            .login-form-panel {
                padding: 23px 19px;
            }

            .login-form-heading h2 {
                font-size: 26px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                scroll-behavior: auto !important;
                transition-duration: .01ms !important;
            }
        }
    </style>
</head>

<body>
<main class="login-page">
    <div class="login-layout">

        <section class="login-intro" aria-label="About MediGuard">
            <div class="login-intro-content">
                <a class="login-brand" href="<%= contextPath %>/login">
                    <span class="login-brand-mark" aria-hidden="true">&#10010;</span>
                    <span>
                        <span class="login-brand-name">MediGuard</span>
                        <span class="login-brand-caption">INVENTORY MANAGEMENT</span>
                    </span>
                </a>

                <div class="login-hero">
                    <span class="login-eyebrow">
                        <span class="login-eyebrow-dot"></span>
                        Inventory workspace
                    </span>

                    <h1>Manage your inventory with confidence.</h1>

                    <p>
                        A central workspace for tracking medicines, monitoring
                        stock levels, managing batches, and reviewing inventory
                        activity.
                    </p>

                    <div class="login-feature-list">
                        <div class="login-feature">
                            <span class="login-feature-icon" aria-hidden="true">&#10003;</span>
                            <span>Medicine and batch management</span>
                        </div>

                        <div class="login-feature">
                            <span class="login-feature-icon" aria-hidden="true">&#8599;</span>
                            <span>Stock receiving and issuing</span>
                        </div>

                        <div class="login-feature">
                            <span class="login-feature-icon" aria-hidden="true">&#9673;</span>
                            <span>Expiry monitoring and inventory reports</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="login-intro-footer">
                MediGuard Medicine Inventory Management System
            </div>
        </section>

        <section class="login-form-panel" aria-labelledby="loginTitle">
            <div class="login-form-heading">
                <p class="login-form-kicker">Welcome back</p>
                <h2 id="loginTitle">Sign in</h2>
                <p>Enter your registered credentials to access your workspace.</p>
            </div>

            <% if (loggedOut) { %>
                <div class="login-notice login-notice-success" role="status">
                    <span class="login-notice-icon" aria-hidden="true">&#10003;</span>
                    <span>You have been logged out successfully.</span>
                </div>
            <% } %>

            <% if (setupSuccess) { %>
                <div class="login-notice login-notice-info" role="status">
                    <span class="login-notice-icon" aria-hidden="true">&#8505;</span>
                    <span>Setup completed. You can now sign in.</span>
                </div>
            <% } %>

            <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                <div class="login-notice login-notice-error" role="alert">
                    <span class="login-notice-icon" aria-hidden="true">!</span>
                    <span><%= esc(errorMessage) %></span>
                </div>
            <% } %>

            <form class="login-form"
                  method="post"
                  action="<%= contextPath %>/login"
                  autocomplete="on">

                <div class="login-field">
                    <div class="login-label-row">
                        <label class="login-label" for="email">Email address</label>
                    </div>

                    <input class="login-input"
                           type="email"
                           id="email"
                           name="email"
                           maxlength="254"
                           placeholder="you@example.com"
                           autocomplete="username"
                           autocapitalize="none"
                           spellcheck="false"
                           required>
                </div>

                <div class="login-field">
                    <div class="login-label-row">
                        <label class="login-label" for="password">Password</label>
                    </div>

                    <div class="login-input-wrap">
                        <input class="login-input login-password-input"
                               type="password"
                               id="password"
                               name="password"
                               placeholder="Enter your password"
                               autocomplete="current-password"
                               required>

                        <button class="login-password-toggle"
                                type="button"
                                id="togglePassword"
                                aria-controls="password"
                                aria-pressed="false">
                            Show
                        </button>
                    </div>
                </div>

                <button class="login-submit" type="submit">
                    Sign in securely
                    <span aria-hidden="true">&#8594;</span>
                </button>
            </form>

            <div class="login-security-note">
                <span class="login-security-icon" aria-hidden="true">&#128274;</span>
                <span>
                    Use your assigned account credentials. For account access
                    issues, contact your system administrator.
                </span>
            </div>

            <div class="login-bottom">
                &copy; MediGuard. Medicine Inventory Management System.
            </div>
        </section>

    </div>
</main>

<script>
    (function () {
        "use strict";

        const passwordInput = document.getElementById("password");
        const toggleButton = document.getElementById("togglePassword");

        if (!passwordInput || !toggleButton) {
            return;
        }

        toggleButton.addEventListener("click", function () {
            const showingPassword = passwordInput.type === "password";

            passwordInput.type = showingPassword ? "text" : "password";
            toggleButton.textContent = showingPassword ? "Hide" : "Show";
            toggleButton.setAttribute(
                "aria-pressed",
                showingPassword ? "true" : "false"
            );
        });
    })();
</script>
</body>
</html>
