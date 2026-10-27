
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

@WebServlet(name = "ReceiveStockServlet", urlPatterns = {"/receive-stock"})
public class ReceiveStockServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String sql =
            "SELECT b.BATCH_ID, m.MEDICINE_NAME, b.BATCH_NUMBER, " +
            "b.QUANTITY FROM MGX26_BATCHES b " +
            "JOIN MGX26_MEDICINES m ON m.MEDICINE_ID = b.MEDICINE_ID " +
            "ORDER BY m.MEDICINE_NAME, b.BATCH_ID";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {

            java.util.List<BatchOption> batches = new java.util.ArrayList<>();

            while (result.next()) {
                batches.add(new BatchOption(
                    result.getLong("BATCH_ID"),
                    result.getString("MEDICINE_NAME"),
                    result.getString("BATCH_NUMBER"),
                    result.getLong("QUANTITY")
                ));
            }

            request.setAttribute("batches", batches);

        } catch (SQLException e) {
            getServletContext().log("Could not load medicine batches.", e);
            request.setAttribute("errorMessage",
                "Unable to load batches. Check your Oracle database connection.");
        }

        request.getRequestDispatcher("/receive-stock.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            long batchId = Long.parseLong(request.getParameter("batchId"));
            long quantity = Long.parseLong(request.getParameter("quantity"));
            String reason = request.getParameter("reason");

            if (batchId <= 0 || quantity <= 0) {
                throw new IllegalArgumentException(
                    "Select a valid batch and enter a quantity greater than zero.");
            }

            if (reason == null || reason.trim().isEmpty()) {
                throw new IllegalArgumentException(
                    "Please enter a reason for receiving stock.");
            }

            if (reason.trim().length() > 200) {
                throw new IllegalArgumentException(
                    "The reason cannot exceed 200 characters.");
            }

            /*
             * Use a database sequence for a unique log ID.
             * This assumes MGX26_STOCK_LOG has a LOG_ID column
             * and MGX26_AUDIT_SEQ is available to this schema.
             */
            long logId;

            try (Connection connection = DBConnection.getConnection();
                 PreparedStatement statement = connection.prepareStatement(
                     "SELECT MGX26_AUDIT_SEQ.NEXTVAL FROM DUAL");
                 ResultSet result = statement.executeQuery()) {

                if (!result.next()) {
                    throw new SQLException("Could not generate a stock log ID.");
                }

                logId = result.getLong(1);
            }

            try (Connection connection = DBConnection.getConnection();
                 CallableStatement statement = connection.prepareCall(
                     "{ call MGX26_RECEIVE_STOCK(?, ?, ?, ?) }")) {

                statement.setLong(1, logId);
                statement.setLong(2, batchId);
                statement.setLong(3, quantity);
                statement.setString(4, reason.trim());

                statement.execute();
            }

            response.sendRedirect(
                request.getContextPath() + "/dashboard?stockReceived=success");
            return;

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage",
                "Please select a batch and enter a whole-number quantity.");

        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());

        } catch (SQLException e) {
            getServletContext().log("Failed to receive stock.", e);
            request.setAttribute("errorMessage",
                "Stock could not be received. Check the server log for the database error.");
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

        public long getBatchId() { return batchId; }
        public String getMedicineName() { return medicineName; }
        public String getBatchNumber() { return batchNumber; }
        public long getQuantity() { return quantity; }
    }
}
