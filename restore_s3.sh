#!/bin/bash

# Make sure S3 is mounted
if [ $(grep -c 's3fs\s/s3' /proc/mounts) -eq 0 ]; then
    s3fs wp-backup-2676 /s3
fi

# Make sure we're in repo top dir
cd `dirname $0`

# Get DB UID AND GID
DB_IDS=$(ls -lan db | tail -n 1)
DB_UID=$(echo $DB_IDS | awk '{print $3}')
DB_GID=$(echo $DB_IDS | awk '{print $3}')

# Get Wordpress UID and GID
WP_IDS=$(ls -lan wordpress | tail -n 1)
WP_UID=$(echo $WP_IDS | awk '{print $3}')
WP_GID=$(echo $WP_IDS | awk '{print $3}')

# Set up temp dir out of S3 bucket for perms changing
TEMP_DIR=/home/ec2-user/backup_temp
rm -rf $TEMP_DIR
mkdir $TEMP_DIR

# Copy bucket contents to temp dir, then ultimate target
cp -r /s3/db /s3/wordpress /s3/.env $TEMP_DIR
sudo cp -r $TEMP_DIR/* .

# Set permissions for db and wordpress directories
cd db
sudo chown -R $DB_UID:$DB_GID *
cd ../wordpress
sudo chown -R $WP_UID:$WP_GID *

# Copy .env file for use with Docker Compose
cp /s3/.env .

# Relaunch
cd ..
docker-compose up -d

# Cleanup
rm -rf $TEMP_DIR