
  
    

        create or replace transient table LARSR_DB.DEV_LARSR_TASTY_BYTES.fct_daily_sales
         as
        (select
    o.order_date,
    o.truck_id,
    o.location_id,
    count(distinct o.order_id) as order_count,
    count(distinct o.customer_id) as unique_customers,
    sum(od.quantity) as items_sold,
    sum(od.price) as total_revenue,
    sum(od.line_cogs) as total_cogs,
    sum(od.line_gross_profit) as total_gross_profit,
    avg(o.order_total) as avg_order_value
from LARSR_DB.DEV_LARSR_TASTY_BYTES.stg_orders o
inner join LARSR_DB.DEV_LARSR_TASTY_BYTES.int_order_details_enriched od
    on o.order_id = od.order_id
group by
    o.order_date,
    o.truck_id,
    o.location_id
        );
      
  