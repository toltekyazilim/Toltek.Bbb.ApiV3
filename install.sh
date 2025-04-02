#!/bin/bash

# ==============================================================================
# Toltek Bbb ApiV3 - Update Bash Script
# Yavuz - 02/04/2025
# Bu script, Toltek.Bbb.ApiV3 servisini Ubuntu sunucusunda kurar ve günceller.
#
# Çalıştırma Komutu (Örnek):
# wget -qO- https://raw.githubusercontent.com/toltekyazilim/Toltek.Bbb.ApiV3/refs/heads/main/install.sh | bash -s -- subu

#
# Açıklama:
# - .NET SDK ve Runtime kontrol edilir ve eksikse kurulur.
# - BigBlueButton için Nginx yapılandırması ayarlanır.
# - Toltek.Bbb.ApiV3 kod deposu çekilir/güncellenir.
# - Servis dosyaları kontrol edilir ve sistemde etkinleştirilir.
# ==============================================================================

set -e  # Hata oluşursa script'i durdur

# 📌 Kurulum Adını Parametre Olarak Al
INSTANCE_NAME=${1:-"default-instance"}

echo "📌 Kurulum başlatılıyor... (Instance: $INSTANCE_NAME)"

# Ubuntu sürümünü öğren
UBUNTU_VERSION=$(lsb_release -rs)

# .NET için en uygun sürümü belirle
if [[ "$UBUNTU_VERSION" == "24.04" ]] || [[ "$UBUNTU_VERSION" == "22.04" ]]; then
    DOTNET_VERSION="9.0"
else
    echo "🚨 Desteklenmeyen Ubuntu sürümü: $UBUNTU_VERSION"
    exit 1
fi

echo "🟢 Ubuntu $UBUNTU_VERSION tespit edildi. .NET $DOTNET_VERSION kontrol ediliyor..."

# .NET yüklü mü kontrol et
if ! command -v dotnet &> /dev/null; then
    echo "🔴 .NET yüklü değil, kurulum başlatılıyor..."
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates wget software-properties-common

    echo "🔑 Microsoft paket deposu ekleniyor..."
    wget -q https://packages.microsoft.com/config/ubuntu/$UBUNTU_VERSION/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb

    echo "📦 .NET $DOTNET_VERSION yükleniyor..."
    sudo apt update
    sudo apt install -y dotnet-sdk-$DOTNET_VERSION aspnetcore-runtime-$DOTNET_VERSION
    echo "✅ .NET $DOTNET_VERSION başarıyla yüklendi."
else
    echo "✅ .NET zaten yüklü: $(dotnet --version)"
fi

dotnet --info

# 📂 Dizin yapısını oluştur
BASE_DIR="/var/toltek/instances/$INSTANCE_NAME"
APPS_DIR="$BASE_DIR/apps"
NGINX_CONFIG="/usr/share/bigbluebutton/nginx/$INSTANCE_NAME.bbb.apiv3.nginx"
SERVICE_FILE="/etc/systemd/system/$INSTANCE_NAME.bbb.apiv3.service"
REPO_URL="https://github.com/toltekyazilim/Toltek.Bbb.ApiV3.git"
SERVICE_NAME="$INSTANCE_NAME.bbb.apiv3.service"

for dir in "/var/toltek" "/var/toltek/instances" "$BASE_DIR" "$BASE_DIR/settings" "$APPS_DIR"; do
    if [ ! -d "$dir" ]; then
        sudo mkdir -p "$dir"
        echo "✅ Dizin oluşturuldu: $dir"
    else
        echo "🔹 Dizin zaten mevcut: $dir"
    fi
done

# Repository çekme veya güncelleme
echo "🔄 Repository güncelleniyor..."
if [ ! -d "$APPS_DIR/Toltek.Bbb.ApiV3/.git" ]; then
    sudo git clone "$REPO_URL" "$APPS_DIR/Toltek.Bbb.ApiV3"
    echo "✅ Repository klonlandı."
else
    cd "$APPS_DIR/Toltek.Bbb.ApiV3"
    git reset --hard  # Çakışmaları önlemek için
    git pull origin main
    echo "✅ Repository güncellendi."
fi

# SSL Sertifikasını güvenilir hale getirme
echo "🔒 SSL sertifikası yapılandırılıyor..."
dotnet dev-certs https --trust || echo "⚠️ Dev-cert yapılandırması başarısız oldu."

# BigBlueButton Nginx yapılandırması
echo "🌐 BigBlueButton Nginx yapılandırması kontrol ediliyor..."
if [ -f "$NGINX_CONFIG" ]; then
    sudo rm "$NGINX_CONFIG"
    echo "✅ Mevcut Nginx konfigürasyonu kaldırıldı."
fi

sudo ln -s "$APPS_DIR/Toltek.Bbb.ApiV3/config/$INSTANCE_NAME.bbb.apiv3.nginx" "$NGINX_CONFIG"
sudo service nginx reload
echo "✅ Nginx konfigürasyonu güncellendi ve yeniden yüklendi."

# Systemd servis dosyasını oluşturma
echo "🛠️ Servis yapılandırması kontrol ediliyor..."
if systemctl list-units --full -all | grep -Fq "$SERVICE_NAME"; then
    sudo systemctl stop "$SERVICE_NAME"
    echo "✅ Mevcut servis durduruldu."
fi

if [ -e "$SERVICE_FILE" ]; then
    if [ -L "$SERVICE_FILE" ]; then
        sudo unlink "$SERVICE_FILE"
        echo "✅ Eski sembolik link kaldırıldı."
    else
        sudo rm -f "$SERVICE_FILE"
        echo "✅ Eski servis dosyası kaldırıldı."
    fi
fi

sudo ln -s "$APPS_DIR/Toltek.Bbb.ApiV3/config/$INSTANCE_NAME.bbb.apiv3.service" "$SERVICE_FILE"
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

journalctl -u $INSTANCE_NAME.bbb.apiv3.service -e
sudo systemctl enable $INSTANCE_NAME.blue.api.service
# journalctl -u subu.bbb.apiv3.service -e