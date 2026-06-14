set search_path to liocinema_db

select * from content_consumption

select * from contents

select * from subscribers

-- Studying all the KPIs for Jotstar Platform

-- 1. Total Content Items

select count(content_id) as total_contents from contents

-- 2. Total users

select count(user_id) as total_user from subscribers

-- 3. Paid Users

select count(user_id) as paid_users from subscribers
where subscription_plan IN ('Basic', 'Premium')

-- 4. Paid Users(%)

select round(
	count(
		case when subscription_plan IN ('Basic', 'Premium') then 1 end
	) * 100.00/count(*) , 2
) as paid_user_percent
from subscribers

-- 5. Active Users

select count(*) as active_users from subscribers
where last_active_date is null

-- 6. Inactive Users

select count(*) as inactive_users from subscribers
where last_active_date is not null

-- 7. Inactive Rate

select round(
	count(
		case when last_active_date is not null then 1 end
	) * 100.0/count(*)
) as inactive_rate
from subscribers

-- 8. Active Rate

select round(
	count(
		case when last_active_date is null then 1 end
	) * 100.0/count(*)
) as active_rate
from subscribers

-- 9. Upgraded Users

select count(*) as upgraded_user from subscribers
where (subscription_plan = 'Free' AND new_subscription_plan IN ('Basic','Premium'))
OR (subscription_plan = 'Basic' AND new_subscription_plan = 'Premium');

-- 10. Upgrade Rate(%)

select
	round(
		count(case when (subscription_plan = 'Free' 
						AND new_subscription_plan IN ('VIP','Premium')
						)
						OR 
						(subscription_plan = 'VIP' 
						AND new_subscription_plan = 'Premium'
						) then 1 end
						) * 100.0/count(*) , 2
	) as upgrade_rate_percent
from subscribers

-- 11. Downgraded Users

select count(*) as downgraded_users from subscribers
where (subscription_plan = 'Premium' and new_subscription_plan in ('Free','Basic'))
or (subscription_plan = 'Basic' and new_subscription_plan ='Free')

-- 12. Downgraded Rate(%)

select
	round(
		count(case when (subscription_plan = 'Premium' 
						AND new_subscription_plan IN ('VIP','Free')
						)
						OR 
						(subscription_plan = 'VIP' 
						AND new_subscription_plan = 'Free'
						) then 1 end
						) * 100.0/count(*) , 2
	) as downgrade_rate_percent
from subscribers

-- 13. Total watch time in hours

select
	round(
		sum(
			total_watch_time_mins
		)/60.0, 2
	) as total_watch_time_hours
from content_consumption

-- 14. Average watch time in hours

select
	round(
		avg(
			total_watch_time_mins
		)/60.0, 2
	) as avg_watch_time_hours
from content_consumption

-- 15. Monthly users Growth Rate(%)

with MonthlyUsers as (
	select 
		extract ('month' from subscription_date) as months,
		count(*) as no_of_users
	from 
		subscribers
	group by 
		months
),
growth as (
select
	months,
	no_of_users,
	lag(no_of_users) over(order by months) as prev_users
from
	MonthlyUsers
)
select 
months,
round((no_of_users - prev_users) * 100.0 / prev_users, 2) AS growth_rate_percent
from growth
where prev_users is not null

-- 16. Upgrade / Downgrade Rate (%)

select
round(
    count(case when new_subscription_plan is not null then 1 end) * 100.0
    / count(*), 2
) as subscription_volatility
from subscribers


