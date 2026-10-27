
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add Medicine | MediGuard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/mediguard.css">

    <style>
        /* Page-specific layout; shared theme comes from mediguard.css */
        .medicine-page {
            max-width: 760px;
            margin: 35px auto;
            padding: 0 18px;
        }

        .medicine-card {
            padding: 30px;
        }

        .medicine-subtitle {
            color: var(--mg-muted);
            margin-bottom: 25px;
        }

        .medicine-form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 20px;
        }

        .medicine-field {
            display: flex;
            flex-direction: column;
            gap: 8px;
            min-width: 0;
        }

        .medicine-field-full {
            grid-column: 1 / -1;
        }

        .medicine-field label {
            font-weight: 600;
        }

        .medicine-hint {
            font-size: 12px;
            color: var(--mg-muted);
            line-height: 1.6;
        }

        .medicine-error {
            background: #fee2e2;
            color: #991b1b;
            padding: 12px 14px;
            border-radius: 8px;
            border: 1px solid #fecaca;
            margin-bottom: 20px;
        }

        .medicine-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            align-items: center;
            margin-top: 25px;
        }

        .medicine-actions .medicine-cancel {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            padding: 12px 18px;
            border: 1px solid var(--mg-border);
            border-radius: var(--mg-radius);
            background: var(--mg-surface);
            color: var(--mg-primary);
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
        }

        .medicine-actions .medicine-cancel:hover {
            background: var(--mg-bg);
        }

        @media (max-width: 560px) {
            .medicine-page {
                margin: 20px auto;
                padding: 0 12px;
            }

            .medicine-card {
                padding: 20px;
            }

            .medicine-form-grid {
                grid-template-columns: 1fr;
            }

            .medicine-field-full {
                grid-column: auto;
            }

            .medicine-actions {
                flex-direction: column;
                align-items: stretch;
            }

            .medicine-actions > * {
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
        <p>Add a new medicine</p>
    </div>

    <a class="mg-dashboard-button"
       href="${pageContext.request.contextPath}/dashboard">
        Dashboard
    </a>
</header>

<main class="medicine-page">
    <section class="card medicine-card">

        <h2>Add New Medicine</h2>

        <p class="medicine-subtitle">
            Enter the medicine details to register it in the inventory.
        </p>

        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="medicine-error" role="alert">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/add-medicine"
              method="post">

            <div class="medicine-form-grid">

                <div class="medicine-field">
                    <label for="medicineId">Medicine ID *</label>

                    <input type="number"
                           id="medicineId"
                           name="medicineId"
                           min="1"
                           step="1"
                           required
                           value="<%= request.getAttribute("medicineId") == null ? "" : request.getAttribute("medicineId") %>">

                    <span class="medicine-hint">
                        Enter a unique positive ID.
                    </span>
                </div>

                <div class="medicine-field">
                    <label for="medicineName">Medicine Name *</label>

                    <input type="text"
                           id="medicineName"
                           name="medicineName"
                           maxlength="100"
                           required
                           value="<%= request.getAttribute("medicineName") == null ? "" : request.getAttribute("medicineName") %>">
                </div>

                <div class="medicine-field">
                    <label for="category">Category *</label>

                    <select id="category" name="category" required>
                        <option value="">Select category</option>
                        <option value="Pain Relief">Pain Relief</option>
                        <option value="Antibiotic">Antibiotic</option>
                        <option value="Allergy">Allergy</option>
                        <option value="Vitamins">Vitamins</option>
                        <option value="Other">Other</option>
                    </select>
                </div>

                <div class="medicine-field">
                    <label for="unitName">Unit *</label>

                    <select id="unitName" name="unitName" required>
                        <option value="">Select unit</option>
                        <option value="Tablet">Tablet</option>
                        <option value="Capsule">Capsule</option>
                        <option value="Bottle">Bottle</option>
                        <option value="Strip">Strip</option>
                        <option value="Pack">Pack</option>
                        <option value="Piece">Piece</option>
                    </select>
                </div>

                <div class="medicine-field medicine-field-full">
                    <label for="reorderLevel">Reorder Level *</label>

                    <input type="number"
                           id="reorderLevel"
                           name="reorderLevel"
                           min="0"
                           step="1"
                           required
                           value="10">

                    <span class="medicine-hint">
                        The minimum stock quantity at which the medicine
                        should be flagged as low stock.
                    </span>
                </div>

            </div>

            <div class="medicine-actions">
                <button type="submit">Save Medicine</button>

                <a class="medicine-cancel"
                   href="${pageContext.request.contextPath}/dashboard">
                    Cancel
                </a>
            </div>

        </form>
    </section>
</main>

</body>
</html>
