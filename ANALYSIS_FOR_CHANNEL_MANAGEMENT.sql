-- Hi there,
-- With gsearch doing well and the site performing better, we 
-- launched a second paid search channel, bsearch, around 
-- August 22.
-- Can you pull weekly trended session volume since then and 
-- compare to gsearch nonbrand so I can get a sense for how 
-- important this will be for the business?
-- Thanks, Tom

select  min(date(created_at)), sum(case when utm_source = 'gsearch' then 1 else 0 end) as gsearch_sessions,
sum(case when utm_source = 'bsearch' then 1 else 0 end) as bsearch_sessions
  from website_sessions
where created_at between '2012-08-22' and '2012-11-29' and utm_campaign ='nonbrand'

group by yearweek(CREATED_AT)


-- Hi there,
-- I’d like to learn more about the bsearch nonbrand campaign. 
-- Could you please pull the percentage of traffic coming on 
-- Mobile, and compare that to gsearch?
-- Feel free to dig around and share anything else you find 
-- interesting. Aggregate data since August 22nd is great, no 
-- need to show trending at this point. 
-- Thanks, Tom


select utm_source, 
count(distinct website_session_id) as sessions, 
sum(case when device_type = 'mobile' then 1 else 0 end) as mobile_sessions,
sum(case when device_type = 'mobile' then 1 else 0 end) /count(distinct website_session_id) as pct_mobile
 from website_sessions
where created_at between '2012-08-22' and '2012-11-30' and (utm_source = 'gsearch' or utm_source ='bsearch')
and utm_campaign = 'nonbrand'
group by utm_source

-- Hi there,
-- I’m wondering if bsearch nonbrand should have the same 
-- bids as gsearch. Could you pull nonbrand conversion rates 
-- from session to order for gsearch and bsearch, and slice the 
-- data by device type?
-- Please analyze data from August 22 to September 18; we 
-- ran a special pre-holiday campaign for gsearch starting on 
-- September 19th, so the data after that isn’t fair game.
-- Thanks, Tom


select ws.device_type, ws.utm_source, 
count(distinct ws.website_session_id) as sessions,
count(distinct o.order_id) as orders,
count(distinct o.order_id)/count(distinct ws.website_session_id) as conv_rate
 from website_sessions as ws left join orders o on ws.website_session_id = o.website_session_id
where ws.created_at between '2012-08-22' and  '2012-09-18'  and (utm_source = 'gsearch' or utm_source ='bsearch')
and utm_campaign = 'nonbrand'
group by ws.device_type, ws.utm_source

-- Hi there,
-- Based on your last analysis, we bid down bsearch nonbrand on 
-- December 2nd.
-- Can you pull weekly session volume for gsearch and bsearch 
-- nonbrand, broken down by device, since November 4th?
-- If you can include a comparison metric to show bsearch as a 
-- percent of gsearch for each device, that would be great too. 
-- Thanks, Tom


SELECT 
    MIN(DATE(created_at)),
    SUM(CASE
        WHEN
            utm_source = 'gsearch'
                AND device_type = 'desktop'
        THEN
            1
        ELSE 0
    END) AS g_dtop_sessions,
    SUM(CASE
        WHEN
            utm_source = 'bsearch'
                AND device_type = 'desktop'
        THEN
            1
        ELSE 0
    END) AS b_dtop_sessions,
    SUM(CASE
        WHEN
            utm_source = 'bsearch'
                AND device_type = 'desktop'
        THEN
            1
        ELSE 0
    END) / SUM(CASE
        WHEN
            utm_source = 'gsearch'
                AND device_type = 'desktop'
        THEN
            1
        ELSE 0
    END) AS b_pct_of_g_dtop,
    SUM(CASE
        WHEN
            utm_source = 'gsearch'
                AND device_type = 'mobile'
        THEN
            1
        ELSE 0
    END) AS g_mob_sessions,
    SUM(CASE
        WHEN
            utm_source = 'bsearch'
                AND device_type = 'mobile'
        THEN
            1
        ELSE 0
    END) AS b_mob_sessions,
    SUM(CASE
        WHEN
            utm_source = 'bsearch'
                AND device_type = 'mobile'
        THEN
            1
        ELSE 0
    END) / SUM(CASE
        WHEN
            utm_source = 'gsearch'
                AND device_type = 'mobile'
        THEN
            1
        ELSE 0
    END) AS b_pct_of_g_mob
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-11-04' AND '2012-12-22'
        AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(CREATED_AT)

--   Good morning,
-- A potential investor is asking if we’re building any 
-- momentum with our brand or if we’ll need to keep relying 
-- on paid traffic.
-- Could you pull organic search, direct type in, and paid 
-- brand search sessions by month, and show those sessions 
-- as a % of paid search nonbrand?
-- -Cindy

  
select year(created_at) as yr, month(created_at) as mo , 
sum(case when utm_campaign ='nonbrand' then 1 else 0 end) as nonbrand,
sum(case when utm_campaign ='brand' then 1 else 0 end) as brand,
sum(case when utm_campaign ='brand' then 1 else 0 end)/sum(case when utm_campaign ='nonbrand' then 1 else 0 end) brand_cpt_of_nonbrand,
sum(case when http_referer is null then 1 else 0 end) direct,
sum(case when http_referer is null then 1 else 0 end)/sum(case when utm_campaign ='nonbrand' then 1 else 0 end) direct_pct_of_nonbrand,
sum(case when http_referer in ('https://www.gsearch.com','https://www.bsearch.com') and utm_source is null then 1 else 0 end) organic,
sum(case when http_referer in ('https://www.gsearch.com','https://www.bsearch.com') and utm_source is null then 1 else 0 end)/sum(case when utm_campaign ='nonbrand' then 1 else 0 end) as organic_pct_of_non_brand
from website_sessions
where created_at <'2012-12-23'
group by 1,2

