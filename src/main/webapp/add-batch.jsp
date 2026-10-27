
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mediguard.servlet.AddBatchServlet.MedicineOption" %>
<%@ page import="com.mediguard.servlet.AddBatchServlet.SupplierOption" %>
<%
    List<MedicineOption> medicines =
        (List<MedicineOption>) request.getAttribute("medicines");

    List<SupplierOption> suppliers =
        (List<SupplierOption>) request.getAttribute("suppliers");

    if (medicines == null) {
        medicines = java.util.Collections.emptyList();
    }

    if (suppliers == null) {
        suppliers = java.util.Collections.emptyList();
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add Batch | MediGuard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/mediguard.css">

    <style>
        /* Page-specific layout only; theme comes from mediguard.css */
        .batch-page {
            max-width: 850px;
            margin: 32px auto;
            padding: 0 18px;
        }

        .batch-card {
            padding: 28px;
        }

        .batch-subtitle {
            color: var(--mg-muted);
            margin-bottom: 24px;
        }

        .batch-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 20px;
        }

        .batch-field {
            display: flex;
            flex-direction: column;
            gap: 8px;
            min-width: 0;
        }

        .batch-field-full {
            grid-column: 1 / -1;
        }

        .batch-field label {
            font-weight: 600;
        }

        .batch-hint {
            color: var(--mg-muted);
            font-size: 12px;
            line-height: 1.6;
        }

        .batch-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            align-items: center;
            margin-top: 25px;
        }

        .batch-actions .btn-back {
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

        .batch-actions .btn-back:hover {
            background: var(--mg-bg);
        }

        .batch-error {
            padding: 12px 14px;
            border-radius: 8px;
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
            margin-bottom: 18px;
        }

        @media (max-width: 600px) {
            .batch-page {
                margin: 20px auto;
                padding: 0 12px;
            }

            .batch-card {
                padding: 20px;
            }

            .batch-grid {
                grid-template-columns: 1fr;
            }

            .batch-field-full {
                grid-column: auto;
            }

            .batch-actions {
                align-items: stretch;
                flex-direction: column;
            }

            .batch-actions > * {
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
        <p>Add a new medicine batch</p>
    </div>

    <a class="mg-dashboard-button"
       href="${pageContext.request.contextPath}/dashboard">
        Dashboard
    </a>
</header>


<main class="batch-page">
    <section class="card batch-card">
        <h2>Register Medicine Batch</h2>

        <p class="batch-subtitle">
            Create a batch for a medicine already registered in MediGuard.
        </p>

        <% if (errorMessage != null) { %>
            <div class="batch-error" role="alert">
                <%= errorMessage %>
            </div>
        <% } %>

        <% if (medicines.isEmpty()) { %>
            <p>No medicines are registered yet. Add a medicine first.</p>
        <% } else { %>

        <form action="${pageContext.request.contextPath}/add-batch"
              method="post">

            <div class="batch-grid">

                <div class="batch-field batch-field-full">
                    <label for="medicineId">Medicine *</label>

                    <select id="medicineId" name="medicineId" required>
                        <option value="">Select medicine</option>

                        <% for (MedicineOption medicine : medicines) { %>
                            <option value="<%= medicine.getMedicineId() %>">
                                <%= medicine.getMedicineName() %>
                                (ID: <%= medicine.getMedicineId() %>)
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="batch-field">
                    <label for="supplierId">Supplier (optional)</label>

                    <select id="supplierId" name="supplierId">
                        <option value="">No supplier selected</option>

                        <% for (SupplierOption supplier : suppliers) { %>
                            <option value="<%= supplier.getSupplierId() %>">
                                Supplier ID <%= supplier.getSupplierId() %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="batch-field">
                    <label for="batchNumber">Batch Number *</label>

                    <input type="text"
                           id="batchNumber"
                           name="batchNumber"
                           maxlength="100"
                           placeholder="e.g. PCM-2026-001"
                           required>
                </div>

                <div class="batch-field">
                    <label for="quantity">Initial Quantity *</label>

                    <input type="number"
                           id="quantity"
                           name="quantity"
                           min="0"
                           step="1"
                           value="0"
                           required>
                </div>

                <div class="batch-field">
                    <label for="unitCost">Unit Cost *</label>

                    <input type="number"
                           id="unitCost"
                           name="unitCost"
                           min="0"
                           step="0.01"
                           value="0.00"
                           required>
                </div>

                <div class="batch-field">
                    <label for="mfgDate">Manufacturing Date</label>

                    <input type="date"
                           id="mfgDate"
                           name="mfgDate">
                </div>

                <div class="batch-field">
                    <label for="expiryDate">Expiry Date *</label>

                    <input type="date"
                           id="expiryDate"
                           name="expiryDate"
                           required>
                </div>

                <div class="batch-field batch-field-full">
                    <span class="batch-hint">
                        Batch numbers must be unique. The batch ID and creation
                        timestamp are generated by the database.
                    </span>
                </div>

            </div>

            <div class="batch-actions">
                <button type="submit">Save Batch</button>
            </div>

        </form>

        <% } %>
    </section>
</main>

</body>
</html>
