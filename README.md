# 🔐 MySQL Backup Harian ke Server dengan Telegram Log

Script ini melakukan backup harian database MySQL, mengarsipkan dalam file `.tar.gz`, mengirim ke server remote via `rsync` menggunakan SSH, dan mengirim laporan ke Telegram dengan format rapi.

---

## 📦 Fitur

* ✅ Backup banyak database (didefinisikan dalam `.env`)
* ✅ Hanya satu file backup per hari (ditimpa jika dieksekusi ulang)
* ✅ Kompresi hasil backup ke `.tar.gz`
* ✅ Kirim via `rsync` menggunakan koneksi SSH tanpa password
* ✅ Kirim laporan hasil backup ke Telegram (parse\_mode: HTML)
* ✅ Menampilkan ukuran file backup di laporan Telegram

---

## ⚙️ Konfigurasi `.env`

Buat file `.env` di direktori yang sama:

```env
# MySQL
MYSQL_USER=root
MYSQL_PASSWORD=rahasia
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DATABASES="simkom_db kinerja_db pasar_db"

# Direktori lokal backup
BACKUP_DIR=/data/backup/mysql-local

# Server remote (via SSH)
REMOTE_USER=backupuser
REMOTE_HOST=backup.example.com
REMOTE_PATH=/data/backup/server1
SSH_PORT=22

# Telegram Bot
TELEGRAM_BOT_TOKEN=123456789:ABCDEFyourbotToken
TELEGRAM_CHAT_ID=123456789
```

---

## 🔐 Konfigurasi SSH Tanpa Password (id\_rsa)

Agar `rsync` tidak meminta password saat mengirim ke server:

### 1. Buat SSH key (jika belum)

```bash
ssh-keygen -t rsa -b 4096 -C "backup@local"
# Tekan Enter terus (jangan isi passphrase)
```

### 2. Kirim public key ke server backup

```bash
ssh-copy-id -p 22 backupuser@backup.example.com
```

### 3. Uji koneksi tanpa password

```bash
ssh -p 22 backupuser@backup.example.com
```

Jika langsung masuk tanpa diminta password, maka sudah berhasil.

---

## 🚀 Menjalankan Script

### Manual:

```bash
chmod +x backup_script.sh
./backup_script.sh
```

### Otomatis via `cron` (misal jam 2 dini hari):

```bash
0 2 * * * /path/to/backup_script.sh >> /var/log/mysql_backup.log 2>&1
```

---

## 🧾 Contoh Log Telegram

```
🛡️ Backup MySQL Dimulai
🖥️ Host: cd-nt (192.168.1.14)
🕒 Waktu: 2025-06-20 19:44:01

✅ simkom_db berhasil dibackup
✅ kinerja_db berhasil dibackup
✅ pasar_db berhasil dibackup

📤 Backup berhasil dikirim ke server via rsync.

📁 Arsip: cd-nt_mysql_backup_2025-06-20.tar.gz
📂 Lokal: /data/backup/mysql-local
📦 Ukuran: 1.2 MB
🔢 Sukses: 3 | Gagal: 0
```

---

## 📁 Struktur Output

* `/data/backup/mysql-local/`

  * `cd-nt_mysql_backup_2025-06-20.tar.gz` ← File hasil backup hari ini

---

## 🤝 Kontribusi

Script ini dapat dikembangkan untuk:

* Upload file langsung ke Telegram
* Backup semua database secara otomatis
* Backup ke beberapa server sekaligus

Pull Request dan ide sangat diterima!
