------ BLOCK 1:

--- 4. Identify the join keys connecting the tables: order_id, customer_id, product_id, seller_id 
--- — and confirm with a quick query that they actually match across tables (e.g., do all order_items.order_id values exist in orders?).

SELECT COUNT(*) AS miss_order_items
FROM olist_order_items_dataset oi
LEFT JOIN olist_orders_dataset o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS miss_customers
FROM olist_orders_dataset o
LEFT JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


SELECT COUNT(*) AS miss_sellers
FROM olist_order_items_dataset oi
LEFT JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

--- 5. Check order_items and order_payments specifically for one-to-many behavior relative to orders 
--- — run a query counting rows per order_id in each and confirm your assumption about the grain.

SELECT order_id, COUNT(*) AS item_count
FROM olist_order_items_dataset
GROUP BY order_id
ORDER BY item_count DESC;

SELECT order_id, COUNT(*) AS payment_count
FROM olist_order_payments_dataset
GROUP BY order_id
ORDER BY payment_count DESC;

--- 6. Look at products and product_category_name_translation together, and confirm how the Portuguese category names map to English ones.

SELECT
    p.product_category_name,
    t.product_category_name_english
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name_english IS NULL;

--- 7. Note anything that looks off — nulls in unexpected places, an unfamiliar status value in orders, a category that didn't translate 
--- — as things to handle explicitly in Block 3, not ignore.

SELECT
    COUNT(DISTINCT p.product_id) AS null_category_name 
FROM olist_products_dataset p
WHERE p.product_category_name IS  NULL;

SELECT 'order_items' AS table_name, COUNT(DISTINCT order_id) AS order_count
FROM olist_order_items_dataset

UNION ALL

SELECT 'order_payments' AS table_name, COUNT(DISTINCT order_id) AS order_count
FROM olist_order_payments_dataset;

------ BLOCK 2:

-- 1. Based on what Block 1 turned up, write down two or three specific business questions the dashboard will answer (e.g., revenue trend over time by category, delivery time vs. review score, top/bottom states or categories by performance).

----- 1: Revenue trend over time by product category Is revenue growing or shrinking, and which categories drive it?

----- 2: Does delivery time affect review score? Do late/slow deliveries correlate with lower review scores?

----- 3: Which states have the best/worst order volume and average review score? Where is the business strong or weak geographically?

-- 2. For each question, list the specific tables and columns it needs — this becomes the contract for Block 3's SQL.

-----    1. Revenue trend by category:
-----    tabs: 'orders', 'order_items', 'products', 'product_category_name_translation'
-----    columns: order_purchase_timestamp, price, product_id, → product_category_name → product_category_name_english

-----    2. Delivery time vs review score:
-----    tabs: 'orders', 'order_reviews'
-----    columns: order_purchase_timestamp, order_delivered_customer_date, order_estimated_delivery_date → review_score

-----    3. State-level performance:
-----    tabs: 'orders', 'customers', 'order_reviews'
-----    columns: customer_id → customer_state, order_id → review_score

-- 3. Explicitly write down what's *out of scope* for this project — for example, geolocation mapping, or payment-method-level analysis — so it stops competing for time later in the week.

----    Paymentmethodlevel analysis  is not part of this build.
----    Seller level performance. No seller scorecards or seller geography.
----    Product attribute analysis. weight, dimensions, photo count from products are not analyzed.

-- 4. Sanity-check the scope against the remaining time: three build days left, one of which (Thursday) is polish and export, not new analysis. If the scope feels heavy for that, cut a question now rather than on Wednesday.

----  Three questions across build days is reasonable if each question maps to roughly one chart or table and doesn't require new joins beyond what's above. 

----  Given the joins are all simple (orders ↔ items ↔ products ↔ translation and orders ↔ customers, orders ↔ reviews), this is achievable no cuts needed right now.

