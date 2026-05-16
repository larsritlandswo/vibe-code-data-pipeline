
        

    
        create dynamic table LARSR_DB.PROD.int_order_details_enriched
        target_lag = '1 hour'
        warehouse = LARSR_WH
        refresh_mode = AUTO

        initialize = ON_CREATE

        as (
            select
    od.order_detail_id,
    od.order_id,
    od.menu_item_id,
    od.line_number,
    od.quantity,
    od.unit_price,
    od.price,
    od.order_item_discount_amount,
    m.menu_item_name,
    m.menu_type,
    m.truck_brand_name,
    m.item_category,
    m.item_subcategory,
    m.cost_of_goods_usd,
    m.sale_price_usd,
    od.quantity * m.cost_of_goods_usd as line_cogs,
    od.price - (od.quantity * m.cost_of_goods_usd) as line_gross_profit
from LARSR_DB.PROD.stg_order_details od
inner join LARSR_DB.PROD.stg_menu m
    on od.menu_item_id = m.menu_item_id
        )

    


    