-- Dataset:
-- `showroom_mobil.dataset`
--
-- Business Focus:
-- 01. Revenue Realization
-- 02. Revenue Drivers
-- 03. Branch Performance
-- 04. Customer & Transaction Behavior
-- 05. Sales Trend
-- 06. Cross-Analysis
-- 07. Final Analytical Dataset

---------------------------------------------------------------
-- 00. DATA OVERVIEW
---------------------------------------------------------------

-- 00.1 — Total records
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS unique_orders
FROM `showroom_mobil.dataset`;

-- 00.2 — Date range
SELECT
    MIN(sales_date) AS first_sales_date,
    MAX(sales_date) AS last_sales_date
FROM `showroom_mobil.dataset`;

-- 00.3 — Status overview
SELECT
    status,
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS units,
    SUM(total_sales) AS reported_sales
FROM `showroom_mobil.dataset`
GROUP BY status
ORDER BY reported_sales DESC;

-- 00.4 — Category overview
SELECT
    category,
    COUNT(DISTINCT order_id) AS orders,
    SUM(quantity) AS units,
    SUM(total_sales) AS reported_sales
FROM `showroom_mobil.dataset`
GROUP BY category
ORDER BY reported_sales DESC;

---------------------------------------------------------------
-- 01. REVENUE REALIZATION
---------------------------------------------------------------

-- 01.1 — Revenue by transaction status
SELECT
    status,
    COUNT(DISTINCT order_id) AS orders,
    SUM(quantity) AS units,
    SUM(total_sales) AS revenue
FROM `showroom_mobil.dataset`
GROUP BY status
ORDER BY revenue DESC;

-- 01.2 — Reported vs realized revenue
SELECT
    SUM(total_sales) AS reported_revenue,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN total_sales
            ELSE 0
        END
    ) AS realized_revenue
FROM `showroom_mobil.dataset`;

-- 01.3 — Revenue gap
SELECT
    SUM(total_sales) AS reported_revenue,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN total_sales
            ELSE 0
        END
    ) AS realized_revenue,
    SUM(
        CASE
            WHEN status != 'completed'
            THEN total_sales
            ELSE 0
        END
    ) AS revenue_gap
FROM `showroom_mobil.dataset`;

-- 01.4 — Revenue realization rate
SELECT
    ROUND(
        SAFE_DIVIDE(
            SUM(
                CASE
                    WHEN status = 'completed'
                    THEN total_sales
                    ELSE 0
                END
            ),
            SUM(total_sales)
        ) * 100, 
        2
    ) AS realization_rate_pct
FROM `showroom_mobil.dataset`;

-- 01.5 — Revenue contribution by status
SELECT
    status,
    COUNT(DISTINCT order_id) AS orders,
    SUM(total_sales) AS revenue,
    ROUND(
        SAFE_DIVIDE(
            SUM(total_sales),
            SUM(SUM(total_sales)) OVER ()
        ) * 100,
        2
    ) AS revenue_contribution_pct
FROM `showroom_mobil.dataset`
GROUP BY status
ORDER BY revenue DESC;

---------------------------------------------------------------
-- 02. REVENUE DRIVERS
---------------------------------------------------------------
-- 02.1 — Revenue by category
-- Completed transactions only
SELECT
    category,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT order_id) AS completed_orders,
    SUM(total_sales) AS realized_revenue
FROM `showroom_mobil.dataset`
WHERE status = 'completed'
GROUP BY category
ORDER BY realized_revenue DESC;

-- 02.2 — Revenue by product
SELECT
    product_name,
    category,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT order_id) AS completed_orders,
    SUM(total_sales) AS realized_revenue
FROM `showroom_mobil.dataset`
WHERE status = 'completed'
GROUP BY
    product_name,
    category
ORDER BY realized_revenue DESC;

-- 02.3 — Top 10 products by revenue
SELECT
    product_name,
    category,
    SUM(quantity) AS units_sold,
    SUM(total_sales) AS realized_revenue
FROM `showroom_mobil.dataset`
WHERE status = 'completed'
GROUP BY
    product_name,
    category
ORDER BY realized_revenue DESC
LIMIT 10;


-- 02.4 — Revenue contribution by category
WITH category_revenue AS (
    SELECT
        category,
        SUM(total_sales) AS realized_revenue
    FROM `showroom_mobil.dataset`
    WHERE status = 'completed'
    GROUP BY category
)
SELECT
    category,
    realized_revenue,
    ROUND(
        SAFE_DIVIDE(
            realized_revenue,
            SUM(realized_revenue) OVER ()
        ) * 100,
        2
    ) AS revenue_contribution_bycategory
FROM category_revenue
ORDER BY realized_revenue DESC;

