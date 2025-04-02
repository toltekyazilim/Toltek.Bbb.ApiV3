# Toltek Bbb ApiV3 - Update Bash
# Yavuz 02/04/2025
# wget -qO- https://raw.githubusercontent.com/toltekyazilim/Toltek.Bbb.ApiV3/refs/heads/main/demo/install.sh | bash -s -- -v jammy-300
echo Bbb.ApiV3 install
sudo su
echo dotnet install

sudo sudo add-apt-repository ppa:dotnet/backports

yes | sudo apt-get update
yes | sudo apt-get install apt-transport-https

yes | sudo apt-get update
yes | sudo apt-get install -y dotnet-sdk-9.0

echo Bbb.ApiV3 pull


mkdir /var/toltek
mkdir /var/toltek/instances
mkdir /var/toltek/instances/demo 
mkdir /var/toltek/instances/demo/apps 
sudo git clone https://github.com/toltekyazilim/Toltek.Bbb.ApiV3.git /var/toltek/instances/demo/apps
cd  /var/toltek/instances/demo/apps/Toltek.Bbb.ApiV3 
git pull
dotnet dev-certs https --trust

echo Bbb.ApiV3 configure

rm /usr/share/bigbluebutton/nginx/toltek.bbb.apiv3.nginx
ln -s /var/toltek/instances/demo/apps/Toltek.Bbb.ApiV3/toltek.bbb.apiv3.nginx /usr/share/bigbluebutton/nginx/toltek.bbb.apiv3.nginx
service nginx reload

systemctl stop toltek.bbb.apiv3.service
#systemctl disable toltek.bbb.apiv3.service
rm /etc/systemd/system/toltek.bbb.apiv3.service
ln -s /var/toltek/instances/demo/apps/toltek.bbb.apiv3.service /etc/systemd/system/toltek.bbb.apiv3.service


echo Bbb.ApiV3 starting
systemctl start toltek.blue.api.service
systemctl status toltek.blue.api.service
sudo systemctl enable toltek.blue.api.service
#journalctl -u toltek.bbb.apiv3.service -e