
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mediguard.servlet.IssueStockServlet.BatchOption" %>

<%
    List<BatchOption> batches =
        (List<BatchOption>) request.getAttribute("batches");

    if (batches == null) {
        batches = java.util.Collections.emptyList();
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Issue Stock | MediGuard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/mediguard.css">

    <style>
        /* Page-specific layout; colors come from mediguard.css */
        .issue-page {
            max-width: 700px;
            margin: 35px auto;
            padding: 0 18px;
        }

        .issue-card {
            padding: 28px;
        }

        .issue-subtitle {
            color: var(--mg-muted);
            margin-bottom: 25px;
        }

        .issue-field {
            margin-bottom: 20px;
        }

        .issue-field label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .issue-field input,
        .issue-field select {
            width: 100%;
        }

        .issue-notice {
            background: #fff7ed;
            color: #9a3412;
            border: 1px solid #fed7aa;
            padding: 12px 14px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            line-height: 1.6;
        }

        .issue-error {
            padding: 12px 14px;
            border-radius: 8px;
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
            margin-bottom: 18px;
        }

        .issue-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            align-items: center;
            margin-top: 25px;
        }

        .issue-back {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 12px 18px;
            border: 1px solid var(--mg-border);
            border-radius: var(--mg-radius);
            background: var(--mg-surface);
            color: var(--mg-primary);
            text-decoration: none;
            font-weight: 600;
        }

        .issue-back:hover {
            background: var(--mg-bg);
        }

        @media (max-width: 500px) {
            .issue-page {
                margin: 20px auto;
                padding: 0 12px;
            }

            .issue-card {
                padding: 20px;
            }

            .issue-actions {
                flex-direction: column;
                align-items: stretch;
            }

            .issue-actions > * {
                width: 100%;
                text-align: center;
            }
        }
    </style>
</head>

<body>

<header class="mg-standard-header">
    <div class="mg-brand">
        <h1>MediGuard</h1>
        <p>Issue Stock</p>
    </div>

    <a class="mg-dashboard-button"
       href="${pageContext.request.contextPath}/dashboard">
        Dashboard
    </a>
</header>

<main class="issue-page">
    <section class="card issue-card">

        <h2>Issue Stock</h2>

        <p class="issue-subtitle">
            Record medicines dispensed or removed from inventory.
        </p>

        <div class="issue-notice">
            Check the available quantity before issuing stock.
            You cannot issue more than the available batch quantity.
        </div>

        <% if (errorMessage != null) { %>
            <div class="issue-error" role="alert">
                <%= errorMessage %>
            </div>
        <% } %>

        <% if (batches.isEmpty()) { %>

            <p>No medicine batches are available.</p>

        <% } else { %>

            <form action="${pageContext.request.contextPath}/issue-stock"
                  method="post">

                <div class="issue-field">
                    <label for="batchId">Medicine Batch *</label>

                    <select id="batchId" name="batchId" required>
                        <option value="">Select a batch</option>

                        <% for (BatchOption batch : batches) { %>
                            <option value="<%= batch.getBatchId() %>">
                                <%= batch.getMedicineName() %>
                                — <%= batch.getBatchNumber() %>
                                (Available: <%= batch.getQuantity() %>)
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="issue-field">
                    <label for="quantity">Quantity to Issue *</label>

                    <input type="number"
                           id="quantity"
                           name="quantity"
                           min="1"
                           step="1"
                           required>
                </div>

                <div class="issue-field">
                    <label for="reason">Reason for Issue *</label>

                    <input type="text"
                           id="reason"
                           name="reason"
                           maxlength="200"
                           placeholder="e.g. Medicine dispensed"
                           required>
                </div>

                <div class="issue-actions">
                    <button type="submit">Issue Stock</button>
                </div>

            </form>

        <% } %>

    </section>
</main>

</body>
</html>
