
package com.mediguard.servlet;

import com.mediguard.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "IssueStockServlet", urlPatterns = {"/issue-stock"})
public class IssueStockServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String sql =
            "SELECT b.BATCH_ID, m.MEDICINE_NAME, b.BATCH_NUMBER, " +
            "b.QUANTITY FROM MGX26_BATCHES b " +
            "JOIN MGX26_MEDICINES m " +
            "ON m.MEDICINE_ID = b.MEDICINE_ID " +
            "ORDER BY m.MEDICINE_NAME, b.BATCH_ID";

        List<BatchOption> batches = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {

            while (result.next()) {
                batches.add(new BatchOption(
                    result.getLong("BATCH_ID"),
                    result.getString("MEDICINE_NAME"),
                    result.getString("BATCH_NUMBER"),
                    result.getLong("QUANTITY")
                ));
            }

        } catch (SQLException e) {
            getServletContext().log("Could not load stock batches.", e);
            request.setAttribute("errorMessage",
                "Unable to load batches. Check the database connection.");
        }

        request.setAttribute("batches", batches);
        request.getRequestDispatcher("/issue-stock.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            String batchText = request.getParameter("batchId");
            String quantityText = request.getParameter("quantity");
            String reason = request.getParameter("reason");

            if (batchText == null || quantityText == null
                    || reason == null) {
                throw new IllegalArgumentException(
                    "Please complete all required fields.");
            }

            long batchId = Long.parseLong(batchText.trim());
            long quantity = Long.parseLong(quantityText.trim());
            reason = reason.trim();

            if (batchId <= 0 || quantity <= 0) {
                throw new IllegalArgumentException(
                    "Select a batch and enter a quantity greater than zero.");
            }

            if (reason.isEmpty()) {
                throw new IllegalArgumentException(
                    "Please enter a reason for issuing stock.");
            }

            if (reason.length() > 200) {
                throw new IllegalArgumentException(
                    "The reason cannot exceed 200 characters.");
            }

            /*
             * Check the selected batch and its current stock.
             * The PL/SQL procedure must also enforce stock availability.
             */
            try (Connection connection = DBConnection.getConnection();
                 PreparedStatement statement = connection.prepareStatement(
                     "SELECT QUANTITY FROM MGX26_BATCHES " +
                     "WHERE BATCH_ID = ?")) {

                statement.setLong(1, batchId);

                try (ResultSet result = statement.executeQuery()) {
                    if (!result.next()) {
                        throw new IllegalArgumentException(
                            "The selected batch does not exist.");
                    }

                    long available = result.getLong("QUANTITY");

                    if (quantity > available) {
                        throw new IllegalArgumentException(
                            "Insufficient stock. Available quantity: "
                            + available);
                    }
                }
            }

            long logId;

            try (Connection connection = DBConnection.getConnection();
                 PreparedStatement statement = connection.prepareStatement(
                     "SELECT MGX26_AUDIT_SEQ.NEXTVAL FROM DUAL");
                 ResultSet result = statement.executeQuery()) {

                if (!result.next()) {
                    throw new SQLException(
                        "Could not generate the stock transaction ID.");
                }

                logId = result.getLong(1);
            }

            try (Connection connection = DBConnection.getConnection();
                 CallableStatement statement = connection.prepareCall(
                     "{ call MGX26_ISSUE_STOCK(?, ?, ?, ?) }")) {

                statement.setLong(1, logId);
                statement.setLong(2, batchId);
                statement.setLong(3, quantity);
                statement.setString(4, reason);

                statement.execute();
            }

            response.sendRedirect(
                request.getContextPath()
                + "/dashboard?stockIssued=success");
            return;

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage",
                "Batch ID and quantity must be valid whole numbers.");

        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());

        } catch (SQLException e) {
            getServletContext().log("Unable to issue medicine stock.", e);
            request.setAttribute("errorMessage",
                "Stock could not be issued. Check the server log for details.");
        }

        doGet(request, response);
    }

    public static class BatchOption {

        private final long batchId;
        private final String medicineName;
        private final String batchNumber;
        private final long quantity;

        public BatchOption(long batchId, String medicineName,
                           String batchNumber, long quantity) {
            this.batchId = batchId;
            this.medicineName = medicineName;
            this.batchNumber = batchNumber;
            this.quantity = quantity;
        }

        public long getBatchId() {
            return batchId;
        }

        public String getMedicineName() {
            return medicineName;
        }

        public String getBatchNumber() {
            return batchNumber;
        }

        public long getQuantity() {
            return quantity;
        }
    }
}
