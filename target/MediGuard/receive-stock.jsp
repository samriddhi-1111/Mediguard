
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mediguard.servlet.ReceiveStockServlet.BatchOption" %>

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

    <title>Receive Stock | MediGuard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/mediguard.css">

    <style>
        /* Page-specific layout; shared theme comes from mediguard.css */

        .receive-page {
            max-width: 700px;
            margin: 35px auto;
            padding: 0 18px;
        }

        .receive-card {
            padding: 28px;
        }

        .receive-subtitle {
            color: var(--mg-muted);
            margin-bottom: 25px;
            line-height: 1.6;
        }

        .receive-field {
            margin-bottom: 20px;
        }

        .receive-field label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .receive-field select,
        .receive-field input {
            width: 100%;
        }

        .receive-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
            border-radius: 8px;
            padding: 12px 14px;
            margin-bottom: 18px;
            overflow-wrap: anywhere;
        }

        .receive-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            align-items: center;
            margin-top: 25px;
        }

        .receive-back {
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

        .receive-back:hover {
            background: var(--mg-bg);
        }

        @media (max-width: 500px) {
            .receive-page {
                margin: 20px auto;
                padding: 0 12px;
            }

            .receive-card {
                padding: 20px;
            }

            .receive-actions {
                flex-direction: column;
                align-items: stretch;
            }

            .receive-actions > * {
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
        <p>Receive Stock</p>
    </div>

    <a class="mg-dashboard-button"
       href="${pageContext.request.contextPath}/dashboard">
        Dashboard
    </a>
</header>

<main class="receive-page">
    <section class="card receive-card">

        <h2>Receive Medicine Stock</h2>

        <p class="receive-subtitle">
            Select an existing batch and enter the additional quantity received.
        </p>

        <% if (errorMessage != null) { %>
            <div class="receive-error" role="alert">
                <%= errorMessage %>
            </div>
        <% } %>

        <% if (batches.isEmpty()) { %>

            <p>
                No batches are available. Add a medicine batch before receiving stock.
            </p>

        <% } else { %>

            <form action="${pageContext.request.contextPath}/receive-stock"
                  method="post">

                <div class="receive-field">
                    <label for="batchId">Medicine Batch *</label>

                    <select id="batchId" name="batchId" required>
                        <option value="">Select a batch</option>

                        <% for (BatchOption batch : batches) { %>
                            <option value="<%= batch.getBatchId() %>">
                                <%= batch.getMedicineName() %>
                                — <%= batch.getBatchNumber() %>
                                (Current stock: <%= batch.getQuantity() %>)
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="receive-field">
                    <label for="quantity">Quantity Received *</label>

                    <input type="number"
                           id="quantity"
                           name="quantity"
                           min="1"
                           step="1"
                           required>
                </div>

                <div class="receive-field">
                    <label for="reason">Reason *</label>

                    <input type="text"
                           id="reason"
                           name="reason"
                           maxlength="200"
                           required
                           placeholder="e.g. New supplier delivery">
                </div>

                <div class="receive-actions">
                    <button type="submit">Receive Stock</button>

                </div>

            </form>

        <% } %>

    </section>
</main>

</body>
</html>
