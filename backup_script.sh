#!/bin/bash
set -e

# Load konfigurasi dari file .env
if [ -f .env ]; then
  source .env
else
  echo "❌ File .env tidak ditemukan!"
  exit 1
fi

# Informasi sistem
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
FILENAME_DATE=$(date +'%Y-%m-%d')
HSTNAME=$(hostname)
LOCAL_IP=$(hostname -I | awk '{print $1}')

# Lokasi backup
TEMP_DIR="${BACKUP_DIR}/temp_daily"
ARCHIVE="${BACKUP_DIR}/${HSTNAME}_mysql_backup_${FILENAME_DATE}.tar.gz"

# Bersihkan backup sebelumnya untuk hari ini
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Inisialisasi log Telegram (mode HTML)
LOG="🛡️ <b>Backup MySQL Dimulai</b>
🖥️ Host: <b>${HSTNAME}</b> (${LOCAL_IP})
🕒 Waktu: <b>${TIMESTAMP}</b>

"

SUCCESS=0
FAILED=0

# Loop dan backup tiap database
for DB in $MYSQL_DATABASES; do
  OUT="$TEMP_DIR/${DB}.sql"
  if mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -h"$MYSQL_HOST" -P"$MYSQL_PORT" "$DB" > "$OUT" 2>/dev/null; then
    LOG+="✅ <b>$DB</b> berhasil dibackup
"
    SUCCESS=$((SUCCESS + 1))
  else
    LOG+="❌ <b>$DB</b> gagal dibackup
"
    FAILED=$((FAILED + 1))
  fi
done

# Kompres backup dan hapus direktori sementara
tar -czf "$ARCHIVE" -C "$TEMP_DIR" .
rm -rf "$TEMP_DIR"

# Kirim backup ke server via rsync
if rsync -az -e "ssh -p ${SSH_PORT}" "$ARCHIVE" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"; then
  LOG+="
📤 <b>Backup berhasil dikirim</b> ke server via rsync.
"
else
  LOG+="
⚠️ <b>Gagal mengirim backup</b> ke server via rsync.
"
fi

# Tambahan informasi akhir
LOG+="
📁 Arsip: <code>${ARCHIVE##*/}</code>
📂 Lokal: <code>${BACKUP_DIR}</code>
🔢 Sukses: <b>${SUCCESS}</b> | Gagal: <b>${FAILED}</b>
"

# Kirim log ke Telegram
RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/telegram_response.txt -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d parse_mode="HTML" \
  --data-urlencode text="$LOG")

if [[ "$RESPONSE" != "200" ]]; then
  echo "❌ Gagal mengirim ke Telegram. Response code: $RESPONSE"
  echo "🔍 Respon Telegram:"
  cat /tmp/telegram_response.txt
else
  echo "✅ Pesan berhasil dikirim ke Telegram."
fi

# Tampilkan log juga di terminal
echo -e "$LOG"
