
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

@WebServlet("/low-stock")
public class LowStockServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        List<LowStockRow> medicines = new ArrayList<>();

        int lowStockCount = 0;
        int outOfStockCount = 0;
        long totalReorderUnits = 0;

        String sql =
            "SELECT m.MEDICINE_ID, m.MEDICINE_NAME, m.CATEGORY, " +
            "m.UNIT_NAME, m.REORDER_LEVEL, " +
            "NVL(SUM(b.QUANTITY), 0) AS CURRENT_STOCK " +
            "FROM MGX26_MEDICINES m " +
            "LEFT JOIN MGX26_BATCHES b " +
            "ON m.MEDICINE_ID = b.MEDICINE_ID " +
            "GROUP BY m.MEDICINE_ID, m.MEDICINE_NAME, " +
            "m.CATEGORY, m.UNIT_NAME, m.REORDER_LEVEL " +
            "HAVING NVL(SUM(b.QUANTITY), 0) <= m.REORDER_LEVEL " +
            "ORDER BY NVL(SUM(b.QUANTITY), 0) ASC, m.MEDICINE_NAME";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {

            while (rs.next()) {
                LowStockRow row = new LowStockRow();

                row.setMedicineId(rs.getLong("MEDICINE_ID"));
                row.setMedicineName(rs.getString("MEDICINE_NAME"));
                row.setCategory(rs.getString("CATEGORY"));
                row.setUnitName(rs.getString("UNIT_NAME"));
                row.setReorderLevel(rs.getLong("REORDER_LEVEL"));
                row.setCurrentStock(rs.getLong("CURRENT_STOCK"));

                long suggested = Math.max(
                    0,
                    row.getReorderLevel() - row.getCurrentStock()
                );
                row.setSuggestedReorder(suggested);

                if (row.getCurrentStock() == 0) {
                    outOfStockCount++;
                }

                lowStockCount++;
                totalReorderUnits += suggested;
                medicines.add(row);
            }

            request.setAttribute("lowStockMedicines", medicines);
            request.setAttribute("lowStockCount", lowStockCount);
            request.setAttribute("outOfStockCount", outOfStockCount);
            request.setAttribute("totalReorderUnits", totalReorderUnits);

        } catch (SQLException e) {
            getServletContext().log("Unable to load low-stock alerts.", e);

            request.setAttribute(
                "errorMessage",
                "Unable to load low-stock alerts. Check the database connection and server log."
            );
            request.setAttribute("lowStockMedicines", medicines);
            request.setAttribute("lowStockCount", 0);
            request.setAttribute("outOfStockCount", 0);
            request.setAttribute("totalReorderUnits", 0L);
        }

        request.getRequestDispatcher("/low-stock.jsp")
               .forward(request, response);
    }

    public static class LowStockRow {
        private long medicineId;
        private String medicineName;
        private String category;
        private String unitName;
        private long reorderLevel;
        private long currentStock;
        private long suggestedReorder;

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

        public long getCurrentStock() {
            return currentStock;
        }

        public void setCurrentStock(long currentStock) {
            this.currentStock = currentStock;
        }

        public long getSuggestedReorder() {
            return suggestedReorder;
        }

        public void setSuggestedReorder(long suggestedReorder) {
            this.suggestedReorder = suggestedReorder;
        }

        public String getStatus() {
            return currentStock == 0 ? "Out of stock" : "Low stock";
        }
    }
}
