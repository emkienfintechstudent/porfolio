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

