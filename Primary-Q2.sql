-- Q2. Content Library Comparison

-- What is the total number of contents available on LioCinema vs. Jotstar?
-- How do they differ in terms of language and content type?

-- Part 1 - TOTAL CONTENTS FOR BOTH PLATFORMS
(select 
	'liocinema' as platform,
	count(distinct content_id) as total_contents
from
	liocinema_db.contents
group by 
	platform)
union all
(select 
	'jotstar' as platform,
	count(distinct content_id) as total_contents
from
	jotstar_db.contents
group by 
	platform

-- Part 2 - CONTENT TYPE SPLIT (Movies vs Series vs Sports)

select 
    content_type,
    sum(case when platform = 'jotstar'
		then content_count else 0 end) 
		as jotstar_count,
    sum(case when platform = 'liocinema' 
		then content_count else 0 end) 
		as liocinema_count
from (
    select 
		'jotstar' as platform, 
		content_type, 
		count(*) content_count
    from 
		jotstar_db.contents 
	group by 2
	
    union all
	
    select 
		'liocinema' as platform, 
		content_type, 
		count(*) content_count
    from 
		liocinema_db.contents 
	group by 2
)
group by 1

-- Part 3 - LANGUAGE-WISE CONTENT DISTRIBUTION

select
	language,
	sum(case when platform = 'jotstar' 
		then language_count else 0 end) 
		as jotstar_count,
	sum(case when platform = 'liocinema' 
		then language_count else 0 end) 
		as liocinema_count

from (select 
		'jotstar' as platform, 
		language, 
		count(*) language_count
    from 
		jotstar_db.contents 
	group by 2
	
    union all
	
    select 
		'liocinema' as platform, 
		language, 
		count(*) language_count
    from 
		liocinema_db.contents 
	group by 2)
group by 1

-- Part 4 - GENRE-WISE CONTENT DISTRIBUTION

select
	genre,
	sum(case when platform ='jotstar' 
		then genre_count else 0 end)
		as jotstar_count,
	sum(case when platform ='liocinema' 
		then genre_count else 0 end)
		as liocinema_count
	
from (select 
		'jotstar' as platform, 
		genre, 
		count(*) genre_count
	from 
		jotstar_db.contents 
	group by 2
	
	union all
	
	select 
		'liocinema' as platform, 
		genre, 
		count(*) genre_count
	from 
		liocinema_db.contents 
	group by 2)
group by 1