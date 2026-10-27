
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.mediguard.servlet.StockValuationServlet.ValuationRow" %>

<%
    List<ValuationRow> rows =
        (List<ValuationRow>) request.getAttribute("valuationRows");

    if (rows == null) {
        rows = java.util.Collections.emptyList();
    }

    BigDecimal totalStockValue =
        (BigDecimal) request.getAttribute("totalStockValue");

    if (totalStockValue == null) {
        totalStockValue = BigDecimal.ZERO;
    }

    NumberFormat currencyFormat =
        NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

    String errorMessage =
        (String) request.getAttribute("errorMessage");

    Object totalMedicines = request.getAttribute("totalMedicines");
    Object totalUnits = request.getAttribute("totalUnits");
    Object totalBatches = request.getAttribute("totalBatches");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Stock Valuation | MediGuard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/mediguard.css">

    <style>
        .valuation-page {
            min-height: 100vh;
            background: var(--mg-bg);
        }

        .valuation-header {
            background: var(--mg-primary);
            color: #ffffff;
            padding: 20px 5%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
        }

        .valuation-header h1 {
            margin: 0;
            color: #ffffff;
            font-size: 24px;
        }

        .valuation-header p {
            margin: 6px 0 0;
            color: #dbeafe;
        }

        .valuation-nav {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .valuation-nav a {
            color: #ffffff;
            text-decoration: none;
            padding: 9px 12px;
            border-radius: 7px;
            background: rgba(255, 255, 255, 0.12);
            border: 1px solid rgba(255, 255, 255, 0.15);
            font-size: 13px;
            transition: background 0.2s ease;
        }

        .valuation-nav a:hover {
            background: rgba(255, 255, 255, 0.22);
        }

        .valuation-main {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 22px;
        }

        .valuation-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 24px;
        }

        .valuation-heading h2,
        .valuation-report h2 {
            margin: 0 0 8px;
            color: var(--mg-text);
        }

        .valuation-muted {
            color: var(--mg-muted);
            line-height: 1.6;
            margin: 0;
        }

        .valuation-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .valuation-action-button {
            border: none;
            border-radius: 8px;
            padding: 11px 15px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            background: var(--mg-primary);
            color: #ffffff;
            transition: background 0.2s ease;
        }

        .valuation-action-button:hover {
            background: var(--mg-primary-dark);
        }

        .valuation-summary {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }

        .valuation-card {
            min-width: 0;
            background: var(--mg-surface);
            padding: 22px;
            border-radius: var(--mg-radius);
            border: 1px solid var(--mg-border);
            box-shadow: var(--mg-shadow);
        }

        .valuation-card-label {
            font-size: 14px;
            color: var(--mg-muted);
            margin-bottom: 12px;
        }

        .valuation-card-value {
            font-size: 26px;
            font-weight: 700;
            color: var(--mg-primary);
            overflow-wrap: anywhere;
        }

        .valuation-report {
            background: var(--mg-surface);
            padding: 22px;
            border-radius: var(--mg-radius);
            border: 1px solid var(--mg-border);
            box-shadow: var(--mg-shadow);
        }

        .valuation-table-wrap {
            overflow-x: auto;
            margin-top: 18px;
        }

        .valuation-table {
            width: 100%;
            min-width: 850px;
            border-collapse: collapse;
            text-align: left;
        }

        .valuation-table th,
        .valuation-table td {
            padding: 14px 12px;
            border-bottom: 1px solid var(--mg-border);
            font-size: 14px;
            vertical-align: middle;
        }

        .valuation-table th {
            color: #475569;
            background: #f8fafc;
            font-weight: 600;
            white-space: nowrap;
        }

        .valuation-table tbody tr:hover {
            background: #f8fafc;
        }

        .valuation-number {
            text-align: right;
            white-space: nowrap;
        }

        .valuation-table tfoot td {
            font-weight: 700;
            background: var(--mg-accent-light);
            color: var(--mg-text);
        }

        .valuation-empty {
            padding: 28px !important;
            text-align: center;
            color: var(--mg-muted);
        }

        .valuation-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
            padding: 14px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .valuation-footer {
            text-align: center;
            color: var(--mg-muted);
            padding: 25px;
            font-size: 13px;
        }

        @media (max-width: 900px) {
            .valuation-summary {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 500px) {
            .valuation-header {
                padding: 20px 4%;
            }

            .valuation-main {
                padding: 0 12px;
            }

            .valuation-summary {
                grid-template-columns: 1fr;
            }

            .valuation-report {
                padding: 14px;
            }

            .valuation-card-value {
                font-size: 23px;
            }

            .valuation-actions {
                width: 100%;
            }

            .valuation-action-button {
                flex: 1;
            }
        }

        @media print {
            .valuation-header nav,
            .valuation-actions,
            .valuation-footer {
                display: none !important;
            }

            .valuation-page {
                background: #ffffff;
            }

            .valuation-header {
                background: #ffffff;
                color: #000000;
                padding: 10px 0;
            }

            .valuation-header h1,
            .valuation-header p {
                color: #000000;
            }

            .valuation-main {
                max-width: none;
                margin: 10px 0;
                padding: 0;
            }

            .valuation-card,
            .valuation-report {
                box-shadow: none;
                break-inside: avoid;
            }

            .valuation-summary {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .valuation-table {
                min-width: 0;
            }

            .valuation-table th,
            .valuation-table td {
                padding: 7px 5px;
                font-size: 10px;
            }
        }
    </style>
</head>

<body>
<div class="valuation-page">
<header class="mg-standard-header">
    <div class="mg-brand">
        <h1>MediGuard</h1>
        <p>Stock Valuation & Reports</p>
    </div>

    <a class="mg-dashboard-button"
       href="${pageContext.request.contextPath}/dashboard">
        Dashboard
    </a>
</header>

    <main class="valuation-main">

        <div class="valuation-heading">
            <div>
                <h2>Stock Valuation Report</h2>
                <p class="valuation-muted">
                    Inventory value calculated from recorded batch quantities
                    and unit costs.
                </p>
            </div>

            <div class="valuation-actions">
                <button class="valuation-action-button"
                        type="button"
                        onclick="window.print()">
                    Print / Save as PDF
                </button>

                <button class="valuation-action-button"
                        type="button"
                        onclick="exportTableToCSV()">
                    Export CSV
                </button>
            </div>
        </div>

        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
            <div class="valuation-error" role="alert">
                <%= errorMessage %>
            </div>
        <% } %>

        <section class="valuation-summary">

            <div class="valuation-card">
                <div class="valuation-card-label">
                    Total Inventory Value
                </div>
                <div class="valuation-card-value">
                    <%= currencyFormat.format(totalStockValue) %>
                </div>
            </div>

            <div class="valuation-card">
                <div class="valuation-card-label">
                    Registered Medicines
                </div>
                <div class="valuation-card-value">
                    <%= totalMedicines == null ? 0 : totalMedicines %>
                </div>
            </div>

            <div class="valuation-card">
                <div class="valuation-card-label">
                    Total Units in Stock
                </div>
                <div class="valuation-card-value">
                    <%= totalUnits == null ? 0 : totalUnits %>
                </div>
            </div>

            <div class="valuation-card">
                <div class="valuation-card-label">
                    Registered Batches
                </div>
                <div class="valuation-card-value">
                    <%= totalBatches == null ? 0 : totalBatches %>
                </div>
            </div>

        </section>

        <section class="valuation-report">
            <h2>Medicine-wise Valuation</h2>

            <p class="valuation-muted">
                Value per medicine = sum of quantity multiplied by unit cost
                across its batches.
            </p>

            <div class="valuation-table-wrap">
                <table class="valuation-table" id="valuationTable">
                    <thead>
                        <tr>
                            <th>Medicine ID</th>
                            <th>Medicine Name</th>
                            <th>Category</th>
                            <th>Unit</th>
                            <th class="valuation-number">Batches</th>
                            <th class="valuation-number">Total Quantity</th>
                            <th class="valuation-number">Stock Value (INR)</th>
                        </tr>
                    </thead>

                    <tbody>
                        <% if (rows.isEmpty()) { %>
                            <tr>
                                <td colspan="7" class="valuation-empty">
                                    No medicine records found.
                                </td>
                            </tr>
                        <% } else {
                            for (ValuationRow row : rows) {
                        %>
                            <tr>
                                <td><%= row.getMedicineId() %></td>

                                <td>
                                    <%= row.getMedicineName() == null
                                            ? "-" : row.getMedicineName() %>
                                </td>

                                <td>
                                    <%= row.getCategory() == null
                                            ? "-" : row.getCategory() %>
                                </td>

                                <td>
                                    <%= row.getUnitName() == null
                                            ? "-" : row.getUnitName() %>
                                </td>

                                <td class="valuation-number">
                                    <%= row.getBatchCount() %>
                                </td>

                                <td class="valuation-number">
                                    <%= row.getQuantity() %>
                                </td>

                                <td class="valuation-number">
                                    <%= currencyFormat.format(row.getStockValue()) %>
                                </td>
                            </tr>
                        <%  }
                           } %>
                    </tbody>

                    <tfoot>
                        <tr>
                            <td colspan="5">TOTAL</td>

                            <td class="valuation-number">
                                <%= totalUnits == null ? 0 : totalUnits %>
                            </td>

                            <td class="valuation-number">
                                <%= currencyFormat.format(totalStockValue) %>
                            </td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </section>

    </main>

    <footer class="valuation-footer">
        MediGuard &mdash; Medicine Inventory Management System
    </footer>

</div>

<script>
    function exportTableToCSV() {
        const table = document.getElementById("valuationTable");
        const rows = Array.from(table.querySelectorAll("tr"));

        const csv = rows.map(row => {
            const cells = Array.from(row.querySelectorAll("th, td"));

            return cells.map(cell => {
                let value = cell.innerText.trim().replace(/\s+/g, " ");
                value = value.replace(/"/g, '""');
                return '"' + value + '"';
            }).join(",");
        }).join("\r\n");

        const blob = new Blob(["\uFEFF" + csv], {
            type: "text/csv;charset=utf-8;"
        });

        const url = URL.createObjectURL(blob);
        const link = document.createElement("a");

        link.href = url;
        link.download = "mediguard-stock-valuation.csv";

        document.body.appendChild(link);
        link.click();
        link.remove();

        URL.revokeObjectURL(url);
    }
</script>

</body>
</html>
