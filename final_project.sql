-- First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter 
-- for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it. 
select year(ws.created_at) as year, quarter(ws.created_at) quarter, count(distinct ws.website_session_id) as sessions,
count(distinct o.order_id) as orders
 from website_sessions as ws left join orders as o 
on ws.website_session_id = o.website_session_id
group by 1,2


-- Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we 
-- launched, for session-to-order conversion rate, revenue per order, and revenue per session. 
select year(ws.created_at) as year, quarter(ws.created_at) quarter, count(distinct ws.website_session_id) as sessions,
count(distinct o.order_id) as orders,
 count(distinct ws.website_session_id)/count(distinct o.order_id) session_to_order_conversion_rate ,
 sum(o.price_usd)/count(distinct o.order_id) as  revenue_per_order,
 sum(o.price_usd)/count(distinct ws.website_session_id) as  revenue_per_session
 from website_sessions as ws left join orders as o 
on ws.website_session_id = o.website_session_id
group by 1,2






-- I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch 
-- nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in? 
--   Next, let’s show the overall session-to-order conversion rate trends for those same channels, by quarter. 
-- Please also make a note of any periods where we made major improvements or optimizations.
select year(ws.created_at) as year, quarter(ws.created_at) quarter,
count(case when utm_source ='gsearch' and utm_campaign ='nonbrand' then o.order_id end )
/count(case when utm_source ='gsearch' and utm_campaign ='nonbrand' then ws.website_session_id end )  as Gsearch_nonbrand_conversion_rate,
count(case when utm_source ='bsearch' and utm_campaign ='nonbrand' then o.order_id end ) /
count(case when utm_source ='bsearch' and utm_campaign ='nonbrand' then ws.website_session_id end ) 
as Bsearch_nonbrand_conversion_rate,
count(case when utm_campaign ='brand' then o.order_id end ) / count(case when utm_campaign ='brand' then ws.website_session_id end ) 
as  Brand_search_overall_conversion_rate,
count(case when http_referer is not null and utm_source is null  then o.order_id end )/
count(case when http_referer is not null and utm_source is null  then ws.website_session_id end )
 as  organic_search_conversion_rate,
count(case when http_referer is  null and utm_source is null  then o.order_id end )/
count(case when http_referer is  null and utm_source is null  then ws.website_session_id end )
 as  direct_type_in_conversion_rate

 from website_sessions as ws left join orders as o 
on ws.website_session_id = o.website_session_id
group by 1,2


/* We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue 
 and margin by product, along with total sales and revenue. Note anything you notice about seasonality.*/
select year(created_at) as year, quarter(created_at) quarter,
sum(case when product_id =1 then price_usd else 0 end) as mrfuzzy_revenue,
sum(case when product_id =1 then price_usd - cogs_usd else 0 end) as mrfuzzy_margin,
sum(case when product_id =2 then price_usd else 0 end) as love_bear_revenue,
sum(case when product_id =2 then price_usd - cogs_usd else 0 end) as love_bear_margin,
sum(case when product_id =3 then price_usd else 0 end) as birthday_sugar_panda_revenue,
sum(case when product_id =3 then price_usd - cogs_usd else 0 end) as birthday_sugar_panda_margin,
sum(case when product_id =4 then price_usd else 0 end) as mini_bear_revenue,
sum(case when product_id =4 then price_usd - cogs_usd else 0 end) as mini_bear_margin

 from order_items 
group by 1,2




/* Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products 
 page, and show how the % of those sessions clicking through another page has changed over time, along with 
 a view of how conversion from /products to placing an order has improved.*/
 create temporary table product_pageviews
 select website_session_id, website_pageview_id, created_at as saw_product_page_at 
 from website_pageviews
 where pageview_url ='/products';

 select year(saw_product_page_at) year, quarter(saw_product_page_at) quarter,
 count(distinct a.website_session_id) as session_to_product_page,
  count(distinct b.website_session_id) as click_to_next_page,
  count(distinct b.website_session_id)/count(distinct a.website_session_id) as click_through_rate,
  count(distinct o.order_id) as orders,
  count(distinct o.order_id)/ count(distinct a.website_session_id) as product_to_oder_rate
 from product_pageviews a left join website_pageviews b on a.website_session_id=b.website_session_id
 and b.website_pageview_id > a.website_pageview_id
 left join orders o on a.website_session_id=o.website_session_id
 group by 1,2
