#!/usr/bin/env bash

# Website config and credentials.
WWW_URL="websiteurl.com" # Website URL.
WWW_DB_HOST="dbhost.websiteurl.com" # Database host URL or IP.
WWW_DB_USER="database_user" # Database user.
WWW_DB_PASS="database_p4ssw0rd" # Database password.
WWW_DB_NAME="database_schema" # Database schema name.
WWW_FTP_HOST="ftp.websiteurl.com" # FTP host URL or IP.
WWW_FTP_PATH="path/to/public_html" # Without first and last slash "/"
WWW_FTP_USER="ftp_user" # FTP user.
WWW_FTP_PASS="ftp_p4ssw0rd" # FTP password.

# Script and backup config.
BKP_KEEPNUMBER=8 # Number of backups to keep.

BKP_BASE_SCRIPT=$(readlink -f "$0") 
BKP_BASE_DIR=$(dirname "$BKP_BASE_SCRIPT")"/" #Absolute path to current script directory, can be replaced manually with: BKP_BASE_DIR="/volume1/Backups/www/globalmar.net/"
BKP_CURR_DIR=$BKP_BASE_DIR"bkp_"$(date +"%Y%m%d")"/"
BKP_CURR_TGZ=$BKP_BASE_DIR$WWW_URL"_"$(date +"%Y%m%d")".tar.gz"

# Backup process.

echo "Beginning backup $WWW_URL: [$(date +"%Y-%m-%d %H:%M:%S"))]"
echo "    Creating directory [$(date +"%H:%M:%S")]"
if [ -d "$BKP_CURR_DIR" ]; then
  echo "        Deleting path for storage backup, it exists..."
  rm -fr $BKP_CURR_DIR
fi
mkdir $BKP_CURR_DIR
cd $BKP_CURR_DIR

echo "    Downloading database [$(date +"%H:%M:%S")]"
mysqldump --host=$WWW_DB_HOST --port=3306 --user=$WWW_DB_USER --password=$WWW_DB_PASS --databases $WWW_DB_NAME --single-transaction --quick --lock-tables=false > /$BKP_CURR_DIR$WWW_URL.db.sql

echo "    Downloading files [$(date +"%H:%M:%S")]"
BKP_CONN_FILE=$BKP_BASE_DIR"conn.lftp"
if [ -f "$BKP_CONN_FILE" ]; then
    echo "        Deleting lftp configuration file..."
	rm -f $BKP_CONN_FILE
fi
echo "set ftp:ssl-allow false" >> $BKP_CONN_FILE
echo "set ssl:verify-certificate no" >> $BKP_CONN_FILE
echo "open ftp://$WWW_FTP_USER:$WWW_FTP_PASS@$WWW_FTP_HOST" >> $BKP_CONN_FILE
echo "mirror --parallel=5 --use-pget-n=5 --continue $WWW_FTP_PATH $BKP_CURR_DIR/files/;" >> $BKP_CONN_FILE
lftp -f $BKP_BASE_DIR"conn.lftp" > /dev/null 2>&1
rm -f $BKP_CONN_FILE

echo "    Compressing backup [$(date +"%H:%M:%S")]"
tar -czf $BKP_CURR_TGZ -C $BKP_CURR_DIR .

echo "    Deleting downloaded files [$(date +"%H:%M:%S")]"
rm -fr $BKP_CURR_DIR

echo "    Deleting oldests backups, keeeping last $BKP_KEEPNUMBER backups [$(date +"%H:%M:%S")]"
find $BKP_BASE_DIR -maxdepth 1 -iname "*.tar.gz" | head -n -$BKP_KEEPNUMBER | xargs -d '\n' rm -f

echo "DONE! [$(date +"%H:%M:%S")]"
