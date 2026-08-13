----- BLOCK 1:

-- 1. Revisit Day 1's scope note and, for each of the two or three business questions, identify what someone would actually want to filter by while exploring it.
-- 2. Build a date range slicer on order date.
-- 3. Build a category slicer, using the same Top N logic as yesterday's bar chart if the category field has high cardinality.
-- 4. Build a state slicer.
-- 5. Test each slicer individually against yesterday's three charts, confirming the numbers update correctly.

-- Slicer where connected to all tabs

----- BLOCK 2:

-- 1. Open Format → Edit Interactions and review, for every pair of visuals, what the current default interaction is.
-- 2. For each slicer, confirm it's set to filter every relevant visual on the page.
-- 3. For the category and state bar charts, decide deliberately whether clicking a bar should cross-filter the other chart, and set it explicitly rather than leaving it ambiguous.
-- 4. Write one sentence per visual pair where you changed the default, explaining why.

--  Monthly Revenue, Jan 2017–Aug 2018. Set the revenue chart to filter (not just highlight) the rest of the page, since selecting a month should show what portion of that month's totals each other visual represents.
--  Delivery Time & Order Volume by Review Score. Set to filter as well, so selecting a delivery bucket shows how that specific slice of orders breaks down across category, state and revenue.
--  TOP 10 charts. Kept cross-filtering enabled between them so clicking a category or state gives a quick visual read on that segment of the business reflected across the rest of the dashboard.

----- Block 3:

-- 1. Confirm the delivery-time calculation from Day 1's SQL summary table is available as a column in the model.

-- We have delivery_time_days in power BI

-- 2. Decide on bucket boundaries (e.g., 0–3, 4–7, 8–14, 15+ days) based on the actual distribution — check delivery-time quartiles first rather than guessing round numbers.

SELECT 
    MIN(delivery_time_days) AS min_days,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY delivery_time_days) AS p25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY delivery_time_days) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY delivery_time_days) AS p75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY delivery_time_days) AS p90,
    MAX(delivery_time_days) AS max_days
FROM main_sales_orders_detail
WHERE delivery_time_days IS NOT NULL;

-- 3. Write a DAX calculated column or measure that assigns each order to a bucket.

-- delivery_bucket = 
-- SWITCH(
--    TRUE(),
--    ISBLANK(main_sales_orders_detail[delivery_time_days]), "6. Not delivered", 
--    main_sales_orders_detail[delivery_time_days] <= 7, "1. Fast (0-7d)",
--    main_sales_orders_detail[delivery_time_days] <= 10, "2. Normal (8-10d)",
--    main_sales_orders_detail[delivery_time_days] <= 16, "3. Slower (11-16d)",
--    main_sales_orders_detail[delivery_time_days] <= 23, "4. Slow (17-23d)",
--    main_sales_orders_detail[delivery_time_days] >= 24, "5. Very slow (24d+)"
-- )
-- 4. Confirm the buckets sort in the correct order in a visual (not alphabetically) by setting a sort-by column if needed.

-- 5. Spot-check five orders against their raw delivery-time value to confirm they landed in the correct bucket.
-- 6. Add `Order Count` per bucket as a quick table visual, checking that the buckets have enough volume each to be meaningful (a bucket with three orders isn't a reliable pattern).

SELECT 
    *,strftime(order_purchase_timestamp, '%d/%m/%Y'),strftime(order_delivered_customer_date, '%d/%m/%Y')
FROM main_sales_orders_detail
WHERE delivery_time_days >= 100;



SELECT strftime(order_purchase_timestamp, '%d/%m/%Y %H:%M:%S'),strftime(order_delivered_customer_date, '%d/%m/%Y %H:%M:%S'), delivery_time_days
FROM main_sales_orders_detail
WHERE order_id ='1d893dd7ca5f77ebf5f59f0d2017eee0';

  SELECT COUNT (distinct order_id)
FROM main_sales_orders_detail
WHERE delivery_time_days IS NULL 
  AND order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31';

----- Block 4:

-- 1. Build a bar or column chart with the delivery-time bucket on one axis and `Avg Review Score` as the value.
-- 2. Add `Order Count` as a tooltip or secondary label, so a bucket's reliability is visible alongside its average score.
-- 3. Title the chart in language that describes association, not causation (e.g., "Average Review Score by Delivery-Time Bucket" rather than "How Delivery Time Affects Reviews").
-- 4. Write a one-sentence caption or note for the presentation script explicitly naming the correlation-vs-causation caveat from Day 3 Concepts.

-- This is an observed association not a controlled comparison. We can't rule out other variables influencing both delivery time and review score.

-- 5. Confirm the chart responds correctly to the slicers built in Block 1.

----- Block 5:

-- 1. Place the slicers in a consistent location (commonly a left rail or top bar) rather than scattered around the canvas.
-- 2. Add today's delivery-time-vs-review-score chart into the layout alongside yesterday's three.
-- 3. Click through every slicer and confirm all four charts (trend, category, state, delivery/review) update correctly together.
-- 4. Note any visual that feels crowded or redundant now that everything's on one page — flag it for Thursday rather than fixing it today.
-- 5. Save the `.pbix` file.

-- Reporter : Serhiy Dranko
-- Date : 2026-08-12
