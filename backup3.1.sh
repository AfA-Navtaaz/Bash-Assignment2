#!/bin/bash

# Set up variables
BACKUP_DIR="/home/navtaaz/task_002/data2"
S3_BUCKET="my-s3-bucket"
S3_ENDPOINT="http://localhost:4566" 
IMP_DIR="/home/navtaaz/task_002/impdata"  #(Passing the directory to be backed up)

# Help function
usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "-d, --dir <backup_directory>  The directory to backup (default: /home/navtaaz/task_002/impdata)"
  echo "-b, --bucket <bucket_name>    The name of the S3 bucket (my-s3-bucket)"
  echo "-l, --localstack <url>       The URL of the Localstack server (default: http://localhost:4566)"
  echo "-h, --help                   Show this help message"
  exit 1
}

# Parse options
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -d|--dir)
      IMP_DIR="$2"
      shift
      shift
      ;;
    -b|--bucket)
      BUCKET_NAME="$2"
      shift
      shift
      ;;
    -l|--localstack)
      LOCALSTACK_HOST="$2"
      shift
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# Define function to create backup archive
create_backup() {

  # Create a compressed archive of the backup directory
  timestamp=$(date +%Y-%m-%d_%H:%M:%S)

  backup_filename="backup_${timestamp}.tar.gz"
  tar -czf "${BACKUP_DIR}/${backup_filename}" "$IMP_DIR"
}

# Define function to copy backup to remote server
copy_to_remote() {

  # Copy the backup to the s3 bucket using AWS CLI
  aws --endpoint-url $S3_ENDPOINT s3 cp "$BACKUP_DIR/$backup_filename" "s3://$S3_BUCKET/$backup_filename"
}

# Define function to test backup and recover data
test_backup() {
  
  # Delete important data to simulate data loss
  rm -rf $IMP_DIR
  
  # Restore data from backup
  tar -xzf "${BACKUP_DIR}/${backup_filename}" -C /

  # Verify that important data has been restored
  ls -l $IMP_DIR
}

# Run backup and copy to remote server
create_backup
copy_to_remote

# Test backup and recover data
test_backup
