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
 
export ASPNETCORE_ENVIRONMENT=$INSTANCE_NAME)
export DOTNET_PRINT_TELEMETRY_MESSAGE=true
export ConfigPath=/var/toltek/$INSTANCE_NAME)/settings
export Instance=$INSTANCE_NAME)

cd /var/toltek/$INSTANCE_NAME)/apps/Toltek.Bbb.ApiV3/app
dotnet Toltek.Bbb.ApiV3.dll
