-- Q9. Paid Users Distribution

-- How does the paid user percentage(Basic, Premium for LioCinema and
-- VIP, Premium for Jotstar)vary across different platforms?
-- Analyse the proportion of premium users in Tier 1, Tier 2, and Tier 3 cities
-- and identify any notable trends or differences.

-- Part 1 - PAID USER PERCENTAGE ACROSS BOTH PLATFORMS

with platform_paid_user as (
    select 
        'jotstar' as platform,
        sum(case when subscription_plan in ('VIP', 'Premium') 
			then 1 else 0 end) as paid_users,
        count(*) as total_users
    from 
		jotstar_db.subscribers
    
    union all
    
    select 
        'liocinema' as platform,
        sum(case when subscription_plan in ('Basic', 'Premium') 
			then 1 else 0 end) as paid_users,
        count(*) as total_users
    from 
		liocinema_db.subscribers
)
select 
    platform,
    paid_users,
    total_users,
    round(paid_users * 100.0 / total_users, 2) as paid_user_percentage
from 
	platform_paid_user

-- Part 2 -  Premium Proportion by City Tier

with premium_city_stats as (
	select 
		city_tier,
		'jotstar' as platform,
		sum(
			case when subscription_plan in ('Premium') 
				then 1 else 0 end
		) as premium_users,
		count(*) as total_users
	from
		jotstar_db.subscribers
	group by 1

	union all

	select 
		city_tier,
		'liocinema' as platform,
		sum(
			case when subscription_plan in ('Premium') 
				then 1 else 0 end
		) as premium_users,
		count(*) as total_users
	from
		liocinema_db.subscribers
	group by 1
)
select 
	city_tier,
	sum(case when platform ='jotstar' 
		then premium_users else 0 end) 
		as jotstar_premium_users,
	sum(case when platform ='jotstar' 
		then total_users else 0 end) 
		as jotstar_total_users,
	sum(case when platform ='liocinema' 
		then premium_users else 0 end) 
		as liocinema_premium_users,
	sum(case when platform ='liocinema' 
		then total_users else 0 end) 
		as liocinema_total_users,
	round(
        sum(case when platform = 'jotstar' then premium_users else 0 end) * 100.0 / 
        nullif(sum(case when platform = 'jotstar' then total_users else 0 end), 0), 2
    ) as jotstar_premium_percent,
    round(
        sum(case when platform = 'liocinema' then premium_users else 0 end) * 100.0 / 
        nullif(sum(case when platform = 'liocinema' then total_users else 0 end), 0), 2
    ) as liocinema_premium_percent
from
	premium_city_stats
group by 1