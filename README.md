# Olist E-Commerce Sales & Delivery Analytics

A data engineering + BI project that turns the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (9 raw CSV tables, 100k+ orders, 2016–2018) into a single analytical model and an interactive Power BI dashboard.

> Built as a hands-on data engineering exercise: raw CSVs → SQL transformation pipeline → semantic model → dashboard. The folder keeps the day-by-day build history alongside the final, numbered pipeline.

---

## Business Questions

The dashboard is built to answer three concrete questions:

| # | Question | Why it matters |
|---|---|---|
| 1 | **Revenue trend by category** — Is revenue growing or shrinking over 2017–2018, and which product categories drive it? | Identifies where growth is (or isn't) coming from |
| 2 | **Delivery time vs. review score** — Do late or slow deliveries correlate with lower customer satisfaction? | Tests whether logistics performance is a satisfaction lever |
| 3 | **State-level performance** — Where is order volume and review quality strongest — and weakest — across Brazil? | Surfaces geographic strengths/gaps for the business |

## Data Contract

Each business question is backed by a specific, minimal set of source tables and columns — this is the contract the SQL pipeline is built against.

<details>
<summary><strong>1. Revenue trend by category</strong></summary>

- **Tables:** `orders`, `order_items`, `products`, `product_category_name_translation`
- **Columns:** `order_purchase_timestamp`, `price`, `product_id` → `product_category_name` → `product_category_name_english`
</details>

<details>
<summary><strong>2. Delivery time vs. review score</strong></summary>

- **Tables:** `orders`, `order_reviews`
- **Columns:** `order_purchase_timestamp`, `order_delivered_customer_date`, `order_estimated_delivery_date` → `review_score`
</details>

<details>
<summary><strong>3. State-level performance</strong></summary>

- **Tables:** `orders`, `customers`, `order_reviews`
- **Columns:** `customer_id` → `customer_state`, `order_id` → `review_score`
</details>

## Pipeline Architecture

```
 Kaggle CSVs (9 tables)
        │
        ▼
 ┌─────────────┐   type casting, key cleanup,
 │  1. EXTRACT │   de-duplication
 │  / STAGE    │
 └─────────────┘
        │
        ▼
 ┌─────────────┐   calculated fields:
 │ 2. TRANSFORM│   delivery_time_days, state_grouped,
 │             │   pCat_grouped
 └─────────────┘
        │
        ▼
 ┌─────────────┐   star-schema-style model:
 │  3. MODEL   │   main_sales_orders_detail (fact/detail)
 │             │   + lookup dimensions (states, categories)
 └─────────────┘
        │
        ▼
 ┌─────────────┐   DAX measures: Total Revenue, Order Count,
 │  4. SERVE   │   Avg Review Score → Power BI report
 └─────────────┘
```

## Key Insights

- **Revenue grew, then plateaued.** Monthly revenue climbed through 2017, spiked to R$178K on Nov 24, 2017 (Brazil's Black Friday), then stabilized around R$1M/month through mid-2018.
- **Slower delivery → lower reviews.** Average review score falls from 4.33 (0–7 day delivery) to 1.80 for undelivered orders — a clear, near-linear relationship.
- **São Paulo dominates, but the tail matters.** São Paulo alone drives 37% of revenue; the next 10 states combined still contribute the majority of the remainder.

[Olis_dashboard]([https://github.com](http://github.com/serhiy-dranko/olist-e-commerce-dataset/blob/main/dashboard/screenshot/Olis%20dashboard.png))

## Tech Stack

- **SQL** — staging, transformation, and modeling
- **Power BI Desktop** — semantic model (DAX) and interactive report
- **Data source** — [Kaggle: Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
