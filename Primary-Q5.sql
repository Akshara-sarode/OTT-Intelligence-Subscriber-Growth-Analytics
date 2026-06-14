-- 5. Watch Time Analysis

-- What is the average watch time for LioCinema vs Jotstar during the analysis period?
-- How do these compare by city tier and device type?

-- Part 1 - AVERAGE WATCHTIME FOR BOTH PLATFORMS IN HOURS

select 
	'jotstar' as platform,
	round(sum(total_watch_time_mins)/60.0,2),
	round(avg(total_watch_time_mins)/60.0,2)
from 
	jotstar_db.content_consumption

union all

select 
	'liocinema' as platform,
	round(sum(total_watch_time_mins)/60.0,2),
	round(avg(total_watch_time_mins)/60.0,2)
from 
	liocinema_db.content_consumption

-- Part 2 - AVERAGE WATCHTIME BY DEVICE TYPE

select
	device_type,
	sum(case when platform = 'jotstar' 
		then avg_watchtime else 0 end)
		as jotstar_avg_watchtime,
	sum(case when platform = 'liocinema' 
		then avg_watchtime else 0 end)
		as liocinema_avg_watchtime
from
	(select 
		'jotstar' as platform,
		device_type,
		round(avg(total_watch_time_mins)/60.0,2) as avg_watchtime
	from 
		jotstar_db.content_consumption
	group by 2
	
	union all
	
	select 
		'liocinema' as platform,
		device_type,
		round(avg(total_watch_time_mins)/60.0,2) as avg_watchtime
	from 
		liocinema_db.content_consumption
	group by 2)
group by 1

-- Part 3 - AVERAGE WATCHTIME BY CITY TIER

select
	city_tier,
	sum(case when platform = 'jotstar' 
		then avg_watchtime else 0 end)
		as jotstar_avg_watchtime,
	sum(case when platform = 'liocinema' 
		then avg_watchtime else 0 end)
		as liocinema_avg_watchtime
from
	(select 
		'jotstar' as platform,
		city_tier,
		round(avg(total_watch_time_mins)/60.0,2) as avg_watchtime
	from 
		jotstar_db.content_consumption jc
	join 
		jotstar_db.subscribers js on
		jc.user_id = js.user_id
	group by 2
	
	union all
	
	select 
		'liocinema' as platform,
		city_tier,
		round(avg(total_watch_time_mins)/60.0,2) as avg_watchtime
	from 
		liocinema_db.content_consumption lc
	join 
		liocinema_db.subscribers ls on
		lc.user_id = ls.user_id
	group by 2)
group by 1