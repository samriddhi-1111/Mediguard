
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

@WebServlet(name = "MedicineSearchServlet",
            urlPatterns = {"/medicine-search"})
public class MedicineSearchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String category = request.getParameter("category");
        String stockStatus = request.getParameter("stockStatus");

        if (search == null) search = "";
        if (category == null) category = "";
        if (stockStatus == null) stockStatus = "";

        search = search.trim();
        category = category.trim();
        stockStatus = stockStatus.trim();

        request.setAttribute("search", search);
        request.setAttribute("category", category);
        request.setAttribute("stockStatus", stockStatus);

        List<MedicineResult> medicines = new ArrayList<>();
        String errorMessage = null;

        String sql =
            "SELECT m.MEDICINE_ID, m.MEDICINE_NAME, m.CATEGORY, " +
            "m.UNIT_NAME, m.REORDER_LEVEL, " +
            "NVL(SUM(b.QUANTITY), 0) AS TOTAL_QUANTITY, " +
            "LISTAGG(b.BATCH_NUMBER, ', ') " +
            "WITHIN GROUP (ORDER BY b.BATCH_ID) AS BATCH_NUMBERS " +
            "FROM MGX26_MEDICINES m " +
            "LEFT JOIN MGX26_BATCHES b " +
            "ON m.MEDICINE_ID = b.MEDICINE_ID " +
            "WHERE UPPER(m.MEDICINE_NAME) LIKE UPPER(?) " +
            "AND (? IS NULL OR m.CATEGORY = ?) " +
            "GROUP BY m.MEDICINE_ID, m.MEDICINE_NAME, " +
            "m.CATEGORY, m.UNIT_NAME, m.REORDER_LEVEL " +
            "ORDER BY m.MEDICINE_NAME";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, "%" + search + "%");
            statement.setString(2, category.isEmpty() ? null : category);
            statement.setString(3, category.isEmpty() ? null : category);

            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    MedicineResult medicine = new MedicineResult();

                    medicine.setMedicineId(
                        result.getLong("MEDICINE_ID"));
                    medicine.setMedicineName(
                        result.getString("MEDICINE_NAME"));
                    medicine.setCategory(
                        result.getString("CATEGORY"));
                    medicine.setUnitName(
                        result.getString("UNIT_NAME"));
                    medicine.setReorderLevel(
                        result.getLong("REORDER_LEVEL"));
                    medicine.setQuantity(
                        result.getLong("TOTAL_QUANTITY"));
                    medicine.setBatchNumbers(
                        result.getString("BATCH_NUMBERS"));

                    medicines.add(medicine);
                }
            }

        } catch (SQLException e) {
            getServletContext().log(
                "Medicine search failed.", e);

            errorMessage =
                "Unable to search medicines. Please check the database connection.";
        }

        // Apply the stock-status filter to the returned inventory.
        if (!stockStatus.isEmpty()) {
            final String selectedStatus = stockStatus;

            medicines.removeIf(medicine ->
                !selectedStatus.equals(medicine.getStockStatus()));
        }

        request.setAttribute("medicines", medicines);
        request.setAttribute("errorMessage", errorMessage);

        request.getRequestDispatcher("/medicine-search.jsp")
               .forward(request, response);
    }

    public static class MedicineResult {

        private long medicineId;
        private String medicineName;
        private String category;
        private String unitName;
        private long reorderLevel;
        private long quantity;
        private String batchNumbers;

        public long getMedicineId() { return medicineId; }
        public void setMedicineId(long value) { medicineId = value; }

        public String getMedicineName() { return medicineName; }
        public void setMedicineName(String value) { medicineName = value; }

        public String getCategory() { return category; }
        public void setCategory(String value) { category = value; }

        public String getUnitName() { return unitName; }
        public void setUnitName(String value) { unitName = value; }

        public long getReorderLevel() { return reorderLevel; }
        public void setReorderLevel(long value) { reorderLevel = value; }

        public long getQuantity() { return quantity; }
        public void setQuantity(long value) { quantity = value; }

        public String getBatchNumbers() { return batchNumbers; }
        public void setBatchNumbers(String value) { batchNumbers = value; }

        public String getStockStatus() {
            if (quantity <= 0) {
                return "Out of stock";
            }

            if (quantity < reorderLevel) {
                return "Low stock";
            }

            return "In stock";
        }
    }
}
