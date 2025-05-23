#!/bin/bash

# Define variables
BACKUP_DIR="$HOME/github_backup"
ARCHIVE_FILE="$HOME/github_backup_$(date +%Y-%m-%d).tar.gz"
ENCRYPTED_FILE="$ARCHIVE_FILE.gpg"
LOG_FILE="$HOME/github_backup.log"
EMAIL="docbenjamen@gmail.com"
RETENTION_DAYS=7  # Delete backups older than X days

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Start logging
echo "🕒 $(date): Starting GitHub backup" | tee -a "$LOG_FILE"

# Navigate to backup directory
cd "$BACKUP_DIR" || exit

# Fetch all repositories and clone/update as bare mirrors
gh repo list chemben17  --json name -q '.[].name' | while read -r repo; do
    {
        if [ ! -d "$repo.git" ]; then
            echo "📥 Cloning $repo..." | tee -a "$LOG_FILE"
            git clone --mirror "https://github.com/chemben17/$repo.git"
        else
            echo "🔄 Updating $repo..." | tee -a "$LOG_FILE"
            cd "$repo.git" || exit
            git fetch --all
            cd ..
        fi
    } &
done
wait

# Compress backup directory
echo "📦 Compressing backup..." | tee -a "$LOG_FILE"
tar -czf "$ARCHIVE_FILE" -C "$HOME" "github_backup"

# Encrypt the backup
echo "🔒 Encrypting backup..." | tee -a "$LOG_FILE"
gpg --symmetric --cipher-algo AES256 --output "$ENCRYPTED_FILE" "$ARCHIVE_FILE"

# Remove unencrypted archive after encryption
rm "$ARCHIVE_FILE"

# Remove old backups to save storage
echo "🗑️ Removing backups older than $RETENTION_DAYS days..." | tee -a "$LOG_FILE"
find "$HOME" -name "github_backup_*.tar.gz.gpg" -mtime +$RETENTION_DAYS -exec rm {} \;

# Upload to cloud storage (Google Drive example)
#echo "☁️ Uploading to Google Drive..." | tee -a "$LOG_FILE"
#rclone copy "$ENCRYPTED_FILE" gdrive:/GitHubBackups/

# Send email notification
if [ -f "$ENCRYPTED_FILE" ]; then
    echo "✅ GitHub backup completed successfully! File: $ENCRYPTED_FILE" | mail -s "GitHub Backup Success" "$EMAIL"
    echo "✅ Backup complete!" | tee -a "$LOG_FILE"
else
    echo "❌ Backup failed!" | mail -s "GitHub Backup Failure" "$EMAIL"
    echo "❌ Backup failed!" | tee -a "$LOG_FILE"
fi

