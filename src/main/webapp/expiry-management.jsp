
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mediguard.servlet.ExpiryManagementServlet.ExpiryBatch" %>

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
    List<ExpiryBatch> batches =
        (List<ExpiryBatch>) request.getAttribute("batches");

    if (batches == null) {
        batches = java.util.Collections.emptyList();
    }

    String selectedStatus =
        (String) request.getAttribute("selectedStatus");

    if (selectedStatus == null) {
        selectedStatus = "all";
    }

    String errorMessage =
        (String) request.getAttribute("errorMessage");

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Expiry Management | MediGuard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/mediguard.css">

    <style>
        /* Page layout only. Shared colors and components use mediguard.css. */

        .expiry-page {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 22px;
        }

        .expiry-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 25px;
        }

        .expiry-heading h1 {
            margin: 0 0 8px;
            color: var(--mg-primary);
            font-size: 29px;
        }

        .expiry-subtitle {
            color: var(--mg-muted);
            margin: 0;
        }

        .expiry-back {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 42px;
            padding: 11px 17px;
            border: 1px solid var(--mg-border);
            border-radius: 8px;
            background: var(--mg-surface);
            color: var(--mg-primary);
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            white-space: nowrap;
        }

        .expiry-back:hover {
            background: var(--mg-bg);
        }

        .expiry-summary {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 18px;
            margin-bottom: 25px;
        }

        .expiry-summary-card {
            min-width: 0;
            padding: 23px;
        }

        .expiry-card-label {
            color: var(--mg-muted);
            font-size: 13px;
        }

        .expiry-card-number {
            font-size: 32px;
            font-weight: 800;
            margin-top: 12px;
        }

        /* Status colors remain meaningful. */
        .expiry-red {
            color: var(--mg-danger);
        }

        .expiry-orange {
            color: var(--mg-warning);
        }

        .expiry-green {
            color: var(--mg-success);
        }

        .expiry-panel {
            padding: 22px;
        }

        .expiry-filters {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }

        .expiry-filters h2 {
            margin: 0;
            font-size: 20px;
            color: var(--mg-primary);
        }

        .expiry-filter-form {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            margin: 0;
        }

        .expiry-filter-form select {
            min-height: 42px;
            min-width: 155px;
        }

        .expiry-filter-form button {
            min-height: 42px;
        }

        .expiry-table-wrapper {
            width: 100%;
            overflow-x: auto;
        }

        .expiry-table {
            width: 100%;
            min-width: 900px;
            border-collapse: collapse;
        }

        .expiry-table th,
        .expiry-table td {
            padding: 14px 12px;
            text-align: left;
            border-bottom: 1px solid var(--mg-border);
            font-size: 13px;
        }

        .expiry-table th {
            background: var(--mg-bg);
            color: var(--mg-muted);
            font-weight: 700;
            white-space: nowrap;
        }

        .expiry-table tbody tr:hover {
            background: #f8fafc;
        }

        .expiry-table small {
            display: inline-block;
            margin-top: 4px;
            color: var(--mg-muted);
        }

        .expiry-status-badge {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 800;
            white-space: nowrap;
        }

        .expiry-status-expired {
            background: #fee2e2;
            color: #991b1b;
        }

        .expiry-status-soon {
            background: #ffedd5;
            color: #9a3412;
        }

        .expiry-status-safe {
            background: #dcfce7;
            color: #166534;
        }

        .expiry-days {
            font-weight: 600;
        }

        .expiry-empty {
            text-align: center !important;
            padding: 35px !important;
            color: var(--mg-muted);
        }

        .expiry-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
            padding: 14px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .expiry-footer {
            text-align: center;
            color: var(--mg-muted);
            padding: 28px 15px;
            font-size: 12px;
        }

        @media (max-width: 700px) {
            .expiry-page {
                padding: 0 12px;
                margin: 20px auto;
            }

            .expiry-heading h1 {
                font-size: 24px;
            }

            .expiry-summary {
                grid-template-columns: 1fr;
            }

            .expiry-panel {
                padding: 14px;
            }

            .expiry-filters {
                align-items: stretch;
            }

            .expiry-filters h2 {
                font-size: 18px;
            }

            .expiry-filter-form {
                width: 100%;
            }

            .expiry-filter-form select,
            .expiry-filter-form button {
                flex: 1;
                min-width: 0;
            }

            .expiry-back {
                width: 100%;
            }
        }
    </style>
</head>

