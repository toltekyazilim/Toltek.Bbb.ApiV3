# Toltek Blue Api - Update Bash
# Yavuz 31/01/2025

FILE=/etc/bigbluebutton/nginx/toltek.blue.api.nginx
if [ -f "$FILE" ]; then
    systemctl stop toltek.blue.api.service

    rm /etc/systemd/system/toltek.blue.api.service
    ln -s /var/toltek/instances/subu/apps/subu/toltek.blue.api.service /etc/systemd/system/toltek.blue.api.service

    rm /usr/share/bigbluebutton/nginx/toltek.blue.api.nginx
    ln -s /var/toltek/instances/subu/apps/subu/toltek.blue.api.nginx /usr/share/bigbluebutton/nginx/toltek.blue.api.nginx

else
    echo "$FILE does not exist."
fi

service nginx reload
systemctl restart toltek.blue.api.service
systemctl status toltek.blue.api.service