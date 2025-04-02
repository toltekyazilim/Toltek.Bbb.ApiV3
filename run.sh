#!/bin/bash

# ==============================================================================
# Toltek Bbb ApiV3 - Run Bash Script
# Yavuz - 02/04/2025
# Bu script, Toltek.Bbb.ApiV3 servisini günceller.
#
# Çalıştırma Komutu (Örnek):
# wget -qO- https://raw.githubusercontent.com/toltekyazilim/Toltek.Bbb.ApiV3/refs/heads/main/run.sh | bash -s --subu
#
# Açıklama:
# - BigBlueButton için Nginx yapılandırması ayarlanır. 
# - Servis dosyaları kontrol edilir ve sistemde etkinleştirilir.
# ==============================================================================

set -e  # Hata oluşursa script'i durdur

# 📌 Kurulum Adını Parametre Olarak Al
INSTANCE_NAME=${1:-"default-instance"}

echo "📌 Kurulum başlatılıyor... (Instance: $INSTANCE_NAME)"

# 📂 Dizin yapısını oluştur
BASE_DIR="/var/toltek/instances/$INSTANCE_NAME"
APPS_DIR="$BASE_DIR/apps"
NGINX_CONFIG="/usr/share/bigbluebutton/nginx/toltek.bbb.apiv3.nginx"
SERVICE_FILE="/etc/systemd/system/toltek.bbb.apiv3.service"
REPO_URL="https://github.com/toltekyazilim/Toltek.Bbb.ApiV3.git"
SERVICE_NAME="toltek.bbb.apiv3.service"
 
# BigBlueButton Nginx yapılandırması
echo "🌐 BigBlueButton Nginx yapılandırması kontrol ediliyor..."
if [ -f "$NGINX_CONFIG" ]; then
    sudo rm "$NGINX_CONFIG"
    echo "✅ Mevcut Nginx konfigürasyonu kaldırıldı."
fi

sudo ln -s "$BASE_DIR/toltek.bbb.apiv3.nginx" "$NGINX_CONFIG"
sudo service nginx reload
echo "✅ Nginx konfigürasyonu güncellendi ve yeniden yüklendi."

# Systemd servis dosyasını oluşturma
echo "🛠️ Servis yapılandırması kontrol ediliyor..."
if systemctl list-units --full -all | grep -Fq "$SERVICE_NAME"; then
    sudo systemctl stop "$SERVICE_NAME"
    echo "✅ Mevcut servis durduruldu."
fi

if [ -f "$SERVICE_FILE" ]; then
    sudo rm "$SERVICE_FILE"
    echo "✅ Eski servis dosyası kaldırıldı."
fi

sudo ln -s "$BASE_DIR/$INSTANCE_NAME/toltek.bbb.apiv3.service" "$SERVICE_FILE"
echo "✅ Yeni servis dosyası oluşturuldu."

# Servisi başlatma ve etkinleştirme
echo "🚀 Servis başlatılıyor..."
sudo systemctl daemon-reload
sudo systemctl start "$SERVICE_NAME"
sudo systemctl enable "$SERVICE_NAME"

# Servis durumunu kontrol etme
echo "📊 Servis durumu:"
systemctl status "$SERVICE_NAME" --no-pager
echo "🎉 Kurulum tamamlandı!"
