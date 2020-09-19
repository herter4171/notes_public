#!/bin/bash

# Make sure S3 is mounted
if [ $(grep -c 's3fs\s/s3' /proc/mounts) -eq 0 ]; then
    s3fs wp-backup-2676 /s3
fi

# Make sure we're in repo top dir
cd `dirname $0`

# Copy env file
cp .env /s3

TEMP_DIR=/home/ec2-user/backup_temp
rm -rf $TEMP_DIR
mkdir $TEMP_DIR

sudo cp -r db wordpress .env $TEMP_DIR
sudo chown -R ec2-user:ec2-user $TEMP_DIR

# Copy database and wordpress content to S3
rsync -auv $TEMP_DIR/*  /s3

# Cleanup
rm -rf $TEMP_DIR
