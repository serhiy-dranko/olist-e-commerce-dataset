----- BLOCK 1:

-- 1. Decide, in writing, whether `Total Revenue` means item price alone or price plus freight — check this against Day 1's scope note if it was already decided there.

--- 8272b63d03f5f79c56e9e4120aec44ef if we look at this order we can see total by price and freight value 31.80 + 164.37 = 196.17 and open this order in olist_order_payments_datase
--- We'll see 196.11 witch is 6cents less than our summ's. So I would say we charge our client for shipping of items so we should include freight value in Total revenue. 

-- 2. Write a `Total Revenue` measure using `SUM()` over the appropriate column(s).

--- Total Revenue = SUM('main_sales_orders_detail'[price]) + SUM('main_sales_orders_detail'[freight_value])

-- 3. Write an `Order Count` measure using `DISTINCTCOUNT()` on the order ID, not a plain row count (since the table is at order-item grain, a row count would overcount).

--- Order Count = DISTINCTCOUNT(main_sales_orders_detail[order_id])

-- 4. Write an `Avg Review Score` measure and an `Avg Delivery Days` measure.

--- Avg Review Score = AVERAGE(main_sales_orders_detail[review_score])
--- Avg Delivery Days = AVERAGE(main_sales_orders_detail[delivery_time_days])

-- 5. Add all four measures to a visible measures table or clearly labeled section of the Fields pane so they're easy to find tomorrow.

-- At Mesure check tab saved

----- BLOCK 2:

-- 1. Build a line chart with order date on the axis and `Total Revenue` as the value, at daily grain first, just to see the raw shape.
-- 2. Decide, based on what that first version shows, whether to switch to monthly grain or trim the sparse early months — make the call from Day 2 Concepts, not by default.
-- 3. Rebuild the chart at the chosen grain.
-- 4. Add a secondary line or a tooltip showing `Order Count` alongside revenue, so a revenue dip can be read against volume, not just eyeballed.
-- 5. Title the chart with what it actually shows (e.g., "Monthly Revenue, Jan 2017–Aug 2018") rather than a generic label.

--- Check Monthly Revenue tab in .pbx

----- BLOCK 3:

-- 1. Build a first-pass bar chart of `Total Revenue` by product category, just to see the full distribution.
-- 2. Apply a Top N filter (Power BI's built-in Top N, or a DAX rank measure) to cut it down to a genuinely readable number of categories.
-- 3. Decide whether to add an "Other" bucket summing everything outside the Top N, and build it if so.
-- 4. Sort the chart by revenue, not alphabetically.
-- 5. Add `Order Count` or `Avg Review Score` as a tooltip field, so a category's story isn't reduced to revenue alone.
-- 6. Title the chart clearly, including how many categories are shown (e.g., "Top 10 Categories by Revenue").

--- Check TOP 10 pCat tab in .pbx


----- BLOCK 4:

-- 1. Build a bar chart of `Total Revenue` by customer state.
-- 2. Decide whether all states are readable as-is or whether this chart also needs a Top N treatment — 27 is fewer than 70, but check rather than assume.
-- 3. Sort by revenue and confirm state abbreviations or names are clean and consistent (Olist uses two-letter state codes; confirm they're not being read as a numeric or sorted oddly).
-- 4. Add `Order Count` as a tooltip field.
-- 5. Title the chart clearly.

--- Check TOP 10 State tab in .pbx

----- BLOCK= 5: 

-- 1. Pick the top category from Block 3's chart and run the equivalent `SUM`/`GROUP BY` query directly against Day 1's summary table in DuckDB — confirm the numbers match exactly.

SELECT 
    pCat_grouped,
    ROUND(SUM(price) + SUM(freight_value),2) AS total_revenue,
    COUNT(distinct order_id) AS orders_count
FROM main_sales_orders_detail
WHERE order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY pCat_grouped
ORDER BY total_revenue DESC;

-- 2. Do the same spot-check for one state from Block 4's chart.

SELECT 
    state_grouped,
    ROUND(SUM(price) + SUM(freight_value),2) AS total_revenue,
    COUNT(distinct order_id) AS orders_count
FROM main_sales_orders_detail
WHERE order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY state_grouped
ORDER BY total_revenue DESC;

-- 3. Do the same spot-check for one month's total from Block 2's line chart.



SELECT 
    strftime(order_purchase_timestamp, '%Y') AS year,
    strftime(order_purchase_timestamp, '%m') AS month,
    ROUND(SUM(price) + SUM(freight_value),2) AS total_revenue,
    COUNT(distinct order_id) AS orders_count
FROM main_sales_orders_detail
WHERE order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY 
    strftime(order_purchase_timestamp, '%Y'),
    strftime(order_purchase_timestamp, '%m')
ORDER BY year, month;
-- 4. If any number doesn't match, trace whether the issue is in the DAX measure, the visual's filter context, or the underlying SQL table — and fix it at the source rather than adjusting the visual to match.
-- 5. Arrange the three visuals into a rough first-pass layout — trend chart prominent, category and state charts below or beside it — without worrying yet about final polish (that's Thursday).

--- Check Summary tab in .pbx 

-- 6. Save the `.pbix` file.


-- Reporter : Serhiy Dranko
-- Date : 2026-08-11
