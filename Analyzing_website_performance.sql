-- Hi there! 
-- Would you be able to pull a list of the top entry pages? I 
-- want to confirm where our users are hitting the site. 
-- If you could pull all entry pages and rank them on entry 
-- volume, that would be great.
-- Thanks! 
-- -Morgan

create temporary table fist_page_view 
select website_session_id, min(website_pageview_id) as min_pv_id from website_pageviews
group by website_session_id

select pageview_url, count(*) as sessions from website_pageviews ws join fist_page_view  fpv on ws.website_session_id = fpv.website_session_id
where created_at < '2012-06-12'
group by pageview_url
order by sessions desc 

-- Hi there! 
-- The other day you showed us that all of our traffic is landing 
-- on the homepage right now. We should check how that 
-- landing page is performing. 
-- Can you pull bounce rates for traffic landing on the 
-- homepage? I would like to see three numbers…Sessions, 
-- Bounced Sessions, and % of Sessions which Bounced 
-- (aka “Bounce Rate”).
-- Thanks! 
-- -Morgan


use mavenfuzzyfactory

create temporary table fist_page_view 
select website_session_id, min(website_pageview_id) as min_pv_id from website_pageviews
group by website_session_id 
create temporary table session_w_home_landing_page 
select fpv.website_session_id, pageview_url as landing_page from fist_page_view fpv join website_pageviews wp on fpv.min_pv_id  = wp.website_pageview_id
where pageview_url = '/home'

select a.website_session_id,a.landing_page, count(b.website_session_id) as count_of_page_viewd from session_w_home_landing_page a left join website_pageviews b on a.website_session_id = b.website_session_id 
group by a.website_session_id,a.landing_page
having count_of_page_viewd = 1
-- pending
