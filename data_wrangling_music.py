import pandas as pd
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent


def load_data():
    """Load the raw datasets."""

    spotify_file = BASE_DIR / "spotify_top50.csv"
    grammy_file = BASE_DIR / "Grammy Award Nominees and Winners 1958-2024.csv"

    spotify_df = pd.read_csv(spotify_file, encoding="latin1")
    grammy_df = pd.read_csv(grammy_file)

    return spotify_df, grammy_df


def clean_spotify(spotify_df):
    """Rename Spotify columns and clean the dataset."""

    spotify_df = spotify_df.rename(columns={
        "Unnamed: 0": "Rank",
        "Track.Name": "Track_Name",
        "Artist.Name": "Artist_Name",
        "Beats.Per.Minute": "BPM",
        "Loudness..dB..": "Loudness_dB",
        "Valence.": "Valence",
        "Length.": "Length",
        "Acousticness..": "Acousticness",
        "Speechiness.": "Speechiness"
    })

    return spotify_df


def create_tables(spotify_df):
    """Create the normalized Spotify tables."""

    # ---------- Artists ----------
    artists = spotify_df[["Artist_Name"]].drop_duplicates().reset_index(drop=True)
    artists["artist_id"] = artists.index + 1

    artists = artists.rename(columns={
        "Artist_Name": "artist_name"
    })

    artists = artists[
        [
            "artist_id",
            "artist_name"
        ]
    ]

    # ---------- Genres ----------
    genres = spotify_df[["Genre"]].drop_duplicates().reset_index(drop=True)
    genres["genre_id"] = genres.index + 1

    genres = genres.rename(columns={
        "Genre": "genre_name"
    })

    genres = genres[
        [
            "genre_id",
            "genre_name"
        ]
    ]

    # ---------- Tracks ----------
    tracks = spotify_df.merge(
        artists,
        left_on="Artist_Name",
        right_on="artist_name"
    )

    tracks = tracks.merge(
        genres,
        left_on="Genre",
        right_on="genre_name"
    )

    tracks["track_id"] = range(1, len(tracks) + 1)

    tracks = tracks.rename(columns={
        "Track_Name": "track_name",
        "Popularity": "popularity"
    })

    tracks = tracks[
        [
            "track_id",
            "track_name",
            "artist_id",
            "genre_id",
            "popularity"
        ]
    ]

    # ---------- Audio Features ----------
    audio_features = spotify_df.copy()

    audio_features["track_id"] = range(1, len(audio_features) + 1)

    audio_features = audio_features.rename(columns={
        "BPM": "bpm",
        "Energy": "energy",
        "Danceability": "danceability",
        "Loudness_dB": "loudness_db",
        "Liveness": "liveness",
        "Valence": "valence",
        "Length": "length",
        "Acousticness": "acousticness",
        "Speechiness": "speechiness"
    })

    audio_features = audio_features[
        [
            "track_id",
            "bpm",
            "energy",
            "danceability",
            "loudness_db",
            "liveness",
            "valence",
            "length",
            "acousticness",
            "speechiness"
        ]
    ]

    return artists, genres, tracks, audio_features


def process_grammy(grammy_df, artists):
    """Prepare the Grammy nominations table."""

    grammy_df = grammy_df.rename(columns={
        "Award ID": "Award_ID",
        "Award Type": "Award_Type",
        "Award Name": "Award_Name"
    })

    grammy_recent = grammy_df[grammy_df["Year"] >= 2015].copy()

    spotify_artist_names = set(artists["artist_name"])
    grammy_artist_names = set(grammy_recent["Nominee"])

    matches = spotify_artist_names.intersection(grammy_artist_names)

    print(f"\nMatching artists: {len(matches)}")
    print(matches)

    grammy_2019 = grammy_recent[grammy_recent["Year"] == 2019].copy()

    grammy_nominations = grammy_2019.merge(
    artists,
    left_on="Nominee",
    right_on="artist_name",
    how="inner"
)

    grammy_nominations = grammy_nominations[
        [
            "artist_id",
            "Year",
            "Award_Type",
            "Award_Name",
            "Work",
            "Winner"
        ]
    ]

    grammy_nominations = grammy_nominations.rename(columns={
        "Year": "year",
        "Award_Type": "award_type",
        "Award_Name": "award_name",
        "Work": "work",
        "Winner": "winner"
    })

    grammy_nominations = grammy_nominations.reset_index(drop=True)

    grammy_nominations["nomination_id"] = (
        grammy_nominations.index + 1
    )

    grammy_nominations = grammy_nominations[
        [
            "nomination_id",
            "artist_id",
            "year",
            "award_type",
            "award_name",
            "work",
            "winner"
        ]
    ]

    return grammy_nominations


def save_tables(
    artists,
    genres,
    tracks,
    audio_features,
    grammy_nominations
):
    """Save processed tables as CSV files."""

    output = BASE_DIR / "processed_data"
    output.mkdir(exist_ok=True)

    artists.to_csv(output / "artists.csv", index=False)
    genres.to_csv(output / "genres.csv", index=False)
    tracks.to_csv(output / "tracks.csv", index=False)
    audio_features.to_csv(output / "audio_features.csv", index=False)
    grammy_nominations.to_csv(output / "grammy_nominations.csv", index=False)

    print("\nProcessed tables saved successfully.")


def main():

    spotify_df, grammy_df = load_data()

    spotify_df = clean_spotify(spotify_df)

    artists, genres, tracks, audio_features = create_tables(
        spotify_df
    )

    grammy_nominations = process_grammy(
        grammy_df,
        artists
    )

    save_tables(
        artists,
        genres,
        tracks,
        audio_features,
        grammy_nominations
    )


if __name__ == "__main__":
    main()



