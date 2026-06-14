# Metric Catalog: E-commerce Analytics Warehouse

## gross_revenue
- Business definition: Total product sales from delivered orders.
- SQL formula: `sum(order_value)` filtered where `is_delivered = true`.
- Grain: daily, product category, seller, or customer depending on mart.
- Caveat: Does not include freight unless explicitly stated.
- Used in: Executive Overview, Product Performance, Seller Scorecard.

## freight_revenue
- Business definition: Total freight value from delivered orders.
- SQL formula: `sum(freight_value)` filtered where `is_delivered = true`.
- Caveat: This is freight charged, not necessarily shipping profit.

## order_count
- Business definition: Number of distinct orders.
- SQL formula: `count(distinct order_id)`.
- Caveat: Some charts use all orders; revenue charts usually use delivered orders.

## delivered_order_count
- Business definition: Number of orders with status delivered.
- SQL formula: `count(distinct case when is_delivered then order_id end)`.

## cancellation_rate
- Business definition: Share of orders that were cancelled.
- SQL formula: `cancelled_order_count / order_count`.

## average_order_value
- Business definition: Average product revenue per delivered order.
- SQL formula: `gross_revenue / delivered_order_count`.

## on_time_delivery_rate
- Business definition: Share of delivered orders arriving on or before estimated delivery date.
- SQL formula: `on_time_delivered_orders / delivered_order_count`.

## average_review_score
- Business definition: Average customer review score.
- SQL formula: `avg(review_score)`.

## rfm_segment
- Business definition: Customer segmentation based on recency, frequency, and monetary value.
- Caveat: Olist dataset is historical snapshot, so recency is relative to dataset period.

## cohort_retention_rate
- Business definition: Share of customers from a first-order month who purchased again in later months.
- SQL formula: `active_customers_in_month / cohort_customers`.