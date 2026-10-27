
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mediguard.servlet.SupplierServlet.Supplier" %>
<%
    List<Supplier> suppliers =
        (List<Supplier>) request.getAttribute("suppliers");

    if (suppliers == null) {
        suppliers = java.util.Collections.emptyList();
    }

    String successMessage =
        (String) request.getAttribute("successMessage");

    String errorMessage =
        (String) request.getAttribute("errorMessage");

    String formError =
        (String) request.getAttribute("formError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Supplier Management | MediGuard</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/mediguard.css">

    <style>
        .suppliers-page {
            min-height: 100vh;
            background: var(--mg-bg);
        }

        .suppliers-header {
            background: var(--mg-primary);
            color: #ffffff;
            padding: 22px 6%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
        }

        .suppliers-header h1 {
            margin: 0;
            color: #ffffff;
        }

        .suppliers-header p {
            margin: 6px 0 0;
            color: #dbeafe;
        }

        .suppliers-back {
            display: inline-block;
            padding: 11px 15px;
            border-radius: 8px;
            background: #ffffff;
            color: var(--mg-primary);
            text-decoration: none;
            font-weight: 600;
            transition: background 0.2s ease;
        }

        .suppliers-back:hover {
            background: #eff6ff;
        }

        .suppliers-main {
            padding: 30px 6%;
        }

        .suppliers-layout {
            display: grid;
            grid-template-columns: minmax(280px, 0.8fr) minmax(0, 1.7fr);
            gap: 22px;
            align-items: start;
        }

        .suppliers-panel {
            min-width: 0;
            background: var(--mg-surface);
            border: 1px solid var(--mg-border);
            border-radius: var(--mg-radius);
            padding: 24px;
            box-shadow: var(--mg-shadow);
        }

        .suppliers-panel h2 {
            margin-top: 0;
            margin-bottom: 10px;
            color: var(--mg-text);
        }

        .suppliers-muted {
            color: var(--mg-muted);
            line-height: 1.6;
            margin: 0 0 18px;
        }

        .suppliers-field {
            margin-bottom: 17px;
        }

        .suppliers-field label {
            display: block;
            margin-bottom: 7px;
            color: var(--mg-text);
            font-size: 14px;
            font-weight: 600;
        }

        .suppliers-field input,
        .suppliers-field textarea {
            width: 100%;
            padding: 11px 12px;
            border: 1px solid var(--mg-border);
            border-radius: 8px;
            background: #ffffff;
            color: var(--mg-text);
            font: inherit;
            box-sizing: border-box;
            transition: border-color 0.2s ease,
                        box-shadow 0.2s ease;
        }

        .suppliers-field input:focus,
        .suppliers-field textarea:focus {
            outline: none;
            border-color: var(--mg-accent);
            box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.12);
        }

        .suppliers-field textarea {
            min-height: 90px;
            resize: vertical;
        }

        .suppliers-submit {
            display: inline-block;
            width: 100%;
            padding: 12px 18px;
            border: none;
            border-radius: 8px;
            background: var(--mg-primary);
            color: #ffffff;
            font: inherit;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s ease;
        }

        .suppliers-submit:hover {
            background: var(--mg-primary-dark);
        }

        .suppliers-message {
            padding: 12px 14px;
            border-radius: 8px;
            margin-bottom: 18px;
            line-height: 1.5;
        }

        .suppliers-success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .suppliers-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .suppliers-table-wrap {
            overflow-x: auto;
            width: 100%;
        }

        .suppliers-table {
            width: 100%;
            min-width: 750px;
            border-collapse: collapse;
            text-align: left;
        }

        .suppliers-table th,
        .suppliers-table td {
            padding: 12px;
            border-bottom: 1px solid var(--mg-border);
            font-size: 13px;
            vertical-align: top;
            overflow-wrap: anywhere;
        }

        .suppliers-table th {
            background: #f8fafc;
            color: #475569;
            font-weight: 600;
            white-space: nowrap;
        }

        .suppliers-table tbody tr:hover {
            background: #f8fafc;
        }

        .suppliers-count {
            font-weight: 700;
            color: var(--mg-primary);
        }

        .suppliers-empty {
            padding: 22px !important;
            text-align: center;
            color: var(--mg-muted);
        }

        @media (max-width: 1000px) {
            .suppliers-layout {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 550px) {
            .suppliers-header {
                padding: 20px 4%;
            }

            .suppliers-main {
                padding: 20px 4%;
            }

            .suppliers-panel {
                padding: 17px;
            }
        }
    </style>
</head>

<body>
<div class="suppliers-page">

 <header class="mg-standard-header">
    <div class="mg-brand">
        <h1>MediGuard</h1>
        <p>Supplier Management</p>
    </div>

    <a class="mg-dashboard-button"
       href="${pageContext.request.contextPath}/dashboard">
        Dashboard
    </a>
</header>

    <main class="suppliers-main">

        <% if (successMessage != null) { %>
            <div class="suppliers-message suppliers-success" role="status">
                <%= successMessage %>
            </div>
        <% } %>

        <% if (errorMessage != null) { %>
            <div class="suppliers-message suppliers-error" role="alert">
                <%= errorMessage %>
            </div>
        <% } %>

        <div class="suppliers-layout">

            <section class="suppliers-panel">
                <h2>Add Supplier</h2>
                <p class="suppliers-muted">
                    Fields marked * are required.
                </p>

                <% if (formError != null) { %>
                    <div class="suppliers-message suppliers-error"
                         role="alert">
                        <%= formError %>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/suppliers"
                      method="post">

                    <div class="suppliers-field">
                        <label for="supplierName">Supplier Name *</label>
                        <input type="text"
                               id="supplierName"
                               name="supplierName"
                               maxlength="200"
                               required
                               placeholder="Company or supplier name">
                    </div>

                    <div class="suppliers-field">
                        <label for="phone">Phone</label>
                        <input type="tel"
                               id="phone"
                               name="phone"
                               maxlength="50"
                               placeholder="Contact number">
                    </div>

                    <div class="suppliers-field">
                        <label for="email">Email</label>
                        <input type="email"
                               id="email"
                               name="email"
                               maxlength="200"
                               placeholder="supplier@example.com">
                    </div>

                    <div class="suppliers-field">
                        <label for="address">Address</label>
                        <textarea id="address"
                                  name="address"
                                  maxlength="500"
                                  placeholder="Supplier address"></textarea>
                    </div>

                    <button class="suppliers-submit" type="submit">
                        Save Supplier
                    </button>
                </form>
            </section>

            <section class="suppliers-panel">
                <h2>Supplier Directory</h2>

                <p class="suppliers-muted">
                    Registered suppliers:
                    <span class="suppliers-count"><%= suppliers.size() %></span>
                </p>

                <div class="suppliers-table-wrap">
                    <table class="suppliers-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Supplier</th>
                                <th>Phone</th>
                                <th>Email</th>
                                <th>Address</th>
                                <th>Created</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% if (suppliers.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="suppliers-empty">
                                        No suppliers found.
                                    </td>
                                </tr>
                            <% } else {
                                for (Supplier supplier : suppliers) {
                            %>
                                <tr>
                                    <td><%= supplier.getSupplierId() %></td>

                                    <td><%= supplier.getSupplierName() %></td>

                                    <td>
                                        <%= supplier.getPhone() == null
                                                ? "—" : supplier.getPhone() %>
                                    </td>

                                    <td>
                                        <%= supplier.getEmail() == null
                                                ? "—" : supplier.getEmail() %>
                                    </td>

                                    <td>
                                        <%= supplier.getAddress() == null
                                                ? "—" : supplier.getAddress() %>
                                    </td>

                                    <td><%= supplier.getCreatedAt() %></td>
                                </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </section>

        </div>
    </main>

</div>
</body>
</html>
