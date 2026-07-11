CREATE DATABASE MusicAnalyticsDB;

USE MusicAnalyticsDB;

CREATE TABLE Artists (
    artist_id INT PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Genres (
    genre_id INT PRIMARY KEY,
    genre_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Tracks (
    track_id INT PRIMARY KEY,
    track_name VARCHAR(255) NOT NULL,
    popularity INT NOT NULL,
    artist_id INT NOT NULL,
    genre_id INT NOT NULL,

    CONSTRAINT fk_tracks_artist
        FOREIGN KEY (artist_id)
        REFERENCES Artists(artist_id),

    CONSTRAINT fk_tracks_genre
        FOREIGN KEY (genre_id)
        REFERENCES Genres(genre_id)
);

CREATE TABLE Audio_Features (
    track_id INT PRIMARY KEY,
    bpm INT,
    energy INT,
    danceability INT,
    loudness_db INT,
    liveness INT,
    valence INT,
    length INT,
    acousticness INT,
    speechiness INT,

    CONSTRAINT fk_audio_track
        FOREIGN KEY (track_id)
        REFERENCES Tracks(track_id)
);

CREATE TABLE Grammy_Nominations (
    nomination_id INT PRIMARY KEY,
    artist_id INT NOT NULL,
    year INT NOT NULL,
    award_type VARCHAR(100),
    award_name VARCHAR(255),
    work VARCHAR(255),
    winner BOOLEAN,

    CONSTRAINT fk_grammy_artist
        FOREIGN KEY (artist_id)
        REFERENCES Artists(artist_id)
);
