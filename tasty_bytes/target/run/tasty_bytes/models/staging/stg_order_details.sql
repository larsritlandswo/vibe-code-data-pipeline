
  create or replace   view LARSR_DB.PROD.stg_order_details
  
   as (
    select
    ORDER_DETAIL_ID as order_detail_id,
    ORDER_ID as order_id,
    MENU_ITEM_ID as menu_item_id,
    DISCOUNT_ID as discount_id,
    LINE_NUMBER as line_number,
    QUANTITY as quantity,
    UNIT_PRICE as unit_price,
    PRICE as price,
    TRY_TO_DECIMAL(ORDER_ITEM_DISCOUNT_AMOUNT, 38, 4) as order_item_discount_amount
from LARSR_DB.RAW.order_detail
  );

