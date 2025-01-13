--1. count the number of movies vs tv shows
select
	type,
	count(*) as total_contents
from netflix
group by 1


---2. find the most common rating for movies and tv shows

WITH t1 as
(
	SELECT
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	from netflix
	GROUP BY 1,2
)
SELECT 
	type,
	rating
from t1
where ranking = 1



--3. list all the movies released in a specific year 2020
select * from netflix
where
	type = 'Movie'
	AND
	release_year = 2020

--4. find the top 5 countries with the most content on netflix

select
	unnest(string_to_array(country, ',')) as stream_countries,
	count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5

--5. identify the longest movie
select * from netflix
where 
	type = 'Movie'
	AND
	duration = (select max(duration)from netflix)


--6. find the content added in the last 5 years

SELECT *
FROM netflix
WHERE date_added::timestamp >= CURRENT_TIMESTAMP - INTERVAL '5 year';


--7. FIND ALL THE MOVIES/TB SHOWS BY DIRECOR 'Rajiv Chilaka'

select * from netflix
where director LIKE '%Rajiv Chilaka'

-- 8. list all tv shows with more than 5 seasons

select * from netflix
where 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 5

--9. count the number of content items in each genre

select
	type,
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as content_gengre,
	count(show_id) as total_content
from netflix
GROUP BY 1,2
ORDER BY 3 DESC


--10. FIND EACH YEAR ABD THE AVERAGE NUMBER OF CONTENT RELEASE BY THE INDIA ON NETFLIX
-- RETURN TOP 5 YEAR WITH HIGEST AVG CONTENT RELEASE


SELECT
	 release_year as content_year,
	COUNT(*) AS yearly_content,
	ROUND(
	COUNT(*)/(SELECT COUNT(*) FROM netflix where country = 'India')::numeric * 100, 2) as ave_cont_per_year
from netflix
where country = 'India'
GROUP BY 1
ORDER BY 3 DESC
--LIMIT 5

--11. list all movies that are documentarie

select * from netflix
where listed_in ILIKE '%documentaries%'


--12. find all contents without directors
select * from netflix
where director is null

--13 find how many movie actor 'Selman Khan' appeared in the last 10 years
select * from netflix
where
	casts ILIKE '%Salman khan%'
	AND
	release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10

--14 FIND THE TOP 10  ACTORS WHO HAVE APPEARED IN THE HIGHEST NUMBER OF MOVIES PRODUCED IN INDIA
select 
	--show_id,
	--casts,
	unnest(string_to_array(casts, ',')) as actors,
	count(*) as total_content
from netflix
where country ILIKE '%India'
group by 1
order by 2 desc
limit 10


---15 categorize the content based on the presence of the keywoeds 'kill' and 'violence' in the description field.
--label content containing these keyword as 'Bad' and all other content as 'Good'
-- Count hodw many items fall into each category.

--select * from netflix
--where 
	--description ILIKE '%Kill%'
	--OR
	--description ILIKE '%violence%'


with new_table as
(
select
	*,
	CASE
	WHEN
	description ILIKE '%kill%' 
	OR 
	description ILIKE '%violence%' THEN 'Bad_content'
	ELSE 'Good_content'
	END category
from netflix
)
select 
	category,
	count(*) as total_content
from new_table
group by 1