import pandas as pd
import mysql.connector
from pathlib import Path
from getpass import getpass

password = getpass("MySQL password: ")

BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "processed_data"

# -----------------------------
# Connect to MySQL
# -----------------------------
connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password=password,
    database="MusicAnalyticsDB"
)

cursor = connection.cursor()

# -----------------------------
# Read processed CSVs
# -----------------------------
artists = pd.read_csv(DATA_DIR / "artists.csv")
genres = pd.read_csv(DATA_DIR / "genres.csv")
tracks = pd.read_csv(DATA_DIR / "tracks.csv")
audio_features = pd.read_csv(DATA_DIR / "audio_features.csv")
grammy_nominations = pd.read_csv(DATA_DIR / "grammy_nominations.csv")

# -----------------------------
# Insert Artists
# -----------------------------
cursor.executemany(
    """
    INSERT INTO Artists (artist_id, artist_name)
    VALUES (%s, %s)
    """,
    artists.values.tolist()
)

# -----------------------------
# Insert Genres
# -----------------------------
cursor.executemany(
    """
    INSERT INTO Genres (genre_id, genre_name)
    VALUES (%s, %s)
    """,
    genres.values.tolist()
)

# -----------------------------
# Insert Tracks
# -----------------------------
cursor.executemany(
    """
    INSERT INTO Tracks
    (track_id, track_name, artist_id, genre_id, popularity)
    VALUES (%s, %s, %s, %s, %s)
    """,
    tracks.values.tolist()
)

# -----------------------------
# Insert Audio Features
# -----------------------------
cursor.executemany(
    """
    INSERT INTO Audio_Features
    (track_id, bpm, energy, danceability,
     loudness_db, liveness, valence,
     length, acousticness, speechiness)
    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """,
    audio_features.values.tolist()
)

# -----------------------------
# Insert Grammy Nominations
# -----------------------------
cursor.executemany(
    """
    INSERT INTO Grammy_Nominations
    (nomination_id, artist_id, year,
     award_type, award_name, work, winner)
    VALUES (%s,%s,%s,%s,%s,%s,%s)
    """,
    grammy_nominations.values.tolist()
)

# -----------------------------
# Save changes
# -----------------------------
connection.commit()

print("All data inserted successfully!")

cursor.close()
connection.close()