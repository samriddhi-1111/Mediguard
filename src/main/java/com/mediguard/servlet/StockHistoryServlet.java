
package com.mediguard.servlet;

import com.mediguard.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "StockHistoryServlet", urlPatterns = {"/stock-history"})
public class StockHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        List<StockTransaction> transactions = new ArrayList<>();
        String errorMessage = null;

        String sql =
            "SELECT l.LOG_ID, l.BATCH_ID, m.MEDICINE_NAME, " +
            "b.BATCH_NUMBER, l.ACTION_TYPE, l.QUANTITY, " +
            "l.REASON, l.ACTION_BY, l.ACTION_AT " +
            "FROM MGX26_STOCK_LOG l " +
            "LEFT JOIN MGX26_BATCHES b ON b.BATCH_ID = l.BATCH_ID " +
            "LEFT JOIN MGX26_MEDICINES m ON m.MEDICINE_ID = b.MEDICINE_ID " +
            "ORDER BY l.ACTION_AT DESC, l.LOG_ID DESC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {

            while (result.next()) {
                StockTransaction transaction = new StockTransaction();

                transaction.setLogId(result.getLong("LOG_ID"));
                transaction.setBatchId(result.getLong("BATCH_ID"));
                transaction.setMedicineName(result.getString("MEDICINE_NAME"));
                transaction.setBatchNumber(result.getString("BATCH_NUMBER"));
                transaction.setActionType(result.getString("ACTION_TYPE"));
                transaction.setQuantity(result.getLong("QUANTITY"));
                transaction.setReason(result.getString("REASON"));
                transaction.setActionBy(result.getString("ACTION_BY"));

                Timestamp timestamp = result.getTimestamp("ACTION_AT");

                transaction.setActionAt(
                    timestamp == null ? "—" : timestamp.toString()
                );

                transactions.add(transaction);
            }

        } catch (SQLException e) {
            getServletContext().log(
                "Unable to load MediGuard stock history.", e);

            errorMessage =
                "Unable to load transaction history. Check the database connection.";
        }

        request.setAttribute("transactions", transactions);
        request.setAttribute("errorMessage", errorMessage);

        request.getRequestDispatcher("/stock-history.jsp")
               .forward(request, response);
    }

    public static class StockTransaction {

        private long logId;
        private long batchId;
        private String medicineName;
        private String batchNumber;
        private String actionType;
        private long quantity;
        private String reason;
        private String actionBy;
        private String actionAt;

        public long getLogId() { return logId; }
        public void setLogId(long logId) { this.logId = logId; }

        public long getBatchId() { return batchId; }
        public void setBatchId(long batchId) { this.batchId = batchId; }

        public String getMedicineName() { return medicineName; }
        public void setMedicineName(String medicineName) {
            this.medicineName = medicineName;
        }

        public String getBatchNumber() { return batchNumber; }
        public void setBatchNumber(String batchNumber) {
            this.batchNumber = batchNumber;
        }

        public String getActionType() { return actionType; }
        public void setActionType(String actionType) {
            this.actionType = actionType;
        }

        public long getQuantity() { return quantity; }
        public void setQuantity(long quantity) { this.quantity = quantity; }

        public String getReason() { return reason; }
        public void setReason(String reason) { this.reason = reason; }

        public String getActionBy() { return actionBy; }
        public void setActionBy(String actionBy) { this.actionBy = actionBy; }

        public String getActionAt() { return actionAt; }
        public void setActionAt(String actionAt) { this.actionAt = actionAt; }
    }
}
