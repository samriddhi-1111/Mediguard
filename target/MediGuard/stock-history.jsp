
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mediguard.servlet.StockHistoryServlet.StockTransaction" %>
<%
    List<StockTransaction> transactions =
        (List<StockTransaction>) request.getAttribute("transactions");

    if (transactions == null) {
        transactions = java.util.Collections.emptyList();
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Stock History | MediGuard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/mediguard.css">

    <style>
        .stock-history-page {
            min-height: 100vh;
            background: var(--mg-bg);
        }

        .stock-history-header {
            background: var(--mg-primary);
            color: #ffffff;
            padding: 22px 6%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .stock-history-header h1 {
            margin: 0;
            color: #ffffff;
        }

        .stock-history-header p {
            margin: 6px 0 0;
            color: #dbeafe;
        }

        .stock-history-back {
            display: inline-block;
            padding: 11px 16px;
            border: 1px solid rgba(255, 255, 255, 0.4);
            border-radius: 8px;
            background: #ffffff;
            color: var(--mg-primary);
            text-decoration: none;
            font-weight: 600;
            transition: background 0.2s ease;
        }

        .stock-history-back:hover {
            background: #eff6ff;
        }

        .stock-history-main {
            padding: 30px 6%;
        }

        .stock-history-panel {
            background: var(--mg-surface);
            padding: 24px;
            border: 1px solid var(--mg-border);
            border-radius: var(--mg-radius);
            box-shadow: var(--mg-shadow);
            overflow-x: auto;
        }

        .stock-history-panel h2 {
            margin-top: 0;
            margin-bottom: 8px;
            color: var(--mg-text);
        }

        .stock-history-subtitle {
            margin: 0 0 22px;
            color: var(--mg-muted);
            line-height: 1.6;
        }

        .stock-history-error {
            padding: 12px 14px;
            margin-bottom: 20px;
            border: 1px solid #fecaca;
            border-radius: 8px;
            background: #fee2e2;
            color: #991b1b;
        }

        .stock-history-table {
            width: 100%;
            min-width: 1000px;
            border-collapse: collapse;
            text-align: left;
        }

        .stock-history-table th,
        .stock-history-table td {
            padding: 13px 12px;
            border-bottom: 1px solid var(--mg-border);
            font-size: 14px;
            vertical-align: middle;
        }

        .stock-history-table th {
            background: #f8fafc;
            color: #475569;
            font-weight: 600;
            white-space: nowrap;
        }

        .stock-history-table tbody tr:hover {
            background: #f8fafc;
        }

        .stock-history-type {
            display: inline-block;
            padding: 5px 9px;
            border-radius: 20px;
            background: #e0f2fe;
            color: #075985;
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

        .stock-history-empty {
            padding: 25px !important;
            text-align: center;
            color: var(--mg-muted);
        }

        @media (max-width: 600px) {
            .stock-history-header {
                padding: 20px 4%;
            }

            .stock-history-main {
                padding: 20px 4%;
            }

            .stock-history-panel {
                padding: 16px;
            }
        }
    </style>
</head>

<body>
<div class="stock-history-page">

    <header class="stock-history-header">
        <div>
            <h1>MediGuard</h1>
            <p>Stock History</p>
        </div>

        <a class="stock-history-back"
           href="${pageContext.request.contextPath}/dashboard">
            Dashboard
        </a>
    </header>

    <main class="stock-history-main">
        <section class="stock-history-panel">
            <h2>Transaction History</h2>

            <p class="stock-history-subtitle">
                Review medicine stock receipts and issues recorded in Oracle.
            </p>

            <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                <div class="stock-history-error" role="alert">
                    <%= errorMessage %>
                </div>
            <% } %>

            <table class="stock-history-table">
                <thead>
                    <tr>
                        <th>Log ID</th>
                        <th>Medicine</th>
                        <th>Batch ID</th>
                        <th>Batch Number</th>
                        <th>Action</th>
                        <th>Quantity</th>
                        <th>Reason</th>
                        <th>Action By</th>
                        <th>Date and Time</th>
                    </tr>
                </thead>

                <tbody>
                    <% if (transactions.isEmpty()) { %>
                        <tr>
                            <td colspan="9" class="stock-history-empty">
                                No stock transactions have been recorded yet.
                            </td>
                        </tr>
                    <% } else {
                        for (StockTransaction transaction : transactions) {
                    %>
                        <tr>
                            <td><%= transaction.getLogId() %></td>

                            <td>
                                <%= transaction.getMedicineName() == null
                                        ? "Unknown medicine"
                                        : transaction.getMedicineName() %>
                            </td>

                            <td><%= transaction.getBatchId() %></td>

                            <td>
                                <%= transaction.getBatchNumber() == null
                                        ? "—"
                                        : transaction.getBatchNumber() %>
                            </td>

                            <td>
                                <span class="stock-history-type">
                                    <%= transaction.getActionType() == null
                                            ? "Unknown"
                                            : transaction.getActionType() %>
                                </span>
                            </td>

                            <td><%= transaction.getQuantity() %></td>

                            <td>
                                <%= transaction.getReason() == null
                                        ? "—"
                                        : transaction.getReason() %>
                            </td>

                            <td>
                                <%= transaction.getActionBy() == null
                                        ? "—"
                                        : transaction.getActionBy() %>
                            </td>

                            <td><%= transaction.getActionAt() %></td>
                        </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </section>
    </main>

</div>
</body>
</html>
