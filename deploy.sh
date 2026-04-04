#!/bin/bash
set -e
WEB_ROOT="/var/www/cv"
cp -r /home/$SUDO_USER/cv/public/. $WEB_ROOT
chown -R www-data:www-data $WEB_ROOT
chmod -R 755 $WEB_ROOT
systemctl reload nginx
echo "Deployed to $WEB_ROOT
