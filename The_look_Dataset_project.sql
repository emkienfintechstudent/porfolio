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

       
--2-- Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng (từ 07–2022 đến 07–2024)
--(*) Note: vì yêu cầu tập trung vào người dùng và không yêu cầu đơn hàng đã hoàn thành nên sử dụng 'created_at' làm mốc thời gian 
Select 
FORMAT_DATE('%Y-%m', created_at) as month_year,
count(DISTINCT user_id) as distinct_users,
round(sum(sale_price)/count(distinct order_id),2) as average_order_value
from bigquery-public-data.thelook_ecommerce.order_items
Where FORMAT_DATE('%Y-%m', created_at) BETWEEN '2022-07' AND '2024-07'
Group by month_year
ORDER BY month_year

       
--3-- Nhóm khách hàng theo độ tuổi
-- Tìm các khách hàng có trẻ tuổi nhất và lớn tuổi nhất theo từng giới tính (từ 07–2022 đến 07–2024)

WITH 
-- CTE này tìm độ tuổi nhỏ nhất và lớn nhất theo từng giới tính
cte AS ( 
  SELECT gender, MIN(age) AS min_age, MAX(age) AS max_age 
  FROM bigquery-public-data.thelook_ecommerce.users 
  GROUP BY gender
),

-- CTE này đếm số lượng người dùng có độ tuổi nhỏ nhất theo từng giới tính trong khoảng thời gian từ 07-2022 đến 07-2024
youngest AS (
  SELECT 
    a.gender, 
    a.age,
    COUNT(*) AS count, 
    'youngest' AS tag 
  FROM bigquery-public-data.thelook_ecommerce.users AS a 
  JOIN cte AS b ON a.gender = b.gender
  WHERE a.age = b.min_age 
    AND FORMAT_DATE('%Y-%m', a.created_at) BETWEEN '2022-07' AND '2024-07'
  GROUP BY a.gender, a.age
),

-- CTE này đếm số lượng người dùng có độ tuổi lớn nhất theo từng giới tính trong khoảng thời gian từ 07-2022 đến 07-2024
oldest AS (
  SELECT 
    a.gender, 
    a.age,
    COUNT(*) AS count, 
    'oldest' AS tag 
  FROM bigquery-public-data.thelook_ecommerce.users AS a 
  JOIN cte AS b ON a.gender = b.gender
  WHERE a.age = b.max_age 
    AND FORMAT_DATE('%Y-%m', a.created_at) BETWEEN '2022-07' AND '2024-07'
  GROUP BY a.gender, a.age
)

SELECT * FROM youngest 
UNION ALL 
SELECT * FROM oldest

       
-- III. Tạo metric trước khi dựng dashboard
-- 1. Tạo metric
       
with a as
(select distinct FORMAT_DATE('%Y-%m', o.created_at) as Month,
extract(year from o.created_at) as Year,
p.category as product_category,
round(sum(oi.sale_price) over (partition by p.category 
order by FORMAT_DATE('%Y-%m', o.created_at)),2) as TPV,
count(*) over (partition by p.category 
order by FORMAT_DATE('%Y-%m', o.created_at)) as TPO,
round(sum(p.cost) over (partition by p.category 
order by FORMAT_DATE('%Y-%m', o.created_at)),2) as total_cost
from bigquery-public-data.thelook_ecommerce.order_items as oi
join bigquery-public-data.thelook_ecommerce.orders as o
on oi.order_id=o.order_id
join bigquery-public-data.thelook_ecommerce.products as p
on oi.product_id=p.id
order by Month)

select Month, Year, product_category, TPV, TPO,
round(((TPV-lag(TPV) over (partition by product_category order by Month))/
lag(TPV) over (partition by product_category 
order by Month))*100,2)||'%' as revenue_growth,
round(((TPO-lag(TPO) over (partition by product_category order by Month))/
lag(TPO) over (partition by product_category 
order by Month))*100,2)||'%' as order_growth,
total_cost,
round(TPV-total_cost,2) as total_profit,
round((TPV-total_cost)/total_cost,2) as profit_to_cost_ratio
from a

-- 2) Tạo retention cohort analysis.
    
with table_index as
(select user_id, sale_price,
FORMAT_DATE('%Y-%m', date(first_date)) as cohort_date,
created_at,
cast(extract(year from created_at)-
extract(year from first_date) as decimal)*12
+cast(extract(month from created_at)-
extract(month from first_date) as decimal)+1 as index,
from
(select user_id, sale_price, 
min(created_at) over (partition by user_id) as first_date,
created_at
from bigquery-public-data.thelook_ecommerce.order_items
where FORMAT_DATE('%Y-%m', created_at) BETWEEN '2023-07' AND '2024-06'
)
)
, cohort_data as
(select cohort_date, index, 
count(distinct user_id) as cnt,
round(sum(sale_price),2) as revenue
from table_index
group by cohort_date, index),
customer_cohort as  (SELECT 
  cohort_date,
  SUM(CASE WHEN index = 1 THEN cnt ELSE 0 END) AS m1,
  SUM(CASE WHEN index = 2 THEN cnt ELSE 0 END) AS m2,
  SUM(CASE WHEN index = 3 THEN cnt ELSE 0 END) AS m3,
  SUM(CASE WHEN index = 4 THEN cnt ELSE 0 END) AS m4,
  SUM(CASE WHEN index = 5 THEN cnt ELSE 0 END) AS m5,
  SUM(CASE WHEN index = 6 THEN cnt ELSE 0 END) AS m6,
  SUM(CASE WHEN index = 7 THEN cnt ELSE 0 END) AS m7,
  SUM(CASE WHEN index = 8 THEN cnt ELSE 0 END) AS m8,
  SUM(CASE WHEN index = 9 THEN cnt ELSE 0 END) AS m9,
  SUM(CASE WHEN index = 10 THEN cnt ELSE 0 END) AS m10,
  SUM(CASE WHEN index = 11 THEN cnt ELSE 0 END) AS m11,
  SUM(CASE WHEN index = 12 THEN cnt ELSE 0 END) AS m12

FROM 
  cohort_data
GROUP BY 
  cohort_date
ORDER BY 
  cohort_date)
SELECT 
  cohort_date,
  ROUND(100.00 * m1 / m1, 2) || '%' AS m1,
  ROUND(100.00 * m2 / m1, 2) || '%' AS m2,
  ROUND(100.00 * m3 / m1, 2) || '%' AS m3,
  ROUND(100.00 * m4 / m1, 2) || '%' AS m4,
  ROUND(100.00 * m5 / m1, 2) || '%' AS m5,
  ROUND(100.00 * m6 / m1, 2) || '%' AS m6,
  ROUND(100.00 * m7 / m1, 2) || '%' AS m7,
  ROUND(100.00 * m8 / m1, 2) || '%' AS m8,
  ROUND(100.00 * m9 / m1, 2) || '%' AS m9,
  ROUND(100.00 * m10 / m1, 2) || '%' AS m10,
  ROUND(100.00 * m11 / m1, 2) || '%' AS m11,
  ROUND(100.00 * m12 / m1, 2) || '%' AS m12

FROM 
  customer_cohort
ORDER BY 
  cohort_date;


