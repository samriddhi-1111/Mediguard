
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
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AddBatchServlet", urlPatterns = {"/add-batch"})
public class AddBatchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        List<MedicineOption> medicines = new ArrayList<>();
        List<SupplierOption> suppliers = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection()) {

            String medicineSql =
                "SELECT MEDICINE_ID, MEDICINE_NAME " +
                "FROM MGX26_MEDICINES ORDER BY MEDICINE_NAME";

            try (PreparedStatement ps =
                         connection.prepareStatement(medicineSql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    medicines.add(new MedicineOption(
                        rs.getLong("MEDICINE_ID"),
                        rs.getString("MEDICINE_NAME")
                    ));
                }
            }

            // Supplier name is not assumed; use the confirmed supplier ID.
            String supplierSql =
                "SELECT SUPPLIER_ID FROM MGX26_SUPPLIERS " +
                "ORDER BY SUPPLIER_ID";

            try (PreparedStatement ps =
                         connection.prepareStatement(supplierSql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    suppliers.add(new SupplierOption(
                        rs.getLong("SUPPLIER_ID")
                    ));
                }
            }

        } catch (SQLException e) {
            getServletContext().log("Unable to load batch form options.", e);
            request.setAttribute("errorMessage",
                "Could not load medicines or suppliers. Check the database connection.");
        }

        request.setAttribute("medicines", medicines);
        request.setAttribute("suppliers", suppliers);

        request.getRequestDispatcher("/add-batch.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String medicineIdText = request.getParameter("medicineId");
        String supplierIdText = request.getParameter("supplierId");
        String batchNumber = request.getParameter("batchNumber");
        String quantityText = request.getParameter("quantity");
        String unitCostText = request.getParameter("unitCost");
        String manufacturingText = request.getParameter("mfgDate");
        String expiryText = request.getParameter("expiryDate");

        try {
            if (medicineIdText == null || batchNumber == null
                    || quantityText == null || unitCostText == null
                    || expiryText == null) {
                throw new IllegalArgumentException(
                    "Please complete all required fields.");
            }

            long medicineId = Long.parseLong(medicineIdText);
            long quantity = Long.parseLong(quantityText);
            BigDecimal unitCost = new BigDecimal(unitCostText);
            batchNumber = batchNumber.trim();

            if (medicineId <= 0 || quantity < 0) {
                throw new IllegalArgumentException(
                    "Select a medicine and enter a non-negative quantity.");
            }

            if (unitCost.compareTo(BigDecimal.ZERO) < 0) {
                throw new IllegalArgumentException(
                    "Unit cost cannot be negative.");
            }

            if (batchNumber.isEmpty() || batchNumber.length() > 100) {
                throw new IllegalArgumentException(
                    "Enter a valid batch number of up to 100 characters.");
            }

            Long supplierId = null;
            if (supplierIdText != null && !supplierIdText.trim().isEmpty()) {
                supplierId = Long.parseLong(supplierIdText.trim());
                if (supplierId <= 0) {
                    throw new IllegalArgumentException(
                        "Select a valid supplier.");
                }
            }

            Date mfgDate = null;
            if (manufacturingText != null
                    && !manufacturingText.trim().isEmpty()) {
                mfgDate = Date.valueOf(manufacturingText.trim());
            }

            Date expiryDate = Date.valueOf(expiryText.trim());

            if (mfgDate != null && !expiryDate.after(mfgDate)) {
                throw new IllegalArgumentException(
                    "Expiry date must be after the manufacturing date.");
            }

            String sql =
                "INSERT INTO MGX26_BATCHES " +
                "(BATCH_ID, MEDICINE_ID, SUPPLIER_ID, BATCH_NUMBER, " +
                "QUANTITY, UNIT_COST, MFG_DATE, EXPIRY_DATE) " +
                "VALUES (MGX26_BATCH_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, ?)";

            try (Connection connection = DBConnection.getConnection();
                 PreparedStatement ps = connection.prepareStatement(sql)) {

                ps.setLong(1, medicineId);

                if (supplierId == null) {
                    ps.setNull(2, java.sql.Types.NUMERIC);
                } else {
                    ps.setLong(2, supplierId);
                }

                ps.setString(3, batchNumber);
                ps.setLong(4, quantity);
                ps.setBigDecimal(5, unitCost);

                if (mfgDate == null) {
                    ps.setNull(6, java.sql.Types.DATE);
                } else {
                    ps.setDate(6, mfgDate);
                }

                ps.setDate(7, expiryDate);

                int inserted = ps.executeUpdate();

                if (inserted == 1) {
                    response.sendRedirect(
                        request.getContextPath()
                        + "/dashboard?batchAdded=success");
                    return;
                }
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage",
                "Medicine ID, quantity, supplier ID, and cost must be valid numbers.");

        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());

        } catch (SQLException e) {
            getServletContext().log("Unable to add medicine batch.", e);

            String message = e.getMessage() == null
                    ? "" : e.getMessage().toLowerCase();

            if (message.contains("ora-00001")
                    || message.contains("unique constraint")) {
                request.setAttribute("errorMessage",
                    "That batch number already exists. Please enter a unique batch number.");
            } else if (message.contains("ora-02291")
                    || message.contains("integrity constraint")) {
                request.setAttribute("errorMessage",
                    "The selected medicine or supplier does not exist.");
            } else {
                request.setAttribute("errorMessage",
                    "The batch could not be saved. Check the server log for details.");
            }
        }

        doGet(request, response);
    }

    public static class MedicineOption {
        private final long medicineId;
        private final String medicineName;

        public MedicineOption(long medicineId, String medicineName) {
            this.medicineId = medicineId;
            this.medicineName = medicineName;
        }

        public long getMedicineId() { return medicineId; }
        public String getMedicineName() { return medicineName; }
    }

    public static class SupplierOption {
        private final long supplierId;

        public SupplierOption(long supplierId) {
            this.supplierId = supplierId;
        }

        public long getSupplierId() { return supplierId; }
    }
}
