-- ==========================================
-- DATABASE: streaming_music_dw (Data Warehouse)
-- Dijalankan di database default (streaming_music_dw)
-- ==========================================

-- DIMENSION TABLES
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
);

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
