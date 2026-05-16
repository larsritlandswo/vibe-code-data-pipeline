
  
    

        create or replace transient table LARSR_DB.PROD.fct_order_summary
         as
        (select
    o.order_id,
    o.truck_id,
    o.location_id,
    o.customer_id,
    o.order_date,
    o.order_ts,
    o.order_channel,
    o.order_currency,
    o.order_amount,
    o.order_tax_amount,
    o.order_discount_amount,
    o.order_total,
    count(od.order_detail_id) as item_count,
    sum(od.quantity) as total_quantity,
    sum(od.line_cogs) as total_cogs,
    sum(od.line_gross_profit) as total_gross_profit
from LARSR_DB.PROD.stg_orders o
inner join LARSR_DB.PROD.int_order_details_enriched od
    on o.order_id = od.order_id
group by
    o.order_id,
    o.truck_id,
    o.location_id,
    o.customer_id,
    o.order_date,
    o.order_ts,
    o.order_channel,
    o.order_currency,
    o.order_amount,
    o.order_tax_amount,
    o.order_discount_amount,
    o.order_total
        );
      
  