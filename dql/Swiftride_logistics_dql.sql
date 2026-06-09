SELECT COUNT(*) FROM operations.customers;

SELECT COUNT(*) FROM fleet.drivers;

SELECT COUNT(*) FROM fleet.vehicles;

SELECT COUNT(*) FROM warehouse.warehouses;

SELECT COUNT(*) FROM operations.orders;

SELECT COUNT(*) FROM operations.deliveries;

SELECT COUNT(*) FROM warehouse.inventory;

SELECT COUNT(*) FROM finance.payments;

-- Phase 2
-- Exploring the tables/data
SELECT * FROM operations.customers LIMIT 10;

SELECT * FROM operations.deliveries LIMIT 10;

SELECT * FROM operations.orders LIMIT 10;

SELECT * FROM fleet.drivers LIMIT 10;

SELECT * FROM fleet.vehicles LIMIT 10;

SELECT * FROM warehouse.warehouses LIMIT 10;

SELECT * FROM warehouse.inventory LIMIT 10;

SELECT * FROM finance.payments LIMIT 10;

-- Solutions to Swiftride's Business Problems/issues
-- Problem 1 — Identify High-Value Customers
-- Business Goal
-- Find customers spending the most money.
SELECT
    c.full_name,
    SUM(o.total_amount) AS total_spent
FROM
    operations.customers c
    JOIN operations.orders o ON c.customer_id = o.customer_id
GROUP BY
    c.full_name
ORDER BY
    total_spent DESC
LIMIT
    10;

/*
 Importance - This helps SwiftRide Logistics identify:
 their most profitable customers
 loyal customers
 premium customers
 */
/* 
 Business Benefits
 The company can: reward loyal customers, offer discounts, create loyalty programs, and prioritize premium clients
 */
-- Problem 2 — Find Drivers Handling the Most Deliveries
SELECT
    d.driver_name,
    COUNT(del.delivery_id) AS total_deliveries
FROM
    fleet.drivers d
    JOIN operations.deliveries del ON d.driver_id = del.driver_id
GROUP BY
    d.driver_name
ORDER BY
    total_deliveries DESC;

/* 
 The above measures:
 - driver productivity
 - driver performance
 - workload distribution
 
 Business Benefits
 - Management can:
 - reward top drivers
 - identify overworked drivers
 - improve staff allocation
 */
-- Problem 3 — Detect Pending Deliveries
SELECT
    *
FROM
    operations.deliveries
WHERE
    delivery_status = 'Pending';

/* 
 The above helps identify:
 - delayed deliveries
 - incomplete operations
 - bottlenecks
 
 Business Benefits
 The company can:
 - improve customer satisfaction
 - reduce delays
 - track operational efficiency
 */
-- Problem 4 — Revenue Analysis
-- Total Revenue 
SELECT
    SUM(total_amount) AS total_revenue
FROM
    operations.orders;

/* 
 The above determines:
 - company income
 - sales performance
 - financial growth
 
 Business Benefits
 Management can:
 - track profitability
 - forecast revenue
 - make strategic decisions
 */
-- Problem 5 — Payment Status Analysis
SELECT
    payment_status,
    COUNT(*) AS total_payments
FROM
    finance.payments
GROUP BY
    payment_status;

/* 
 The above monitors:
 - successful payments
 - failed payments
 - pending transactions
 - refunds
 
 Business Benefits
 The company can:
 - reduce payment failures
 - track cash flow
 - improve financial operations
 */
-- Problem 6 — Inventory Monitoring
-- Low Inventory Detection 
SELECT
    *
FROM
    warehouse.inventory
WHERE
    quantity < 20;

/* 
 The above identifies products running low in stock.
 
 Business Benefits:
 The company can:
 - restock products early
 - prevent stock shortages
 - avoid operational disruption
 */
-- Problem 7 — Warehouse Inventory Report
SELECT
    w.warehouse_name,
    i.product_name,
    i.quantity
FROM
    warehouse.warehouses w
    JOIN warehouse.inventory i ON w.warehouse_id = i.warehouse_id
ORDER BY
    w.warehouse_name;

/* 
 The above provides visibility into:
 - warehouse stock levels
 - product distribution
 - inventory allocation
 
 Business Benefits
 The company can:
 - optimize warehouse operations
 - balance inventory
 - improve logistics planning
 */
-- Problem 8 — Cross-Schema Enterprise Join 
SELECT
    c.full_name,
    o.order_id,
    d.driver_name,
    v.plate_number,
    p.payment_status,
    del.delivery_status
FROM
    operations.customers c
    JOIN operations.orders o ON c.customer_id = o.customer_id
    JOIN operations.deliveries del ON o.order_id = del.order_id
    JOIN fleet.drivers d ON del.driver_id = d.driver_id
    JOIN fleet.vehicles v ON del.vehicle_id = v.vehicle_id
    JOIN finance.payments p ON o.order_id = p.order_id;

/*
 This is the most enterprise-level query in the project.
 It combines:
 - customers
 - orders
 - drivers
 - vehicles
 - deliveries
 - payments
 into one unified business report.
 
 Business Benefits
 Management gets:
 - complete operational visibility
 - centralized reporting
 - business intelligence insights
 */
-- Categorizes the orders into business groups based on their value.
-- NB: CASE WHEN in SQL allows us to apply conditional logic and create categories based on data values.
SELECT
    order_id,
    total_amount,
    CASE
        WHEN total_amount >= 200000 THEN 'High Value'
        WHEN total_amount >= 100000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS order_category
FROM
    operations.orders;
