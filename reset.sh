#!/bin/bash
clear

stty erase '^?'

dbhost="localhost"
dbname="magento_vanilla"
dbuser="root"
dbpass="root"
url="http://localhost.magento-vanilla/"
adminuser="admin"
adminpass="admin123"
adminfname="First"
adminlname="Last"
adminemail="admin@localhost.com"
sample="y"

version="1.9.1.0"


echo
echo "Now installing Magento with sample data..."

echo
echo "Downloading Magento..."
echo

wget -q -S -N http://www.magentocommerce.com/downloads/assets/$version/magento-$version.tar.gz

echo
echo "Downloading Magento Sample Data..."
echo

wget -q -S -N http://www.magentocommerce.com/downloads/assets/$version/magento-sample-data-$version.tar.gz

echo
echo "Removing existing Magento files..."
echo 

rm -rf magento

echo
echo "Extracting data..."
echo

tar -zxvf magento-$version.tar.gz
tar -zxvf magento-sample-data-$version.tar.gz

echo
echo "Moving files..."
echo

ditto -V magento-sample-data-$version/ magento/
mv magento-sample-data-$version/magento_sample_data_for_$version.sql magento/data.sql

echo
echo "Setting permissions..."
echo

cd magento
chmod o+w var var/.htaccess app/etc
chmod -R o+w media
chmod +x mage

echo
echo "Dropping database..."
echo

mysql -h $dbhost -u $dbuser -p$dbpass -f -e "DROP DATABASE IF EXISTS $dbname"

echo
echo "Creating database..."
echo

mysql -h $dbhost -u $dbuser -p$dbpass -f -e "CREATE DATABASE $dbname"

echo
echo "Importing sample products..."
echo

mysql -h $dbhost -u $dbuser -p$dbpass $dbname < data.sql

echo
echo "Cleaning up files..."
echo

rm -rf *.sample *.txt

echo
echo "Installing Magento..."
echo

   php -f install.php -- \
    --license_agreement_accepted "yes" \
    --locale "en_US" \
    --timezone "America/Los_Angeles" \
    --default_currency "USD" \
    --db_host "localhost" \
    --db_name "$dbname" \
    --db_user "$dbuser" \
    --db_pass "$dbpass" \
    --url "$url" \
    --use_rewrites "yes" \
    --use_secure "no" \
    --secure_base_url "" \
    --use_secure_admin "no" \
    --admin_firstname "$adminfname" \
    --admin_lastname "$adminlname" \
    --admin_email "$adminemail" \
    --admin_username "$adminuser" \
    --admin_password "$adminpass"

echo
echo "Setting admin messages to read..."
echo 

mysql -h $dbhost -u $dbuser -p$dbpass -f -e "USE $dbname; update adminnotification_inbox set is_read = 1"

echo
echo "Removing demo store notice..."
echo 

mysql -h $dbhost -u $dbuser -p$dbpass -f -e "USE $dbname; update core_config_data set value = 0 where path='design/head/demonotice'"

echo
echo "Clearing cache and refreshing indexes..."
echo

rm -rf var/cache/*
rm -rf var/session/*
php -f shell/indexer.php reindexall


echo
echo "Finished installing the latest stable version of Magento with Sample Data"
echo

echo "+=================================================+"
echo "| MAGENTO LINKS"
echo "+=================================================+"
echo "|"
echo "| Store: $url"
echo "| Admin: ${url}admin/"
echo "|"
echo "+=================================================+"
echo "| ADMIN ACCOUNT"
echo "+=================================================+"
echo "|"
echo "| Username: admin"
echo "| Password: $adminpass"
echo "|"
echo "+=================================================+"
echo "| DATABASE INFO"
echo "+=================================================+"
echo "|"
echo "| Database: $dbname"
echo "| Username: $dbuser"
echo "| Password: $dbpass"
echo "|"
echo "+=================================================+"


