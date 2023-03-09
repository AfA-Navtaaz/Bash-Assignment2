#!/bin/bash

# Set up variables
BACKUP_DIR="/home/navtaaz/task_002/data2"
REMOTE_SERVER="user@remote-server"
REMOTE_DIR="/path/to/remote/directory"
S3_BUCKET="my-s3-bucket"
S3_ENDPOINT="http://localhost:4566" 

# Define function to create backup archive
create_backup() {
  # Create a compressed archive of the backup directory
  timestamp=$(date +%Y-%m-%d_%H:%M:%S)
  backup_filename="backup_${timestamp}.tar.gz"
  tar -czf "${BACKUP_DIR}/${backup_filename}" /home/navtaaz/task_002/impdata
}

# Define function to copy backup to remote server
copy_to_remote() {
  # Copy the backup to the remote server using AWS CLI
#   aws --endpoint-url $AWS_ENDPOINT s3 cp "$LOCAL_DIR/$BACKUP_FILENAME" s3://$AWS_BUCKET/ --region $AWS_REGION

  aws --endpoint-url $S3_ENDPOINT s3 cp "$BACKUP_DIR/$backup_filename" "s3://$S3_BUCKET/$backup_filename"
#   scp "${BACKUP_DIR}/${backup_filename}" "${REMOTE_SERVER}:${REMOTE_DIR}"
}

# Define function to test backup and recover data
test_backup() {
  # Delete important data to simulate data loss
  rm -rf /home/navtaaz/task_002/impdata
  
  # Restore data from backup
  tar -xzf "${BACKUP_DIR}/${backup_filename}" -C /

  # Verify that important data has been restored
  ls -l /home/navtaaz/task_002/impdata
}

# Run backup and copy to remote server
create_backup
copy_to_remote

# Test backup and recover data
test_backup
