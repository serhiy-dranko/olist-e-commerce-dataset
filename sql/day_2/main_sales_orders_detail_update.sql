CREATE OR REPLACE TABLE main_sales_orders_detail AS
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
),
-- For Top 10 pCat pie chart
category_totals AS (
    SELECT
        t.product_category_name_english AS category,
        SUM(oi.price) + SUM(oi.freight_value) AS total_val,
        RANK() OVER (ORDER BY SUM(oi.price) + SUM(oi.freight_value) DESC) AS category_rank
    FROM olist_order_items_dataset oi
    LEFT JOIN olist_products_dataset p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY t.product_category_name_english
),
-- For Top 10 State pie chart
state_totals AS (
    SELECT
        c.customer_state AS state,
        SUM(oi.price) + SUM(oi.freight_value) AS total_val,
        RANK() OVER (ORDER BY SUM(oi.price) + SUM(oi.freight_value) DESC) AS state_rank
    FROM olist_order_items_dataset oi
    LEFT JOIN olist_orders_dataset o
        ON oi.order_id = o.order_id
    LEFT JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_state
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
    CASE WHEN st.state_rank <= 10 THEN c.customer_state ELSE 'Other' END AS state_grouped,-- For Top 10 State pie chart
    c.customer_state,
    c.customer_city,
    p.product_category_name,
    COALESCE(t.product_category_name_english,'Unknown') AS product_category_name_english,
    CASE WHEN ct.category_rank <= 10 THEN t.product_category_name_english ELSE 'other' END AS pCat_grouped,-- For Top 10 pCat pie chart
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
LEFT JOIN category_totals ct -- For Top 10 pCat pie chart
    ON t.product_category_name_english = ct.category
LEFT JOIN state_totals st -- For Top 10 State pie chart
    ON c.customer_state = st.state
LEFT JOIN last_review_per_order r
    ON o.order_id = r.order_id
    AND r.rn = 1
WHERE o.order_status NOT IN ('canceled','unavailable')
;

