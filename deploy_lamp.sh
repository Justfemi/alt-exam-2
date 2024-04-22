#!/bin/bash

# Update your linux system
sudo apt-get -y update

# Add the php ondrej repository
sudo add-apt-repository -y ppa:ondrej/php

# Install php some of those php dependencies that are needed for laravel to work
sudo apt-get -y install php8.2 php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip

# Enable url rewriting
sudo a2enmod -y rewrite

# Restart your apache server
sudo systemctl restart apache2

# Change directory in the bin directory
cd /usr/bin/

# Install composer
install composer

# Download Composer installer
sudo curl -sS https://getcomposer.org/installer | sudo php

# Rename generated file
sudo mv composer.phar composer

# Change directory in /var/www
cd /var/www/

# Clone laravel site from github
sudo git clone https://github.com/laravel/laravel.git

# Give current user full ownership
sudo chown -R $USER:$USER /var/www/laravel

# Change directory to cloned repo
cd laravel/

# Install composer autoloader
install composer autoloader

# Optimize autoloader for production
composer install --optimize-autoloader --no-dev

# Get latest version of composer
composer update

# Copy .example.env file to .env 
sudo cp .env.example .env

# Change permission of storage and bootstrap/cache
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache

# Navigate to the sites-available directory
cd /etc/apache2/sites-available/

# Create a laravel.conf file
sudo touch laravel.conf

# Append content to laravel.conf
sudo echo '<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel>
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>' | sudo tee /etc/apache2/sites-available/laravel.conf

# Enable laravel.conf
sudo a2ensite laravel.conf

# Disable default apache2 page
sudo a2dissite 000-default.conf

# Restart Apache Server
sudo systemctl restart apache2

# Back to home directory
cd

# Install MySQL
sudo apt-get -y install mysql-server

# Install MySQL client
sudo apt-get -y install mysql-client

# Start MySQL
sudo systemctl start mysql

# Create a new MySQL database named 'laraveldb'
sudo mysql -uroot -e "CREATE DATABASE laraveldb;"

# Create a new MySQL user 'femi' with password 'dbpasswd' for localhost
sudo mysql -uroot -e "CREATE USER 'femi'@'localhost' IDENTIFIED BY 'dbpasswd';"

# Grant all priviledges on the 'laraveldb' to the 'femi' user
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON laraveldb.* TO 'femi'@'localhost';"

# Navigate to the .env file
cd /var/www/laravel

# Uncomment line 23-27 in the .env file using sed command
sudo sed -i "23 s/^#//g" /var/www/laravel/.env
sudo sed -i "24 s/^#//g" /var/www/laravel/.env
sudo sed -i "25 s/^#//g" /var/www/laravel/.env
sudo sed -i "26 s/^#//g" /var/www/laravel/.env
sudo sed -i "27 s/^#//g" /var/www/laravel/.env

# Replace the database connection details in the .env file
sudo sed -i '22 s/=sqlite/=mysql/' /var/www/laravel/.env
sudo sed -i '23 s/=127.0.0.1/=localhost/' /var/www/laravel/.env
sudo sed -i '24 s/=3306/=3306/' /var/www/laravel/.env
sudo sed -i '25 s/=laravel/=laraveldb/' /var/www/laravel/.env
sudo sed -i '26 s/=root/=femi/' /var/www/laravel/.env
sudo sed -i '27 s/=/=dbpasswd/' /var/www/laravel/.env

# Generate a new application key for laravel
sudo php artisan key:generate

# Create a symbolic link to the storage directory
sudo php artisan storage:link

# Run database migration
sudo php artisan migrate

# Seed database with test data
sudo php artisan db:seed

# Restart apache2 server
sudo systemctl restart apache2