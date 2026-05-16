# Session Summary: Tasty Bytes dbt Pipeline + Semantic View
**Date:** 2026-05-14  
**Workspace:** USER$.PUBLIC."vibe-code-data-pipeline"  
**Database:** LARSR_DB | **Schema:** PROD | **Role:** LARSR_ROLE

---

## What Was Built

A medallion architecture dbt project on the Tasty Bytes food truck dataset (LARSR_DB.RAW)
with a Snowflake semantic view as the most downstream artifact for Cortex Analyst.

### Source Data (LARSR_DB.RAW)

| Table | Rows | PK | Notes |
|-------|------|----|-------|
| ORDER_HEADER | 248M | ORDER_ID (unique) | Orders 2019-01-01 to 2022-11-01 |
| ORDER_DETAIL | 674M | ORDER_DETAIL_ID (unique) | ~2.7 lines/order, no fan-out |
| TRUCK | 450 | TRUCK_ID | |
| MENU | 100 | MENU_ID / MENU_ITEM_ID | Both unique |
| LOCATION | 13,093 | LOCATION_ID | |
| CUSTOMER_LOYALTY | 222,540 | CUSTOMER_ID | |
| FRANCHISE | 335 | FRANCHISE_ID | **Has duplicates** — deduped in staging |
| COUNTRY | 30 | CITY_ID | COUNTRY_ID is not unique (2 cities/country) |

### Medallion Layers (LARSR_DB.PROD)

| Layer | Models | Materialization | Objects |
|-------|--------|----------------|---------|
| **Bronze (staging)** | 8 | view | stg_orders, stg_order_details, stg_trucks, stg_menu, stg_locations, stg_customers, stg_franchises, stg_countries |
| **Silver (intermediate)** | 2 | dynamic_table (1hr lag) | int_order_details_enriched (674M), int_trucks_enriched (450) |
| **Gold (marts)** | 6 | table | fct_daily_sales (523K), fct_order_summary (248M), dim_customer (222K), dim_menu (100), dim_truck (450), dim_location (13K) |
| **Semantic** | 1 | semantic_view | sem_sales_analytics |

### Key Design Decisions

1. **FRANCHISE dedup:** `qualify row_number() over (partition by FRANCHISE_ID order by FIRST_NAME) = 1`
2. **No exploding joins:** All joins verified as many-to-one before building
3. **Dynamic tables** for intermediate layer — Snowflake auto-refreshes the 674M row join
4. **Pre-aggregated fact:** `fct_daily_sales` aggregated to day/truck/location grain (523K rows from 248M orders)

---

## Semantic View Evolution

### v1 (Initial) — Had Ambiguity Issues
- Included both `daily_sales` and `orders` tables with competing revenue metrics
- Cortex Analyst could pick either path, producing inconsistent results
- Minimal AI_SQL_GENERATION instructions

### v2 (Fixed) — Single Source of Truth
- **Removed `orders` table** from semantic view — all KPIs from `daily_sales` only
- **Added COMMENT on every metric/dimension** for clarity
- **Added explicit AI_SQL_GENERATION** instructions directing analyst to always use daily_sales
- **Added 5 verified queries** (VQRs) for common board-level questions:
  - Top 5 trucks by revenue
  - Annual revenue trend YoY
  - Revenue by region
  - Revenue by country
  - Daily revenue
- **Added derived `gross_profit_margin` metric**

### Metrics in Semantic View

| Metric | Formula | Synonyms |
|--------|---------|----------|
| total_revenue | SUM(daily_sales.total_revenue) | total sales, gross revenue, revenue, sales |
| total_cogs | SUM(daily_sales.total_cogs) | cost of goods sold, cogs, cost |
| total_gross_profit | SUM(daily_sales.total_gross_profit) | gross profit, profit |
| total_orders | SUM(daily_sales.order_count) | number of orders, order count |
| total_items_sold | SUM(daily_sales.items_sold) | quantity sold, units sold |
| total_unique_customers | SUM(daily_sales.unique_customers) | customer count |
| average_order_value | AVG(daily_sales.avg_order_value) | aov, avg order value |
| gross_profit_margin | total_gross_profit / total_revenue | margin, gp margin |

---

## Board-Level Query Results (from Cortex Analyst)

**Q: Annual revenue trend, gross profit margin, and growth drivers?**

| Year | Revenue | YoY Growth | Gross Margin |
|------|---------|-----------|--------------|
| 2019 | $192M | — | 51.8% |
| 2020 | $1.38B | +619% | 51.9% |
| 2021 | $3.46B | +150% | 52.0% |
| 2022 | $5.06B | +46% | 52.3% |

Top growth regions (2022): Tokyo (+86%), Greater London (+67%), Rio de Janeiro (+71%)

---

## Cortex Analyst Access

- **Snowsight UI:** AI & ML → Cortex Analyst → select LARSR_DB.PROD.SEM_SALES_ANALYTICS
- **SQL function:** Requires provisioned throughput (got "Provisioned Throughput not found" error)
- **Verified queries** appear as onboarding suggestions in the Playground

---

## Files Created

```
tasty_bytes/
├── dbt_project.yml
├── profiles.yml
├── packages.yml
├── models/
│   ├── sources.yml
│   ├── staging/
│   │   ├── stg_countries.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_franchises.sql
│   │   ├── stg_locations.sql
│   │   ├── stg_menu.sql
│   │   ├── stg_order_details.sql
│   │   ├── stg_orders.sql
│   │   └── stg_trucks.sql
│   ├── intermediate/
│   │   ├── int_order_details_enriched.sql
│   │   └── int_trucks_enriched.sql
│   ├── marts/
│   │   ├── dim_customer.sql
│   │   ├── dim_location.sql
│   │   ├── dim_menu.sql
│   │   ├── dim_truck.sql
│   │   ├── fct_daily_sales.sql
│   │   └── fct_order_summary.sql
│   └── semantic/
│       └── sem_sales_analytics.sql
├── signoff/
│   └── metrics_signoff.yml
cortex_analyst_queries.sql
```

---

## Lesson Learned

**Semantic views must have a single, unambiguous path to each metric.**
Having two tables with overlapping revenue metrics (even with different synonyms)
causes Cortex Analyst to produce inconsistent results. Fix: one fact table per
metric concept, detailed COMMENT fields, explicit AI_SQL_GENERATION directives,
and verified queries for critical business questions.
