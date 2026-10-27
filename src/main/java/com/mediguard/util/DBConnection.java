
package com.mediguard.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBConnection {

    private static final String URL =
            "jdbc:oracle:thin:@//localhost:1521/XEPDB1";

    private static final String USERNAME = "SAMRIDDHI";

    // Use your existing local Oracle password.
    private static final String PASSWORD =
            "sam123";

    private DBConnection() {
    }

    public static Connection getConnection() throws SQLException {

        try {
            Class.forName("oracle.jdbc.OracleDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                    "Oracle JDBC driver is missing from the web application. " +
                    "Check the ojdbc11 Maven dependency and WAR packaging.",
                    e
            );
        }

        return DriverManager.getConnection(
                URL,
                USERNAME,
                PASSWORD
        );
    }

    public static void main(String[] args) {

        try (Connection connection = getConnection()) {

            System.out.println(
                    "MediGuard database connected successfully!"
            );

            System.out.println(
                    "Database: " +
                    connection.getMetaData().getDatabaseProductName()
            );

            System.out.println(
                    "Connected user: " +
                    connection.getMetaData().getUserName()
            );

        } catch (Exception e) {
            System.err.println("Database connection failed.");
            e.printStackTrace();
        }
    }
}
