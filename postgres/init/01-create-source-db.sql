-- ==========================================
-- DATABASE: SPOTIFY ETL (Source Database)
-- PostgreSQL
-- ==========================================

-- Buat database sumber
CREATE DATABASE etl_database;

-- Connect ke etl_database dan buat schema
\c etl_database

-- 1. USERS
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    nama VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    tanggal_daftar DATE,
    kota VARCHAR(255)
);

-- 2. USER ACTIVITY
CREATE TABLE user_activity (
    activity_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    activity_date DATE,
    activity_type VARCHAR(100),
    session_id INTEGER,
    waktu_mulai TIMESTAMP,
    waktu_selesai TIMESTAMP
);

-- 3. SUBSCRIPTIONS
CREATE TABLE subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    tipe_paket VARCHAR(50),
    harga NUMERIC(12,2),
    mulai DATE,
    berakhir DATE,
    status VARCHAR(50)
);

-- 4. PAYMENTS
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    subscription_id INTEGER
        REFERENCES subscriptions(subscription_id),
    tanggal_bayar DATE,
    jumlah NUMERIC(12,2),
    metode_bayar VARCHAR(100)
);

-- 5. LABELS
CREATE TABLE labels (
    label_id SERIAL PRIMARY KEY,
    nama_label VARCHAR(255),
    negara VARCHAR(100)
);

-- 6. ARTISTS
CREATE TABLE artists (
    artist_id SERIAL PRIMARY KEY,
    label_id INTEGER REFERENCES labels(label_id),
    nama_artis VARCHAR(255),
    genre_utama VARCHAR(100),
    negara_asal VARCHAR(100)
);

-- 7. ALBUMS
CREATE TABLE albums (
    album_id SERIAL PRIMARY KEY,
    artist_id INTEGER REFERENCES artists(artist_id),
    judul_album VARCHAR(255),
    tanggal_rilis DATE,
    tipe_album VARCHAR(50)
);

-- 8. SONGS
CREATE TABLE songs (
    song_id SERIAL PRIMARY KEY,
    album_id INTEGER REFERENCES albums(album_id),
    judul_lagu VARCHAR(255),
    durasi_detik INTEGER
);

-- 9. GENRES
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    nama_genre VARCHAR(100)
);

-- 10. SONG GENRES
CREATE TABLE song_genres (
    song_id INTEGER REFERENCES songs(song_id),
    genre_id INTEGER REFERENCES genres(genre_id),
    PRIMARY KEY (song_id, genre_id)
);

-- 11. PLAYLISTS
CREATE TABLE playlists (
    playlist_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    nama_playlist VARCHAR(255),
    is_public BOOLEAN
);

-- 12. PLAYLIST SONGS
CREATE TABLE playlist_songs (
    playlist_id INTEGER REFERENCES playlists(playlist_id),
    song_id INTEGER REFERENCES songs(song_id),
    urutan INTEGER,
    PRIMARY KEY (playlist_id, song_id)
);

-- 13. DEVICES
CREATE TABLE devices (
    device_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    tipe_device VARCHAR(100),
    os VARCHAR(100)
);

-- 14. PLAY HISTORY
CREATE TABLE play_history (
    play_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    song_id INTEGER REFERENCES songs(song_id),
    device_id INTEGER REFERENCES devices(device_id),
    waktu_mulai TIMESTAMP,
    durasi_diputar_detik INTEGER,
    is_skip BOOLEAN
);

-- 15. ARTIST FOLLOWERS
CREATE TABLE artist_followers (
    user_id INTEGER REFERENCES users(user_id),
    artist_id INTEGER REFERENCES artists(artist_id),
    tanggal_follow DATE,
    PRIMARY KEY (user_id, artist_id)
);

-- 16. ADS
CREATE TABLE ads (
    ad_id SERIAL PRIMARY KEY,
    nama_campaign VARCHAR(255),
    pengiklan VARCHAR(255)
);

-- 17. AD IMPRESSIONS
CREATE TABLE ad_impressions (
    impression_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    ad_id INTEGER REFERENCES ads(ad_id),
    device_id INTEGER REFERENCES devices(device_id),
    waktu_tayang TIMESTAMP,
    is_click BOOLEAN
);

-- ==========================================
-- INSERT DATA DUMMY
-- ==========================================

