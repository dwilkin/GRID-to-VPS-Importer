#!/bin/bash

site=$1

mkdir /var/www/$site

chown sunrise:www-data /var/www/$site

chmod 775 /var/www/$site

cat <<EOT > /etc/apache2/sites-available/$site.conf
<VirtualHost *:8080>
	ServerName $site
	ServerAlias www.$site
	DocumentRoot /var/www/$site/html
	<Directory /var/www/$site>
		AllowOverride All
		Options +FollowSymlinks
	</Directory>
	<LocationMatch "/wp-admin/post.php">
         SecRuleRemoveById 300016
      </LocationMatch>

      <LocationMatch "/wp-admin/nav-menus.php">
         SecRuleRemoveById 300016
      </LocationMatch>

      <LocationMatch "(/wp-admin/|/wp-login.php)">
         SecRuleRemoveById 950117
         SecRuleRemoveById 950005
      </LocationMatch>
</VirtualHost>
EOT

a2ensite $site


cat <<EOT >> /etc/nginx/sites-available/apache
server {
    listen 80;
    server_name $site www.$site;
    root /var/www/$site/html;
    index index.php index.htm index.html;

    location / {
     try_files \$uri \$uri/ /index.php;
    }

    location ~ \.php$ {
        proxy_pass http://72.10.33.85:8080\$request_uri;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    location ~ /\. {
     deny all;
    }
}
EOT

service apache2 reload
service nginx reload
