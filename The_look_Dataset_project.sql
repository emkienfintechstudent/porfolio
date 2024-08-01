--GOOGLE CLOUD--
--I. Ad-hoc tasks
-- 1. Xem xét số lượng khách hàng và số lượng đơn hàng đã hoàn thành mỗi tháng (từ 07–2022 đến 07–2024)

SELECT FORMAT_DATE('%Y-%m', t2.delivered_at) AS month_year,
       count(DISTINCT t1.user_id) AS total_user,
       count(t1.ORDER_id) AS total_order
from bigquery-public-data.thelook_ecommerce.orders as t1
Join bigquery-public-data.thelook_ecommerce.order_items as t2  ON t1.order_id=t2.order_id
WHERE t1.status='Complete'
  AND FORMAT_DATE('%Y-%m', t2.delivered_at) BETWEEN '2022-07' AND '2024-07'
GROUP BY month_year
ORDER BY month_year
