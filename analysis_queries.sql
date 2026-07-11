USE MusicAnalyticsDB;

-- Which are the most popular tracks in the Spotify Top 50, and who performs them?
SELECT
    g.genre_name,
    COUNT(*) AS tracks,
    ROUND(AVG(t.popularity),2) AS average_popularity
FROM Tracks t
JOIN Genres g
    ON t.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY average_popularity DESC;

-- Because many genres in our dataset only have one song, we will filter out genres represented by only one track.
SELECT
    g.genre_name,
    COUNT(*) AS tracks,
    ROUND(AVG(t.popularity),2) AS average_popularity
FROM Tracks t
JOIN Genres g
    ON t.genre_id = g.genre_id
GROUP BY g.genre_name
HAVING COUNT(*) >= 2
ORDER BY average_popularity DESC;

-- Which genres have the highest average popularity among the Spotify Top 50 tracks?
SELECT
    g.genre_name,
    COUNT(*) AS number_of_tracks,
    ROUND(AVG(t.popularity),2) AS average_popularity
FROM Tracks t
JOIN Genres g
    ON t.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY average_popularity DESC;

-- What are the average audio characteristics of highly popular songs?
SELECT
    ROUND(AVG(energy),2) AS avg_energy,
    ROUND(AVG(danceability),2) AS avg_danceability,
    ROUND(AVG(acousticness),2) AS avg_acousticness,
    ROUND(AVG(speechiness),2) AS avg_speechiness
FROM Audio_Features af
JOIN Tracks t
    ON af.track_id = t.track_id
WHERE t.popularity >= 90;

-- Which songs perform better than the average popularity of the Spotify Top 50?
SELECT
    track_name,
    popularity
FROM Tracks
WHERE popularity >
(
    SELECT AVG(popularity)
    FROM Tracks
)
ORDER BY popularity DESC;

-- Which Grammy-nominated artists also achieve high popularity on Spotify?
SELECT
    a.artist_name,
    COUNT(DISTINCT gn.nomination_id) AS nominations,
    ROUND(AVG(t.popularity),2) AS avg_popularity
FROM Artists a
JOIN Grammy_Nominations gn
    ON a.artist_id = gn.artist_id
JOIN Tracks t
    ON a.artist_id = t.artist_id
GROUP BY a.artist_name
ORDER BY nominations DESC, avg_popularity DESC;

-- What are the average audio characteristics of the Spotify Top 50 songs?
SELECT
    ROUND(AVG(bpm),2) AS bpm,
    ROUND(AVG(energy),2) AS energy,
    ROUND(AVG(danceability),2) AS danceability,
    ROUND(AVG(acousticness),2) AS acousticness,
    ROUND(AVG(speechiness),2) AS speechiness,
    ROUND(AVG(valence),2) AS valence
FROM Audio_Features;

