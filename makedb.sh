#!/bin/bash

access=$1
site=$2
dbname=$(grep 'DB_NAME' /var/www/$site/html/wp-config.php | cut -d "'" -f4)
dbuser=$(grep 'DB_USER' /var/www/$site/html/wp-config.php | cut -d "'" -f4)
dbpw=$(grep 'DB_PASSWORD' /var/www/$site/html/wp-config.php | cut -d "'" -f4)
rootpw="5K^DtsinUs2^K@Ge"

echo "User set to: $dbuser"
echo "Password set to: $dbpw"
echo "DB set to: $dbname"

sed -i "/DB_HOST/c\define('DB_HOST', 'localhost');" /var/www/$site/html/wp-config.php

db="CREATE DATABASE $dbname;CREATE USER $dbuser@localhost;SET PASSWORD FOR $dbuser@localhost= PASSWORD('$dbpw');GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -u root -p$rootpw -e "$db"

if [ $? != "0" ]; then
 echo "[Error]: Database creation failed"
 exit 1
else
 echo "------------------------------------------"
 echo " Database has been created successfully "
 echo "------------------------------------------"
fi

mysqldump -u $dbuser -p$dbpw -h external-db.$access $dbname > /var/dbdrop/"$site".sql

mysql -u root -p$rootpw $dbname < /var/dbdrop/"$site".sql

chmod 644 /var/www/$site/html/wp-config.php
