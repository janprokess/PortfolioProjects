
--Vytvoøení "primárního klíèe" k tabulce NetflixCast 

WITH CTE AS (
    SELECT id,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS new_id
    FROM NetflixCast
)
UPDATE CTE
SET id = new_id;


--Vytvoøení "primárního klíèe" k tabulce NetflixGenre

WITH CTE AS (
    SELECT id,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS new_id
    FROM NetflixGenre
)
UPDATE CTE
SET id = new_id;


--Vytvoøení "primárního klíèe" k tabulce NetflixDescription

WITH CTE AS (
    SELECT id,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS new_id
    FROM NetflixDescription
)
UPDATE CTE
SET id = new_id;


-- Pøidání "cizích klíèù" do tabulky NetflixShows

ALTER TABLE NetflixShows
ADD CONSTRAINT FK_NetflixShows_genre_id
FOREIGN KEY (genre_id) REFERENCES NetflixGenre (id);

ALTER TABLE NetflixShows
ADD CONSTRAINT FK_NetflixShows_cast_id
FOREIGN KEY (cast_id) REFERENCES NetflixCast (id);

ALTER TABLE NetflixShows
ADD CONSTRAINT FK_NetflixShows_desc_id
FOREIGN KEY (desc_id) REFERENCES NetflixDescription (id);


-- Pøidání hodnot k cizím klíèùm v tabulce NetflixShows

-- genre

WITH CTE AS (
    SELECT genre_id,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS new_genre_id
    FROM NetflixShows
)
UPDATE CTE
SET genre_id = new_genre_id;

-- cast

WITH CTE AS (
    SELECT cast_id,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS new_cast_id
    FROM NetflixShows
)
UPDATE CTE
SET cast_id = new_cast_id;

-- description

WITH CTE AS (
    SELECT desc_id,
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS new_desc_id
    FROM NetflixShows
)
UPDATE CTE
SET desc_id = new_desc_id;








