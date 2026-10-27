
package com.mediguard.servlet;

import com.mediguard.util.DBConnection;
import com.mediguard.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@WebServlet("/user-management")
public class UserManagementServlet extends HttpServlet {

    public static class UserRow {
        private final long userId;
        private final String fullName;
        private final String email;
        private final String role;
        private final String createdAt;

        public UserRow(long userId, String fullName, String email,
                       String role, String createdAt) {
            this.userId = userId;
            this.fullName = fullName;
            this.email = email;
            this.role = role;
            this.createdAt = createdAt;
        }

        public long getUserId() { return userId; }
        public String getFullName() { return fullName; }
        public String getEmail() { return email; }
        public String getRole() { return role; }
        public String getCreatedAt() { return createdAt; }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        return session != null
                && session.getAttribute("userId") != null
                && "ADMIN".equals(
                    String.valueOf(session.getAttribute("userRole"))
                );
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Administrator access required."
            );
            return;
        }

        List<UserRow> users = new ArrayList<>();

        String sql =
            "SELECT USER_ID, FULL_NAME, EMAIL, USER_ROLE, " +
            "TO_CHAR(CREATED_AT, 'DD Mon YYYY HH24:MI') AS CREATED_LABEL " +
            "FROM MGX26_USERS ORDER BY USER_ID";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {

            while (rs.next()) {
                users.add(new UserRow(
                    rs.getLong("USER_ID"),
                    rs.getString("FULL_NAME"),
                    rs.getString("EMAIL"),
                    rs.getString("USER_ROLE"),
                    rs.getString("CREATED_LABEL")
                ));
            }

        } catch (SQLException ex) {
            throw new ServletException(
                "Unable to load registered users.", ex
            );
        }

        request.setAttribute("users", users);

        request.getRequestDispatcher("/user-management.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Administrator access required."
            );
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            createUser(request, response);
        } else if ("changeRole".equals(action)) {
            changeRole(request, response);
        } else {
            response.sendRedirect(
                request.getContextPath()
                + "/user-management?error=invalidAction"
            );
        }
    }

    private void createUser(HttpServletRequest request,
                            HttpServletResponse response)
            throws ServletException, IOException {

        String name = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String password = request.getParameter("password");
        String role = trim(request.getParameter("role"))
                .toUpperCase(Locale.ROOT);

        if (name.isEmpty()
                || email.isEmpty()
                || password == null
                || password.length() < 12
                || name.length() > 100
                || email.length() > 254
                || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")
                || !(role.equals("ADMIN") || role.equals("STAFF"))) {

            response.sendRedirect(
                request.getContextPath()
                + "/user-management?error=invalidInput"
            );
            return;
        }

        String sql =
            "INSERT INTO MGX26_USERS " +
            "(USER_ID, FULL_NAME, EMAIL, PASSWORD_HASH, USER_ROLE) " +
            "VALUES (MGX26_USER_SEQ.NEXTVAL, ?, ?, ?, ?)";

        try {
            String passwordHash =
                PasswordUtil.hashPassword(password.toCharArray());

            try (Connection connection = DBConnection.getConnection();
                 PreparedStatement statement =
                     connection.prepareStatement(sql)) {

                statement.setString(1, name);
                statement.setString(2, email);
                statement.setString(3, passwordHash);
                statement.setString(4, role);

                statement.executeUpdate();
            }

            response.sendRedirect(
                request.getContextPath()
                + "/user-management?message=created"
            );

        } catch (GeneralSecurityException ex) {
            throw new ServletException(
                "Unable to securely hash the password.", ex
            );

        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1) {
                response.sendRedirect(
                    request.getContextPath()
                    + "/user-management?error=duplicateEmail"
                );
            } else {
                throw new ServletException(
                    "Unable to create user. Check the database constraints.",
                    ex
                );
            }
        }
    }

    private void changeRole(HttpServletRequest request,
                            HttpServletResponse response)
            throws ServletException, IOException {

        long targetId;

        try {
            targetId = Long.parseLong(
                request.getParameter("userId")
            );
        } catch (Exception ex) {
            response.sendRedirect(
                request.getContextPath()
                + "/user-management?error=invalidInput"
            );
            return;
        }

        String newRole = trim(request.getParameter("role"))
                .toUpperCase(Locale.ROOT);

        if (!(newRole.equals("ADMIN") || newRole.equals("STAFF"))) {
            response.sendRedirect(
                request.getContextPath()
                + "/user-management?error=invalidInput"
            );
            return;
        }

        HttpSession session = request.getSession(false);
        long currentId =
            ((Number) session.getAttribute("userId")).longValue();

        if (currentId == targetId && newRole.equals("STAFF")) {
            response.sendRedirect(
                request.getContextPath()
                + "/user-management?error=selfDemotion"
            );
            return;
        }

        try (Connection connection = DBConnection.getConnection()) {
            connection.setAutoCommit(false);

            try {
                if (newRole.equals("STAFF")) {
                    String checkSql =
                        "SELECT USER_ROLE FROM MGX26_USERS " +
                        "WHERE USER_ID = ? FOR UPDATE";

                    try (PreparedStatement check =
                            connection.prepareStatement(checkSql)) {

                        check.setLong(1, targetId);

                        try (ResultSet rs = check.executeQuery()) {
                            if (!rs.next()) {
                                connection.rollback();
                                response.sendRedirect(
                                    request.getContextPath()
                                    + "/user-management?error=userNotFound"
                                );
                                return;
                            }

                            String currentRole = rs.getString("USER_ROLE");

                            if ("ADMIN".equalsIgnoreCase(currentRole)) {
                                try (PreparedStatement count =
                                    connection.prepareStatement(
                                        "SELECT COUNT(*) FROM MGX26_USERS " +
                                        "WHERE UPPER(USER_ROLE) = 'ADMIN'"
                                    );
                                     ResultSet countRs = count.executeQuery()) {

                                    if (countRs.next()
                                            && countRs.getInt(1) <= 1) {
                                        connection.rollback();
                                        response.sendRedirect(
                                            request.getContextPath()
                                            + "/user-management?error=lastAdmin"
                                        );
                                        return;
                                    }
                                }
                            }
                        }
                    }
                }

                String updateSql =
                    "UPDATE MGX26_USERS SET USER_ROLE = ? " +
                    "WHERE USER_ID = ?";

                try (PreparedStatement update =
                        connection.prepareStatement(updateSql)) {

                    update.setString(1, newRole);
                    update.setLong(2, targetId);

                    if (update.executeUpdate() != 1) {
                        connection.rollback();
                        response.sendRedirect(
                            request.getContextPath()
                            + "/user-management?error=userNotFound"
                        );
                        return;
                    }
                }

                connection.commit();

            } catch (SQLException ex) {
                connection.rollback();
                throw ex;

            } finally {
                connection.setAutoCommit(true);
            }

            response.sendRedirect(
                request.getContextPath()
                + "/user-management?message=roleUpdated"
            );

        } catch (SQLException ex) {
            throw new ServletException(
                "Unable to update user role.", ex
            );
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
