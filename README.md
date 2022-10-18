# Simple Website Backup Script

Really simple bash script to backup websites (files and MySQL database). This script is a simple automation of downloading all files in a FTP path and a MySQL database and compress periodically to store a number of backups.

## Requisites

Minimum requisites for this to work:

 - Linux shell backup with Bash
 - FTP and MySQL credentials (and remote access, some hosts block external access to database)
 - cron to periodically runs the scripts
 - 'mysqldump' installed on the system running the script
 - 'lftp' installed on the system running the script
 - 'tar' installed on the system running the script
 - 'find' installed on the system running the script

## Configuration

Script is sef-explanatory 😉.