-- 5. Save this scope as a short written note in the project repo — it's also the backbone of Thursday's reflection and Friday's presentation narrative.

------ BLOCK 3:

-- 1. Write a query joining `orders`, `order_items`, `customers`, `products`, and `product_category_name_translation` into a single order-item-level result, with category in English.

SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    c.customer_state,
    c.customer_city,
    p.product_category_name,
    t.product_category_name_english
FROM olist_orders_dataset o
LEFT JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
LEFT JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name;



-- 2. Join in `order_payments`, aggregating to one payment total per order where multiple payment rows exist, so the join doesn't silently duplicate order-item rows.
WITH payments_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(*) AS payment_count
    FROM olist_order_payments_dataset
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    c.customer_state,
    c.customer_city,
    p.product_category_name,
    t.product_category_name_english
FROM olist_orders_dataset o
LEFT JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
LEFT JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
LEFT JOIN payments_per_order pp
    ON o.order_id = pp.order_id;

-- 3. Join in `order_reviews`, handling orders with no review or more than one review row explicitly (`COALESCE`, or picking the most recent review per order) rather than letting a join quietly drop or duplicate rows.

WITH payments_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(*) AS payment_count
    FROM olist_order_payments_dataset
    GROUP BY order_id
),

last_review_per_order AS(

SELECT
    order_id,
    review_score,
    review_comment_title,
    review_creation_date,
    review_comment_message,
    strftime(review_creation_date, '%d/%m/%Y %H:%M:%S')
    review_answer_timestamp,
    ROW_NUMBER() OVER (
        PARTITION BY order_id
        ORDER BY review_creation_date DESC
    ) AS rn
FROM olist_order_reviews_dataset
)  

SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    c.customer_state,
    c.customer_city,
    p.product_category_name,
    t.product_category_name_english,
    r.review_score,
    r.review_comment_title,
    r.review_comment_message
  
FROM olist_orders_dataset o
LEFT JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
LEFT JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
LEFT JOIN payments_per_order pp
    ON o.order_id = pp.order_id
LEFT JOIN last_review_per_order r
    ON o.order_id = r.order_id
    AND r.rn = 1
;

-- 4. Add a delivery-time calculation (delivered date minus purchase date) directly in this query, so it's ready to use as a measure without extra work in Power BI.

WITH payments_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(*) AS payment_count
    FROM olist_order_payments_dataset
    GROUP BY order_id
),

last_review_per_order AS(

SELECT
    order_id,
    review_score,
    review_comment_title,
    review_creation_date,
    review_comment_message,
    strftime(review_creation_date, '%d/%m/%Y %H:%M:%S')
    review_answer_timestamp,
    ROW_NUMBER() OVER (
        PARTITION BY order_id
        ORDER BY review_creation_date DESC
    ) AS rn
FROM olist_order_reviews_dataset
)  

SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATEDIFF('day', o.order_purchase_timestamp, o.order_delivered_customer_date)
        AS delivery_time_days,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    c.customer_state,
    c.customer_city,
    p.product_category_name,
    t.product_category_name_english,
    r.review_score,
    r.review_comment_title,
    r.review_comment_message
  
FROM olist_orders_dataset o
LEFT JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
LEFT JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
LEFT JOIN payments_per_order pp
    ON o.order_id = pp.order_id
LEFT JOIN last_review_per_order r
    ON o.order_id = r.order_id
    AND r.rn = 1
;

-- 5. Filter out or explicitly flag orders with a status that shouldn't count toward revenue (e.g., canceled orders), based on what Block 1 found in the `orders.order_status` values.

WITH payments_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(*) AS payment_count
    FROM olist_order_payments_dataset
    GROUP BY order_id
),

last_review_per_order AS(

SELECT
    order_id,
    review_score,
    review_comment_title,
    review_creation_date,
    review_comment_message,
    strftime(review_creation_date, '%d/%m/%Y %H:%M:%S')
    review_answer_timestamp,
    ROW_NUMBER() OVER (
        PARTITION BY order_id
        ORDER BY review_creation_date DESC
    ) AS rn
FROM olist_order_reviews_dataset
)  

SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATEDIFF('day', o.order_purchase_timestamp, o.order_delivered_customer_date)
        AS delivery_time_days,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    c.customer_state,
    c.customer_city,
    p.product_category_name,
    t.product_category_name_english,
    r.review_score,
    r.review_comment_title,
    r.review_comment_message
  
FROM olist_orders_dataset o
LEFT JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
LEFT JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
LEFT JOIN payments_per_order pp
    ON o.order_id = pp.order_id
LEFT JOIN last_review_per_order r
    ON o.order_id = r.order_id
    AND r.rn = 1
WHERE o.order_status NOT IN ('canceled','unavailable')
;
-- 6. Save the finished query as a `.sql` file in the project repo, and run it to produce the summary table this week's dashboard will be built on.

--- https://github.com/serhiy-dranko/olist-e-commerce-dataset/blob/main/sql/main_sales_orders_detail.sql

-- 7. Spot-check five rows of the result against the raw tables directly, confirming revenue, category, state, delivery time, and review score all look correct for those orders.

------ BLOCK 4:

-- 1. Export the summary table (and a second one too, if Block 2's scope genuinely needs two separate grains — e.g., an order-level table and a lighter daily-aggregate table) to Parquet using `COPY ... TO ... (FORMAT PARQUET)`.

---- Create or replace table  main_sales_orders_detail AS ...

-- 2. Open Power BI Desktop, start a new report, and load the exported file(s) via **Get Data → Parquet** or **Get Data → Folder**.

----  main_sales_orders_detail export during  'duckdb-power-query-connector' direct query connection. and save as power_bi_olist_summary 

---- source https://github.com/motherduckdb/duckdb-power-query-connector#installing

-- 3. In Power Query, confirm data types landed correctly — dates as dates, numeric columns as numbers, not text — since this determines whether tomorrow's charts and slicers behave correctly.

---- the same as in duckdb

-- 4. Rename any messily-auto-named queries, then **Close & Apply**.

---- Renamed to main_sales_orders_detail

-- 5. Confirm the row count in Power BI's Data view matches the row count of the exported table in DuckDB.

---- Confirmed 112109 rows in bouth sources.

------ BLOCK 5:

-- 1. If Block 4 produced more than one table, build the relationship between them in Model view now, checking the cardinality Power BI infers against what's actually true of the data.
-- 2. If the summary table has a proper date column (order purchase date), decide whether it needs a separate date dimension table or can be used directly — for a single-table model, a direct date column is often enough; only build a separate date table if Block 2's questions need real time-intelligence calculations.
-- 3. If you do build a separate date table, mark it as the official date table (Model view → right-click → "Mark as date table").

--- DateTable = 
--- VAR MinDate =
---    MIN(main_sales_orders_detail[order_purchase_timestamp])
--- VAR MaxDate =
---    MAX(main_sales_orders_detail[order_purchase_timestamp])
--- RETURN
---    ADDCOLUMNS(
---        CALENDAR(MinDate, MaxDate),
---        "Year", YEAR([Date]),
---        "Month", FORMAT([Date], "MMMM"),
---        "Quarter", "Q" & FORMAT([Date], "Q"),
---        "Week number", WEEKNUM([Date], 2),
---        "Day of the week", FORMAT([Date], "dddd")
---    )

-- 4. Either way, confirm a quick date-based slicer behaves correctly — continuous range, correct sort order, no text-sorted dates.
-- 5. Write one sentence on why you did or didn't need a separate date table this time, compared to `dim_date_spine` in the bikeshare project.

-- Never do that so just wanna to try this way. It keeps our data ful and also we can highlight gap in the data.


-- Reporter : Serhiy Dranko
-- Date : 2026-08-10
