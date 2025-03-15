#!/data/data/com.termux/files/usr/bin/bash

echo "========================================="
echo "       Backing Up Termux Home Directory  "
echo "========================================="

# Step 1: Ensure storage permission is granted
echo -e "\n[Step 1] Ensuring storage permission is granted..."
/data/data/com.termux/files/usr/bin/termux-setup-storage
if [ $? -ne 0 ]; then
    echo "Error: Failed to grant storage permission. Please try again."
    exit 1
fi

# Step 2: Define backup destination and temporary log file
BACKUP_FILE="/sdcard/termux-home-backup.tar.gz"
ERROR_LOG="/sdcard/termux-backup-errors.log"

# Step 3: Compress and move home directory
echo -e "\n[Step 2] Compressing home directory..."
/data/data/com.termux/files/usr/bin/tar -zcf "$BACKUP_FILE" -C /data/data/com.termux/files/home . --ignore-failed-read --warning=no-file-changed 2> "$ERROR_LOG"

if [ $? -eq 0 ]; then
    echo "Backup completed successfully!"
    echo "Backup file location: $BACKUP_FILE"
else
    echo "Backup completed with errors. See $ERROR_LOG for details."
fi

# Step 4: List problematic files (if any)
if [ -s "$ERROR_LOG" ]; then
    echo -e "\n[Step 3] Listing problematic files..."
    /data/data/com.termux/files/usr/bin/cat "$ERROR_LOG"
else
    echo "No problematic files encountered during backup."
fi

echo -e "\n========================================="
echo "       Backup Process Complete           "
echo "========================================="