-- 1. USERS (20 Data)
INSERT INTO users (user_id, nama, email, tanggal_daftar, kota) VALUES
(1, 'Andi Pratama', 'andi.pratama@email.com', '2026-01-10', 'Surabaya'),
(2, 'Siti Rahma', 'siti.rahma@email.com', '2026-01-15', 'Jakarta'),
(3, 'Budi Santoso', 'budi.santoso@email.com', '2026-01-20', 'Bandung'),
(4, 'Dewi Lestari', 'dewi.lestari@email.com', '2026-02-05', 'Surabaya'),
(5, 'Eko Prasetyo', 'eko.prasetyo@email.com', '2026-02-12', 'Medan'),
(6, 'Fitri Wulandari', 'fitri.wulandari@email.com', '2026-02-18', 'Yogyakarta'),
(7, 'Gilang Ramadhan', 'gilang.ramadhan@email.com', '2026-03-01', 'Semarang'),
(8, 'Hana Salsabila', 'hana.salsabila@email.com', '2026-03-10', 'Surabaya'),
(9, 'Irfan Hakim', 'irfan.hakim@email.com', '2026-03-22', 'Malang'),
(10, 'Joko Anwar', 'joko.anwar@email.com', '2026-04-02', 'Jakarta'),
(11, 'Kartika Putri', 'kartika.putri@email.com', '2026-04-14', 'Bandung'),
(12, 'Lukman Hakim', 'lukman.hakim@email.com', '2026-04-25', 'Surabaya'),
(13, 'Maya Sofa', 'maya.sofa@email.com', '2026-05-03', 'Bali'),
(14, 'Naufal Al Farisi', 'naufal.farisi@email.com', '2026-05-11', 'Yogyakarta'),
(15, 'Olivia Wilde', 'olivia.wilde@email.com', '2026-05-20', 'Jakarta'),
(16, 'Pandu Winata', 'pandu.winata@email.com', '2026-06-01', 'Surabaya'),
(17, 'Qory Sandioriva', 'qory.sandio@email.com', '2026-06-12', 'Medan'),
(18, 'Rizky Febian', 'rizky.febian@email.com', '2026-06-19', 'Bandung'),
(19, 'Salma Salsabila', 'salma.salin@email.com', '2026-06-25', 'Malang'),
(20, 'Tegar Septian', 'tegar.septian@email.com', '2026-06-30', 'Surabaya')
ON CONFLICT (user_id) DO NOTHING;

SELECT setval('users_user_id_seq', 20);

-- 2. LABELS (5 Data)
INSERT INTO labels (label_id, nama_label, negara) VALUES
(1, 'Universal Music Indonesia', 'Indonesia'),
(2, 'Sony Music Entertainment', 'United States'),
(3, 'Jagonya Musik & Sport', 'Indonesia'),
(4, 'Warner Music Group', 'United States'),
(5, 'Hited Records', 'Indonesia')
ON CONFLICT (label_id) DO NOTHING;

SELECT setval('labels_label_id_seq', 5);

-- 3. ARTISTS (5 Data)
INSERT INTO artists (artist_id, label_id, nama_artis, genre_utama, negara_asal) VALUES
(1, 1, 'Tulus', 'Pop', 'Indonesia'),
(2, 2, 'Taylor Swift', 'Pop', 'United States'),
(3, 3, 'Sheila On 7', 'Rock', 'Indonesia'),
(4, 4, 'Ed Sheeran', 'Pop', 'United Kingdom'),
(5, 5, 'Mahalini', 'Pop', 'Indonesia')
ON CONFLICT (artist_id) DO NOTHING;

SELECT setval('artists_artist_id_seq', 5);

-- 4. ALBUMS (5 Data)
INSERT INTO albums (album_id, artist_id, judul_album, tanggal_rilis, tipe_album) VALUES
(1, 1, 'Manusia', '2022-03-03', 'Album'),
(2, 2, 'Midnights', '2022-10-21', 'Album'),
(3, 3, 'Kisah Klasik Untuk Masa Depan', '2000-01-01', 'Album'),
(4, 4, 'Divide', '2017-03-03', 'Album'),
(5, 5, 'Fabula', '2023-01-23', 'Album')
ON CONFLICT (album_id) DO NOTHING;

