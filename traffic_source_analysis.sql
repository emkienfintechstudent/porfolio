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












