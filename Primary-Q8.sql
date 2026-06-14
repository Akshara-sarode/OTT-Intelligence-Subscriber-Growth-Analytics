-- Q8. Upgrade Patterns

-- What are the most common upgrade transitions 
-- (e.g., Free to Basic, Free to VIP, Free to Premium)
-- for LioCinema and Jotstar? How do these differ across platforms?

-- Part 1 - OVERALL UPGRADE USERS & RATE FOR BOTH PLATFOMRS

select 
	'jotstar' as platform,
	count(*) as upgraded_users,
	(round(count(*) * 100.0/(select count(*) from jotstar_db.subscribers),2))
	as upgraded_rate
from jotstar_db.subscribers
where (subscription_plan ='Free' and new_subscription_plan in ('VIP','Premium'))
	or (subscription_plan = 'VIP' and new_subscription_plan = 'Premium')

union all

select 
	'liocinema' as platform,
	count(*) as upgraded_users,
	(round(count(*) * 100.0/(select count(*) from liocinema_db.subscribers),2))
	as upgraded_rate
from liocinema_db.subscribers
where (subscription_plan ='Free' and new_subscription_plan in ('Basic','Premium'))
	or (subscription_plan = 'Basic' and new_subscription_plan = 'Premium')


-- PART 2 -  UPGRADES BY ORIGINAL PLAN FOR BOTH PLATFORMS

with upgrade_jotstar as (
	select 
		'jotstar' as platform,
		subscription_plan as old_plan,
		new_subscription_plan as new_plan,
		count(*) as upgraded_users
	from 
		jotstar_db.subscribers
	where (subscription_plan ='Free' and new_subscription_plan in ('VIP','Premium'))
		or (subscription_plan = 'VIP' and new_subscription_plan = 'Premium')
	group by 2,3),
	
upgrade_liocinema as (
	select 
		'liocinema' as platform,
		subscription_plan as old_plan,
		new_subscription_plan as new_plan,
		count(*) as upgraded_users
	from 
		liocinema_db.subscribers
	where (subscription_plan ='Free' and new_subscription_plan in ('Basic','Premium'))
		or (subscription_plan = 'Basic' and new_subscription_plan = 'Premium')
	group by 2,3)
(	
select 
	platform,
	old_plan,
	new_plan,
	upgraded_users,
	(round(upgraded_users * 100.0/sum(upgraded_users) over(),2))
	as upgraded_rate
from
	upgrade_jotstar 
group by 
	1,2,3,4)

union all

(select 
	platform,
	old_plan,
	new_plan,
	upgraded_users,
	(round(upgraded_users * 100.0/sum(upgraded_users) over(),2))
	as upgraded_rate
from
	upgrade_liocinema
group by 
	1,2,3,4)
	
order by 
	platform,upgraded_rate desc

-- PART 3 -  UPGRADES BY AGE_GROUP

select 
	age_group,
	sum(case when platform = 'jotstar' 
		then upgraded_users else 0 end)
		as jotstar_upgraded_users,
	sum(case when platform = 'liocinema' 
		then upgraded_users else 0 end)
		as liocinema_upgraded_users,
	round(
        sum(case when platform = 'jotstar' then upgraded_users else 0 end) * 100.0 / 
        nullif(sum(case when platform = 'jotstar' then total_users else 0 end), 0), 2
    ) as jotstar_upgrade_rate,
    round(
        sum(case when platform = 'liocinema' then upgraded_users else 0 end) * 100.0 / 
        nullif(sum(case when platform = 'liocinema' then total_users else 0 end), 0), 2
    ) as liocinema_upgrade_rate
from
	(select 
		'jotstar' as platform,
		age_group,
		count(*) as total_users,
		count(*) filter (where 
		(subscription_plan ='Free' and new_subscription_plan in ('VIP','Premium'))
		or (subscription_plan = 'VIP' and new_subscription_plan = 'Premium')) 
		as upgraded_users
	from 
		jotstar_db.subscribers
	group by 2
	
	union all
	
	select 
		'liocinema' as platform,
		age_group,
		count(*) as total_users,
		count(*) filter (where 
		(subscription_plan ='Free' and new_subscription_plan in ('Basic','Premium'))
		or (subscription_plan = 'Basic' and new_subscription_plan = 'Premium')) 
		as upgraded_users
	from 
		liocinema_db.subscribers
	group by 2)
group by 1


-- PART 4 -  UPGRADES BY CITY-TIER

select 
	city_tier,
	sum(case when platform = 'jotstar' 
		then upgraded_users else 0 end)
		as jotstar_upgraded_users,
	sum(case when platform = 'liocinema' 
		then upgraded_users else 0 end)
		as liocinema_upgraded_users,
	round(
        sum(case when platform = 'jotstar' then upgraded_users else 0 end) * 100.0 / 
        nullif(sum(case when platform = 'jotstar' then total_users else 0 end), 0), 2
    ) as jotstar_upgrade_rate,
    round(
        sum(case when platform = 'liocinema' then upgraded_users else 0 end) * 100.0 / 
        nullif(sum(case when platform = 'liocinema' then total_users else 0 end), 0), 2
    ) as liocinema_upgrade_rate
from
	(select 
		'jotstar' as platform,
		city_tier,
		count(*) as total_users,
		count(*) filter (where 
		(subscription_plan ='Free' and new_subscription_plan in ('VIP','Premium'))
		or (subscription_plan = 'VIP' and new_subscription_plan = 'Premium')) 
		as upgraded_users
	from 
		jotstar_db.subscribers
	group by 2
	
	union all
	
	select 
		'liocinema' as platform,
		city_tier,
		count(*) as total_users,
		count(*) filter (where 
		(subscription_plan ='Free' and new_subscription_plan in ('Basic','Premium'))
		or (subscription_plan = 'Basic' and new_subscription_plan = 'Premium')) 
		as upgraded_users
	from 
		liocinema_db.subscribers
	group by 2)
group by 1
