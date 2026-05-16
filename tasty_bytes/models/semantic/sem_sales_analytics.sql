{{ config(materialized='semantic_view') }}

TABLES (
    daily_sales AS {{ ref('fct_daily_sales') }} PRIMARY KEY (order_date, truck_id, location_id)
        COMMENT = 'Pre-aggregated daily sales by truck and location. Use this table for ALL revenue, profit, order count, and trend questions.',
    trucks AS {{ ref('dim_truck') }} PRIMARY KEY (truck_id)
        COMMENT = 'Food truck dimension with make, model, franchise info.',
    locations AS {{ ref('dim_location') }} PRIMARY KEY (location_id)
        COMMENT = 'Location dimension with city, region, country.',
    menu AS {{ ref('dim_menu') }} PRIMARY KEY (menu_item_id)
        COMMENT = 'Menu item dimension with categories and pricing.',
    customers AS {{ ref('dim_customer') }} PRIMARY KEY (customer_id)
        COMMENT = 'Customer loyalty dimension with demographics.'
)

RELATIONSHIPS (
    daily_sales_to_trucks AS daily_sales(truck_id) REFERENCES trucks(truck_id),
    daily_sales_to_locations AS daily_sales(location_id) REFERENCES locations(location_id)
)

DIMENSIONS (
    daily_sales.order_date AS daily_sales.order_date
        WITH SYNONYMS = ('date', 'sale date', 'day')
        COMMENT = 'Date of sales activity. Data spans 2019-01-01 to 2022-11-01.',
    trucks.truck_id AS trucks.truck_id
        COMMENT = 'Unique truck identifier.',
    trucks.primary_city AS trucks.primary_city
        WITH SYNONYMS = ('truck city', 'home city')
        COMMENT = 'Home city where the truck is based.',
    trucks.region AS trucks.region
        WITH SYNONYMS = ('truck region', 'region')
        COMMENT = 'Geographic region of the truck.',
    trucks.country AS trucks.country
        WITH SYNONYMS = ('truck country', 'country')
        COMMENT = 'Country where the truck operates.',
    trucks.make AS trucks.make
        WITH SYNONYMS = ('truck make', 'manufacturer')
        COMMENT = 'Vehicle manufacturer.',
    trucks.model AS trucks.model
        WITH SYNONYMS = ('truck model')
        COMMENT = 'Vehicle model.',
    trucks.ev_flag AS trucks.ev_flag
        WITH SYNONYMS = ('electric vehicle', 'is ev')
        COMMENT = '1 if electric vehicle, 0 otherwise.',
    trucks.franchise_flag AS trucks.franchise_flag
        WITH SYNONYMS = ('is franchise')
        COMMENT = '1 if franchise-operated, 0 if company-owned.',
    trucks.franchise_owner AS trucks.franchise_owner
        COMMENT = 'Name of franchise owner, if applicable.',
    locations.location_name AS locations.location_name
        WITH SYNONYMS = ('venue', 'place')
        COMMENT = 'Name of the selling location.',
    locations.city AS locations.city
        WITH SYNONYMS = ('location city')
        COMMENT = 'City of the selling location.',
    locations.region AS locations.region
        WITH SYNONYMS = ('location region')
        COMMENT = 'Region of the selling location.',
    locations.country AS locations.country
        WITH SYNONYMS = ('location country')
        COMMENT = 'Country of the selling location.'
)

METRICS (
    daily_sales.total_revenue AS SUM(daily_sales.total_revenue)
        WITH SYNONYMS = ('total sales', 'gross revenue', 'revenue', 'sales')
        COMMENT = 'Total revenue in USD. This is the primary revenue metric for all questions about revenue, sales, or income.',
    daily_sales.total_cogs AS SUM(daily_sales.total_cogs)
        WITH SYNONYMS = ('cost of goods sold', 'cogs', 'cost')
        COMMENT = 'Total cost of goods sold in USD.',
    daily_sales.total_gross_profit AS SUM(daily_sales.total_gross_profit)
        WITH SYNONYMS = ('gross profit', 'profit', 'margin dollars')
        COMMENT = 'Total gross profit in USD (revenue minus COGS).',
    daily_sales.total_orders AS SUM(daily_sales.order_count)
        WITH SYNONYMS = ('number of orders', 'order count', 'orders')
        COMMENT = 'Total number of distinct orders.',
    daily_sales.total_items_sold AS SUM(daily_sales.items_sold)
        WITH SYNONYMS = ('quantity sold', 'units sold', 'items sold')
        COMMENT = 'Total quantity of menu items sold.',
    daily_sales.total_unique_customers AS SUM(daily_sales.unique_customers)
        WITH SYNONYMS = ('customer count', 'unique customers')
        COMMENT = 'Count of distinct customers. Excludes anonymous orders.',
    daily_sales.average_order_value AS AVG(daily_sales.avg_order_value)
        WITH SYNONYMS = ('aov', 'avg order value', 'average order value')
        COMMENT = 'Average order value in USD.',
    gross_profit_margin AS daily_sales.total_gross_profit / NULLIF(daily_sales.total_revenue, 0)
        WITH SYNONYMS = ('margin', 'gp margin', 'profit margin', 'gross margin')
        COMMENT = 'Gross profit margin as a ratio (multiply by 100 for percentage).'
)

