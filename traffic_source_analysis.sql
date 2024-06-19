----------------------------------------1-----------------------------------------------------
-- Good morning,
-- We've been live for almost a month now and we’re 
-- starting to generate sales. Can you help me understand 
-- where the bulk of our website sessions are coming 
-- from, through yesterday?
-- I’d like to see a breakdown by UTM source, campaign
-- and referring domain if possible. Thanks!

select utm_source,utm_campaign,http_referer, count(*) as sessions from website_sessions
where created_at <  '2012-04-12'
group by utm_source,utm_campaign,http_referer
order by sessions desc

----------------------------------------2-----------------------------------------------------
-- Hi there,
-- Sounds like gsearch nonbrand is our major traffic source, but 
-- we need to understand if those sessions are driving sales.
-- Could you please calculate the conversion rate (CVR) from 
-- session to order? Based on what we're paying for clicks, 
-- we’ll need a CVR of at least 4% to make the numbers work. 
-- If we're much lower, we’ll need to reduce bids. If we’re 
-- higher, we can increase bids to drive more volume.
-- Thanks, Tom
select   count(ws.website_session_id) as sessions, count(o.website_session_id) as orders,count(o.website_session_id)/count(ws.website_session_id) as session_to_oder_conv_rate  from website_sessions ws  left join orders o 
on ws.website_session_id = o.website_session_id
where ws.created_at <  '2012-04-14' and utm_source='gsearch' and utm_campaign = 'nonbrand'
group by ws.utm_source,ws.utm_campaign,ws.http_referer
order by sessions desc

----------------------------------------3-----------------------------------------------------
-- Hi there,
-- Based on your conversion rate analysis, we bid down 
-- gsearch nonbrand on 2012-04-15. 
-- Can you pull gsearch nonbrand trended session volume, by 
-- week, to see if the bid changes have caused volume to drop 
-- at all?
-- Thanks, Tom
select  min(date(created_at)) as start_of_week, count(distinct website_session_id) from website_sessions
where utm_source = 'gsearch' and utm_campaign = 'nonbrand' and  created_at < '2012-05-12'
group by yearweek(created_at)

----------------------------------------4-----------------------------------------------------
--   Hi there,
-- I was trying to use our site on my mobile device the other 
-- day, and the experience was not great. 
-- Could you pull conversion rates from session to order, by 
-- device type? 
-- If desktop performance is better than on mobile we may be 
-- able to bid up for desktop specifically to get more volume?
-- Thanks, Tom
select ws.device_type, count(distinct ws.website_session_id), count(distinct o.order_id) as orders,count(distinct o.order_id)/ count(distinct ws.website_session_id) from website_sessions ws left join orders o on ws.website_session_id = o.website_session_id 
where ws.utm_source = 'gsearch' and ws.utm_campaign = 'nonbrand' and  ws.created_at < '2012-05-12'
group by device_type

----------------------------------------5-----------------------------------------------------
-- Hi there,
-- After your device-level analysis of conversion rates, we 
-- realized desktop was doing well, so we bid our gsearch 
-- nonbrand desktop campaigns up on 2012-05-19. 
-- Could you pull weekly trends for both desktop and mobile 
-- so we can see the impact on volume? 
-- You can use 2012-04-15 until the bid change as a baseline.
-- Thanks, Tom

select  min(date(created_at)) as start_of_week, 
sum(case when device_type = 'desktop' then 1 else 0 end) as dtop_sessions ,
sum(case when device_type = 'mobile' then 1 else 0 end) as mob_sessions 
 from website_sessions
where utm_source = 'gsearch' and utm_campaign = 'nonbrand' and  created_at  between '2012-04-15' and '2012-06-09'
group by yearweek(created_at)


