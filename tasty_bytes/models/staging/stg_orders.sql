select
    ORDER_ID as order_id,
    TRUCK_ID as truck_id,
    LOCATION_ID::NUMBER(38,0) as location_id,
    CUSTOMER_ID as customer_id,
    DISCOUNT_ID as discount_id,
    SHIFT_ID as shift_id,
    SHIFT_START_TIME as shift_start_time,
    SHIFT_END_TIME as shift_end_time,
    ORDER_CHANNEL as order_channel,
    ORDER_TS as order_ts,
    ORDER_TS::DATE as order_date,
    TRY_TO_TIMESTAMP(SERVED_TS) as served_ts,
    ORDER_CURRENCY as order_currency,
    ORDER_AMOUNT as order_amount,
    TRY_TO_DECIMAL(ORDER_TAX_AMOUNT, 38, 4) as order_tax_amount,
    TRY_TO_DECIMAL(ORDER_DISCOUNT_AMOUNT, 38, 4) as order_discount_amount,
    ORDER_TOTAL as order_total
from {{ source('raw', 'order_header') }}
