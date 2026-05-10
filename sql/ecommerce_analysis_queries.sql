-- =========================================================
-- E-Commerce Sales & Customer Experience Analysis
-- FINAL SQL QUERIES
-- =========================================================

-- =========================================================
-- 1. TOTAL REVENUE
-- =========================================================

SELECT
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments;

-- =========================================================
-- 2. TOTAL ORDERS
-- =========================================================

SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;



-- =========================================================
-- 3. TOTAL CUSTOMERS
-- Real unique customers
-- =========================================================

SELECT
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;



-- =========================================================
-- 4. AVERAGE ORDER VALUE (AOV)
-- =========================================================

SELECT
    ROUND(
        SUM(payment_value) * 1.0 /
        COUNT(DISTINCT order_id),
    2) AS avg_order_value
FROM payments;



-- =========================================================
-- 5. FIRST & LAST ORDER DATE
-- =========================================================

SELECT
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date
FROM orders;



-- =========================================================
-- 6. MONTHLY REVENUE TREND
-- =========================================================

SELECT

    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,

    ROUND(SUM(p.payment_value), 2) AS total_revenue

FROM orders o

JOIN payments p
    ON o.order_id = p.order_id

GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')

ORDER BY order_month;



-- =========================================================
-- 7. AVERAGE REVIEW SCORE
-- =========================================================

SELECT
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM reviews;



-- =========================================================
-- 8. REVIEW SCORE DISTRIBUTION
-- =========================================================

SELECT

    review_score,

    COUNT(*) AS total_reviews

FROM reviews

GROUP BY review_score

ORDER BY review_score;



-- =========================================================
-- 9. BAD REVIEW PERCENTAGE (1 & 2 STARS)
-- =========================================================

SELECT

    ROUND(
        COUNT(
            CASE
                WHEN review_score IN (1,2)
                THEN 1
            END
        ) * 100.0 / COUNT(*),
    2) AS bad_review_percentage

FROM reviews;

-- =========================================================
-- 10. AVERAGE DELIVERY TIME
-- =========================================================
SELECT

    AVG(
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        )
    ) AS avg_delivery_days

FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- =========================================================
-- 11. DELAYED ORDERS COUNT
-- =========================================================

SELECT
    COUNT(*) AS delayed_orders
FROM orders
WHERE order_delivered_customer_date >
      order_estimated_delivery_date;
-- =========================================================
-- 12. DELAYED ORDERS PERCENTAGE
-- =========================================================
SELECT

    ROUND(
        COUNT(
            CASE
                WHEN order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1
            END
        ) * 100.0 / COUNT(*),
    2) AS delayed_order_percentage

FROM orders

WHERE order_delivered_customer_date IS NOT NULL;

-- =========================================================
-- 13. REVIEW SCORE BY DELIVERY STATUS
-- =========================================================

SELECT

    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Delayed'

        ELSE 'On Time'
    END AS delivery_status,

    ROUND(AVG(r.review_score), 2) AS avg_review_score

FROM orders o

JOIN reviews r
    ON o.order_id = r.order_id

WHERE o.order_delivered_customer_date IS NOT NULL

GROUP BY
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Delayed'

        ELSE 'On Time'
    END;


-- =========================================================
-- 14. TOP PRODUCT CATEGORIES BY REVENUE
-- =========================================================

SELECT TOP 10
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id

GROUP BY p.product_category_name

ORDER BY total_revenue DESC;

-- =========================================================
-- 15. TOP PRODUCT CATEGORIES BY SALES VOLUME
-- =========================================================

SELECT TOP 10

    p.product_category_name,

    COUNT(*) AS total_sales

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

GROUP BY p.product_category_name

ORDER BY total_sales DESC;

-- =========================================================
-- 16. TOP CUSTOMERS BY SPENDING
-- =========================================================

SELECT TOP 10

    c.customer_unique_id,
    ROUND(SUM(p.payment_value), 2) AS total_spent,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC;

-- =========================================================
-- 17. REVENUE BY STATE
-- =========================================================

SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;



-- =========================================================
-- 18. FINAL ANALYTICAL DATASET
-- =========================================================

SELECT
    o.order_id,
    c.customer_id,
    c.customer_unique_id,
    o.order_purchase_timestamp,
    p.payment_value,
    r.review_score,
    pr.product_category_name,
    oi.price,
    oi.freight_value,
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Delayed'
        ELSE 'On Time'
    END AS delivery_status
FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id
JOIN payments p
    ON o.order_id = p.order_id
JOIN reviews r
    ON o.order_id = r.order_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products pr
    ON oi.product_id = pr.product_id;