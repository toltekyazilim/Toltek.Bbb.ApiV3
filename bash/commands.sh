 ﻿#!/bin/bash
 #📌 Notlar
 #Servis başlamazsa veya hata alırsanız, aşağıdaki komutları kullanarak servis durumunu kontrol edebilirsiniz:
 journalctl -u ebyu.bbb.apiv3.service -e
 systemctl status ebyu.bbb.apiv3.service
 🛑 Servisi durdurma ve devre dışı bırakma
 sudo systemctl restart ebyu.bbb.apiv3.service
 sudo systemctl stop ebyu.bbb.apiv3.service
 sudo systemctl disable ebyu.bbb.apiv3.service
 sudo systemctl status ebyu.bbb.apiv3.service

 sudo systemctl stop subu.bbb.apiv3.service
 sudo -i -u postgres -- psql -U postgres -d bbb_graphql -q -f "/tmp/bbb_schema.sql" --set ON_ERROR_STOP=on

 chmod +x /var/toltek/subu/settings/subu-postgres.sh
 bash /var/toltek/subu/settings/subu-postgres.sh