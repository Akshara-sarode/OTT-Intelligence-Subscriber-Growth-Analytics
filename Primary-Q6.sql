-- Q6. Inactivity Correlation

-- How do inactivity patterns correlate with total watch time or average watch time?
-- Are less engaged users more likely to become inactive?

-- Part 1 - AVERAGE WATCH TIME — ACTIVE vs INACTIVE USERS

select
	user_status,
	sum(case when platform = 'jotstar' 
		then avg_watchtime else 0 end)
		as jotstar_avg_watchtime,
	sum(case when platform = 'liocinema' 
		then avg_watchtime else 0 end)
		as liocinema_avg_watchtime
from
	(select 
		'jotstar' as platform,
		case when js.last_active_date is null then 'Active User'
		else 'Inactive User' end user_status,
		round(avg(jc.total_watch_time_mins)/60.0,2) as avg_watchtime
	from
		jotstar_db.subscribers js
	join 
		jotstar_db.content_consumption jc on 
		js.user_id = jc.user_id
	group by 2
	
	union all
	
	select 
		'liocinema' as platform,
		case when ls.last_active_date is null then 'Active User'
		else 'Inactive User' end user_status,
		round(avg(lc.total_watch_time_mins)/60.0,2) as avg_watchtime
	from
		liocinema_db.subscribers ls
	join 
		liocinema_db.content_consumption lc on 
		ls.user_id = lc.user_id
	group by 2)
group by 1

-- Part 2 - WATCH TIME BUCKETING (ENGAGEMENT LEVELS)

select 
	watch_time_bucket,
	sum(case when platform = 'jotstar' 
		then users else 0 end)
		as jotstar_users,
	sum(case when platform = 'liocinema' 
		then users else 0 end)
		as liocinema_users
from
	(select 
		'jotstar' as platform,
		case 
			when round(total_user_time/60.0, 2) < 25 then 'Low (<25 hours)'
			when round(total_user_time/60.0, 2) between 25 and 55 then 'Medium (25-55 hours)'
			else 'HIGH (>55 hours)'
			end as watch_time_bucket,
		count(*) as users
	from 
		(
        select user_id, sum(total_watch_time_mins) as total_user_time
        from jotstar_db.content_consumption
        group by user_id
    	) user_level_jotstar
	group by 2
	
	union all
	
	select 
		'liocinema' as platform,
		case 
			when round(total_user_time/60.0, 2) < 25 then 'Low (<25 hours)'
			when round(total_user_time/60.0, 2) between 25 and 55 then 'Medium (25-55 hours)'
			else 'HIGH (>55 hours)'
			end as watch_time_bucket,
		count(*) as users
	from
		(
        select user_id, sum(total_watch_time_mins) as total_user_time
        from liocinema_db.content_consumption
        group by user_id
    	) user_level_lio
	group by 2)
group by 1
order by 2

-- Part 3 - CORREALTION BETWEEN ACTIVE USER AND WATCHTIME

with correlation as (
    select 
        'jotstar' as platform,
        case when s.last_active_date is null 
			then 1 else 0 end as activity_flag,
        c.total_watch_time_mins as watch_time
    from 
		jotstar_db.subscribers s
    join 
		jotstar_db.content_consumption c on 
		s.user_id = c.user_id

    union all

    select 
        'liocinema' as platform,
        case when s.last_active_date is null 
			then 1 else 0 end as activity_flag,
        c.total_watch_time_mins as watch_time
    from 
		liocinema_db.subscribers s
    join 
		liocinema_db.content_consumption c on 
		s.user_id = c.user_id
)
select 
    platform,
    round(corr(activity_flag, watch_time)::numeric, 3) as correlation_score,
    case 
        when corr(activity_flag, watch_time) > 0.6 
			then 'strong positive relationship'
        when corr(activity_flag, watch_time) between 0.3 and 0.6 
			then 'moderate positive relationship'
        when corr(activity_flag, watch_time) between -0.3 and 0.3 
			then 'weak or no relationship'
        else 'negative relationship'
    end as active_watch_relation
from 
	correlation
group by 1