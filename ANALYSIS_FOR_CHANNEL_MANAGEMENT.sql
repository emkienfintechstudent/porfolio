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



