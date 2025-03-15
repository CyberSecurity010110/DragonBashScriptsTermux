#!/data/data/com.termux/files/usr/bin/bash

echo "========================================="
echo "       Fixing Termux Permissions         "
echo "========================================="

# Step 1: Reset permissions for Termux internal directories
echo -e "\n[Step 1] Resetting permissions for internal directories..."
DIRECTORIES=(
    "/data/data/com.termux/files"
    "/data/data/com.termux/files/home"
    "/data/data/com.termux/files/usr"
)

for DIR in "${DIRECTORIES[@]}"; do
    if [ -d "$DIR" ]; then
        echo "Processing directory: $DIR"
        chmod -R 700 "$DIR" && echo "Permissions set to 700 for $DIR"
    else
        echo "Directory not found: $DIR (skipping)"
    fi
done

# Step 2: Reconfigure storage access
echo -e "\n[Step 2] Reconfiguring storage access..."
echo "Running termux-setup-storage to reconfigure storage links..."
termux-setup-storage && echo "Storage access has been successfully reconfigured."

# Step 3: Reset ownership (if needed)
echo -e "\n[Step 3] Resetting ownership of Termux files..."
UID=$(id -u)
GID=$(id -g)
echo "Detected UID: $UID, GID: $GID"
for DIR in "${DIRECTORIES[@]}"; do
    if [ -d "$DIR" ]; then
        echo "Resetting ownership for directory: $DIR"
        chown -R $UID:$GID "$DIR" && echo "Ownership reset to UID:$UID and GID:$GID for $DIR"
    else
        echo "Directory not found: $DIR (skipping)"
    fi
done

# Step 4: Restore SELinux contexts (optional, requires root)
if [ "$(id -u)" -eq 0 ]; then
    echo -e "\n[Step 4] Restoring SELinux contexts (requires root)..."
    for DIR in "${DIRECTORIES[@]}"; do
        if [ -d "$DIR" ]; then
            echo "Restoring SELinux context for directory: $DIR"
            restorecon -R "$DIR" && echo "SELinux context restored for $DIR"
        else
            echo "Directory not found: $DIR (skipping)"
        fi
    done
else
    echo -e "\n[Step 4] Skipping SELinux context restoration (root required)."
fi

# Step 5: Verify permissions
echo -e "\n[Step 5] Verifying permissions..."
for DIR in "${DIRECTORIES[@]}"; do
    if [ -d "$DIR" ]; then
        echo "Permissions for directory: $DIR"
        ls -ld "$DIR"
    else
        echo "Directory not found: $DIR (skipping)"
    fi
done

echo "Listing storage directory links:"
ls -l ~/storage

echo -e "\n========================================="
echo "       Termux Permissions Fixed!         "
echo "========================================="
echo "Please restart Termux if needed."