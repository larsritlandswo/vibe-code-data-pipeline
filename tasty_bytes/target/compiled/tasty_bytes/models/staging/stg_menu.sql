select
    MENU_ID as menu_id,
    MENU_TYPE_ID as menu_type_id,
    MENU_TYPE as menu_type,
    TRUCK_BRAND_NAME as truck_brand_name,
    MENU_ITEM_ID as menu_item_id,
    MENU_ITEM_NAME as menu_item_name,
    ITEM_CATEGORY as item_category,
    ITEM_SUBCATEGORY as item_subcategory,
    COST_OF_GOODS_USD as cost_of_goods_usd,
    SALE_PRICE_USD as sale_price_usd
from LARSR_DB.RAW.menu