-- =====================================================
-- FOODORA INDIA — DATA ANALYSIS
-- PostgreSQL / SQL
-- =====================================================


-- =====================================================
-- 1. BASIC DATA EXPLORATION
-- =====================================================

-- Total number of orders
SELECT COUNT(*) AS total_orders
FROM orders;


-- Order status distribution
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Payment method distribution
SELECT
    payment_method,
    COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC;

-- =====================================================
-- 2. REVENUE ANALYSIS
-- =====================================================

-- Total Revenue
SELECT
    SUM(total_amount) AS total_revenue
FROM orders;


-- Average Order Value
SELECT
    AVG(total_amount) AS average_order_value
FROM orders;


-- Minimum and Maximum Order Value
SELECT
    MIN(total_amount) AS minimum_order_value,
    MAX(total_amount) AS maximum_order_value
FROM orders;


-- Revenue by Payment Method
SELECT
    payment_method,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY payment_method
ORDER BY total_revenue DESC;


-- Revenue by Delivery Method
SELECT
    delivery_method,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY delivery_method
ORDER BY total_revenue DESC;
-- =====================================================
-- 3. CUSTOMER ANALYSIS
-- =====================================================

-- Total Unique Customers
SELECT
    COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;


-- Total Spending by Customer
SELECT
    customer_id,
    SUM(total_amount) AS total_spending
FROM orders
GROUP BY customer_id
ORDER BY total_spending DESC;


-- Top 5 Customers by Spending
SELECT
    customer_id,
    SUM(total_amount) AS total_spending
FROM orders
GROUP BY customer_id
ORDER BY total_spending DESC
LIMIT 5;
-- =====================================================
-- 4. CITY & RESTAURANT ANALYSIS
-- =====================================================

-- Revenue by City
SELECT
    r.city,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.city
ORDER BY total_revenue DESC;


-- Delivered Orders by City
SELECT
    r.city,
    COUNT(*) AS delivered_orders
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.city
ORDER BY delivered_orders DESC;


-- Average Order Value by City
SELECT
    r.city,
    AVG(o.total_amount) AS average_order_value
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.city
ORDER BY average_order_value DESC;


-- Restaurant Revenue
SELECT
    r.restaurant_name,
    r.city,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_name, r.city
ORDER BY total_revenue DESC;


-- Top 5 Restaurants by Revenue
SELECT
    r.restaurant_name,
    r.city,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_name, r.city
ORDER BY total_revenue DESC
LIMIT 5;
-- =====================================================
-- 5. DELIVERY PERFORMANCE
-- =====================================================

-- Average Delivery Time
SELECT
    AVG(delivery_time_min) AS average_delivery_time
FROM orders
WHERE order_status = 'Delivered';


-- Average Delivery Time by Delivery Method
SELECT
    delivery_method,
    AVG(delivery_time_min) AS average_delivery_time
FROM orders
WHERE order_status = 'Delivered'
GROUP BY delivery_method
ORDER BY average_delivery_time;


-- Average Delivery Time by Traffic Level
SELECT
    traffic_level,
    AVG(delivery_time_min) AS average_delivery_time
FROM orders
WHERE order_status = 'Delivered'
GROUP BY traffic_level
ORDER BY average_delivery_time DESC;


-- Average Delivery Time by Weather
SELECT
    weather,
    AVG(delivery_time_min) AS average_delivery_time
FROM orders
WHERE order_status = 'Delivered'
GROUP BY weather
ORDER BY average_delivery_time DESC;
-- =====================================================
-- 6. MONTHLY TRENDS
-- =====================================================

-- Monthly Revenue
SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    SUM(total_amount) AS total_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
ORDER BY
    order_year,
    order_month;


-- Monthly Orders
SELECT
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    COUNT(*) AS total_orders
FROM orders
WHERE order_status = 'Delivered'
GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
ORDER BY
    order_year,
    order_month;
-- =====================================================
-- 7. ADVANCED SQL ANALYSIS
-- =====================================================

-- Rank Restaurants by Revenue within Each City
SELECT
    r.city,
    r.restaurant_name,
    SUM(o.total_amount) AS total_revenue,
    RANK() OVER (
        PARTITION BY r.city
        ORDER BY SUM(o.total_amount) DESC
    ) AS revenue_rank
FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY
    r.city,
    r.restaurant_name
ORDER BY
    r.city,
    revenue_rank;


-- Monthly Revenue with Previous Month Revenue
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS order_month,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (
        ORDER BY order_month
    ) AS previous_month_revenue
FROM monthly_revenue
ORDER BY order_month;