## Block 6: Sanity Check and Reflection (30 min)

### Do this: 3 tasks

1. Build one temporary table visual pulling several columns from the model, spot-check it against the SQL summary table directly, then delete it before saving.

<img width="1208" height="724" alt="Screenshot 2026-08-11 113451" src="https://github.com/user-attachments/assets/d437de0b-ee27-49bf-ac4e-e956e71950e3" />

  
2. Save the `.pbix` file with a clear name identifying it as this week's Olist project.

  C:\Users\User\Documents\Dataskools\olist-e-commerce-dataset\power_bi_olist_summary.pbix
  
3. Answer the reflection questions below and save them alongside the scope note from Block 2.

**Reflection questions:**

1. Given what today's exploration turned up, does Block 2's scope still feel achievable by Thursday, or does something need to be cut now rather than discovered mid-week?

Yes, still achievable — but with less slack than it looked like this morning. The joins for all three questions (Q1 revenue by category, Q2 delivery vs review score, Q3 state performance) came together in a single summary table today, which is ahead of where I expected to be. The one thing that ate more time than planned was handling fan-out from order_payments and order_reviews — both needed aggregation/deduplication before joining, and the first attempt (using DENSE_RANK() for reviews) silently produced extra rows that had to be caught and fixed. That's now solved and reusable, but it's a reminder that Q3, which reuses this same table, is not "free" — if anything goes wrong upstream in this base table, it breaks all three questions at once. No cut needed yet, but if Wednesday's chart-building surfaces a similar hidden issue, Q3 (state-level) is still the one to drop first, per the scope note.
   
2. Compare building today's summary table to Week 1's first joined table — what's different about doing this with no schema doc provided by the course, and no prior queries to lean on?

The biggest difference is the absence of a given schema doc — Week 1's table came with column definitions and relationships already specified, so the work was mostly translating a known structure into SQL. This week, the schema had to be reconstructed first: reading table structures directly from Beekeeper, sketching the ERD from foreign key names (order_id, customer_id, product_id, seller_id), and then verifying assumptions with actual queries (checking for orphaned keys, checking row counts per order) rather than trusting a document. That verification step is new — Week 1 didn't require confirming that a join key "actually behaves" the way it's supposed to, because the doc guaranteed it. Here, the guarantee had to be earned with orphan checks and grain checks before the real joins were trustworthy. There's also no prior query library to copy patterns from, so today's CTE-based deduplication pattern (aggregate first, then join) is now the reusable pattern for the rest of the week, not something to borrow from earlier work.
   
3. With Friday 11am fixed, what's the single biggest risk to being ready in time, and what's the plan for catching it early rather than on Thursday night?

The biggest risk is a data-quality surprise discovered after the summary table is already built into charts — something like a category with no English translation, an order with a delivery date earlier than its purchase date, or a state code that doesn't match what Power BI expects for a map visual. These are the kind of issues that don't show up until a visual looks obviously wrong, which could easily happen Wednesday afternoon or later. The plan to catch this early: before building any Power BI visuals tomorrow, run a short set of sanity queries directly against today's summary table — null counts per key column, min/max on delivery_time_days (to catch negative values), and a distinct list of customer_state and product_category_name_english — so any oddities surface first thing Wednesday morning, not while a visual is half-built Thursday night.
   
4. Based on the shape of today's summary table, which specific visual do you expect to be the most natural fit tomorrow, and which do you expect to take the most extra work?

The most natural fit is a category revenue trend line/bar chart — the summary table already has order_purchase_timestamp, price, and product_category_name_english sitting at the right grain, so this is close to a direct drag-and-drop in Power BI with a date hierarchy and a category filter.

The one expected to take the most extra work is the delivery time vs. review score visual (likely a scatter or binned bar chart). The underlying fields (delivery_time_days, review_score) are ready, but the table is at order-item grain while this question is really order-level — a multi-item order currently repeats the same delivery_time_days and review_score across several rows, so an aggregation or a distinct-order rollup will be needed inside Power BI (or as a separate query) to avoid overweighting large orders in the chart.
