
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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/expiry-management")
public class ExpiryManagementServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String status = request.getParameter("status");

        if (status == null || status.isBlank()) {
            status = "all";
        }

        List<ExpiryBatch> batches = new ArrayList<>();

        int expiredCount = 0;
        int expiringCount = 0;
        int safeCount = 0;

        String sql =
            "SELECT b.BATCH_ID, b.BATCH_NUMBER, " +
            "m.MEDICINE_NAME, m.CATEGORY, m.UNIT_NAME, " +
            "b.QUANTITY, b.EXPIRY_DATE, " +
            "CASE " +
            " WHEN TRUNC(b.EXPIRY_DATE) < TRUNC(SYSDATE) " +
            " THEN 'Expired' " +
            " WHEN TRUNC(b.EXPIRY_DATE) <= TRUNC(SYSDATE) + 30 " +
            " THEN 'Expiring Soon' " +
            " ELSE 'Safe' " +
            "END AS EXPIRY_STATUS, " +
            "TRUNC(b.EXPIRY_DATE) - TRUNC(SYSDATE) AS DAYS_LEFT " +
            "FROM MGX26_BATCHES b " +
            "JOIN MGX26_MEDICINES m ON m.MEDICINE_ID = b.MEDICINE_ID " +
            "WHERE (? = 'all' " +
            " OR (? = 'expired' AND TRUNC(b.EXPIRY_DATE) < TRUNC(SYSDATE)) " +
            " OR (? = 'expiring' AND TRUNC(b.EXPIRY_DATE) >= TRUNC(SYSDATE) " +
            "     AND TRUNC(b.EXPIRY_DATE) <= TRUNC(SYSDATE) + 30) " +
            " OR (? = 'safe' AND TRUNC(b.EXPIRY_DATE) > TRUNC(SYSDATE) + 30)) " +
            "ORDER BY b.EXPIRY_DATE ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setString(2, status);
            statement.setString(3, status);
            statement.setString(4, status);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    ExpiryBatch batch = new ExpiryBatch();

                    batch.setBatchId(rs.getLong("BATCH_ID"));
                    batch.setBatchNumber(rs.getString("BATCH_NUMBER"));
                    batch.setMedicineName(rs.getString("MEDICINE_NAME"));
                    batch.setCategory(rs.getString("CATEGORY"));
                    batch.setUnitName(rs.getString("UNIT_NAME"));
                    batch.setQuantity(rs.getInt("QUANTITY"));
                    batch.setExpiryDate(rs.getDate("EXPIRY_DATE"));
                    batch.setExpiryStatus(rs.getString("EXPIRY_STATUS"));
                    batch.setDaysLeft(rs.getInt("DAYS_LEFT"));

                    batches.add(batch);

                    switch (batch.getExpiryStatus()) {
                        case "Expired" -> expiredCount++;
                        case "Expiring Soon" -> expiringCount++;
                        default -> safeCount++;
                    }
                }
            }

            request.setAttribute("batches", batches);
            request.setAttribute("expiredCount", expiredCount);
            request.setAttribute("expiringCount", expiringCount);
            request.setAttribute("safeCount", safeCount);
            request.setAttribute("selectedStatus", status);

        } catch (SQLException e) {
            getServletContext().log("Unable to load expiry management.", e);
            request.setAttribute(
                "errorMessage",
                "Unable to load expiry records. Please check the database connection."
            );
            request.setAttribute("batches", batches);
            request.setAttribute("expiredCount", 0);
            request.setAttribute("expiringCount", 0);
            request.setAttribute("safeCount", 0);
            request.setAttribute("selectedStatus", status);
        }

        request.getRequestDispatcher("/expiry-management.jsp")
               .forward(request, response);
    }

    public static class ExpiryBatch {
        private long batchId;
        private String batchNumber;
        private String medicineName;
        private String category;
        private String unitName;
        private int quantity;
        private java.sql.Date expiryDate;
        private String expiryStatus;
        private int daysLeft;

        public long getBatchId() {
            return batchId;
        }

        public void setBatchId(long batchId) {
            this.batchId = batchId;
        }

        public String getBatchNumber() {
            return batchNumber;
        }

        public void setBatchNumber(String batchNumber) {
            this.batchNumber = batchNumber;
        }

        public String getMedicineName() {
            return medicineName;
        }

        public void setMedicineName(String medicineName) {
            this.medicineName = medicineName;
        }

        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public String getUnitName() {
            return unitName;
        }

        public void setUnitName(String unitName) {
            this.unitName = unitName;
        }

        public int getQuantity() {
            return quantity;
        }

        public void setQuantity(int quantity) {
            this.quantity = quantity;
        }

        public java.sql.Date getExpiryDate() {
            return expiryDate;
        }

        public void setExpiryDate(java.sql.Date expiryDate) {
            this.expiryDate = expiryDate;
        }

        public String getExpiryStatus() {
            return expiryStatus;
        }

        public void setExpiryStatus(String expiryStatus) {
            this.expiryStatus = expiryStatus;
        }

        public int getDaysLeft() {
            return daysLeft;
        }

        public void setDaysLeft(int daysLeft) {
            this.daysLeft = daysLeft;
        }
    }
}