-- 02.5 — Product volume ranking
SELECT
    product_name,
    category,
    SUM(quantity) AS units_sold,
    RANK() OVER (
        ORDER BY SUM(quantity) DESC
    ) AS unit_rank
FROM `showroom_mobil.dataset`
WHERE status = 'completed'
GROUP BY
    product_name,
    category
ORDER BY unit_rank;

---------------------------------------------------------------
-- 03. BRANCH PERFORMANCE
---------------------------------------------------------------
-- 03.1 — Branch sales performance
SELECT
    branch,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNTIF(status = 'completed') AS completed_orders,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN quantity
            ELSE 0
        END
    ) AS units_sold,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN total_sales
            ELSE 0
        END
    ) AS realized_revenue
FROM `showroom_mobil.dataset`
GROUP BY branch
ORDER BY realized_revenue DESC;

-- 03.2 — Completion rate by branch
SELECT
    branch,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT IF(status = 'completed', order_id, NULL))
        AS completed_orders,

    ROUND(
        SAFE_DIVIDE(
            COUNT(DISTINCT IF(status = 'completed', order_id, NULL)),
            COUNT(DISTINCT order_id)
        ) * 100,
        2
    ) AS completion_rate_branch
FROM `showroom_mobil.dataset`
GROUP BY branch
ORDER BY completion_rate_branch DESC;

-- 03.3 — Branch performance summary
WITH branch_summary AS (
    SELECT
        branch,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(
            DISTINCT IF(
                status = 'completed',
                order_id,
                NULL
            )
        ) AS completed_orders,
        SUM(
            CASE
                WHEN status = 'completed'
                THEN quantity
                ELSE 0
            END
        ) AS units_sold,
        SUM(
            CASE
                WHEN status = 'completed'
                THEN total_sales
                ELSE 0
            END
        ) AS realized_revenue
    FROM `showroom_mobil.dataset`
    GROUP BY branch
)
SELECT
    branch,
    total_orders,
    completed_orders,
    units_sold,
    realized_revenue,

    ROUND(
        SAFE_DIVIDE(
            completed_orders,
            total_orders
        ) * 100,
        2
    ) AS completion_rate_branch
FROM branch_summary
ORDER BY realized_revenue DESC;

---------------------------------------------------------------
-- 04. CUSTOMER & TRANSACTION BEHAVIOR
---------------------------------------------------------------
-- 04.1 — Unique customers
SELECT
    COUNT(DISTINCT customer_name) AS unique_customers
FROM `showroom_mobil.dataset`;

-- 04.2 — Payment type distribution
-- Completed transactions only
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    SUM(quantity) AS units_sold,
    SUM(total_sales) AS realized_revenue
FROM `showroom_mobil.dataset`
WHERE status = 'completed'
GROUP BY payment_type
ORDER BY orders DESC;

-- 04.3 — Trade-In usage
SELECT
    trade_in_status,
    COUNT(DISTINCT order_id) AS orders,
    SUM(quantity) AS units
FROM `showroom_mobil.dataset`
GROUP BY trade_in_status
ORDER BY orders DESC;

-- 04.4 — Trade-In usage by branch
SELECT
    branch,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(
        DISTINCT IF(
            trade_in_status = 'Trade In',
            order_id,
            NULL
        )
    ) AS trade_in_orders,
    ROUND(
        SAFE_DIVIDE(
            COUNT(
                DISTINCT IF(
                    trade_in_status = 'Trade In',
                    order_id,
                    NULL
                )
            ),
            COUNT(DISTINCT order_id)
        ) * 100,
        2
    ) AS trade_in_percentage
FROM `showroom_mobil.dataset`
GROUP BY branch
ORDER BY trade_in_percentage DESC;

-- 04.5 — Customers with most Trade-In transactions
SELECT
    customer_name,
    COUNT(DISTINCT order_id) AS trade_in_orders
FROM `showroom_mobil.dataset`
WHERE trade_in_status = 'Trade In'
GROUP BY customer_name
ORDER BY trade_in_orders DESC;

-- 04.6 — Most frequently sold products
SELECT
    product_name,
    category,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT order_id) AS completed_orders
FROM `showroom_mobil.dataset`
WHERE status = 'completed'
GROUP BY
    product_name,
    category
ORDER BY units_sold DESC;

-- 04.7 — Payment type by transaction volume
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(
        SAFE_DIVIDE(
            COUNT(DISTINCT order_id),
            SUM(COUNT(DISTINCT order_id)) OVER ()
        ) * 100,
        2
    ) AS transaction_share_pct
FROM `showroom_mobil.dataset`
WHERE status = 'completed'
GROUP BY payment_type
ORDER BY orders DESC;

