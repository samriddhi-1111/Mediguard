
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

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        List<MedicineRow> medicines = new ArrayList<>();

        int totalMedicines = 0;
        long totalUnits = 0;
        int lowStockMedicines = 0;
        int expiryAlerts = 0;
        String errorMessage = null;

        String summarySql =
                "SELECT " +
                " (SELECT COUNT(*) FROM MGX26_MEDICINES) AS TOTAL_MEDICINES, " +
                " (SELECT NVL(SUM(QUANTITY), 0) FROM MGX26_BATCHES) AS TOTAL_UNITS, " +
                " (SELECT COUNT(*) FROM MGX26_MEDICINES m " +
                "  WHERE m.REORDER_LEVEL > NVL(" +
                "    (SELECT SUM(b.QUANTITY) FROM MGX26_BATCHES b " +
                "     WHERE b.MEDICINE_ID = m.MEDICINE_ID), 0)) AS LOW_STOCK, " +
                " (SELECT COUNT(*) FROM MGX26_BATCHES " +
                "  WHERE EXPIRY_DATE < TRUNC(SYSDATE) + 30) AS EXPIRY_ALERTS " +
                "FROM DUAL";

        String inventorySql =
                "SELECT m.MEDICINE_ID, m.MEDICINE_NAME, m.CATEGORY, " +
                "m.UNIT_NAME, m.REORDER_LEVEL, b.BATCH_ID, " +
                "b.BATCH_NUMBER, b.QUANTITY, b.EXPIRY_DATE " +
                "FROM MGX26_MEDICINES m " +
                "LEFT JOIN MGX26_BATCHES b " +
                "ON m.MEDICINE_ID = b.MEDICINE_ID " +
                "ORDER BY m.MEDICINE_NAME, b.EXPIRY_DATE";

        try (Connection connection = DBConnection.getConnection()) {

            try (PreparedStatement statement =
                         connection.prepareStatement(summarySql);
                 ResultSet result = statement.executeQuery()) {

                if (result.next()) {
                    totalMedicines = result.getInt("TOTAL_MEDICINES");
                    totalUnits = result.getLong("TOTAL_UNITS");
                    lowStockMedicines = result.getInt("LOW_STOCK");
                    expiryAlerts = result.getInt("EXPIRY_ALERTS");
                }
            }

            try (PreparedStatement statement =
                         connection.prepareStatement(inventorySql);
                 ResultSet result = statement.executeQuery()) {

                while (result.next()) {
                    MedicineRow row = new MedicineRow();

                    row.setMedicineId(result.getLong("MEDICINE_ID"));
                    row.setMedicineName(result.getString("MEDICINE_NAME"));
                    row.setCategory(result.getString("CATEGORY"));
                    row.setUnitName(result.getString("UNIT_NAME"));
                    row.setReorderLevel(result.getLong("REORDER_LEVEL"));

                    long batchId = result.getLong("BATCH_ID");
                    row.setHasBatch(!result.wasNull());
                    row.setBatchId(batchId);

                    row.setBatchNumber(result.getString("BATCH_NUMBER"));
                    row.setQuantity(result.getLong("QUANTITY"));

                    java.sql.Date expiryDate =
                            result.getDate("EXPIRY_DATE");

                    row.setExpiryDate(
                            expiryDate == null ? null : expiryDate.toString());

                    medicines.add(row);
                }
            }

        } catch (SQLException e) {
            getServletContext().log(
                    "Unable to load MediGuard dashboard.", e);

            errorMessage =
                    "Unable to load inventory from the database. "
                    + "Please check the database connection.";
        }

        request.setAttribute("totalMedicines", totalMedicines);
        request.setAttribute("totalUnits", totalUnits);
        request.setAttribute("lowStockMedicines", lowStockMedicines);
        request.setAttribute("expiryAlerts", expiryAlerts);
        request.setAttribute("medicines", medicines);
        request.setAttribute("errorMessage", errorMessage);

        // Success message after adding a medicine
        if ("added".equals(request.getParameter("message"))) {
            request.setAttribute("successMessage",
                    "Medicine registered successfully!");
        }

        // Success message after receiving stock
        if ("success".equals(request.getParameter("stockReceived"))) {
            request.setAttribute("successMessage",
                    "Stock received successfully!");
        }

        // Success message after issuing stock
        if ("success".equals(request.getParameter("stockIssued"))) {
            request.setAttribute("successMessage",
                    "Stock issued successfully!");
        }
        
        if ("success".equals(request.getParameter("batchAdded"))) {
            request.setAttribute("successMessage",
                    "Medicine batch added successfully!");
        }

        request.getRequestDispatcher("/dashboard.jsp")
               .forward(request, response);
    }

    public static class MedicineRow {

        private long medicineId;
        private String medicineName;
        private String category;
        private String unitName;
        private long reorderLevel;
        private long batchId;
        private boolean hasBatch;
        private String batchNumber;
        private long quantity;
        private String expiryDate;

        public long getMedicineId() {
            return medicineId;
        }

        public void setMedicineId(long medicineId) {
            this.medicineId = medicineId;
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

        public long getReorderLevel() {
            return reorderLevel;
        }

        public void setReorderLevel(long reorderLevel) {
            this.reorderLevel = reorderLevel;
        }

        public long getBatchId() {
            return batchId;
        }

        public void setBatchId(long batchId) {
            this.batchId = batchId;
        }

        public boolean isHasBatch() {
            return hasBatch;
        }

        public void setHasBatch(boolean hasBatch) {
            this.hasBatch = hasBatch;
        }

        public String getBatchNumber() {
            return batchNumber;
        }

        public void setBatchNumber(String batchNumber) {
            this.batchNumber = batchNumber;
        }

        public long getQuantity() {
            return quantity;
        }

        public void setQuantity(long quantity) {
            this.quantity = quantity;
        }

        public String getExpiryDate() {
            return expiryDate;
        }

        public void setExpiryDate(String expiryDate) {
            this.expiryDate = expiryDate;
        }

        public String getStockStatus() {
            if (!hasBatch || quantity <= 0) {
                return "Out of stock";
            }

            if (quantity < reorderLevel) {
                return "Low stock";
            }

            return "In stock";
        }

        public String getExpiryStatus() {
            if (expiryDate == null) {
                return "No batch";
            }

            try {
                java.time.LocalDate expiry =
                        java.time.LocalDate.parse(expiryDate);

                java.time.LocalDate today =
                        java.time.LocalDate.now();

                if (expiry.isBefore(today)) {
                    return "Expired";
                }

                if (!expiry.isAfter(today.plusDays(30))) {
                    return "Expiring soon";
                }

                return "Valid";

            } catch (java.time.format.DateTimeParseException e) {
                return "Unknown";
            }
        }
    }
}
