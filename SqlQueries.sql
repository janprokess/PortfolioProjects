-- Cely dataset


SELECT 
	show.id, title, country, date_added, release_year, rating, duration, type, listed_in, director, cast, description
FROM NetflixShows show
	 JOIN NetflixGenre genr ON show.genre_id = genr.id
	 JOIN NetflixCast cast ON show.cast_id = cast.id
	 JOIN NetflixDescription des ON show.desc_id = des.id;


-- Uplny pocet pridaných filmu a seriálu v datasetu


SELECT 
	genr.type, COUNT(*) AS total_number
FROM 
	NetflixShows show
	JOIN NetflixGenre genr ON show.genre_id = genr.id
WHERE 
	type IS NOT NULL 
	AND type <> 'William Wyler' -- Nepresna data
GROUP BY type;


-- Uprava sloupce 'date_added'


SELECT date_added, CONVERT(date, date_added)
FROM NetflixShows

ALTER TABLE NetflixShows
ALTER COLUMN date_added DATE

Update NetflixShows
SET date_added = CONVERT(date, date_added);


-- Uplny pocet pridanych filmu a serialu kazdy rok


SELECT 
	YEAR(show.date_added) AS year,
	SUM(CASE WHEN genr.type = 'Movie' THEN 1 ELSE 0 END) AS total_movies,
	SUM(CASE WHEN genr.type = 'TV Show' THEN 1 ELSE 0 END) AS total_TVshows
FROM 
	NetflixShows show
	JOIN NetflixGenre genr ON show.genre_id = genr.id
WHERE 
    (genr.type = 'Movie' OR genr.type = 'TV Show')
    AND show.date_added IS NOT NULL
GROUP BY 
    YEAR(show.date_added)
ORDER BY 1;


-- TOP 5 nejaktivnejsich reziseru


SELECT TOP 5
	director, COUNT(*) AS show_number
FROM 
	NetflixShows show
	JOIN NetflixCast cast ON show.cast_id = cast.id
WHERE director IS NOT NULL
GROUP BY director
ORDER BY 2 DESC;


-- Nejcetnejsí zanry v datasetu

--Filmy

SELECT DISTINCT
    TRIM(value) AS most_common_genre,
    COUNT(*) AS show_number,
	type
FROM NetflixShows show
    JOIN NetflixGenre genr ON show.genre_id = genr.id
    CROSS APPLY STRING_SPLIT(TRIM(genr.listed_in), ',') AS genres
WHERE 
    value IS NOT NULL 
	AND type = 'Movie'
GROUP BY 
    TRIM(value), type
ORDER BY 2 DESC;
   

--Serialy

SELECT DISTINCT
    TRIM(value) AS most_common_genre,
    COUNT(*) AS show_number,
	type
FROM NetflixShows show
    JOIN NetflixGenre genr ON show.genre_id = genr.id
    CROSS APPLY STRING_SPLIT(TRIM(genr.listed_in), ',') AS genres
WHERE 
    value IS NOT NULL
	AND type = 'TV Show'
GROUP BY 
    TRIM(value), type
ORDER BY 2 DESC;
    

-- Top 10 nejdelsich filmu pro dospele (TV-MA rating)


SELECT TOP 10
    title,
    CASE 
        WHEN CHARINDEX('min', duration) > 0 THEN CAST(LEFT(duration, CHARINDEX('min', duration) - 1) AS INT)
        ELSE NULL
    END AS duration_in_minutes
FROM 
    NetflixShows AS show
    JOIN NetflixGenre AS genr ON show.genre_id = genr.id
WHERE 
    genr.type = 'Movie'
	AND show.id <> 4254 -- Nepøesná data
	AND rating = 'TV-MA'   
ORDER BY 
    duration_in_minutes DESC;


-- TOP 10 zemi s nejvetsi rozmanitosti hercu a herecek ve svych filmech/serialech


SELECT TOP 10 
	country, 
	COUNT(DISTINCT cast) AS diversity_count
FROM 
	NetflixShows show
	JOIN NetflixCast cast ON show.cast_id = cast.id
WHERE country IS NOT NULL
GROUP BY country
ORDER BY diversity_count DESC;


-- Procentuálne


WITH Top10countries AS (
SELECT TOP 10 
	country, 
	COUNT(DISTINCT cast) AS diversity_count
FROM 
	NetflixShows show
	JOIN NetflixCast cast ON show.cast_id = cast.id
WHERE country IS NOT NULL
GROUP BY country
ORDER BY diversity_count DESC
)
SELECT 
	country,  
	CAST(ROUND((diversity_count * 100.0) / (SELECT SUM(diversity_count) FROM Top10Countries), 2) AS float)
		AS diversity_percentage
FROM 
    Top10Countries
ORDER BY 
    diversity_percentage DESC;


-- Prumerna delka filmu v jednotlivych zemich pro male deti (TV-Y rating)


DROP Table if exists #TempTable
CREATE TABLE #TempTable 
(
country nvarchar(50),
AvgDuration float
);
INSERT INTO #TempTable
   SELECT
	country,
    AVG(CASE 
        WHEN CHARINDEX('min', duration) > 0 THEN CAST(LEFT(duration, CHARINDEX('min', duration) - 1) AS float)
        ELSE NULL
    END) AS AvgDuration
FROM 
    NetflixShows AS show
    JOIN NetflixGenre AS genr ON show.genre_id = genr.id
WHERE 
    genr.type = 'Movie'
	AND show.id <> 4254 -- Nepøesná data
	AND rating = 'TV-Y' 
GROUP BY country;

-- Query

SELECT 
    LEFT(TRIM(value), CHARINDEX(',', TRIM(value) + ',') - 1) AS country,
    ROUND(AVG(AvgDuration), 2) AS AvgDuration_In_Minutes
FROM 
    #TempTable
    CROSS APPLY STRING_SPLIT(country, ',')
WHERE 
	AvgDuration IS NOT NULL
GROUP BY 
    LEFT(TRIM(value), CHARINDEX(',', TRIM(value) + ',') - 1)
ORDER BY 
    AvgDuration_In_Minutes DESC;


-- Odstranení prebytecnych tabulek


DROP TABLE NetflixDescription