<body>
<header class="mg-standard-header">
    <div class="mg-brand">
        <h1>MediGuard</h1>
        <p>Expiry Management</p>
    </div>

    <a class="mg-dashboard-button"
       href="${pageContext.request.contextPath}/dashboard">
        Dashboard
    </a>
</header>

<main class="expiry-page">

    <div class="expiry-heading">
        <div>
            <h1>Expiry Management</h1>
            <p class="expiry-subtitle">
                Track medicine batches by expiry date and monitor stock safety.
            </p>
        </div>
    </div>

    <% if (errorMessage != null) { %>
        <div class="expiry-error" role="alert">
            <%= esc(errorMessage) %>
        </div>
    <% } %>

    <section class="expiry-summary">

        <div class="card expiry-summary-card">
            <div class="expiry-card-label">Expired Batches</div>
            <div class="expiry-card-number expiry-red">
                <%= request.getAttribute("expiredCount") == null
                    ? 0 : request.getAttribute("expiredCount") %>
            </div>
        </div>

        <div class="card expiry-summary-card">
            <div class="expiry-card-label">Expiring Within 30 Days</div>
            <div class="expiry-card-number expiry-orange">
                <%= request.getAttribute("expiringCount") == null
                    ? 0 : request.getAttribute("expiringCount") %>
            </div>
        </div>

        <div class="card expiry-summary-card">
            <div class="expiry-card-label">Safe Batches</div>
            <div class="expiry-card-number expiry-green">
                <%= request.getAttribute("safeCount") == null
                    ? 0 : request.getAttribute("safeCount") %>
            </div>
        </div>

    </section>

    <section class="card expiry-panel">

        <div class="expiry-filters">
            <h2>Medicine Expiry Records</h2>

            <form class="expiry-filter-form"
                  method="get"
                  action="<%= ctx %>/expiry-management">

                <select name="status" aria-label="Filter expiry status">
                    <option value="all"
                        <%= "all".equals(selectedStatus) ? "selected" : "" %>>
                        All Batches
                    </option>

                    <option value="expired"
                        <%= "expired".equals(selectedStatus) ? "selected" : "" %>>
                        Expired
                    </option>

                    <option value="expiring"
                        <%= "expiring".equals(selectedStatus) ? "selected" : "" %>>
                        Expiring Soon
                    </option>

                    <option value="safe"
                        <%= "safe".equals(selectedStatus) ? "selected" : "" %>>
                        Safe
                    </option>
                </select>

                <button type="submit">Apply Filter</button>
            </form>
        </div>

        <div class="expiry-table-wrapper">
            <table class="expiry-table">

                <thead>
                    <tr>
                        <th>Medicine</th>
                        <th>Category</th>
                        <th>Batch Number</th>
                        <th>Quantity</th>
                        <th>Expiry Date</th>
                        <th>Days Remaining</th>
                        <th>Status</th>
                    </tr>
                </thead>

                <tbody>

                <% if (batches.isEmpty()) { %>
                    <tr>
                        <td colspan="7" class="expiry-empty">
                            No batches found for this filter.
                        </td>
                    </tr>
                <% } else {
                    for (ExpiryBatch batch : batches) {
                        String badgeClass;

                        if ("Expired".equals(batch.getExpiryStatus())) {
                            badgeClass = "expiry-status-expired";
                        } else if ("Expiring Soon".equals(batch.getExpiryStatus())) {
                            badgeClass = "expiry-status-soon";
                        } else {
                            badgeClass = "expiry-status-safe";
                        }
                %>

                    <tr>
                        <td>
                            <strong><%= esc(batch.getMedicineName()) %></strong>
                            <br>
                            <small><%= esc(batch.getUnitName()) %></small>
                        </td>

                        <td>
                            <%= esc(batch.getCategory() == null
                                ? "-" : batch.getCategory()) %>
                        </td>

                        <td><%= esc(batch.getBatchNumber()) %></td>

                        <td><%= batch.getQuantity() %></td>

                        <td><%= esc(batch.getExpiryDate()) %></td>

                        <td class="expiry-days">
                            <% if (batch.getDaysLeft() < 0) { %>
                                Expired <%= Math.abs(batch.getDaysLeft()) %> day(s) ago
                            <% } else if (batch.getDaysLeft() == 0) { %>
                                Expires today
                            <% } else { %>
                                <%= batch.getDaysLeft() %> day(s)
                            <% } %>
                        </td>

                        <td>
                            <span class="expiry-status-badge <%= badgeClass %>">
                                <%= esc(batch.getExpiryStatus()) %>
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

<footer class="expiry-footer">
    MediGuard &mdash; Medicine Inventory Management System
</footer>

</body>
</html>
