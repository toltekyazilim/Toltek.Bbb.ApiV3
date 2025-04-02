# Toltek Bbb ApiV3 - Update Bash
# Yavuz 02/04/2025
# wget -qO- https://raw.githubusercontent.com/toltekyazilim/Toltek.Bbb.ApiV3/refs/heads/main/subu/install.sh | bash -s -- -v jammy-300
echo Toltek.Bbb.ApiV3

echo Toltek install dotnet
sudo su

sudo sudo add-apt-repository ppa:dotnet/backports

yes | sudo apt-get update
yes | sudo apt-get install apt-transport-https

yes | sudo apt-get update
yes | sudo apt-get install -y dotnet-sdk-9.0

echo Toltek install Bbb ApiV3


mkdir /var/toltek
mkdir /var/toltek/instances
mkdir /var/toltek/instances/subu 
mkdir /var/toltek/instances/subu/apps 
sudo git clone https://github.com/toltekyazilim/Toltek.Bbb.ApiV3.git /var/toltek/instances/subu/apps
cd  /var/toltek/instances/subu/apps/Toltek.Bbb.ApiV3 
git pull
dotnet dev-certs https --trust

echo Toltek configure nginx

rm /usr/share/bigbluebutton/nginx/toltek.bbb.apiv3.nginx
ln -s /var/toltek/instances/subu/apps/Toltek.Bbb.ApiV3/toltek.bbb.apiv3.nginx /usr/share/bigbluebutton/nginx/toltek.bbb.apiv3.nginx
service nginx reload

echo Toltek configure service

systemctl stop toltek.bbb.apiv3.service
#systemctl disable toltek.bbb.apiv3.service

rm /etc/systemd/system/toltek.bbb.apiv3.service
ln -s /var/toltek/instances/subu/apps/toltek.bbb.apiv3.service /etc/systemd/system/toltek.bbb.apiv3.service


systemctl start toltek.bbb.apiv3.service
systemctl status toltek.bbb.apiv3.service

sudo systemctl enable toltek.bbb.apiv3.service
#journalctl -u toltek.bbb.apiv3.service -e
