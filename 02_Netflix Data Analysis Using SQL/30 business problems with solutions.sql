-- Netflix Data Analysis using SQL
-- Solutions of 30 business problems
-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5


-- 5. Identify the longest movie

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC


-- 6. Find content added in the last 5 years
SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM
(

SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
netflix
)
WHERE 
	director_name = 'Rajiv Chilaka'



-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5


-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !


SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5


-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'



-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.



SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2


16. Find the Monthly Trend of Content Added (last 3 years)

SELECT
    DATE_TRUNC('month', TO_DATE(date_added, 'Month DD, YYYY')) AS month,
    COUNT(*) AS total_titles
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '3 years'
GROUP BY month
ORDER BY month;

17. Find the Top 3 Most Prolific Directors of All Time

SELECT 
    TRIM(director_name) AS director,
    COUNT(*) AS total_titles
FROM (
    SELECT UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
    WHERE director IS NOT NULL
)as t
GROUP BY director
ORDER BY total_titles DESC
LIMIT 3;


18. Identify Actors Appearing Together Most Frequently (Top 10 Pairs)

WITH exploded AS (
    SELECT 
        show_id,
        UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor
    FROM netflix
),
pairs AS (
    SELECT 
        e1.actor AS actor1,
        e2.actor AS actor2
    FROM exploded e1
    JOIN exploded e2
        ON e1.show_id = e2.show_id
       AND e1.actor < e2.actor
)
SELECT actor1, actor2, COUNT(*) AS pair_count
FROM pairs
GROUP BY actor1, actor2
ORDER BY pair_count DESC
LIMIT 10;

19. Rank Movies by Duration Within Each Year

SELECT 
    title,
    release_year,
    SPLIT_PART(duration, ' ', 1)::INT AS minutes,
    RANK() OVER (PARTITION BY release_year ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC) AS rank
FROM netflix
WHERE type = 'Movie';

20. Find Countries Producing the Most TV Shows Only

SELECT 
    TRIM(country_name) AS country,
    COUNT(*) AS total_tv_shows
FROM (
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country_name
    FROM netflix
    WHERE type = 'TV Show'
) t
GROUP BY country
ORDER BY total_tv_shows DESC;

21. Detect Content With the Longest Description
SELECT 
    title,
    LENGTH(description) AS description_length
FROM netflix
ORDER BY LENGTH(description) DESC
LIMIT 1;

22. Identify Titles With Multiple Directors
SELECT 
    title,
    director
FROM netflix
WHERE director LIKE '%,%';

23. Count Movies Released Between 1990–2000 Grouped by Rating
SELECT 
    rating,
    COUNT(*) AS total_movies
FROM netflix
WHERE type = 'Movie'
  AND release_year BETWEEN 1990 AND 2000
GROUP BY rating
ORDER BY total_movies DESC;

24. Find the Average Number of New Titles Added Per Year
SELECT 
    ROUND(AVG(title_count)) AS avg_titles_per_year
FROM (
    SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS   year_added,
        COUNT(*) AS title_count
    FROM netflix
    GROUP BY year_added
) t;

25. Find the Most Diverse Actor (Appeared in Most Different Genres)
WITH actor_genres AS (
    SELECT 
        UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
    FROM netflix
)
SELECT 
    TRIM(actor) AS actor,
    COUNT(DISTINCT TRIM(genre)) AS unique_genres
FROM actor_genres
GROUP BY actor
ORDER BY unique_genres DESC
LIMIT 1;
26. Find Duplicate Titles (Same Title, Different Release Years)
SELECT 
    title,
    COUNT(*) AS occurrences
FROM netflix
GROUP BY title
HAVING COUNT(*) > 1;

27. Identify Titles With Ambiguous or Missing Country Information
SELECT *
FROM netflix
WHERE country IS NULL 
   OR country = '' 
   OR country = 'N/A';

28. Compare Movie vs TV Show Average Duration
SELECT 
    type,
    AVG(SPLIT_PART(duration, ' ', 1)::INT) AS avg_value
FROM netflix
GROUP BY type;

29. Identify the Most Popular Genre Combo (Multi-Genre Titles)
SELECT 
    listed_in,
    COUNT(*) AS total
FROM netflix
WHERE listed_in LIKE '%,%'
GROUP BY listed_in
ORDER BY total DESC
LIMIT 5;

30. List Titles Whose Description Mentions Both “Love” AND “War”
SELECT 
    title,
    description
FROM netflix
WHERE description ILIKE '%love%'
  AND description ILIKE '%war%';

-- End of reports