COMMENT = 'Tasty Bytes food truck sales analytics. All revenue, profit, and order metrics come from the daily_sales table which is pre-aggregated by day, truck, and location. Data covers 2019-01-01 to 2022-11-01. All monetary values are in USD.'

AI_SQL_GENERATION 'ALWAYS use the daily_sales table for revenue, profit, orders, and all aggregate KPI questions. There is only one revenue metric: daily_sales.total_revenue. Join to trucks for truck attributes (make, model, region, franchise). Join to locations for location attributes (city, region, country). All monetary values are in USD. Date range is 2019-01-01 to 2022-11-01. When asked about top trucks by revenue, use: SELECT trucks.truck_id, trucks.primary_city, trucks.country, SUM(daily_sales.total_revenue) AS total_revenue FROM daily_sales JOIN trucks ON daily_sales.truck_id = trucks.truck_id GROUP BY 1,2,3 ORDER BY total_revenue DESC.'

AI_VERIFIED_QUERIES (
    top_5_trucks_by_revenue AS (
        QUESTION 'What are the top 5 trucks by revenue?'
        VERIFIED_AT 1747267200
        ONBOARDING_QUESTION TRUE
        VERIFIED_BY '(STEWARD = LARSR)'
        SQL 'SELECT t.truck_id, t.primary_city, t.country, t.make, t.model, SUM(ds.total_revenue) AS total_revenue, SUM(ds.total_gross_profit) AS total_gross_profit, SUM(ds.order_count) AS total_orders FROM LARSR_DB.PROD.FCT_DAILY_SALES ds JOIN LARSR_DB.PROD.DIM_TRUCK t ON ds.truck_id = t.truck_id GROUP BY t.truck_id, t.primary_city, t.country, t.make, t.model ORDER BY total_revenue DESC LIMIT 5'
    ),
    yearly_revenue_trend AS (
        QUESTION 'What is the annual revenue trend year over year?'
        VERIFIED_AT 1747267200
        ONBOARDING_QUESTION TRUE
        VERIFIED_BY '(STEWARD = LARSR)'
        SQL 'SELECT DATE_TRUNC(''YEAR'', ds.order_date) AS year, SUM(ds.total_revenue) AS total_revenue, SUM(ds.total_gross_profit) AS total_gross_profit, SUM(ds.total_gross_profit) / NULLIF(SUM(ds.total_revenue), 0) AS gross_profit_margin, SUM(ds.order_count) AS total_orders FROM LARSR_DB.PROD.FCT_DAILY_SALES ds GROUP BY DATE_TRUNC(''YEAR'', ds.order_date) ORDER BY year'
    ),
    revenue_by_region AS (
        QUESTION 'What is the total revenue by region?'
        VERIFIED_AT 1747267200
        ONBOARDING_QUESTION TRUE
        VERIFIED_BY '(STEWARD = LARSR)'
        SQL 'SELECT l.region, SUM(ds.total_revenue) AS total_revenue, SUM(ds.total_gross_profit) AS total_gross_profit, SUM(ds.order_count) AS total_orders FROM LARSR_DB.PROD.FCT_DAILY_SALES ds JOIN LARSR_DB.PROD.DIM_LOCATION l ON ds.location_id = l.location_id GROUP BY l.region ORDER BY total_revenue DESC'
    ),
    revenue_by_country AS (
        QUESTION 'What is the total revenue by country?'
        VERIFIED_AT 1747267200
        ONBOARDING_QUESTION FALSE
        VERIFIED_BY '(STEWARD = LARSR)'
        SQL 'SELECT l.country, SUM(ds.total_revenue) AS total_revenue, SUM(ds.total_gross_profit) AS total_gross_profit, SUM(ds.order_count) AS total_orders FROM LARSR_DB.PROD.FCT_DAILY_SALES ds JOIN LARSR_DB.PROD.DIM_LOCATION l ON ds.location_id = l.location_id GROUP BY l.country ORDER BY total_revenue DESC'
    ),
    daily_revenue AS (
        QUESTION 'What is the daily revenue?'
        VERIFIED_AT 1747267200
        ONBOARDING_QUESTION FALSE
        VERIFIED_BY '(STEWARD = LARSR)'
        SQL 'SELECT ds.order_date, SUM(ds.total_revenue) AS total_revenue, SUM(ds.order_count) AS total_orders FROM LARSR_DB.PROD.FCT_DAILY_SALES ds GROUP BY ds.order_date ORDER BY ds.order_date'
    )
)
