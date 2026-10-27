
package com.mediguard.servlet;

import com.mediguard.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/stock-valuation")
public class StockValuationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        List<ValuationRow> rows = new ArrayList<>();

        BigDecimal totalStockValue = BigDecimal.ZERO;
        long totalUnits = 0;
        int totalMedicines = 0;
        int totalBatches = 0;

        String sql =
            "SELECT m.MEDICINE_ID, m.MEDICINE_NAME, m.CATEGORY, " +
            "m.UNIT_NAME, " +
            "COUNT(b.BATCH_ID) AS BATCH_COUNT, " +
            "NVL(SUM(b.QUANTITY), 0) AS TOTAL_QUANTITY, " +
            "NVL(SUM(b.QUANTITY * b.UNIT_COST), 0) AS STOCK_VALUE " +
            "FROM MGX26_MEDICINES m " +
            "LEFT JOIN MGX26_BATCHES b " +
            "ON m.MEDICINE_ID = b.MEDICINE_ID " +
            "GROUP BY m.MEDICINE_ID, m.MEDICINE_NAME, " +
            "m.CATEGORY, m.UNIT_NAME " +
            "ORDER BY m.MEDICINE_NAME";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {

            while (rs.next()) {
                ValuationRow row = new ValuationRow();

                row.setMedicineId(rs.getLong("MEDICINE_ID"));
                row.setMedicineName(rs.getString("MEDICINE_NAME"));
                row.setCategory(rs.getString("CATEGORY"));
                row.setUnitName(rs.getString("UNIT_NAME"));
                row.setBatchCount(rs.getInt("BATCH_COUNT"));
                row.setQuantity(rs.getLong("TOTAL_QUANTITY"));

                BigDecimal value = rs.getBigDecimal("STOCK_VALUE");
                if (value == null) {
                    value = BigDecimal.ZERO;
                }

                row.setStockValue(value);

                rows.add(row);

                totalMedicines++;
                totalBatches += row.getBatchCount();
                totalUnits += row.getQuantity();
                totalStockValue = totalStockValue.add(value);
            }

            request.setAttribute("valuationRows", rows);
            request.setAttribute("totalStockValue", totalStockValue);
            request.setAttribute("totalUnits", totalUnits);
            request.setAttribute("totalMedicines", totalMedicines);
            request.setAttribute("totalBatches", totalBatches);

        } catch (SQLException e) {
            getServletContext().log(
                "Unable to load stock valuation report.", e
            );

            request.setAttribute(
                "errorMessage",
                "Unable to load the stock valuation report. " +
                "Please check the database connection and server log."
            );

            request.setAttribute("valuationRows", rows);
            request.setAttribute("totalStockValue", BigDecimal.ZERO);
            request.setAttribute("totalUnits", 0L);
            request.setAttribute("totalMedicines", 0);
            request.setAttribute("totalBatches", 0);
        }

        request.getRequestDispatcher("/stock-valuation.jsp")
               .forward(request, response);
    }

    public static class ValuationRow {
        private long medicineId;
        private String medicineName;
        private String category;
        private String unitName;
        private int batchCount;
        private long quantity;
        private BigDecimal stockValue = BigDecimal.ZERO;

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

        public int getBatchCount() {
            return batchCount;
        }

        public void setBatchCount(int batchCount) {
            this.batchCount = batchCount;
        }

        public long getQuantity() {
            return quantity;
        }

        public void setQuantity(long quantity) {
            this.quantity = quantity;
        }

        public BigDecimal getStockValue() {
            return stockValue;
        }

        public void setStockValue(BigDecimal stockValue) {
            this.stockValue = stockValue;
        }
    }
}
