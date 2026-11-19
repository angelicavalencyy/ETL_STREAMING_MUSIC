# ETL Streaming Music Data Warehouse

Proyek ETL (Extract, Transform, Load) untuk membangun Data Warehouse platform musik streaming menggunakan **Apache Hop**, **PostgreSQL**, dan **pgAdmin** yang dijalankan di dalam container **Docker**.

---

##  Arsitektur & Teknologi

- **Source Database**: PostgreSQL (`etl_database`) — OLTP berisi 17 tabel data operasional Spotify/Streaming.
- **Target Data Warehouse**: PostgreSQL (`streaming_music_dw`) — Skema Bintang (Star Schema) berisi 12 Dimension Tables dan 6 Fact Tables.
- **ETL Tool**: Apache Hop Web (Port `8081`).
- **Database Management**: pgAdmin 4 (Port `5050`).
- **Orkestrasi**: Docker & Docker Compose.

---

##  Struktur Direktori

```text
etl-project/
├── docker-compose.yaml               # Konfigurasi container Docker
├── .gitignore
├── README.md
├── hop-projects/
│   └── streaming-project/            # Project Apache Hop
│       ├── project-config.json       # Konfigurasi Hop project
│       ├── workflow.hwf              # Main workflow orkestrasi ETL
│       ├── metadata/                 # Definisi koneksi DB (RDBMS)
│       │   └── rdbms/
│       │       ├── SOURCE_STREAMING_MUSIC.json
│       │       └── TARGET_STREAMING_MUSIC.json
│       └── pipelines/                # Pipeline transformasi Hop (.hpl)
│           ├── PL_DIM_USERS.hpl
│           ├── PL_DIM_STATUS.hpl
│           ├── PL_DIM_PACKAGE.hpl
│           ├── PL_DIM_ACTIVITY.hpl
│           ├── PL_DIM_DATE.hpl
│           ├── PL_SUBSCRIPTION.hpl
│           ├── PL_FACT_USER_ACTIVITY.hpl
│           └── PL_FACT_PAYMENT.hpl
├── pgadmin/
│   ├── servers.json                  # Auto-register koneksi PostgreSQL di pgAdmin
│   └── pgpass                        # Password otomatis koneksi DB
└── postgres/
    └── init/
        ├── 01-create-source-db.sql   # DDL + Dummy Data OLTP (etl_database)
        └── 02-create-dw.sql          # DDL Data Warehouse (streaming_music_dw)
```

---

## Panduan Setup (After Clone dari Git)

Jika baru saja clone repository ini ke local, langkah-langkahnya:

### 1. Clone Repository
```bash
git clone https://github.com/angelicavalencyy/ETL_STREAMING_MUSIC.git
cd ETL_STREAMING_MUSIC
```

### 2. Jalankan Container
Pastikan **Docker Desktop** sudah berjalan, lalu jalankan:
```bash
docker compose up -d
```
> *Database `etl_database` dan `streaming_music_dw` beserta tabel dan dummy data akan otomatis diinisialisasi oleh script di folder `postgres/init/`.*

### 3. Beri Izin Tulis untuk Apache Hop (Hanya saat inisialisasi awal)
Jalankan perintah ini satu kali agar container Hop memiliki izin menulis konfigurasi:
```bash
docker exec -u 0 etl-hop chown -R hop:hop /hop/config /hop/audit
```

### 4. Mendaftarkan Project di Apache Hop Web
Jika di Apache Hop Web project `streaming-project` belum muncul di dropdown:

**Cara A (Otomatis via Terminal):**
```bash
docker exec etl-hop /usr/local/tomcat/webapps/ROOT/hop-conf.sh \
  --project=streaming-project \
  --project-create \
  --project-home=/hop/projects/streaming-project \
  --project-config-file=project-config.json \
  --project-keep-config-file
```
Lalu refresh browser di `http://localhost:8081` dan pilih `streaming-project` di dropdown pojok kiri atas.

**Cara B (Manual via GUI Web):**
1. Buka [http://localhost:8081](http://localhost:8081).
2. Di pojok kiri atas, klik tombol **`+`** (di samping dropdown project).
3. Masukkan:
   - **Project name**: `streaming-project`
   - **Home folder**: `/hop/projects/streaming-project`
   - **Config file**: `project-config.json`
4. Klik **OK / Save**, lalu pilih `streaming-project` pada dropdown.

---

##  Informasi Akses & Kredensial

| Layanan | URL | Kredensial |
|---|---|---|
| **pgAdmin 4** | [http://localhost:5050](http://localhost:5050) | Email: `admin@etl.com`<br>Password: `admin123` |
| **Apache Hop Web** | [http://localhost:8081](http://localhost:8081) | Langsung terbuka (tanpa login) |
| **PostgreSQL** | `localhost:5432` | User: `etl_user`<br>Password: `etl_password`<br>DB: `etl_database` & `streaming_music_dw` |

*(Server PostgreSQL sudah otomatis terdaftar di pgAdmin dengan nama **ETL PostgreSQL**).*

---

##  Runtutan Eksekusi ETL di Apache Hop

Agar integritas referensial (Foreign Key) terpenuhi, pipeline **harus** dijalankan sesuai urutan:

### Tahap 1: Eksekusi Dimension Tables
1. `PL_DIM_USERS.hpl`
2. `PL_DIM_STATUS.hpl`
3. `PL_DIM_PACKAGE.hpl`
4. `PL_DIM_ACTIVITY.hpl`
5. `PL_DIM_DATE.hpl`

### Tahap 2: Eksekusi Fact Tables
1. `PL_SUBSCRIPTION.hpl`
2. `PL_FACT_USER_ACTIVITY.hpl`
3. `PL_FACT_PAYMENT.hpl`

> **Tips:** dapat menjalankan seluruh pipeline secara berurutan dan otomatis melalui file workflow:
> **`hop-projects/streaming-project/workflow.hwf`**.

---

##  Git 

### Aturan Simpan di Apache Hop Web
Saat membuat atau mengedit pipeline di Apache Hop Web, simpan file ke direktori:
```text
/hop/projects/streaming-project/pipelines/NAMA_PIPELINE.hpl
```
*(Atau klik folder **`pipelines`** pada window Save As).* File otomatis tersinkronisasi secara realtime ke folder local.

### Commit
Buka terminal di folder project, lalu jalankan:
```bash
git add .
git commit -m "feat (pipelines): add PL_DIM_ALBUM "
git push origin main
```

### Menghentikan & Menjalankan Kembali Layanan
Data tersimpan aman di Docker named volumes meskipun laptop dimatikan/direstart.
- **Mematikan container**: `docker compose down`
- **Menjalankan kembali**: `docker compose up -d`
