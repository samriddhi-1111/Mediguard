
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
import java.sql.SQLException;

@WebServlet(name = "AddMedicineServlet", urlPatterns = {"/add-medicine"})
public class AddMedicineServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/add-medicine.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String medicineIdText = request.getParameter("medicineId");
        String medicineName = request.getParameter("medicineName");
        String category = request.getParameter("category");
        String unitName = request.getParameter("unitName");
        String reorderLevelText = request.getParameter("reorderLevel");

        // Keep entered values if validation or database insertion fails.
        request.setAttribute("medicineId", medicineIdText);
        request.setAttribute("medicineName", medicineName);

        long medicineId;
        long reorderLevel;

        try {
            if (medicineIdText == null || medicineName == null
                    || category == null || unitName == null
                    || reorderLevelText == null) {
                throw new IllegalArgumentException(
                        "Please complete all required fields.");
            }

            medicineId = Long.parseLong(medicineIdText.trim());
            reorderLevel = Long.parseLong(reorderLevelText.trim());

            medicineName = medicineName.trim();
            category = category.trim();
            unitName = unitName.trim();

            if (medicineId <= 0) {
                throw new IllegalArgumentException(
                        "Medicine ID must be greater than zero.");
            }

            if (reorderLevel < 0) {
                throw new IllegalArgumentException(
                        "Reorder level cannot be negative.");
            }

            if (medicineName.isEmpty() || category.isEmpty()
                    || unitName.isEmpty()) {
                throw new IllegalArgumentException(
                        "Medicine name, category, and unit are required.");
            }

            if (medicineName.length() > 100) {
                throw new IllegalArgumentException(
                        "Medicine name cannot exceed 100 characters.");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage",
                    "Medicine ID and reorder level must be whole numbers.");
            request.getRequestDispatcher("/add-medicine.jsp")
                   .forward(request, response);
            return;

        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/add-medicine.jsp")
                   .forward(request, response);
            return;
        }

        try (Connection connection = DBConnection.getConnection();
             CallableStatement statement = connection.prepareCall(
                     "{ call MGX26_ADD_MEDICINE(?, ?, ?, ?, ?) }")) {

            statement.setLong(1, medicineId);
            statement.setString(2, medicineName);
            statement.setString(3, category);
            statement.setString(4, unitName);
            statement.setLong(5, reorderLevel);

            statement.execute();

            response.sendRedirect(
                    request.getContextPath()
                    + "/dashboard?message=added");
            return;

        } catch (SQLException e) {
            getServletContext().log(
                    "Unable to add medicine to MediGuard.", e);

            String oracleMessage = e.getMessage() == null
                    ? "" : e.getMessage().toLowerCase();

            if (oracleMessage.contains("unique constraint")
                    || oracleMessage.contains("ora-00001")) {
                request.setAttribute("errorMessage",
                        "This Medicine ID already exists. Please enter a unique ID.");
            } else {
                request.setAttribute("errorMessage",
                        "The medicine could not be saved. Check the Medicine ID "
                        + "and database procedure, then try again.");
            }

            request.getRequestDispatcher("/add-medicine.jsp")
                   .forward(request, response);
        }
    }
}
