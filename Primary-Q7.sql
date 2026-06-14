-- Q7. Downgrade Trends

-- How do downgrade trends differ between LioCinema and Jotstar?
-- Are downgrades more prevalent on one platform compared to the other?

-- Part 1 - OVERALL DOWNGRADED USERS & RATE FOR BOTH PLATFOMRS

select 
	'jotstar' as platform,
	count(*) as downgraded_users,
	(round(count(*) * 100.0/(select count(*) from jotstar_db.subscribers),2))
	as downgraded_rate
from jotstar_db.subscribers
where (subscription_plan ='Premium' and new_subscription_plan in ('VIP','Free'))
	or (subscription_plan = 'VIP' and new_subscription_plan = 'Free')

union all

select 
	'liocinema' as platform,
	count(*) as users,
	(round(count(*) * 100.0/(select count(*) from liocinema_db.subscribers),2))
	as downgraded_rate
from liocinema_db.subscribers
where (subscription_plan ='Premium' and new_subscription_plan in ('Basic','Free'))
	or (subscription_plan = 'Basic' and new_subscription_plan = 'Free')


-- PART 2 -  DOWNGRADES BY ORIGINAL PLAN FOR BOTH PLATFORMS

with downgrade_jotstar as (
	select 
		'jotstar' as platform,
		subscription_plan as old_plan,
		new_subscription_plan as new_plan,
		count(*) as downgraded_users
	from 
		jotstar_db.subscribers
	where (subscription_plan ='Premium' and new_subscription_plan in ('VIP','Free'))
		or (subscription_plan = 'VIP' and new_subscription_plan = 'Free')
	group by 2,3),
	
downgrade_liocinema as (
	select 
		'liocinema' as platform,
		subscription_plan as old_plan,
		new_subscription_plan as new_plan,
		count(*) as downgraded_users
	from 
		liocinema_db.subscribers
	where (subscription_plan ='Premium' and new_subscription_plan in ('Basic','Free'))
		or (subscription_plan = 'Basic' and new_subscription_plan = 'Free')
	group by 2,3)
(	
select 
	platform,
	old_plan,
	new_plan,
	downgraded_users,
	(round(downgraded_users * 100.0/sum(downgraded_users) over(),2))
	as downgraded_rate
from
	downgrade_jotstar 
group by 
	1,2,3,4)

union all

(select 
	platform,
	old_plan,
	new_plan,
	downgraded_users,
	(round(downgraded_users * 100.0/sum(downgraded_users) over(),2))
	as downgraded_rate
from
	downgrade_liocinema
group by 
	1,2,3,4)
	
order by 
	downgraded_users desc

-- PART 3 -  DOWNGRADES BY AGE_GROUP

select 
	age_group,
	sum(case when platform = 'jotstar' 
		then downgraded_users else 0 end)
		as jotstar_downgraded_users,
	sum(case when platform = 'liocinema' 
		then downgraded_users else 0 end)
		as liocinema_downgraded_users,
	round(
        sum(case when platform = 'jotstar' then downgraded_users else 0 end) * 100.0 / 
        nullif(sum(case when platform = 'jotstar' then total_users else 0 end), 0), 2
    ) as jotstar_downgrade_rate,
    round(
        sum(case when platform = 'liocinema' then downgraded_users else 0 end) * 100.0 / 
        nullif(sum(case when platform = 'liocinema' then total_users else 0 end), 0), 2
    ) as liocinema_downgrade_rate
from
	(select 
		'jotstar' as platform,
		age_group,
		count(*) as total_users,
		count(*) filter (where 
		(subscription_plan ='Premium' and new_subscription_plan in ('VIP','Free'))
		or (subscription_plan = 'VIP' and new_subscription_plan = 'Free')) 
		as downgraded_users
	from 
		jotstar_db.subscribers
	group by 2
	
	union all
	
	select 
		'liocinema' as platform,
		age_group,
		count(*) as total_users,
		count(*) filter (where 
		(subscription_plan ='Premium' and new_subscription_plan in ('Basic','Free'))
		or (subscription_plan = 'Basic' and new_subscription_plan = 'Free')) 
		as downgraded_users
	from 
		liocinema_db.subscribers
	group by 2)
group by 1


-- PART 4 -  DOWNGRADES BY CITY-TIER

select 
	city_tier,
	sum(case when platform = 'jotstar' 
		then downgraded_users else 0 end)
		as jotstar_downgraded_users,
	sum(case when platform = 'liocinema' 
		then downgraded_users else 0 end)
		as liocinema_downgraded_users,
	round(
        sum(case when platform = 'jotstar' then downgraded_users else 0 end) * 100.0 / 
        nullif(sum(case when platform = 'jotstar' then total_users else 0 end), 0), 2
    ) as jotstar_downgrade_rate,
    round(
        sum(case when platform = 'liocinema' then downgraded_users else 0 end) * 100.0 / 
        nullif(sum(case when platform = 'liocinema' then total_users else 0 end), 0), 2
    ) as liocinema_downgrade_rate
from
	(select 
		'jotstar' as platform,
		city_tier,
		count(*) as total_users,
		count(*) filter (where 
		(subscription_plan ='Premium' and new_subscription_plan in ('VIP','Free'))
		or (subscription_plan = 'VIP' and new_subscription_plan = 'Free')) 
		as downgraded_users
	from 
		jotstar_db.subscribers
	group by 2
	
	union all
	
	select 
		'liocinema' as platform,
		city_tier,
		count(*) as total_users,
		count(*) filter (where 
		(subscription_plan ='Premium' and new_subscription_plan in ('Basic','Free'))
		or (subscription_plan = 'Basic' and new_subscription_plan = 'Free')) 
		as downgraded_users
	from 
		liocinema_db.subscribers
	group by 2)
group by 1
