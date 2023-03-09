#!/bin/bash

# Define local and remote directories
LOCAL_DIR="/home/navtaaz/task_002/data"
REMOTE_DIR="/path/to/remote/backup"

# Define remote server details
REMOTE_USER="ubuntu"
REMOTE_HOST="remote.host.com"
REMOTE_SSH_KEY="testing.pem"

# Define AWS S3 bucket details
AWS_BUCKET="my-s3-bucket"
AWS_REGION="us-west-2"
AWS_ENDPOINT="http://localhost:4566"  # For localstack

# Define backup file naming convention
BACKUP_FILENAME="backup-$(date +%Y-%m-%d-%H:%M:%S).tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$LOCAL_DIR"

# Create backup using tar and gzip
tar czf "$LOCAL_DIR/$BACKUP_FILENAME" /home/navtaaz/task_002/impdata

# Copy backup to remote server

# SCP command
# scp -i "$REMOTE_SSH_KEY" "$LOCAL_DIR/$BACKUP_FILENAME" $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR

# AWS CLI command
aws --endpoint-url $AWS_ENDPOINT s3 cp "$LOCAL_DIR/$BACKUP_FILENAME" s3://$AWS_BUCKET/ --region $AWS_REGION

# Test backup by extracting it to a temporary directory
TEMP_DIR=/home/navtaaz/task_002/example
mkdir -p "$TEMP_DIR"

tar xzf "$LOCAL_DIR/$BACKUP_FILENAME" -C "$TEMP_DIR"
# Check that important data was successfully restored
if [ ! -d "$TEMP_DIR/home/navtaaz/task_002/impdata/" ]; then
  echo "Backup test failed. Data not found."
  exit 1
fi
echo "Backup test succeeded. Data restored."

# Clean up temporary directory
rm -rf "$TEMP_DIR"

# For scp:
# scp -i "$REMOTE_SSH_KEY" $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/latest-backup.tar.gz "$LOCAL_DIR"
# tar xzf "$LOCAL_DIR/latest-backup.tar.gz" -C /

# For AWS CLI:
mkdir -p "$LOCAL_DIR/latestbackup"

LAST_BACKUP_DIR="/home/navtaaz/task_002/"

# LAST_BACKUP_FILENAME=$(aws --endpoint-url=http://localhost:4566 s3 ls s3://my-s3-bucket/  | grep -E '.*' | tail -1)


aws --endpoint-url $AWS_ENDPOINT s3 cp s3://$AWS_BUCKET/$BACKUP_FILENAME  "$LAST_BACKUP_DIR" --region $AWS_REGION
mv $BACKUP_FILENAME Latest_Backup.tar

tar -xvf Latest_Backup.tar
rm -rf "Latest_Backup.tar"