SELECT setval('albums_album_id_seq', 5);

-- 5. SONGS (10 Data)
INSERT INTO songs (song_id, album_id, judul_lagu, durasi_detik) VALUES
(1, 1, 'Hati-Hati di Jalan', 242),
(2, 1, 'Monokrom', 215),
(3, 2, 'Anti-Hero', 200),
(4, 2, 'Lavender Haze', 202),
(5, 3, 'Dan', 260),
(6, 3, 'Sephia', 312),
(7, 4, 'Shape of You', 233),
(8, 4, 'Castle on the Hill', 261),
(9, 5, 'Sial', 257),
(10, 5, 'Bohongi Hati', 235)
ON CONFLICT (song_id) DO NOTHING;

SELECT setval('songs_song_id_seq', 10);

-- 6. GENRES (5 Data)
INSERT INTO genres (genre_id, nama_genre) VALUES
(1, 'Pop'),
(2, 'Rock'),
(3, 'Indie'),
(4, 'R&B'),
(5, 'Acoustic')
ON CONFLICT (genre_id) DO NOTHING;

SELECT setval('genres_genre_id_seq', 5);

-- 7. SONG GENRES (10 Data)
INSERT INTO song_genres (song_id, genre_id) VALUES
(1, 1), (2, 5), (3, 1), (4, 4),
(5, 2), (6, 2), (7, 1), (8, 3),
(9, 1), (10, 1)
ON CONFLICT (song_id, genre_id) DO NOTHING;

-- 8. DEVICES (10 Data)
INSERT INTO devices (device_id, user_id, tipe_device, os) VALUES
(1, 1, 'Smartphone', 'Android'),
(2, 2, 'Smartphone', 'iOS'),
(3, 3, 'Laptop', 'Windows'),
(4, 4, 'Smartphone', 'Android'),
(5, 5, 'Tablet', 'iOS'),
(6, 6, 'Smartphone', 'Android'),
(7, 7, 'Laptop', 'macOS'),
(8, 8, 'Smartphone', 'iOS'),
(9, 9, 'Smartphone', 'Android'),
(10, 10, 'Laptop', 'Windows')
ON CONFLICT (device_id) DO NOTHING;

SELECT setval('devices_device_id_seq', 10);

-- 9. USER ACTIVITY (10 Data)
INSERT INTO user_activity (activity_id, user_id, activity_date, activity_type, session_id, waktu_mulai, waktu_selesai) VALUES
(1, 1, '2026-06-01', 'PLAY_SONG', 101, '2026-06-01 08:00:00', '2026-06-01 08:35:00'),
(2, 2, '2026-06-01', 'PLAY_SONG', 102, '2026-06-01 09:10:00', '2026-06-01 09:45:00'),
(3, 3, '2026-06-02', 'SEARCH', 103, '2026-06-02 10:00:00', '2026-06-02 10:15:00'),
(4, 4, '2026-06-02', 'PLAY_SONG', 104, '2026-06-02 11:30:00', '2026-06-02 12:20:00'),
(5, 5, '2026-06-03', 'CREATE_PLAYLIST', 105, '2026-06-03 13:00:00', '2026-06-03 13:25:00'),
(6, 6, '2026-06-03', 'PLAY_SONG', 106, '2026-06-03 14:00:00', '2026-06-03 14:50:00'),
(7, 7, '2026-06-04', 'PLAY_SONG', 107, '2026-06-04 15:10:00', '2026-06-04 15:45:00'),
(8, 8, '2026-06-04', 'SKIP_SONG', 108, '2026-06-04 16:00:00', '2026-06-04 16:05:00'),
(9, 9, '2026-06-05', 'PLAY_SONG', 109, '2026-06-05 17:00:00', '2026-06-05 17:40:00'),
(10, 10, '2026-06-05', 'PLAY_SONG', 110, '2026-06-05 18:00:00', '2026-06-05 18:55:00')
ON CONFLICT (activity_id) DO NOTHING;

SELECT setval('user_activity_activity_id_seq', 10);

