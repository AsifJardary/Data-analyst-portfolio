# Netflix Movies & TV Shows — SQL Data Analysis Project

![](https://github.com/AsifJardary/Data-analyst-portfolio/blob/main/02_Netflix%20Data%20Analysis%20Using%20SQL/N_logo.jpeg)

# Overview
This project showcases a complete end-to-end SQL analysis of Netflix’s movie and TV show catalog. Using real-world data from Kaggle, the goal is to uncover insights into Netflix’s content distribution, trends, countries of production, popular ratings, genres, and more.
The analysis answers important business and analytical questions, making this project ideal for SQL portfolio building, interviews, and data exploration practice.

# Project Objectives
The project focuses on exploring Netflix’s catalog to uncover patterns across multiple dimensions, including:
* Content Type Distribution – Compare how many Movies vs. TV Shows are available.
* Rating Analysis – Find the most common rating for each content type.
* Release Trends Over Time – Identify which years had the most content releases.
* Country Insights – See which countries produce the most Netflix titles.
* Duration Analysis – Explore longest movies and TV shows with many seasons.
* Genre & Category Exploration – Deep dive into genre combinations and descriptions.
* Keyword Classification – Categorize content using text-based labels (e.g., violence, crime, romance).
This analysis demonstrates practical SQL skills such as CTEs, window functions, text functions, unnesting array-like fields, date transformations, conditional aggregation, and ranking.

# Dataset Information
This project uses a publicly available dataset from Kaggle, containing all Netflix movies and TV shows listed at the time of collection.
?? Dataset Source
Movies & TV Shows Dataset (Kaggle)
https://www.kaggle.com/datasets/shivamb/netflix-shows

# Dataset Includes
* Titles
* Cast and director details
* Content type (Movie or TV Show)
* Duration (minutes or seasons)
* Ratings
* Countries of production
* Genres / categories
* Date added to Netflix
* Plot descriptions
This makes the dataset ideal for a wide variety of SQL-based analytical tasks.

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
```
**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

### 16. Find the Monthly Trend of Content Added (last 3 years)

```sql
SELECT
    DATE_TRUNC('month', TO_DATE(date_added, 'Month DD, YYYY')) AS month,
    COUNT(*) AS total_titles
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '3 years'
GROUP BY month
ORDER BY month;
```

### 17. Find the Top 3 Most Prolific Directors of All Time

```sql
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
```

### 18. Identify Actors Appearing Together Most Frequently (Top 10 Pairs)

```sql
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
```
### 19. Rank Movies by Duration Within Each Year

```sql
SELECT 
    title,
    release_year,
    SPLIT_PART(duration, ' ', 1)::INT AS minutes,
    RANK() OVER (PARTITION BY release_year ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC) AS rank
FROM netflix
WHERE type = 'Movie';
```

### 20. Find Countries Producing the Most TV Shows Only

```sql
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
```

### 21. Detect Content With the Longest Description

```sql
SELECT 
    title,
    LENGTH(description) AS description_length
FROM netflix
ORDER BY LENGTH(description) DESC
LIMIT 1;
```

### 22. Identify Titles With Multiple Directors

```sql
SELECT 
    title,
    director
FROM netflix
WHERE director LIKE '%,%';
```

### 23. Count Movies Released Between 1990–2000 Grouped by Rating

```sql
SELECT 
    rating,
    COUNT(*) AS total_movies
FROM netflix
WHERE type = 'Movie'
  AND release_year BETWEEN 1990 AND 2000
GROUP BY rating
ORDER BY total_movies DESC;
```

### 24. Find the Average Number of New Titles Added Per Year

```sql
SELECT 
    ROUND(AVG(title_count)) AS avg_titles_per_year
FROM (
    SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS   year_added,
        COUNT(*) AS title_count
    FROM netflix
    GROUP BY year_added
) t;
```

### 25. Find the Most Diverse Actor (Appeared in Most Different Genres)

```sql
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
```



### 26. Find Duplicate Titles (Same Title, Different Release Years)

```sql
SELECT 
    title,
    COUNT(*) AS occurrences
FROM netflix
GROUP BY title
HAVING COUNT(*) > 1;
```

### 27. Identify Titles With Ambiguous or Missing Country Information

```sql
SELECT *
FROM netflix
WHERE country IS NULL 
   OR country = '' 
   OR country = 'N/A';
```

### 28. Compare Movie vs TV Show Average Duration

```sql
SELECT 
    type,
    AVG(SPLIT_PART(duration, ' ', 1)::INT) AS avg_value
FROM netflix
GROUP BY type;
```

### 29. Identify the Most Popular Genre Combo (Multi-Genre Titles)

```sql
SELECT 
    listed_in,
    COUNT(*) AS total
FROM netflix
WHERE listed_in LIKE '%,%'
GROUP BY listed_in
ORDER BY total DESC
LIMIT 5;
```

### 30. List Titles Whose Description Mentions Both “Love” AND “War”

```sql
SELECT 
    title,
    description
FROM netflix
WHERE description ILIKE '%love%'
  AND description ILIKE '%war%';

```


?? Findings & Conclusion
* Content Variety:
Netflix hosts a broad and diverse library of movies and TV shows, spanning multiple genres, themes, and formats. This variety reflects Netflix’s strategy of appealing to a global and multi-demographic audience.
* Audience Targeting Through Ratings:
The analysis of ratings reveals clear patterns in how content is classified, providing insight into Netflix’s primary audience segments. Understanding these ratings helps evaluate the platform’s focus on family-friendly, teen, or mature content.
* Geographical Trends:
Identifying the top content-producing countries and analyzing India’s year-over-year contribution highlights regional production strengths. These findings underline how global markets influence Netflix’s content acquisition and creation decisions.
* Content Classification by Themes:
Categorizing descriptions using keyword analysis (e.g., violence, crime, romance) enables a deeper understanding of thematic trends across the catalog. This helps in recognizing dominant content themes and user preference indicators.

? Overall Conclusion
This SQL-based analysis provides a well-rounded understanding of Netflix’s catalog composition, trends, and distribution. The insights can support strategic decisions related to content acquisition, content development, audience targeting, and regional expansion. It also highlights how data-driven analysis can be used to optimize streaming platform strategies.




