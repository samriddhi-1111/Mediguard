
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

@WebServlet(name = "SupplierServlet", urlPatterns = {"/suppliers"})
public class SupplierServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        List<Supplier> suppliers = new ArrayList<>();
        String errorMessage = null;

        String sql =
            "SELECT SUPPLIER_ID, SUPPLIER_NAME, PHONE, EMAIL, " +
            "ADDRESS, CREATED_AT " +
            "FROM MGX26_SUPPLIERS ORDER BY SUPPLIER_NAME";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {

            while (result.next()) {
                Supplier supplier = new Supplier();

                supplier.setSupplierId(result.getLong("SUPPLIER_ID"));
                supplier.setSupplierName(result.getString("SUPPLIER_NAME"));
                supplier.setPhone(result.getString("PHONE"));
                supplier.setEmail(result.getString("EMAIL"));
                supplier.setAddress(result.getString("ADDRESS"));

                java.sql.Timestamp createdAt =
                    result.getTimestamp("CREATED_AT");

                supplier.setCreatedAt(
                    createdAt == null ? "—" : createdAt.toString());

                suppliers.add(supplier);
            }

        } catch (SQLException e) {
            getServletContext().log("Unable to load suppliers.", e);
            errorMessage =
                "Unable to load suppliers. Check the database connection.";
        }

        request.setAttribute("suppliers", suppliers);
        request.setAttribute("errorMessage", errorMessage);

        if ("success".equals(request.getParameter("added"))) {
            request.setAttribute("successMessage",
                "Supplier added successfully!");
        }

        request.getRequestDispatcher("/suppliers.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String supplierName = request.getParameter("supplierName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String address = request.getParameter("address");

        try {
            if (supplierName == null || supplierName.trim().isEmpty()) {
                throw new IllegalArgumentException(
                    "Supplier name is required.");
            }

            supplierName = supplierName.trim();

            if (supplierName.length() > 200) {
                throw new IllegalArgumentException(
                    "Supplier name must not exceed 200 characters.");
            }

            phone = phone == null ? null : phone.trim();
            email = email == null ? null : email.trim();
            address = address == null ? null : address.trim();

            if (phone != null && phone.isEmpty()) phone = null;
            if (email != null && email.isEmpty()) email = null;
            if (address != null && address.isEmpty()) address = null;

            if (phone != null && phone.length() > 50) {
                throw new IllegalArgumentException(
                    "Phone must not exceed 50 characters.");
            }

            if (email != null && email.length() > 200) {
                throw new IllegalArgumentException(
                    "Email must not exceed 200 characters.");
            }

            if (email != null &&
                    !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                throw new IllegalArgumentException(
                    "Enter a valid email address.");
            }

            if (address != null && address.length() > 500) {
                throw new IllegalArgumentException(
                    "Address must not exceed 500 characters.");
            }

            String sql =
                "INSERT INTO MGX26_SUPPLIERS " +
                "(SUPPLIER_ID, SUPPLIER_NAME, PHONE, EMAIL, ADDRESS) " +
                "VALUES (MGX26_SUPPLIER_SEQ.NEXTVAL, ?, ?, ?, ?)";

            try (Connection connection = DBConnection.getConnection();
                 PreparedStatement statement =
                    connection.prepareStatement(sql)) {

                statement.setString(1, supplierName);
                statement.setString(2, phone);
                statement.setString(3, email);
                statement.setString(4, address);

                statement.executeUpdate();
            }

            response.sendRedirect(
                request.getContextPath() + "/suppliers?added=success");
            return;

        } catch (IllegalArgumentException e) {
            request.setAttribute("formError", e.getMessage());

        } catch (SQLException e) {
            getServletContext().log("Unable to add supplier.", e);
            request.setAttribute("formError",
                "Supplier could not be saved. Check the server log for details.");
        }

        // Reload the supplier directory and display the validation error.
        doGet(request, response);
    }

    public static class Supplier {

        private long supplierId;
        private String supplierName;
        private String phone;
        private String email;
        private String address;
        private String createdAt;

        public long getSupplierId() { return supplierId; }
        public void setSupplierId(long value) { supplierId = value; }

        public String getSupplierName() { return supplierName; }
        public void setSupplierName(String value) { supplierName = value; }

        public String getPhone() { return phone; }
        public void setPhone(String value) { phone = value; }

        public String getEmail() { return email; }
        public void setEmail(String value) { email = value; }

        public String getAddress() { return address; }
        public void setAddress(String value) { address = value; }

        public String getCreatedAt() { return createdAt; }
        public void setCreatedAt(String value) { createdAt = value; }
    }
}