-- 10. SUBSCRIPTIONS (5 Data)
INSERT INTO subscriptions (subscription_id, user_id, tipe_paket, harga, mulai, berakhir, status) VALUES
(1, 1, 'Premium Individual', 54900.00, '2026-01-10', '2026-02-10', 'ACTIVE'),
(2, 2, 'Premium Student', 27500.00, '2026-01-15', '2026-02-15', 'ACTIVE'),
(3, 3, 'Premium Family', 86900.00, '2026-01-20', '2026-02-20', 'EXPIRED'),
(4, 4, 'Free', 0.00, '2026-02-05', '2026-12-31', 'ACTIVE'),
(5, 5, 'Premium Individual', 54900.00, '2026-02-12', '2026-03-12', 'CANCELLED')
ON CONFLICT (subscription_id) DO NOTHING;

SELECT setval('subscriptions_subscription_id_seq', 5);

-- 11. PAYMENTS (5 Data)
INSERT INTO payments (payment_id, subscription_id, tanggal_bayar, jumlah, metode_bayar) VALUES
(1, 1, '2026-01-10', 54900.00, 'GoPay'),
(2, 2, '2026-01-15', 27500.00, 'OVO'),
(3, 3, '2026-01-20', 86900.00, 'Credit Card'),
(4, 5, '2026-02-12', 54900.00, 'Bank Transfer'),
(5, 1, '2026-02-10', 54900.00, 'GoPay')
ON CONFLICT (payment_id) DO NOTHING;

SELECT setval('payments_payment_id_seq', 5);

-- 12. PLAYLISTS (5 Data)
INSERT INTO playlists (playlist_id, user_id, nama_playlist, is_public) VALUES
(1, 1, 'Lagu Galau Malam Hari', true),
(2, 2, 'Workout Booster', false),
(3, 3, 'Rock Classic 90an', true),
(4, 4, 'Mood Booster', true),
(5, 5, 'Top Hits Indonesia', true)
ON CONFLICT (playlist_id) DO NOTHING;

SELECT setval('playlists_playlist_id_seq', 5);

-- 13. PLAYLIST SONGS (5 Data)
INSERT INTO playlist_songs (playlist_id, song_id, urutan) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 7, 1),
(3, 5, 1),
(5, 9, 1)
ON CONFLICT (playlist_id, song_id) DO NOTHING;

-- 14. PLAY HISTORY (5 Data)
INSERT INTO play_history (play_id, user_id, song_id, device_id, waktu_mulai, durasi_diputar_detik, is_skip) VALUES
(1, 1, 1, 1, '2026-06-01 08:05:00', 242, false),
(2, 2, 3, 2, '2026-06-01 09:15:00', 200, false),
(3, 4, 7, 4, '2026-06-02 11:35:00', 120, true),
(4, 6, 5, 6, '2026-06-03 14:10:00', 260, false),
(5, 10, 9, 10, '2026-06-05 18:10:00', 257, false)
ON CONFLICT (play_id) DO NOTHING;

SELECT setval('play_history_play_id_seq', 5);

-- 15. ARTIST FOLLOWERS (5 Data)
INSERT INTO artist_followers (user_id, artist_id, tanggal_follow) VALUES
(1, 1, '2026-01-11'),
(2, 2, '2026-01-16'),
(3, 3, '2026-01-21'),
(4, 1, '2026-02-06'),
(5, 5, '2026-02-13')
ON CONFLICT (user_id, artist_id) DO NOTHING;

-- 16. ADS (3 Data)
INSERT INTO ads (ad_id, nama_campaign, pengiklan) VALUES
(1, 'Promo Tokopedia 6.6', 'Tokopedia'),
(2, 'Shopee PayLater Launch', 'Shopee'),
(3, 'Traveloka Holiday Sale', 'Traveloka')
ON CONFLICT (ad_id) DO NOTHING;

SELECT setval('ads_ad_id_seq', 3);

-- 17. AD IMPRESSIONS (5 Data)
INSERT INTO ad_impressions (impression_id, user_id, ad_id, device_id, waktu_tayang, is_click) VALUES
(1, 4, 1, 4, '2026-06-02 11:45:00', true),
(2, 6, 2, 6, '2026-06-03 14:30:00', false),
(3, 8, 3, 8, '2026-06-04 16:02:00', true),
(4, 10, 1, 10, '2026-06-05 18:30:00', false),
(5, 12, 2, 1, '2026-06-06 09:30:00', true)
ON CONFLICT (impression_id) DO NOTHING;

SELECT setval('ad_impressions_impression_id_seq', 5);
