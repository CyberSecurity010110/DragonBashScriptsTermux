#!/data/data/com.termux/files/usr/bin/bash

echo "========================================="
echo "       Restoring Termux Environment      "
echo "========================================="

# Step 1: Ensure storage permission is granted
echo -e "\n[Step 1] Ensuring storage permission is granted..."
/data/data/com.termux/files/usr/bin/termux-setup-storage
if [ $? -ne 0 ]; then
    echo "Error: Failed to grant storage permission. Please try again."
    exit 1
fi

# Step 2: Define backup file and log file
BACKUP_FILE="/sdcard/termux-home-backup.tar.gz"
ERROR_LOG="/sdcard/termux-restore-errors.log"

# Step 3: Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found at $BACKUP_FILE. Please ensure the file exists."
    exit 1
fi

# Step 4: Extract the backup archive
echo -e "\n[Step 2] Extracting backup archive..."
/data/data/com.termux/files/usr/bin/tar -zxf "$BACKUP_FILE" -C /data/data/com.termux/files --recursive-unlink --preserve-permissions 2> "$ERROR_LOG"

if [ $? -eq 0 ]; then
    echo "Restore completed successfully!"
else
    echo "Restore completed with errors. See $ERROR_LOG for details."
fi

# Step 5: Fix permissions for home and usr directories
echo -e "\n[Step 3] Fixing permissions..."
chmod -R 700 /data/data/com.termux/files/home && echo "Permissions fixed for home directory."
chmod -R 700 /data/data/com.termux/files/usr && echo "Permissions fixed for usr directory."

# Step 6: List problematic files (if any)
if [ -s "$ERROR_LOG" ]; then
    echo -e "\n[Step 4] Listing problematic files..."
    /data/data/com.termux/files/usr/bin/cat "$ERROR_LOG"
else
    echo "No problematic files encountered during restore."
fi

echo -e "\n========================================="
echo "       Restore Process Complete          "
echo "========================================="