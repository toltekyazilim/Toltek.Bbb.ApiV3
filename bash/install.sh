#!/bin/bash

# ==============================================================================
# Toltek Bbb ApiV3 - Update Bash Script
# Yavuz - 02/04/2025
# Bu script, Toltek.Bbb.ApiV3 servisini Ubuntu sunucusunda kurar ve günceller.
#
# Çalıştırma Komutu (Örnek):
# wget -qO- https://raw.githubusercontent.com/toltekyazilim/Toltek.Bbb.ApiV3/refs/heads/main/bash/install.sh | bash -s -- demo
# wget -qO- https://raw.githubusercontent.com/toltekyazilim/Toltek.Bbb.ApiV3/refs/heads/main/bash/install.sh | bash -s -- subu
# wget -qO- https://raw.githubusercontent.com/toltekyazilim/Toltek.Bbb.ApiV3/refs/heads/main/bash/install.sh | bash -s -- ebyu
# wget -qO- https://raw.githubusercontent.com/toltekyazilim/Toltek.Bbb.ApiV3/refs/heads/main/bash/install.sh | bash -s -- kostu
# wget -qO- https://raw.githubusercontent.com/toltekyazilim/Toltek.Bbb.ApiV3/refs/heads/main/bash/install.sh | bash -s -- ksbu

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
    DOTNET_VERSION="10.0"
else
    echo "🚨 Desteklenmeyen Ubuntu sürümü: $UBUNTU_VERSION"
    exit 1
fi

echo "🟢 Ubuntu $UBUNTU_VERSION tespit edildi. .NET $DOTNET_VERSION kontrol ediliyor..."

# .NET sürüm kontrolü
INSTALLED_DOTNET_VERSION=$(dotnet --version 2>/dev/null || echo "")
REQUIRED_VERSION="10.0"

echo "🟢 Yüklü .NET sürümü: $INSTALLED_DOTNET_VERSION (Gerekli: $REQUIRED_VERSION.x)"

if [[ "$INSTALLED_DOTNET_VERSION" != $REQUIRED_VERSION* ]]; then
    echo "🔴 .NET sürümü uygun değil veya eksik. Yükleniyor..." 
    echo "🔑 dotnet backports ekleniyor..."
    sudo add-apt-repository ppa:dotnet/backports 
    echo "📦 .NET $REQUIRED_VERSION kuruluyor..."
    sudo apt update
    sudo apt-get install -y dotnet-sdk-10.0
    sudo apt-get install -y aspnetcore-runtime-10.0

    echo "✅ .NET 10 başarıyla kuruldu."
else
    echo "🟢 Uygun .NET sürümü zaten mevcut: $INSTALLED_DOTNET_VERSION"
fi

dotnet --info

# 📂 Dizin yapısını oluştur
BASE_DIR="/var/toltek"
INSTANCE_DIR="$BASE_DIR/$INSTANCE_NAME"
APPS_DIR="$INSTANCE_DIR/apps"
SETTINGS_DIR="$INSTANCE_DIR/settings"
LOGS_DIR="$INSTANCE_DIR/logs"
NGINX_CONFIG="/usr/share/bigbluebutton/nginx/$INSTANCE_NAME.bbb.apiv3.nginx"
SERVICE_FILE="/etc/systemd/system/$INSTANCE_NAME.bbb.apiv3.service"
REPO_URL="https://github.com/toltekyazilim/Toltek.Bbb.ApiV3.git"
SERVICE_NAME="$INSTANCE_NAME.bbb.apiv3.service"

for dir in "$BASE_DIR" "$INSTANCE_DIR" "$APPS_DIR" "$SETTINGS_DIR" "$LOGS_DIR"; do
    if [ ! -d "$dir" ]; then
        sudo mkdir -p "$dir"
        echo "✅ Dizin oluşturuldu: $dir"
    else
        echo "🔹 Dizin zaten mevcut: $dir"
    fi
done
chmod 777 "$SETTINGS_DIR" "$LOGS_DIR"
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

sudo ln -s "$SETTINGS_DIR/nginx/$INSTANCE_NAME.bbb.apiv3.nginx" "$NGINX_CONFIG"
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

# DOSYALAR ÖNCE YÜKLENMEDİĞİ İÇİN ÇALIŞTIRAMIYORUZ. 2 Script yapıp pre ve post diye uygulayabiliriz
#echo "Veritabanına kullanıcı ekleniyor uygulanıyor..."
#bash /var/toltek/$INSTANCE_NAME/settings/$INSTANCE_NAME-postgres.sh
#echo "Veritabanına migrations uygulanıyor..."
#sudo -u postgres psql -U postgres -d bbb_graphql -f /var/toltek/$INSTANCE_NAME/settings/BbbContext.sql
# sudo -u postgres psql -U postgres -d bbb_graphql -f /var/toltek/$INSTANCE_NAME/settings/migration2.sql


sudo ln -s "$SETTINGS_DIR/systemd/$INSTANCE_NAME.bbb.apiv3.service" "$SERVICE_FILE"
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
sudo systemctl enable $INSTANCE_NAME.bbb.apiv3.service

# 📌 Notlar
# Servis başlamazsa veya hata alırsanız, aşağıdaki komutları kullanarak servis durumunu kontrol edebilirsiniz:
# journalctl -u subu.bbb.apiv3.service -e
# systemctl status subu.bbb.apiv3.service
# 🛑 Servisi durdurma ve devre dışı bırakma
# sudo systemctl stop subu.bbb.apiv3.service
# sudo systemctl disable subu.bbb.apiv3.service

# sudo systemctl stop subu.bbb.apiv3.service
# sudo -i -u postgres -- psql -U postgres -d bbb_graphql -q -f "/tmp/bbb_schema.sql" --set ON_ERROR_STOP=on

# chmod +x /var/toltek/subu/settings/subu-postgres.sh
# bash /var/toltek/subu/settings/subu-postgres.sh