---------------------------------------------------------------
-- 05. SALES TREND
---------------------------------------------------------------
-- 05.1 — Monthly revenue and units sold
SELECT
    DATE_TRUNC(sales_date, MONTH) AS month,
    COUNT(DISTINCT IF(status = 'completed', order_id, NULL))
        AS completed_orders,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN quantity
            ELSE 0
        END
    ) AS units_sold,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN total_sales
            ELSE 0
        END
    ) AS realized_revenue
FROM `showroom_mobil.dataset`
GROUP BY month
ORDER BY month;

-- 05.2 — Monthly transaction status
SELECT
    DATE_TRUNC(sales_date, MONTH) AS month,
    status,
    COUNT(DISTINCT order_id) AS orders,
    SUM(quantity) AS units
FROM `showroom_mobil.dataset`
GROUP BY
    month,
    status
ORDER BY
    month,
    status
;

-- 05.3 — Monthly completion rate
SELECT
    DATE_TRUNC(sales_date, MONTH) AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(
        DISTINCT IF(
            status = 'completed',
            order_id,
            NULL
        )
    ) AS completed_orders,
    ROUND(
        SAFE_DIVIDE(
            COUNT(
                DISTINCT IF(
                    status = 'completed',
                    order_id,
                    NULL
                )
            ),
            COUNT(DISTINCT order_id)
        ) * 100,
        2
    ) AS completion_rate_pct
FROM `showroom_mobil.dataset`
GROUP BY month
ORDER BY month;

-- 05.4 — Monthly revenue growth
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC(sales_date, MONTH) AS month,
        SUM(
            CASE
                WHEN status = 'completed'
                THEN total_sales
                ELSE 0
            END
        ) AS realized_revenue
    FROM `showroom_mobil.dataset`
    GROUP BY month
)
SELECT
    month,
    realized_revenue,
    LAG(realized_revenue) OVER (
        ORDER BY month
    ) AS previous_month_revenue,
    ROUND(
        SAFE_DIVIDE(
            realized_revenue -
            LAG(realized_revenue) OVER (
                ORDER BY month
            ),
            LAG(realized_revenue) OVER (
                ORDER BY month
            )
        ) * 100,
        2
    ) AS revenue_growth_pct
FROM monthly_revenue
ORDER BY month;

---------------------------------------------------------------
-- 06. CROSS-ANALYSIS
---------------------------------------------------------------
-- 06.1 — Branch x Category performance
SELECT
    branch,
    category,
    COUNT(
        DISTINCT IF(
            status = 'completed',
            order_id,
            NULL
        )
    ) AS completed_orders,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN quantity
            ELSE 0
        END
    ) AS units_sold,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN total_sales
            ELSE 0
        END
    ) AS realized_revenue
FROM `showroom_mobil.dataset`
GROUP BY
    branch,
    category
ORDER BY realized_revenue DESC;

-- 06.2 — Trade-In performance by branch
SELECT
    branch,
    trade_in_status,
    COUNT(DISTINCT order_id) AS orders,
    SUM(quantity) AS units,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN total_sales
            ELSE 0
        END
    ) AS realized_revenue
FROM `showroom_mobil.dataset`
GROUP BY
    branch,
    trade_in_status
ORDER BY
    branch,
    realized_revenue 
DESC;

-- 06.3 — Branch x Product performance
SELECT
    branch,
    product_name,
    category,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN quantity
            ELSE 0
        END
    ) AS units_sold,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN total_sales
            ELSE 0
        END
    ) AS realized_revenue
FROM `showroom_mobil.dataset`
GROUP BY
    branch,
    product_name,
    category
ORDER BY realized_revenue DESC;


----------------------------------------------------------------
-- 07. FINAL ANALYTICAL DATASET
----------------------------------------------------------------
-- Grain:
-- 1 row = Branch x Category x Month
-- Used as the analytical dataset for:
-- Python EDA / Power BI
----------------------------------------------------------------
SELECT
    branch,
    category,
    DATE_TRUNC(
        sales_date,
        MONTH
    ) AS month,
    COUNT(DISTINCT order_id) AS total_orders,
     COUNT(
        DISTINCT IF(
            status = 'completed',
            order_id,
            NULL
        )
    ) AS completed_orders,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN quantity
            ELSE 0
        END
    ) AS units_sold,
    SUM(
        CASE
            WHEN status = 'completed'
            THEN total_sales
            ELSE 0
        END
    ) AS realized_revenue,
    ROUND(
        SAFE_DIVIDE(
            COUNT(
                DISTINCT IF(
                    status = 'completed',
                    order_id,
                    NULL
                )
            ),
            COUNT(DISTINCT order_id)
        ) * 100,
        2
    ) AS completion_rate_pct
FROM `showroom_mobil.dataset`
GROUP BY
    branch,
    category,
    month
ORDER BY
    month,
    branch,
    realized_revenue DESC;