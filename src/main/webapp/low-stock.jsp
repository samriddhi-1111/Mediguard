
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mediguard.servlet.LowStockServlet.LowStockRow" %>

<%
    List<LowStockRow> medicines =
        (List<LowStockRow>) request.getAttribute("lowStockMedicines");

    if (medicines == null) {
        medicines = java.util.Collections.emptyList();
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Low-Stock Alerts | MediGuard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/mediguard.css">

    <style>
        /* Page-specific layout; shared theme comes from mediguard.css */

        .low-stock-page {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 22px;
        }

        .low-stock-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 24px;
        }

        .low-stock-heading h2 {
            margin: 0 0 8px;
            color: var(--mg-primary);
        }

        .low-stock-muted {
            color: var(--mg-muted);
            margin: 0;
            line-height: 1.6;
        }

        .low-stock-back {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 11px 15px;
            min-height: 42px;
            border: 1px solid var(--mg-border);
            border-radius: 8px;
            background: var(--mg-surface);
            color: var(--mg-primary);
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
            white-space: nowrap;
        }

        .low-stock-back:hover {
            background: var(--mg-bg);
        }

        .low-stock-summary {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 17px;
            margin-bottom: 25px;
        }

        .low-stock-summary-card {
            min-width: 0;
            padding: 22px;
        }

        .low-stock-label {
            color: var(--mg-muted);
            font-size: 14px;
        }

        .low-stock-value {
            margin-top: 12px;
            font-size: 30px;
            font-weight: 800;
        }

        .low-stock-orange {
            color: var(--mg-warning);
        }

        .low-stock-red {
            color: var(--mg-danger);
        }

        .low-stock-blue {
            color: var(--mg-primary);
        }

        .low-stock-panel {
            padding: 22px;
        }

        .low-stock-panel h2 {
            margin: 0 0 8px;
            color: var(--mg-primary);
        }

        .low-stock-table-wrap {
            width: 100%;
            overflow-x: auto;
            margin-top: 18px;
        }

        .low-stock-table {
            width: 100%;
            min-width: 850px;
            border-collapse: collapse;
            text-align: left;
        }

        .low-stock-table th,
        .low-stock-table td {
            padding: 14px 12px;
            border-bottom: 1px solid var(--mg-border);
            font-size: 14px;
        }

        .low-stock-table th {
            background: var(--mg-bg);
            color: var(--mg-muted);
            font-weight: 700;
            white-space: nowrap;
        }

        .low-stock-table tbody tr:hover {
            background: #f8fafc;
        }

        .low-stock-badge {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

        .low-stock-badge-out {
            background: #fee2e2;
            color: #991b1b;
        }

        .low-stock-badge-low {
            background: #ffedd5;
            color: #9a3412;
        }

        .low-stock-empty {
            padding: 28px !important;
            text-align: center;
            color: var(--mg-muted);
            line-height: 1.6;
        }

        .low-stock-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
            padding: 14px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        @media (max-width: 750px) {
            .low-stock-page {
                margin: 20px auto;
                padding: 0 12px;
            }

            .low-stock-summary {
                grid-template-columns: 1fr;
            }

            .low-stock-summary-card,
            .low-stock-panel {
                padding: 16px;
            }

            .low-stock-heading h2 {
                font-size: 22px;
            }

            .low-stock-back {
                width: 100%;
            }
        }
    </style>
</head>

<body>

<header class="mg-standard-header">
    <div class="mg-brand">
        <h1>MediGuard</h1>
        <p>Low-Stock Alerts</p>
    </div>

    <a class="mg-dashboard-button"
       href="${pageContext.request.contextPath}/dashboard">
        Dashboard
    </a>
</header>

<main class="low-stock-page">

    <div class="low-stock-heading">
        <div>
            <h2>Low-Stock Alerts</h2>
            <p class="low-stock-muted">
                Medicines with current stock at or below their configured
                reorder level.
            </p>
        </div>

        
    </div>

    <% if (errorMessage != null) { %>
        <div class="low-stock-error" role="alert">
            <%= errorMessage %>
        </div>
    <% } %>

    <section class="low-stock-summary">

        <div class="card low-stock-summary-card">
            <div class="low-stock-label">
                Medicines Requiring Attention
            </div>

            <div class="low-stock-value low-stock-orange">
                <%= request.getAttribute("lowStockCount") == null
                    ? 0 : request.getAttribute("lowStockCount") %>
            </div>
        </div>

        <div class="card low-stock-summary-card">
            <div class="low-stock-label">Out of Stock</div>

            <div class="low-stock-value low-stock-red">
                <%= request.getAttribute("outOfStockCount") == null
                    ? 0 : request.getAttribute("outOfStockCount") %>
            </div>
        </div>

        <div class="card low-stock-summary-card">
            <div class="low-stock-label">Suggested Reorder Units</div>

            <div class="low-stock-value low-stock-blue">
                <%= request.getAttribute("totalReorderUnits") == null
                    ? 0 : request.getAttribute("totalReorderUnits") %>
            </div>
        </div>

    </section>

    <section class="card low-stock-panel">

        <h2>Reorder Recommendations</h2>

        <p class="low-stock-muted">
            Suggested quantity = reorder level minus current stock.
        </p>

        <div class="low-stock-table-wrap">
            <table class="low-stock-table">

                <thead>
                    <tr>
                        <th>Medicine ID</th>
                        <th>Medicine Name</th>
                        <th>Category</th>
                        <th>Unit</th>
                        <th>Current Stock</th>
                        <th>Reorder Level</th>
                        <th>Suggested Reorder</th>
                        <th>Status</th>
                    </tr>
                </thead>

                <tbody>

                <% if (medicines.isEmpty()) { %>
                    <tr>
                        <td colspan="8" class="low-stock-empty">
                            No low-stock medicines found. All recorded
                            medicines are above their reorder levels.
                        </td>
                    </tr>
                <% } else {
                    for (LowStockRow medicine : medicines) {
                        String badgeClass =
                            medicine.getCurrentStock() == 0
                                ? "low-stock-badge-out"
                                : "low-stock-badge-low";
                %>

                    <tr>
                        <td><%= medicine.getMedicineId() %></td>

                        <td>
                            <strong><%= medicine.getMedicineName() %></strong>
                        </td>

                        <td>
                            <%= medicine.getCategory() == null
                                ? "-" : medicine.getCategory() %>
                        </td>

                        <td>
                            <%= medicine.getUnitName() == null
                                ? "-" : medicine.getUnitName() %>
                        </td>

                        <td><%= medicine.getCurrentStock() %></td>

                        <td><%= medicine.getReorderLevel() %></td>

                        <td>
                            <strong>
                                <%= medicine.getSuggestedReorder() %>
                            </strong>
                        </td>

                        <td>
                            <span class="low-stock-badge <%= badgeClass %>">
                                <%= medicine.getStatus() %>
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
