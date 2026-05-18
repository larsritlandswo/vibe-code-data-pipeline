
  
    

        create or replace transient table LARSR_DB.DEV_LARSR_TASTY_BYTES.dim_menu
         as
        (select
    menu_id,
    menu_type_id,
    menu_type,
    truck_brand_name,
    menu_item_id,
    menu_item_name,
    item_category,
    item_subcategory,
    cost_of_goods_usd,
    sale_price_usd,
    sale_price_usd - cost_of_goods_usd as unit_margin_usd
from LARSR_DB.DEV_LARSR_TASTY_BYTES.stg_menu
        );
      
  