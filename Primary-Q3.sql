-- Q3. User Demographics

-- What is the distribution of users by age group,
-- city tier, and subscription plan for each platform?

-- Part 1 - AGE GROUP DISTRIBUTION

select
	age_group,
	sum(case when platform = 'jotstar'
		then users else 0 end)
		as jotstar_users,
	sum(case when platform = 'liocinema'
		then users else 0 end)
		as liocinema_users
from 
	(select
		'jotstar' as platform,
		age_group,
		count(*) as users
	from
		jotstar_db.subscribers
	group by 
		2
	
	union all
	
	select
		'liocinema' as platform,
		age_group,
		count(*) as users
	from
		liocinema_db.subscribers
	group by 
		2)
group by 1
order by 
	age_group

-- Part 2 - CITY TIER DISTRIBUTION

select
	city_tier,
	sum(case when platform = 'jotstar'
		then users else 0 end)
		as jotstar_users,
	sum(case when platform = 'liocinema'
		then users else 0 end)
		as liocinema_users
from 
	(select
		'jotstar' as platform,
		city_tier,
		count(*) as users
	from
		jotstar_db.subscribers
	group by 
		2
	
	union all
	
	select
		'liocinema' as platform,
		city_tier,
		count(*) as users
	from
		liocinema_db.subscribers
	group by 
		2)
group by 1

-- PART 3 - SUBSCRIPTION PLAN DISTRIBUTION

select
	subscription_plan,
	sum(case when platform = 'jotstar'
		then users else 0 end)
		as jotstar_users,
	sum(case when platform = 'liocinema'
		then users else 0 end)
		as liocinema_users
from 
	(select
		'jotstar' as platform,
		subscription_plan,
		count(*) as users
	from
		jotstar_db.subscribers
	group by 
		2
	
	union all
	
	select
		'liocinema' as platform,
		subscription_plan,
		count(*) as users
	from
		liocinema_db.subscribers
	group by 
		2)
group by 1

-- PART 4 - SUBSCRIPTION x AGE GROUP PLAN DISTRIBUTION

select
	subscription_plan,
	age_group,
	sum(case when platform = 'jotstar'
		then users else 0 end)
		as jotstar_users,
	sum(case when platform = 'liocinema'
		then users else 0 end)
		as liocinema_users
from 
	(select
		'jotstar' as platform,
		subscription_plan,
		age_group,
		count(*) as users
	from
		jotstar_db.subscribers
	group by 
		2,3
	
	union all
	
	select
		'liocinema' as platform,
		subscription_plan,
		age_group,
		count(*) as users
	from
		liocinema_db.subscribers
	group by 
		2,3)
group by 1,2