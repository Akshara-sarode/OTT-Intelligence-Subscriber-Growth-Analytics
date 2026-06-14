-- Q1. Total Users & Growth Trends

-- What is the total number of users for LioCinema and Jotstar,
-- and how do they compare in terms of growth trends 
-- (January–November 2024)?

-- Part 1 - TOTAL USERS FOR BOTH PLATFORMS

select 
	'Liocinema' as platform,
	count(distinct user_id) as Total_users 
from liocinema_db.subscribers 

Union all 

select 
	'Jotstar' as platform,
	count(distinct user_id) as Total_users 
from jotstar_db.subscribers 

-- Part 2 - MONTH-WISE USER ACQUISITION

select 
    j.month,
    j.users as jotstar_users,
    l.users as liocinema_users
from 
(
    select extract('month' from subscription_date) as month, count(*) as users
    from jotstar_db.subscribers group by month
) as j
join 
(
    select extract('month' from subscription_date) as month, count(*) as users
    from liocinema_db.subscribers group by month
) as l 
on 
	j.month = l.month
order by 
	j.month;

-- Part 3 - MONTHLY USER GROWTH RATE(%)

with jotstar_growth as (
    select 
        extract('month' from subscription_date) as month,
        count(*) as users,
        lag(count(*)) over (order by extract('month' from subscription_date)) as prev_users
    from jotstar_db.subscribers
    group by month
),
liocinema_growth as (
    select 
        extract('month' from subscription_date) as month,
        count(*) as users,
        lag(count(*)) over (order by extract('month' from subscription_date)) as prev_users
    from liocinema_db.subscribers

    group by month
)

select 
    j.month,
    round((j.users - j.prev_users) * 100.0 / j.prev_users, 2) as jotstar_growth_pct,
    round((l.users - l.prev_users) * 100.0 / l.prev_users, 2) as liocinema_growth_pct
from jotstar_growth j
join liocinema_growth l on j.month = l.month
where j.prev_users is not null and l.prev_users is not null
order by j.month