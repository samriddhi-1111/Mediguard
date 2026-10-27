
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mediguard.servlet.MedicineSearchServlet.MedicineResult" %>

<%!
    private String esc(Object value) {
        if (value == null) return "";

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;");
    }
%>

<%
    List<MedicineResult> medicines =
        (List<MedicineResult>) request.getAttribute("medicines");

    if (medicines == null) {
        medicines = java.util.Collections.emptyList();
    }

    String search = (String) request.getAttribute("search");
    String category = (String) request.getAttribute("category");
    String stockStatus = (String) request.getAttribute("stockStatus");
    String errorMessage = (String) request.getAttribute("errorMessage");

    if (search == null) search = "";
    if (category == null) category = "";
    if (stockStatus == null) stockStatus = "";

    String ctx = request.getContextPath();

    String[] categories = {
        "Pain Relief", "Antibiotic", "Allergy", "Vitamins", "Other"
    };
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Medicine Search | MediGuard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/mediguard.css">

    <style>
        /* Page-specific layout; shared theme comes from mediguard.css */

        .medicine-search-page {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 22px;
        }

        .medicine-search-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 24px;
        }

        .medicine-search-heading h1 {
            margin: 0 0 8px;
            color: var(--mg-primary);
            font-size: 28px;
        }

        .medicine-search-muted {
            color: var(--mg-muted);
            margin: 0;
            line-height: 1.6;
        }

        .medicine-search-back {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 11px 16px;
            min-height: 42px;
            border: 1px solid var(--mg-border);
            border-radius: 8px;
            background: var(--mg-surface);
            color: var(--mg-primary);
            text-decoration: none;
            font-weight: 700;
            white-space: nowrap;
        }

        .medicine-search-back:hover {
            background: var(--mg-bg);
        }

        .medicine-search-panel {
            padding: 24px;
            margin-bottom: 24px;
        }

        .medicine-search-panel h2 {
            margin-top: 0;
            color: var(--mg-primary);
        }

        .medicine-search-filters {
            display: grid;
            grid-template-columns: minmax(200px, 2fr)
                                   minmax(140px, 1fr)
                                   minmax(150px, 1fr)
                                   auto;
            gap: 14px;
            align-items: end;
        }

        .medicine-search-field {
            min-width: 0;
        }

        .medicine-search-field label {
            display: block;
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 8px;
        }

        .medicine-search-field input,
        .medicine-search-field select {
            width: 100%;
            min-width: 0;
        }

        .medicine-search-submit {
            min-height: 42px;
            white-space: nowrap;
        }

        .medicine-search-reset {
            display: inline-block;
            margin-top: 16px;
            color: var(--mg-primary);
            text-decoration: none;
            font-weight: 600;
        }

        .medicine-search-reset:hover {
            text-decoration: underline;
        }

        .medicine-search-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
            padding: 12px 14px;
            border-radius: 8px;
            margin-bottom: 18px;
            overflow-wrap: anywhere;
        }

        .medicine-results-count {
            color: var(--mg-muted);
            margin-bottom: 18px;
        }

        .medicine-search-table-wrap {
            width: 100%;
            overflow-x: auto;
        }

        .medicine-search-table {
            width: 100%;
            min-width: 850px;
            border-collapse: collapse;
            text-align: left;
        }

        .medicine-search-table th,
        .medicine-search-table td {
            padding: 13px 12px;
            border-bottom: 1px solid var(--mg-border);
            font-size: 14px;
            vertical-align: middle;
        }

        .medicine-search-table th {
            background: var(--mg-bg);
            color: var(--mg-muted);
            font-weight: 700;
            white-space: nowrap;
        }

        .medicine-search-table tbody tr:hover {
            background: #f8fafc;
        }

        .medicine-stock-status {
            display: inline-block;
            padding: 5px 9px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

        .medicine-status-good {
            background: #dcfce7;
            color: #166534;
        }

        .medicine-status-warning {
            background: #fef3c7;
            color: #92400e;
        }

        .medicine-status-danger {
            background: #fee2e2;
            color: #991b1b;
        }

        .medicine-search-empty {
            padding: 25px !important;
            text-align: center;
            color: var(--mg-muted);
            line-height: 1.6;
        }

        @media (max-width: 950px) {
            .medicine-search-filters {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 550px) {
            .medicine-search-page {
                margin: 20px auto;
                padding: 0 12px;
            }

            .medicine-search-heading h1 {
                font-size: 24px;
            }

            .medicine-search-panel {
                padding: 16px;
            }

            .medicine-search-filters {
                grid-template-columns: 1fr;
            }

            .medicine-search-submit,
            .medicine-search-back {
                width: 100%;
            }
        }
    </style>
</head>

<body>

<header class="mg-standard-header">
    <div class="mg-brand">
        <h1>MediGuard</h1>
        <p>Medicine Search and Filter</p>
    </div>

    <a class="mg-dashboard-button"
       href="${pageContext.request.contextPath}/dashboard">
        Dashboard
    </a>
</header>

<main class="medicine-search-page">

    <div class="medicine-search-heading">
        <div>
            <h1>Medicine Search</h1>
            <p class="medicine-search-muted">
                Find medicines by name, category, or stock status.
            </p>
        </div>

    </div>

    <section class="card medicine-search-panel">

        <h2>Find Medicines</h2>

        <p class="medicine-search-muted">
            Search the inventory by medicine name, category, or stock status.
        </p>

        <% if (errorMessage != null) { %>
            <div class="medicine-search-error" role="alert">
                <%= esc(errorMessage) %>
            </div>
        <% } %>

        <form action="<%= ctx %>/medicine-search" method="get">

            <div class="medicine-search-filters">

                <div class="medicine-search-field">
                    <label for="search">Medicine Name</label>

                    <input type="text"
                           id="search"
                           name="search"
                           value="<%= esc(search) %>"
                           placeholder="e.g. Paracetamol">
                </div>

                <div class="medicine-search-field">
                    <label for="category">Category</label>

                    <select id="category" name="category">
                        <option value="">All categories</option>

                        <% for (String item : categories) { %>
                            <option value="<%= item %>"
                                <%= item.equals(category) ? "selected" : "" %>>
                                <%= item %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="medicine-search-field">
                    <label for="stockStatus">Stock Status</label>

                    <select id="stockStatus" name="stockStatus">
                        <option value="">All statuses</option>

                        <option value="In stock"
                            <%= "In stock".equals(stockStatus) ? "selected" : "" %>>
                            In stock
                        </option>

                        <option value="Low stock"
                            <%= "Low stock".equals(stockStatus) ? "selected" : "" %>>
                            Low stock
                        </option>

                        <option value="Out of stock"
                            <%= "Out of stock".equals(stockStatus) ? "selected" : "" %>>
                            Out of stock
                        </option>
                    </select>
                </div>

                <div class="medicine-search-field">
                    <button class="medicine-search-submit" type="submit">
                        Search
                    </button>
                </div>

            </div>

            <a class="medicine-search-reset" href="<%= ctx %>/medicine-search">
                Clear all filters
            </a>

        </form>
    </section>

    <section class="card medicine-search-panel">

        <h2>Search Results</h2>

        <p class="medicine-results-count">
            Medicines found:
            <strong><%= medicines.size() %></strong>
        </p>

        <div class="medicine-search-table-wrap">
            <table class="medicine-search-table">

                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Medicine Name</th>
                        <th>Category</th>
                        <th>Unit</th>
                        <th>Total Stock</th>
                        <th>Reorder Level</th>
                        <th>Batch Numbers</th>
                        <th>Status</th>
                    </tr>
                </thead>

                <tbody>

                <% if (medicines.isEmpty()) { %>
                    <tr>
                        <td colspan="8" class="medicine-search-empty">
                            No matching medicines found.
                        </td>
                    </tr>
                <% } else {
                    for (MedicineResult medicine : medicines) {
                        String status = medicine.getStockStatus();
                        String statusClass = "medicine-status-good";

                        if ("Low stock".equals(status)) {
                            statusClass = "medicine-status-warning";
                        } else if ("Out of stock".equals(status)) {
                            statusClass = "medicine-status-danger";
                        }

                        String batchNumbers = medicine.getBatchNumbers();

                        if (batchNumbers == null || batchNumbers.isEmpty()) {
                            batchNumbers = "No batch";
                        }
                %>

                    <tr>
                        <td><%= medicine.getMedicineId() %></td>

                        <td>
                            <strong><%= esc(medicine.getMedicineName()) %></strong>
                        </td>

                        <td><%= esc(medicine.getCategory()) %></td>

                        <td><%= esc(medicine.getUnitName()) %></td>

                        <td><%= medicine.getQuantity() %></td>

                        <td><%= medicine.getReorderLevel() %></td>

                        <td><%= esc(batchNumbers) %></td>

                        <td>
                            <span class="medicine-stock-status <%= statusClass %>">
                                <%= esc(status) %>
                            </span>
                        </td>
                    </tr>

                <%  }
                   } %>

                </tbody>
            </table>
        </div>

    </section>

</main>

</body>
</html>
