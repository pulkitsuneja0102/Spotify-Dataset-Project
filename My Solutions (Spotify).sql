--Advanced SQl Project -- Spotify Datasets

DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

SELECT * FROM public.spotify
limit 100

----------------------------------
--Data Analysis ---- Easy category
----------------------------------
--Retrieve the names of all tracks that have more than 1 billion streams.
--List all albums along with their respective artists.
--Get the total number of comments for tracks where licensed = TRUE.
--Find all tracks that belong to the album type single.
--Count the total number of tracks by each artist.

--Q1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT track
FROM spotify
WHERE stream > 1000000000; 

--Q2. List all albums along with their respective artists.

SELECT DISTINCT album, artist 
FROM spotify
ORDER BY 1;

--Q3. Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(comments) AS total_comments 
FROM spotify
WHERE licensed = 'TRUE';

--Q4. Find all tracks that belong to the album type single.

SELECT track 
FROM spotify
WHERE album_type = 'single';

--Q5. Count the total number of tracks by each artist.

SELECT artist,
       COUNT(*) AS total_songs
FROM spotify
GROUP BY 1
ORDER BY 2 ASC;

--Medium Category
/*
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

--Q6. Calculate the average danceability of tracks in each album.

SELECT album,  
       AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC

--Q7. Find the top 5 tracks with the highest energy values.

SELECT track,
       MAX(energy) AS max_energies
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--Q8.List all tracks along with their views and likes where official_video = TRUE.

SELECT track, 
       views, 
	   likes
FROM spotify
WHERE official_video = 'TRUE';

--Q9. For each album, calculate the total views of all associated tracks.

SELECT album,
       track,
       SUM(views)  
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC;

--Q10. Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM 
(
SELECT track,
       COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streamed_on_youtube, 
       COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS streamed_on_spotify  
FROM SPOTIFY
GROUP BY 1
) as T1
WHERE streamed_on_spotify > streamed_on_youtube
      AND
	  streamed_on_youtube <> 0;

--Advance Category
/*
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

--Q11. Find the top 3 most-viewed tracks for each artist using window functions.

WITH ranking_artist
AS 
(
SELECT artist, 
       track,
	   SUM(views) AS total_views,
	   DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank 
FROM spotify
GROUP BY 1, 2
ORDER BY 1, 3 DESC
)

SELECT * FROM ranking_artist 
WHERE rank <= 3;

--Q12. Write a query to find tracks where the liveness score is above the average.

SELECT track, 
       liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness)
                  FROM spotify);

--Q13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH album_energy_stats AS 
(
SELECT
        album,
        MAX(energy) AS max_energy,
        MIN(energy) AS min_energy
    FROM spotify
    GROUP BY 1
)
SELECT
    album,
    max_energy,
    min_energy,
    max_energy - min_energy AS energy_difference
FROM album_energy_stats
ORDER BY 2 DESC;

--Q14. Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT DISTINCT album, track
FROM spotify
WHERE liveness IS NOT NULL AND liveness != 0
  AND (energy / liveness) > 1.2;

--Q15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT track,
       views,
	   SUM(likes) OVER(ORDER BY views DESC) AS cumulative_likes
FROM spotify
ORDER BY views DESC;

--Query Optimisation 

EXPLAIN ANALYZE
SELECT artist,
       track,
	   views
FROM spotify
WHERE artist = 'Gorillaz'
      AND 
      most_played_on = 'Youtube'
ORDER BY stream 
LIMIT 25

CREATE INDEX artist_index ON spotify (artist)


























































































































































