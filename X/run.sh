# Toltek Bbb ApiV3 - Run Bash
# Yavuz 02/04/2025
FILE=/usr/share/bigbluebutton/nginx/toltek.bbb.apiv3.nginx
if [ -f "$FILE" ]; then
    systemctl stop toltek.bbb.apiv3.service

    rm /usr/share/bigbluebutton/nginx/toltek.bbb.apiv3.nginx
    ln -s /var/toltek/instances/demo/apps/Toltek.Bbb.ApiV3/toltek.bbb.apiv3.nginx /usr/share/bigbluebutton/nginx/toltek.bbb.apiv3.nginx

    rm /etc/systemd/system/toltek.bbb.apiv3.service
    ln -s /var/toltek/instances/demo/apps/toltek.bbb.apiv3.service /etc/systemd/system/toltek.bbb.apiv3.service

else
    echo "$FILE does not exist."
fi

service nginx reload
systemctl start toltek.bbb.apiv3.service
systemctl status toltek.bbb.apiv3.service