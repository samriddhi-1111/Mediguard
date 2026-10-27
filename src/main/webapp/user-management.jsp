
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mediguard.servlet.UserManagementServlet.UserRow" %>

<%!
    private String esc(Object value) {
        if (value == null) return "";

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;");
    }
%>

<%
    List<UserRow> users =
        (List<UserRow>) request.getAttribute("users");

    if (users == null) {
        users = java.util.Collections.emptyList();
    }

    String ctx = request.getContextPath();

    String message = request.getParameter("message");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>User Management | MediGuard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/mediguard.css">

    <style>
        .user-management-page {
            min-height: 100vh;
            background: var(--mg-bg);
        }

        .user-management-header {
            background: var(--mg-primary);
            color: #ffffff;
            padding: 22px 6%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            flex-wrap: wrap;
        }

        .user-management-header h1 {
            margin: 0;
            color: #ffffff;
            font-size: 24px;
        }

        .user-management-header p {
            margin: 6px 0 0;
            color: #dbeafe;
        }

        .user-management-header-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .user-management-header-actions a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 10px 14px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: background 0.2s ease;
        }

        .user-management-dashboard-link {
            background: #ffffff;
            color: var(--mg-primary);
        }

        .user-management-dashboard-link:hover {
            background: #eff6ff;
        }

        .user-management-logout-link {
            background: #fee2e2;
            color: #991b1b;
        }

        .user-management-logout-link:hover {
            background: #fecaca;
        }

        .user-management-main {
            padding: 28px 6%;
            display: grid;
            grid-template-columns: minmax(280px, 360px) minmax(0, 1fr);
            gap: 24px;
            align-items: start;
        }

        .user-management-card {
            min-width: 0;
            background: var(--mg-surface);
            border: 1px solid var(--mg-border);
            border-radius: var(--mg-radius);
            padding: 24px;
            box-shadow: var(--mg-shadow);
        }

        .user-management-card h2 {
            margin: 0 0 12px;
            font-size: 20px;
            color: var(--mg-primary);
        }

        .user-management-note {
            margin: 0 0 16px;
            color: var(--mg-muted);
            font-size: 12px;
            line-height: 1.6;
        }

        .user-management-field {
            margin-bottom: 15px;
        }

        .user-management-field label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 7px;
            color: var(--mg-text);
        }

        .user-management-field input,
        .user-management-field select {
            box-sizing: border-box;
            width: 100%;
            min-width: 0;
            padding: 11px 12px;
            border: 1px solid var(--mg-border);
            border-radius: 8px;
            background: #ffffff;
            color: var(--mg-text);
            font: inherit;
            font-size: 14px;
        }

        .user-management-field input:focus,
        .user-management-field select:focus {
            outline: none;
            border-color: var(--mg-accent);
            box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.12);
        }

        .user-management-submit {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            min-height: 45px;
            margin-top: 5px;
            padding: 11px 14px;
            border: none;
            border-radius: 8px;
            background: var(--mg-primary);
            color: #ffffff;
            font: inherit;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s ease;
        }

        .user-management-submit:hover {
            background: var(--mg-primary-dark);
        }

        .user-management-message {
            padding: 12px 14px;
            border-radius: 8px;
            margin-bottom: 16px;
            font-size: 13px;
            line-height: 1.5;
        }

        .user-management-success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .user-management-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .user-management-table-wrap {
            width: 100%;
            overflow-x: auto;
            border: 1px solid var(--mg-border);
            border-radius: 9px;
        }

        .user-management-table {
            width: 100%;
            min-width: 850px;
            border-collapse: separate;
            border-spacing: 0;
            text-align: left;
        }

        .user-management-table th,
        .user-management-table td {
            padding: 13px 12px;
            border-bottom: 1px solid var(--mg-border);
            font-size: 13px;
            vertical-align: middle;
        }

        .user-management-table th {
            background: #f8fafc;
            color: #475569;
            font-weight: 700;
            white-space: nowrap;
        }

        .user-management-table tbody tr:last-child td {
            border-bottom: none;
        }

        .user-management-table tbody tr:hover {
            background: #f8fafc;
        }

        .user-management-table th:last-child,
        .user-management-table td:last-child {
            width: 205px;
            min-width: 205px;
        }

        .user-management-role {
            display: inline-block;
            padding: 5px 9px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            background: #dbeafe;
            color: #1e40af;
            white-space: nowrap;
        }

        .user-management-role-staff {
            background: #dcfce7;
            color: #166534;
        }

        .user-management-role-form {
            display: grid;
            grid-template-columns: minmax(100px, 1fr) auto;
            gap: 8px;
            align-items: center;
            width: 100%;
            margin: 0;
        }

        .user-management-role-form select {
            box-sizing: border-box;
            width: 100%;
            min-width: 100px;
            height: 42px;
            padding: 8px;
            border: 1px solid var(--mg-border);
            border-radius: 8px;
            background: #ffffff;
            color: var(--mg-text);
            font: inherit;
            font-size: 13px;
        }

        .user-management-role-form select:focus {
            outline: none;
            border-color: var(--mg-accent);
        }

        .user-management-role-form button {
            min-width: 76px;
            height: 42px;
            padding: 10px 13px;
            border: none;
            border-radius: 8px;
            background: var(--mg-primary);
            color: #ffffff;
            font: inherit;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
        }

        .user-management-role-form button:hover {
            background: var(--mg-primary-dark);
        }

        .user-management-empty {
            padding: 22px !important;
            text-align: center;
            color: var(--mg-muted);
        }

        @media (max-width: 1150px) {
            .user-management-main {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 550px) {
            .user-management-header {
                padding: 20px 4%;
            }

            .user-management-main {
                padding: 20px 4%;
                gap: 16px;
            }

            .user-management-card {
                padding: 17px;
            }

            .user-management-header-actions {
                width: 100%;
            }
        }
    </style>
</head>

<body>
<div class="user-management-page">

     <header class="mg-standard-header">
    <div class="mg-brand">
        <h1>MediGuard</h1>
        <p>User Management</p>
    </div>

    <a class="mg-dashboard-button"
       href="${pageContext.request.contextPath}/dashboard">
        Dashboard
    </a>
</header>


    <main class="user-management-main">

        <section class="user-management-card">
            <h2>Create User</h2>

            <p class="user-management-note">
                New passwords must contain at least 12 characters.
                Passwords are saved as PBKDF2 hashes.
            </p>

            <form method="post"
                  action="<%= ctx %>/user-management"
                  autocomplete="off">

                <input type="hidden" name="action" value="create">

                <div class="user-management-field">
                    <label for="fullName">Full name</label>
                    <input id="fullName"
                           name="fullName"
                           maxlength="100"
                           required>
                </div>

                <div class="user-management-field">
                    <label for="email">Email address</label>
                    <input id="email"
                           name="email"
                           type="email"
                           maxlength="254"
                           required>
                </div>

                <div class="user-management-field">
                    <label for="password">Temporary password</label>
                    <input id="password"
                           name="password"
                           type="password"
                           minlength="12"
                           required
                           autocomplete="new-password">
                </div>

                <div class="user-management-field">
                    <label for="role">Role</label>
                    <select id="role" name="role" required>
                        <option value="STAFF" selected>Staff</option>
                        <option value="ADMIN">Admin</option>
                    </select>
                </div>

                <button class="user-management-submit" type="submit">
                    Create User
                </button>
            </form>
        </section>

        <section class="user-management-card">
            <h2>Registered Users (<%= users.size() %>)</h2>

            <% if ("created".equals(message)) { %>
                <div class="user-management-message user-management-success"
                     role="status">
                    User account created successfully.
                </div>
            <% } %>

            <% if ("roleUpdated".equals(message)) { %>
                <div class="user-management-message user-management-success"
                     role="status">
                    User role updated successfully.
                </div>
            <% } %>

            <% if (error != null) { %>
                <div class="user-management-message user-management-error"
                     role="alert">
                    <% if ("duplicateEmail".equals(error)) { %>
                        That email may already be registered. Use a unique email address.
                    <% } else if ("selfDemotion".equals(error)) { %>
                        You cannot change your own role from Admin to Staff.
                    <% } else if ("lastAdmin".equals(error)) { %>
                        The last administrator cannot be changed to Staff.
                    <% } else if ("userNotFound".equals(error)) { %>
                        The selected user was not found.
                    <% } else if ("invalidInput".equals(error)) { %>
                        Please check all fields. Passwords must have at least 12 characters.
                    <% } else { %>
                        The requested action could not be completed.
                    <% } %>
                </div>
            <% } %>

            <div class="user-management-table-wrap">
                <table class="user-management-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Created</th>
                            <th>Change Role</th>
                        </tr>
                    </thead>

                    <tbody>
                        <% if (users.isEmpty()) { %>
                            <tr>
                                <td colspan="6" class="user-management-empty">
                                    No users found.
                                </td>
                            </tr>
                        <% } else {
                            for (UserRow user : users) {
                        %>
                            <tr>
                                <td><%= user.getUserId() %></td>

                                <td><%= esc(user.getFullName()) %></td>

                                <td><%= esc(user.getEmail()) %></td>

                                <td>
                                    <span class="user-management-role <%= "STAFF".equalsIgnoreCase(user.getRole()) ? "user-management-role-staff" : "" %>">
                                        <%= esc(user.getRole()) %>
                                    </span>
                                </td>

                                <td><%= esc(user.getCreatedAt()) %></td>

                                <td>
                                    <form class="user-management-role-form"
                                          method="post"
                                          action="<%= ctx %>/user-management">

                                        <input type="hidden"
                                               name="action"
                                               value="changeRole">

                                        <input type="hidden"
                                               name="userId"
                                               value="<%= user.getUserId() %>">

                                        <select name="role"
                                                aria-label="Role for <%= esc(user.getFullName()) %>">
                                            <option value="ADMIN"
                                                <%= "ADMIN".equalsIgnoreCase(user.getRole()) ? "selected" : "" %>>
                                                Admin
                                            </option>

                                            <option value="STAFF"
                                                <%= "STAFF".equalsIgnoreCase(user.getRole()) ? "selected" : "" %>>
                                                Staff
                                            </option>
                                        </select>

                                        <button type="submit">Save</button>
                                    </form>
                                </td>
                            </tr>
                        <%  }
                           } %>
                    </tbody>
                </table>
            </div>
        </section>

    </main>
</div>
</body>
</html>
