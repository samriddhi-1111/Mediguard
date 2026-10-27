
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mediguard.servlet.DashboardServlet.MedicineRow" %>

<%
    List<MedicineRow> medicines =
        (List<MedicineRow>) request.getAttribute("medicines");

    if (medicines == null) {
        medicines = java.util.Collections.emptyList();
    }

    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String contextPath = request.getContextPath();

    Object fullNameValue = session.getAttribute("fullName");
    Object roleValue = session.getAttribute("userRole");

    String fullName = fullNameValue == null ? "User" : fullNameValue.toString();
    String userRole = roleValue == null ? "USER" : roleValue.toString();

    Object totalMedicines = request.getAttribute("totalMedicines");
    Object totalUnits = request.getAttribute("totalUnits");
    Object lowStockMedicines = request.getAttribute("lowStockMedicines");
    Object expiryAlerts = request.getAttribute("expiryAlerts");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>MediGuard | Dashboard</title>

    <style>
        :root {
            --navy: #14243e;
            --navy-light: #1e3455;
            --teal: #16b8a6;
            --background: #f4f7fb;
            --surface: #ffffff;
            --text: #1c2b43;
            --muted: #7a879b;
            --border: #e7ecf3;
        }

        * {
            box-sizing: border-box;
        }

        html {
            min-height: 100%;
            scroll-behavior: smooth;
        }

        body {
            margin: 0;
            background: var(--background);
            color: var(--text);
            font-family: "Segoe UI", Arial, sans-serif;
            font-size: 15px;
            line-height: 1.65;
        }

        a {
            text-decoration: none;
        }

        button {
            font: inherit;
        }

        .app {
            min-height: 100vh;
        }

        /* ================================
           SIDEBAR
           ================================ */

        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            bottom: 0;
            z-index: 10;

            display: flex;
            flex-direction: column;

            width: 250px;
            min-width: 250px;
            max-width: 250px;

            padding: 25px 15px 18px;
            overflow-x: hidden;
            overflow-y: auto;

            background: var(--navy);
            color: #ffffff;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 11px;

            padding: 0 9px 23px;
            border-bottom: 1px solid rgba(255, 255, 255, .12);
        }

        .brand-icon {
            display: grid;
            place-items: center;

            width: 43px;
            height: 43px;
            flex-shrink: 0;

            border-radius: 12px;
            background: var(--teal);
            color: #073c3b;

            font-size: 24px;
            font-weight: 900;
        }

        .brand-name {
            font-size: 24px;
            font-weight: 800;
            line-height: 1.3;
            letter-spacing: -.5px;
        }

        .brand-caption {
            margin-top: 3px;
            color: #a8bad1;
            font-size: 12px;
        }

        .nav-list {
            display: flex;
            flex-direction: column;
            gap: 5px;

            width: 100%;
            min-width: 0;
        }

        .nav-label {
            margin: 24px 10px 9px;
            color: #91a8c5;
            font-size: 13px;
            font-weight: 800;
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 11px;

            width: 100%;
            min-width: 0;
            min-height: 49px;
            padding: 11px 13px;

            border-radius: 10px;
            color: #c8d5e6;

            font-size: 15px;
            font-weight: 600;

            transition: background .2s ease, color .2s ease;
        }

        .nav-link:hover,
        .nav-link:focus-visible {
            background: rgba(255, 255, 255, .09);
            color: #ffffff;
            outline: none;
        }

        .nav-link.active {
            background: rgba(22, 184, 166, .17);
            color: #ffffff;
            box-shadow: inset 3px 0 var(--teal);
        }

        .nav-icon {
            display: inline-grid;
            place-items: center;

            width: 22px;
            flex-shrink: 0;

            font-size: 19px;
        }

        /* ================================
           DROPDOWN HEADINGS
           ================================ */

        .nav-group-toggle {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;

            width: 100%;
            min-width: 0;
            min-height: 48px;

            margin-top: 8px;
            padding: 11px 12px;

            border: 1px solid transparent;
            border-radius: 9px;

            background: transparent;
            color: #b7c9e2;

            font-family: inherit;
            font-size: 14px;
            font-weight: 750;
            letter-spacing: .5px;
            text-align: left;

            cursor: pointer;

            transition:
                background .2s ease,
                color .2s ease,
                border-color .2s ease;
        }

        .nav-group-toggle:hover {
            background: rgba(255, 255, 255, .06);
            color: #ffffff;
        }

        .nav-group-toggle:focus-visible {
            outline: 2px solid var(--teal);
            outline-offset: 2px;
        }

        .nav-group-title {
            min-width: 0;
            line-height: 1.45;
        }

        /* Simple unboxed chevron */

        .nav-chevron {
            display: inline-flex;
            align-items: center;
            justify-content: center;

            width: 24px;
            height: 24px;
            flex-shrink: 0;

            border: none;
            border-radius: 0;
            background: transparent;
            color: var(--teal);

            font-size: 25px;
            font-weight: 500;
            line-height: 1;

            transform: rotate(0deg);

            transition:
                transform .2s ease,
                color .2s ease;
        }

        /* Closed dropdown: chevron points right */

        .nav-group-toggle[aria-expanded="false"] .nav-chevron {
            transform: rotate(-90deg);
        }

        /* Open dropdown: chevron points down */

        .nav-group-toggle[aria-expanded="true"] .nav-chevron {
            transform: rotate(0deg);
            color: var(--teal);
        }

        /* Highlight expanded heading */

        .nav-group-toggle[aria-expanded="true"] {
            background: rgba(22, 184, 166, .10);
            border-color: rgba(22, 184, 166, .35);
            color: #ffffff;
        }

        .nav-group-items {
            display: flex;
            flex-direction: column;
            gap: 4px;

            width: 100%;
            min-width: 0;
            padding: 5px 0 7px 7px;
        }

        .nav-group-items .nav-link {
            min-height: 45px;
            font-size: 14px;
            border-radius: 8px;
        }

        .nav-group-items[hidden] {
            display: none !important;
        }

        .sidebar-bottom {
            margin-top: auto;
            padding: 22px 10px 0;
            color: #91a8c5;
            font-size: 12px;
        }

        .sidebar-bottom span {
            display: block;
            margin-top: 4px;
            color: #d2dbea;
            font-size: 13px;
        }

        /* ================================
           TOP HEADER
           ================================ */

        .main {
            min-width: 0;
            min-height: 100vh;
            margin-left: 250px;
        }

        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;

            min-height: 94px;
            padding: 20px 30px;

            border-bottom: 1px solid var(--border);
            background: var(--surface);
        }

        .topbar-title {
            margin: 0;
            font-size: 27px;
            font-weight: 800;
            line-height: 1.3;
            letter-spacing: -.6px;
        }

        .topbar-subtitle {
            margin: 5px 0 0;
            color: var(--muted);
            font-size: 14px;
        }

        .account {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .avatar {
            display: grid;
            place-items: center;

            width: 44px;
            height: 44px;
            flex-shrink: 0;

            border-radius: 50%;
            background: #dff7f2;
            color: #087e70;

            font-size: 16px;
            font-weight: 800;
        }

        .account-name {
            max-width: 190px;
            overflow: hidden;
            color: var(--text);

            font-size: 14px;
            font-weight: 750;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .account-role {
            margin-top: 2px;
            color: var(--muted);
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 1px;
        }

        /* Logout button */

        .logout {
            display: inline-flex;
            align-items: center;
            justify-content: center;

            min-height: 43px;
            margin-left: 4px;
            padding: 10px 17px;

            border: 1px solid #f0bfc5;
            border-radius: 10px;

            background: #fff1f2;
            color: #b42332;

            font-size: 13px;
            font-weight: 800;
            white-space: nowrap;

            box-shadow: 0 3px 8px rgba(180, 35, 50, .07);

            transition:
                background .2s ease,
                color .2s ease,
                box-shadow .2s ease,
                transform .2s ease;
        }

        .logout:hover {
            background: #b42332;
            color: #ffffff;
            box-shadow: 0 5px 14px rgba(180, 35, 50, .2);
            transform: translateY(-1px);
        }

        .logout:focus-visible {
            outline: 3px solid rgba(180, 35, 50, .25);
            outline-offset: 3px;
        }

        /* ================================
           CONTENT
           ================================ */

        .content {
            width: 100%;
            max-width: 1650px;
            min-width: 0;

            margin: 0 auto;
            padding: 34px 32px 40px;
        }

        .welcome {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 15px;

            margin-bottom: 25px;
        }

        .welcome h2 {
            margin: 0;
            font-size: 23px;
            line-height: 1.4;
            letter-spacing: -.3px;
        }

        .welcome p {
            margin: 6px 0 0;
            color: var(--muted);
            font-size: 14px;
        }

        .live-label {
            display: inline-flex;
            align-items: center;
            gap: 8px;

            padding: 9px 13px;
            border-radius: 30px;

            background: #e5f8f0;
            color: #16764f;

            font-size: 12px;
            font-weight: 800;
            white-space: nowrap;
        }

        .live-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #18a66f;
        }

        .message {
            margin-bottom: 18px;
            padding: 13px 16px;
            border: 1px solid transparent;
            border-radius: 10px;
            font-size: 14px;
        }

        .message.success {
            border-color: #c4edd2;
            background: #eaf9ef;
            color: #17663a;
        }

        .message.error {
            border-color: #ffd0d4;
            background: #fff0f1;
            color: #a21e2b;
        }

        /* ================================
           STATISTIC CARDS
           ================================ */

        .stats {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 18px;
            margin-bottom: 29px;
        }

        .stat-card {
            min-width: 0;
            padding: 23px;

            border: 1px solid var(--border);
            border-top: 3px solid var(--accent);
            border-radius: 15px;

            background: var(--surface);
            box-shadow: 0 5px 22px rgba(22, 39, 67, .06);

            transition: transform .2s ease, box-shadow .2s ease;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 28px rgba(22, 39, 67, .10);
        }

        .stat-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
        }

        .stat-label {
            color: var(--muted);
            font-size: 13px;
            font-weight: 650;
            line-height: 1.5;
        }

        .stat-icon {
            display: grid;
            place-items: center;

            width: 39px;
            height: 39px;
            flex-shrink: 0;

            border-radius: 12px;
            background: var(--icon-bg);
            color: var(--accent);

            font-size: 19px;
        }

        .stat-value {
            display: block;
            margin-top: 17px;

            color: var(--text);
            font-size: 36px;
            font-weight: 800;
            line-height: 1.2;
            letter-spacing: -1px;
        }

        .stat-note {
            margin-top: 9px;
            color: var(--muted);
            font-size: 12px;
        }

        .stat-teal {
            --accent: #109e8f;
            --icon-bg: #def8f2;
        }

        .stat-blue {
            --accent: #477fd2;
            --icon-bg: #e6efff;
        }

        .stat-amber {
            --accent: #d89227;
            --icon-bg: #fff1d9;
        }

        .stat-rose {
            --accent: #d65d70;
            --icon-bg: #ffeaee;
        }

        /* ================================
           INVENTORY TABLE
           ================================ */

        .inventory {
            min-width: 0;
            overflow: hidden;

            border: 1px solid var(--border);
            border-radius: 16px;

            background: var(--surface);
            box-shadow: 0 7px 26px rgba(22, 39, 67, .06);
        }

        .inventory-heading {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;

            padding: 23px 25px;
            border-bottom: 1px solid var(--border);
        }

        .inventory-title {
            margin: 0;
            font-size: 20px;
            font-weight: 800;
            letter-spacing: -.2px;
        }

        .inventory-subtitle {
            margin: 5px 0 0;
            color: var(--muted);
            font-size: 13px;
        }

        .record-count {
            padding: 8px 12px;
            border-radius: 8px;
            background: #f0f4f9;
            color: #627188;
            font-size: 12px;
            font-weight: 800;
            white-space: nowrap;
        }

        .table-scroll {
            width: 100%;
            max-width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }

        table {
            width: 100%;
            min-width: 980px;
            border-collapse: separate;
            border-spacing: 0;
            text-align: left;
        }

        thead th {
            padding: 16px 17px;
            border-bottom: 1px solid var(--border);

            background: #f8fafc;
            color: #68778d;

            font-size: 12px;
            font-weight: 800;
            letter-spacing: .4px;
            text-transform: uppercase;
            white-space: nowrap;
        }

        tbody td {
            padding: 18px 17px;
            border-bottom: 1px solid #edf1f6;

            color: #405069;
            font-size: 14px;
            line-height: 1.6;
            vertical-align: middle;
            white-space: nowrap;
        }

        tbody tr:last-child td {
            border-bottom: none;
        }

        tbody tr {
            transition: background .15s ease;
        }

        tbody tr:hover {
            background: #f7fbff;
        }

        .medicine-name {
            color: #192b45;
            font-size: 14px;
            font-weight: 750;
        }

        .medicine-id {
            color: #8290a5;
            font-variant-numeric: tabular-nums;
        }

        .quantity {
            color: #23334c;
            font-size: 15px;
            font-weight: 800;
            font-variant-numeric: tabular-nums;
        }

        .status {
            display: inline-flex;
            align-items: center;
            padding: 7px 11px;

            border-radius: 8px;
            font-size: 12px;
            font-weight: 800;
            white-space: nowrap;
        }

        .good {
            background: #e3f7eb;
            color: #187647;
        }

        .warning {
            background: #fff2d7;
            color: #93600d;
        }

        .danger {
            background: #ffeaec;
            color: #b42332;
        }

        .empty {
            padding: 35px 20px !important;
            color: var(--muted);
            font-size: 14px;
            text-align: center;
        }

        .footer {
            padding: 20px 0 0;
            color: #8b97a9;
            font-size: 12px;
            text-align: center;
        }

        /* ================================
           RESPONSIVE
           ================================ */

        @media (max-width: 1250px) {
            .content {
                padding: 28px 22px 35px;
            }

            .topbar {
                padding: 18px 22px;
            }

            .stats {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .stat-card {
                padding: 20px;
            }

            .stat-value {
                font-size: 32px;
            }
        }

        @media (max-width: 760px) {
            .sidebar {
                position: relative;

                width: 100%;
                min-width: 0;
                max-width: none;
                max-height: none;

                padding: 16px;
            }

            .brand {
                padding-bottom: 16px;
            }

            .nav-label {
                margin-top: 17px;
            }

            .nav-link {
                min-height: 43px;
                padding: 10px 12px;
                font-size: 14px;
            }

            .nav-group-toggle {
                min-height: 46px;
                margin-top: 8px;
                padding: 10px 12px;
                font-size: 14px;
            }

            .sidebar-bottom {
                display: none;
            }

            .main {
                margin-left: 0;
            }

            .topbar {
                align-items: flex-start;
                gap: 12px;
                padding: 17px 15px;
            }

            .topbar-title {
                font-size: 23px;
            }

            .topbar-subtitle {
                font-size: 13px;
            }

            .account {
                gap: 8px;
            }

            .account-details {
                display: none;
            }

            .avatar {
                width: 38px;
                height: 38px;
            }

            .logout {
                min-height: 40px;
                padding: 9px 12px;
                font-size: 12px;
            }

            .content {
                padding: 23px 15px 30px;
            }

            .welcome {
                align-items: flex-start;
                flex-direction: column;
                gap: 12px;
            }

            .welcome h2 {
                font-size: 21px;
            }

            .stats {
                gap: 12px;
            }

            .stat-card {
                padding: 17px;
            }

            .stat-label {
                font-size: 12px;
            }

            .stat-value {
                font-size: 30px;
            }

            .stat-note {
                font-size: 11px;
            }

            .inventory-heading {
                padding: 18px;
            }

            .inventory-title {
                font-size: 18px;
            }

            .inventory-subtitle {
                font-size: 12px;
            }

            thead th {
                padding: 14px;
                font-size: 11px;
            }

            tbody td {
                padding: 15px 14px;
                font-size: 13px;
            }
        }

        @media (max-width: 380px) {
            .brand-name {
                font-size: 21px;
            }

            .stats {
                grid-template-columns: minmax(0, 1fr);
            }

            .topbar {
                flex-wrap: wrap;
            }

            .account {
                margin-left: auto;
            }

            .logout {
                padding: 8px 10px;
                font-size: 11px;
            }

            .inventory-heading {
                align-items: flex-start;
                flex-direction: column;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                scroll-behavior: auto !important;
                transition: none !important;
            }
        }
    </style>
</head>

<body>
<div class="app">

    <!-- SIDEBAR -->
    <aside class="sidebar">

        <div class="brand">
            <div class="brand-icon">✚</div>

            <div>
                <div class="brand-name">MediGuard</div>
                <div class="brand-caption">Medicine Inventory System</div>
            </div>
        </div>

        <nav class="nav-list" aria-label="Main navigation">

            <div class="nav-label">Workspace</div>

            <a class="nav-link active"
               href="<%= contextPath %>/dashboard">
                <span class="nav-icon">▦</span>
                Dashboard
            </a>

            <!-- Inventory Management -->
            <button type="button"
                    class="nav-group-toggle"
                    aria-expanded="false"
                    aria-controls="inventoryManagementMenu"
                    onclick="toggleNavGroup(this, 'inventoryManagementMenu')">

                <span class="nav-group-title">Inventory Management</span>
                <span class="nav-chevron">›</span>
            </button>

            <div class="nav-group-items"
                 id="inventoryManagementMenu"
                 hidden>

                <a class="nav-link"
                   href="<%= contextPath %>/medicine-search">
                    <span class="nav-icon">⌕</span>
                    Search Medicines
                </a>

                <a class="nav-link"
                   href="<%= contextPath %>/add-medicine">
                    <span class="nav-icon">＋</span>
                    Add Medicine
                </a>

                <a class="nav-link"
                   href="<%= contextPath %>/add-batch">
                    <span class="nav-icon">▤</span>
                    Add Batch
                </a>

            </div>

            <!-- Stock Operations -->
            <button type="button"
                    class="nav-group-toggle"
                    aria-expanded="false"
                    aria-controls="stockOperationsMenu"
                    onclick="toggleNavGroup(this, 'stockOperationsMenu')">

                <span class="nav-group-title">Stock Operations</span>
                <span class="nav-chevron">›</span>
            </button>

            <div class="nav-group-items"
                 id="stockOperationsMenu"
                 hidden>

                <a class="nav-link"
                   href="<%= contextPath %>/receive-stock">
                    <span class="nav-icon">↙</span>
                    Receive Stock
                </a>

                <a class="nav-link"
                   href="<%= contextPath %>/issue-stock">
                    <span class="nav-icon">↗</span>
                    Issue Stock
                </a>

                <a class="nav-link"
                   href="<%= contextPath %>/stock-history">
                    <span class="nav-icon">◷</span>
                    Stock History
                </a>

            </div>

            <!-- Management & Reports -->
            <button type="button"
                    class="nav-group-toggle"
                    aria-expanded="false"
                    aria-controls="managementReportsMenu"
                    onclick="toggleNavGroup(this, 'managementReportsMenu')">

                <span class="nav-group-title">Management &amp; Reports</span>
                <span class="nav-chevron">›</span>
            </button>

            <div class="nav-group-items"
                 id="managementReportsMenu"
                 hidden>

                <a class="nav-link"
                   href="<%= contextPath %>/suppliers">
                    <span class="nav-icon">♧</span>
                    Suppliers
                </a>

                <a class="nav-link"
                   href="<%= contextPath %>/low-stock">
                    <span class="nav-icon">⚑</span>
                    Low-Stock Alerts
                </a>

                <a class="nav-link"
                   href="<%= contextPath %>/expiry-management">
                    <span class="nav-icon">◷</span>
                    Expiry Management
                </a>

                <a class="nav-link"
                   href="<%= contextPath %>/stock-valuation">
                    <span class="nav-icon">▥</span>
                    Stock Valuation
                </a>

                <a class="nav-link"
                   href="<%= contextPath %>/user-management">
                    <span class="nav-icon">♙</span>
                    User Management
                </a>

            </div>

        </nav>

        <div class="sidebar-bottom">
            MEDIGUARD INVENTORY
            <span>Medicine management workspace</span>
        </div>

    </aside>

    <!-- MAIN DASHBOARD -->
    <div class="main">

        <header class="topbar">

            <div>
                <h1 class="topbar-title">Dashboard</h1>
                <p class="topbar-subtitle">
                    Monitor your medicine inventory at a glance.
                </p>
            </div>

            <div class="account">

                <div class="avatar">
                    <%= escapeHtml(fullName.isEmpty()
                        ? "U"
                        : fullName.substring(0, 1).toUpperCase()) %>
                </div>

                <div class="account-details">
                    <div class="account-name">
                        <%= escapeHtml(fullName) %>
                    </div>

                    <div class="account-role">
                        <%= escapeHtml(userRole) %>
                    </div>
                </div>

                <a class="logout"
                   href="<%= contextPath %>/logout"
                   onclick="return confirm('Are you sure you want to log out?');">
                    Logout ↗
                </a>

            </div>

        </header>

        <main class="content">

            <!-- Welcome -->
            <section class="welcome">

                <div>
                    <h2>Welcome back, <%= escapeHtml(fullName) %></h2>

                    <p>
                        Here is the current overview of your medicine inventory.
                    </p>
                </div>

                <div class="live-label">
                    <span class="live-dot"></span>
                    Inventory Overview
                </div>

            </section>

            <!-- Messages -->
            <% if (successMessage != null) { %>
                <div class="message success">
                    ✓ <%= escapeHtml(successMessage) %>
                </div>
            <% } %>

            <% if (errorMessage != null) { %>
                <div class="message error">
                    ⚠ <%= escapeHtml(errorMessage) %>
                </div>
            <% } %>

            <!-- Statistics -->
            <section class="stats" aria-label="Inventory statistics">

                <div class="stat-card stat-teal">
                    <div class="stat-top">
                        <span class="stat-label">Registered Medicines</span>
                        <span class="stat-icon">▤</span>
                    </div>

                    <strong class="stat-value">
                        <%= totalMedicines == null ? 0 : totalMedicines %>
                    </strong>

                    <div class="stat-note">Medicines in the catalogue</div>
                </div>

                <div class="stat-card stat-blue">
                    <div class="stat-top">
                        <span class="stat-label">Total Units in Stock</span>
                        <span class="stat-icon">▦</span>
                    </div>

                    <strong class="stat-value">
                        <%= totalUnits == null ? 0 : totalUnits %>
                    </strong>

                    <div class="stat-note">Units recorded across inventory</div>
                </div>

                <div class="stat-card stat-amber">
                    <div class="stat-top">
                        <span class="stat-label">Low-Stock Medicines</span>
                        <span class="stat-icon">⚑</span>
                    </div>

                    <strong class="stat-value">
                        <%= lowStockMedicines == null ? 0 : lowStockMedicines %>
                    </strong>

                    <div class="stat-note">Review replenishment requirements</div>
                </div>

                <div class="stat-card stat-rose">
                    <div class="stat-top">
                        <span class="stat-label">Expired / Expiring Batches</span>
                        <span class="stat-icon">◷</span>
                    </div>

                    <strong class="stat-value">
                        <%= expiryAlerts == null ? 0 : expiryAlerts %>
                    </strong>

                    <div class="stat-note">Review expiry alerts promptly</div>
                </div>

            </section>

            <!-- Medicine Inventory -->
            <section class="inventory">

                <div class="inventory-heading">

                    <div>
                        <h2 class="inventory-title">Medicine Inventory</h2>

                        <p class="inventory-subtitle">
                            Overview of medicines, batches, quantities and expiry status.
                        </p>
                    </div>

                    <span class="record-count">
                        <%= medicines.size() %> records
                    </span>

                </div>

                <div class="table-scroll">

                    <table>
                        <thead>
                        <tr>
                            <th>Medicine ID</th>
                            <th>Medicine Name</th>
                            <th>Category</th>
                            <th>Unit</th>
                            <th>Reorder Level</th>
                            <th>Batch Number</th>
                            <th>Quantity</th>
                            <th>Expiry Date</th>
                            <th>Stock Status</th>
                            <th>Expiry Status</th>
                        </tr>
                        </thead>

                        <tbody>

                        <% if (medicines.isEmpty()) { %>

                            <tr>
                                <td colspan="10" class="empty">
                                    No medicines found. Add a medicine to get started.
                                </td>
                            </tr>

                        <% } else {
                            for (MedicineRow medicine : medicines) {

                                String stockStatus = medicine.getStockStatus();
                                String expiryStatus = medicine.getExpiryStatus();

                                String stockClass = "good";

                                if ("Low stock".equals(stockStatus)) {
                                    stockClass = "warning";
                                } else if ("Out of stock".equals(stockStatus)) {
                                    stockClass = "danger";
                                }

                                String expiryClass = "good";

                                if ("Expired".equals(expiryStatus)) {
                                    expiryClass = "danger";
                                } else if ("Expiring soon".equals(expiryStatus)) {
                                    expiryClass = "warning";
                                }
                        %>

                            <tr>
                                <td class="medicine-id">
                                    <%= medicine.getMedicineId() %>
                                </td>

                                <td class="medicine-name">
                                    <%= escapeHtml(medicine.getMedicineName()) %>
                                </td>

                                <td>
                                    <%= escapeHtml(medicine.getCategory()) %>
                                </td>

                                <td>
                                    <%= escapeHtml(medicine.getUnitName()) %>
                                </td>

                                <td>
                                    <%= medicine.getReorderLevel() %>
                                </td>

                                <td>
                                    <%= medicine.getBatchNumber() == null
                                        ? "No batch registered"
                                        : escapeHtml(medicine.getBatchNumber()) %>
                                </td>

                                <td class="quantity">
                                    <%= medicine.isHasBatch()
                                        ? medicine.getQuantity()
                                        : 0 %>
                                </td>

                                <td>
                                    <%= medicine.getExpiryDate() == null
                                        ? "—"
                                        : escapeHtml(medicine.getExpiryDate()) %>
                                </td>

                                <td>
                                    <span class="status <%= stockClass %>">
                                        <%= escapeHtml(stockStatus) %>
                                    </span>
                                </td>

                                <td>
                                    <span class="status <%= expiryClass %>">
                                        <%= escapeHtml(expiryStatus) %>
                                    </span>
                                </td>
                            </tr>

                        <%
                            }
                        } %>

                        </tbody>
                    </table>

                </div>

            </section>

            <footer class="footer">
                MediGuard · Medicine Inventory Management System
            </footer>

        </main>
    </div>
</div>

<script>
    function toggleNavGroup(button, menuId) {
        const menu = document.getElementById(menuId);

        if (!menu) {
            return;
        }

        const isExpanded =
            button.getAttribute("aria-expanded") === "true";

        button.setAttribute("aria-expanded", String(!isExpanded));
        menu.hidden = isExpanded;
    }
</script>

</body>
</html>

<%!
    private String escapeHtml(Object value) {
        if (value == null) {
            return "";
        }

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;");
    }
%>
