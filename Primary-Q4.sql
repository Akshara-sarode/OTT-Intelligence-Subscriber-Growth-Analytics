-- Q4. Active vs. Inactive Users

-- What percentage of LioCinema and Jotstar users are active vs inactive?
-- How do these rates vary by age group and subscription plan?

-- PART 1 - ACTIVE vs INACTIVE USERS FOR BOTH PLATFORMS
with user_activity as (
select
	'jotstar' as platform,
	count(*) filter (where last_active_date is null) as active_users,
	count(*) filter (where last_active_date is not null) as inactive_users,
	count(*) as total_users
from 
	jotstar_db.subscribers

union all

select
	'liocinema' as platform,
	count(*) filter (where last_active_date is null) as active_users,
	count(*) filter (where last_active_date is not null) as inactive_users,
	count(*) as total_users
from 
	liocinema_db.subscribers
)
select 
	platform,
	active_users,
	inactive_users,
	round(
		(active_users * 100.0)/total_users, 2 
	) as active_rate
from
	user_activity

-- PART 2 - ACTIVE vs INACTIVE USERS BY AGE GROUP

with user_activity_age_group as(
	select
		age_group,
		sum(case when platform = 'jotstar' then active_users else 0 end) 
		as jotstar_active_users,
		sum(case when platform = 'jotstar' then inactive_users else 0 end) 
		as jotstar_inactive_users,
		sum(case when platform = 'liocinema' then active_users else 0 end) 
		as liocinema_active_users,
		sum(case when platform = 'liocinema' then inactive_users else 0 end) 
		as liocinema_inactive_users,
		sum(total_users) as total_users
	from 
		(select
			'jotstar' as platform,
			age_group,
			count(*) filter (where last_active_date is null) as active_users,
			count(*) filter (where last_active_date is not null) as inactive_users,
			count(*) as total_users
		from 
			jotstar_db.subscribers
		group by 
			2
			
		union all
		
		select
			'liocinema' as platform,
			age_group,
			count(*) filter (where last_active_date is null) as active_users,
			count(*) filter (where last_active_date is not null) as inactive_users,
			count(*) as total_users
		from 
			liocinema_db.subscribers
		group by 
			2)
	group by 1
)
select 
	age_group,
	jotstar_active_users,
	jotstar_inactive_users,
	round(
		(jotstar_active_users * 100.0)/(jotstar_active_users + jotstar_inactive_users), 2 
	) as jotstar_active_rate,
	liocinema_active_users,
	liocinema_inactive_users,
	round(
		(liocinema_active_users * 100.0)/(liocinema_active_users + liocinema_inactive_users), 2 
	) as liocinema_active_rate
from
	user_activity_age_group

-- Part 3 - ACTIVE vs INACTIVE USERS BY SUBSCRIPTION PLAN

with user_activity_subscription_plan as(
	select
		subscription_plan,
		sum(case when platform = 'jotstar' then active_users else 0 end) 
		as jotstar_active_users,
		sum(case when platform = 'jotstar' then inactive_users else 0 end) 
		as jotstar_inactive_users,
		sum(case when platform = 'liocinema' then active_users else 0 end) 
		as liocinema_active_users,
		sum(case when platform = 'liocinema' then inactive_users else 0 end) 
		as liocinema_inactive_users,
		sum(total_users) as total_users
	from 
		(select
			'jotstar' as platform,
			subscription_plan,
			count(*) filter (where last_active_date is null) as active_users,
			count(*) filter (where last_active_date is not null) as inactive_users,
			count(*) as total_users
		from 
			jotstar_db.subscribers
		group by 
			2
			
		union all
		
		select
			'liocinema' as platform,
			subscription_plan,
			count(*) filter (where last_active_date is null) as active_users,
			count(*) filter (where last_active_date is not null) as inactive_users,
			count(*) as total_users
		from 
			liocinema_db.subscribers
		group by 
			2)
	group by 1
)
select 
	subscription_plan,
	jotstar_active_users,
	jotstar_inactive_users,
	round(
		(jotstar_active_users * 100.0)/nullif((jotstar_active_users + jotstar_inactive_users),0), 2 
	) as jotstar_active_rate,
	liocinema_active_users,
	liocinema_inactive_users,
	round(
		(liocinema_active_users * 100.0)/nullif((liocinema_active_users + liocinema_inactive_users),0), 2 
	) as liocinema_active_rate
from
	user_activity_subscription_plan