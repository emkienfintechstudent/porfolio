--------- CREATE TABLE --------- 
create table ecommerce(
	InvoiceNo varchar,
	StockCode varchar,
	description varchar,
	Quantity int,
	InvoiceDate timestamp,
	UnitPrice numeric,
	customerID int, 
	Country varchar
)

--------- DATA CLEANING  --------- 
  
-- check dataset if there are any returned products
select * from ecommerce
where quantity < 0
-- Duplicate check
with cte as (
select *, row_number() over(partition by invoiceno,stockcode, invoicedate, quantity) as dup_check from ecommerce	
),
-- data table without returned products, null customerid, and duplicate. Convert invoicedate into date format 
 clean_data as(
	select invoiceno,stockcode,description, cast(invoicedate as date), quantity,unitprice, customerid, country from cte
	 where quantity > 0 and customerid is not null and dup_check =1
)

--------- RFM ANALYSIS  --------- 
WITH cte AS (
    -- Tạo CTE để đánh dấu các bản sao của dữ liệu dựa trên invoiceno, stockcode, invoicedate và quantity
    -- Mỗi bản sao sẽ được gán một số thứ tự duy nhất trong nhóm
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY invoiceno, stockcode, invoicedate, quantity) AS dup_check 
    FROM ecommerce
),

-- Xóa các đơn hàng trả lại, khách hàng bị null, và các bản sao. Chuyển đổi invoicedate sang định dạng ngày
clean_data AS (
    SELECT invoiceno, stockcode, description, CAST(invoicedate AS date) AS invoicedate, 
           quantity, unitprice, customerid, country 
    FROM cte
    WHERE quantity > 0   -- Chỉ giữ các đơn hàng có số lượng lớn hơn 0
      AND customerid IS NOT NULL  -- Chỉ giữ các đơn hàng có customerid không bị null
      AND dup_check = 1   -- Chỉ giữ các bản sao đầu tiên trong nhóm
),	

cte2 AS (
    -- Tính toán các chỉ số R, F, M cho từng khách hàng
    -- R: Số ngày kể từ lần mua hàng gần nhất cho đến ngày 2011-12-10
    -- F: Số lượng đơn hàng khác nhau
    -- M: Tổng giá trị đơn hàng (quantity * unitprice)
    SELECT customerid, 
           MAX(invoicedate) AS last_date_active, 
           '2011-12-10'::date - MAX(invoicedate)::date AS R,
           COUNT(DISTINCT invoiceno) AS F,
           SUM(quantity * unitprice) AS M
    FROM clean_data
    GROUP BY customerid
),

rfm_score AS (
    -- Phân loại khách hàng thành 4 nhóm cho mỗi chỉ số R, F, M sử dụng hàm ntile
    -- R_score: Điểm phân loại theo mức độ gần đây của hành vi mua hàng (R), cao nhất là 1
    -- F_score: Điểm phân loại theo số lượng đơn hàng (F), thấp nhất là 1
    -- M_score: Điểm phân loại theo tổng giá trị đơn hàng (M), thấp nhất là 1
    SELECT customerid, 
           ntile(4) OVER (ORDER BY R DESC) AS R_score, 
           ntile(4) OVER (ORDER BY F) AS F_score, 
           ntile(4) OVER (ORDER BY M) AS M_score
    FROM cte2
),

rfm_final AS (
    -- Tạo điểm RFM tổng hợp cho từng khách hàng bằng cách kết hợp R_score, F_score, và M_score
    SELECT customerid,
           CAST(R_score AS varchar) || CAST(F_score AS varchar) || CAST(M_score AS varchar) AS rfm_score
    FROM rfm_score
)

-- Kết hợp điểm RFM với phân khúc khách hàng từ bảng segment_score
SELECT customerid, rfm_score, b.segment 
FROM rfm_final AS a 
JOIN segment_score AS b ON a.rfm_score = b.scores

