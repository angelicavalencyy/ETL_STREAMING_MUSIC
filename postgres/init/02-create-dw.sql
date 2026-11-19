-- ==========================================
-- DATABASE: streaming_music_dw (Data Warehouse)
-- Dijalankan di database default (streaming_music_dw)
-- ==========================================

-- 1. DIMENSION TABLES
CREATE TABLE IF NOT EXISTS dim_user (
    user_id INTEGER PRIMARY KEY,
    nama VARCHAR(255),
    email VARCHAR(255),
    kota VARCHAR(255),
    tanggal_daftar DATE
);

CREATE TABLE IF NOT EXISTS dim_date (
    tanggal DATE PRIMARY KEY,
    hari INTEGER,
    bulan INTEGER,
    nama_bulan VARCHAR(20),
    kuartal INTEGER,
    tahun INTEGER
);

CREATE TABLE IF NOT EXISTS dim_package (
    tipe_paket VARCHAR(50) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS dim_status (
    status VARCHAR(50) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS dim_activity (
    activity_type VARCHAR(100) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS dim_payment_method (
    metode_bayar VARCHAR(100) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS dim_device (
    device_id INTEGER PRIMARY KEY,
    tipe_device VARCHAR(100),
    os VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_label (
    label_id INTEGER PRIMARY KEY,
    nama_label VARCHAR(255),
    negara VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_artist (
    artist_id INTEGER PRIMARY KEY,
    label_id INTEGER REFERENCES dim_label(label_id),
    nama_artis VARCHAR(255),
    genre_utama VARCHAR(100),
    negara_asal VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_album (
    album_id INTEGER PRIMARY KEY,
    artist_id INTEGER REFERENCES dim_artist(artist_id),
    judul_album VARCHAR(255),
    tanggal_rilis DATE,
    tipe_album VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS dim_song (
    song_id INTEGER PRIMARY KEY,
    album_id INTEGER REFERENCES dim_album(album_id),
    judul_lagu VARCHAR(255),
    durasi_detik INTEGER
);

CREATE TABLE IF NOT EXISTS dim_playlist (
    playlist_id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES dim_user(user_id),
    nama_playlist VARCHAR(255),
    is_public BOOLEAN
);

-- 2. FACT TABLES
-- FACT USER ACTIVITY
CREATE TABLE IF NOT EXISTS fact_user_activity (
    activity_id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES dim_user(user_id),
    activity_date DATE REFERENCES dim_date(tanggal),
    activity_type VARCHAR(100)
        REFERENCES dim_activity(activity_type),
    session_id INTEGER,
    waktu_mulai TIMESTAMP,
    waktu_selesai TIMESTAMP,
    durasi_detik NUMERIC(12,2)
);

-- FACT SUBSCRIPTION
CREATE TABLE IF NOT EXISTS fact_subscription (
    subscription_id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES dim_user(user_id),
    tipe_paket VARCHAR(50)
        REFERENCES dim_package(tipe_paket),
    status VARCHAR(50)
        REFERENCES dim_status(status),
    mulai DATE,
    berakhir DATE,
    harga NUMERIC(12,2),
    is_cancelled BOOLEAN
);

-- FACT PAYMENT
CREATE TABLE IF NOT EXISTS fact_payment (
    payment_id INTEGER PRIMARY KEY,
    subscription_id INTEGER,
    user_id INTEGER REFERENCES dim_user(user_id),
    tipe_paket VARCHAR(50)
        REFERENCES dim_package(tipe_paket),
    tanggal_bayar DATE REFERENCES dim_date(tanggal),
    jumlah NUMERIC(12,2),
    metode_bayar VARCHAR(100)
        REFERENCES dim_payment_method(metode_bayar)
);

-- FACT PLAY
CREATE TABLE IF NOT EXISTS fact_play (
    play_id INTEGER PRIMARY KEY,
    tanggal DATE REFERENCES dim_date(tanggal),
    user_id INTEGER REFERENCES dim_user(user_id),
    song_id INTEGER REFERENCES dim_song(song_id),
    device_id INTEGER REFERENCES dim_device(device_id),
    waktu_mulai TIMESTAMP,
    durasi_diputar_detik INTEGER,
    jumlah_pemutaran INTEGER DEFAULT 1,
    jumlah_skip INTEGER DEFAULT 0
);

-- FACT ARTIST FOLLOW
CREATE TABLE IF NOT EXISTS fact_artist_follow (
    user_id INTEGER REFERENCES dim_user(user_id),
    artist_id INTEGER REFERENCES dim_artist(artist_id),
    tanggal DATE REFERENCES dim_date(tanggal),
    jumlah_follow INTEGER DEFAULT 1,
    PRIMARY KEY (user_id, artist_id)
);

-- FACT PLAYLIST SONG
CREATE TABLE IF NOT EXISTS fact_playlist_song (
    playlist_id INTEGER REFERENCES dim_playlist(playlist_id),
    song_id INTEGER REFERENCES dim_song(song_id),
    urutan INTEGER,
    jumlah_dimasukkan INTEGER DEFAULT 1,
    PRIMARY KEY (playlist_id, song_id)
);

-- 3. INITIAL DATA POPULATION
-- Populate dim_date (2020-2030)
INSERT INTO dim_date
SELECT
    d::DATE,
    EXTRACT(DAY FROM d)::INTEGER,
    EXTRACT(MONTH FROM d)::INTEGER,
    TO_CHAR(d, 'TMMonth'),
    EXTRACT(QUARTER FROM d)::INTEGER,
    EXTRACT(YEAR FROM d)::INTEGER
FROM generate_series(
    '2020-01-01'::DATE,
    '2030-12-31'::DATE,
    INTERVAL '1 day'
) AS d
ON CONFLICT (tanggal) DO NOTHING;
