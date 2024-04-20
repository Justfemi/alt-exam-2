#!/bin/bash

#add the php repository
sudo add-apt-repository ppa:ondrej/php


sudo apt update

#install php8.2
sudo apt install php8.2 -y

#install php dependencies
sudo apt install php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip

#enable url rewriting
sudo a2enmod rewrite

#restart apache2 server
sudo service apache2 restart

#change directory to /usr/bin
cd /usr/bin/

#download composer installer
curl -sS https://getcomposer.org/installer | sudo php

#rename generated file
sudo mv composer.phar composer

#change directory to /var/www
cd /var/www/

#clone laravel site from github
sudo git clone https://github.com/laravel/laravel.git

#change directory to cloned repository
cd laravel

#optimises autoloader for production
sudo composer install --optimize-autoloader --no-dev

#get latest version of composer
sudo composer update

#copy .example.env to .env
sudo cp .env.example .env

#generate APP_KEY for .env file
sudo php artisan key:generate

#check user of apache2 server
ps aux | grep "apache" | awk '{print $1}' | grep -v root | head -n 1

#change permission of storage and bootstrap/cache
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache

#navigate to the sites-available directory
cd /etc/apache2/sites-available

#create a config file
sudo touch newlaravel.conf

#append content to newlaravel.conf
sudo echo '
  <VirtualHost *:80>
    ServerName  192.168.50.20
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
  </VirtualHost>' | sudo tee /etc/apache2/sites-available/newlaravel.conf

#enable newlaravel.conf
sudo a2ensite newlaravel.conf

#restart apache server
sudo systemctl restart apache2

#install mysql
sudo apt-get install mysql-server -y

#start mysql
sudo systemctl start mysql

# Create a temporary file to store MySQL commands
temp_sql_file="$(mktemp)"
echo "CREATE DATABASE IF NOT EXISTS mylaraveldb;" >> "$temp_sql_file"
echo "CREATE USER 'femi'@'localhost' IDENTIFIED BY 'mydbpassword';" >> "$temp_sql_file"
echo "GRANT ALL PRIVILEGES ON mylaraveldb.* TO 'femi'@'localhost';" >> "$temp_sql_file"
echo "FLUSH PRIVILEGES;" >> "$temp_sql_file"

# Execute MySQL commands
sudo mysql < "$temp_sql_file"

#navigate to the .env file
cd /var/www/laravel/

# Remove the temporary SQL file
rm -f "$temp_sql_file"

# Append database connection information to .env file
echo "DB_CONNECTION=mysql" >> .env
echo "DB_HOST=localhost" >> .env
echo "DB_PORT=3306" >> .env
echo "DB_DATABASE=mylaraveldb" >> .env
echo "DB_USERNAME=femi" >> .env
echo "DB_PASSWORD=mydbpassword" >> .env

# Run migration
sudo php artisan migrate

# Output success message
echo "MySQL setup completed successfully."

