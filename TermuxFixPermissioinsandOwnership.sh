#!/data/data/com.termux/files/usr/bin/bash

echo "Fixing Termux permissions..."

# Step 1: Reset permissions for Termux internal directories
echo "Resetting permissions for internal directories..."
chmod -R 700 /data/data/com.termux/files
chmod 700 /data/data/com.termux/files/home
chmod 700 /data/data/com.termux/files/usr

# Step 2: Reconfigure storage access
echo "Reconfiguring storage access..."
termux-setup-storage

# Step 3: Reset ownership (if needed)
echo "Resetting ownership of Termux files..."
UID=$(id -u)
GID=$(id -g)
chown -R $UID:$GID /data/data/com.termux/files

# Step 4: Restore SELinux contexts (optional, requires root)
if [ "$(id -u)" -eq 0 ]; then
    echo "Restoring SELinux contexts..."
    restorecon -R /data/data/com.termux/files
else
    echo "Skipping SELinux context restoration (root required)."
fi

# Step 5: Verify permissions
echo "Verifying permissions..."
ls -ld /data/data/com.termux/files/*
ls -l ~/storage

echo "Permissions fixed! Please restart Termux if needed."
