#!/data/data/com.termux/files/usr/bin/bash

#Replace xfc with your preferred wildcard selection but without *. In the above instance I wanted to run pkg install xfc* to install all xfce related packages, but ran into dependency issues. instead put xfc in the script above and it does pkg inst xfc* but works thru the issues autonomously 

for pkg in $(pkg list-all | grep 'xfc' | cut -d'/' -f1); do
    echo "Attempting to install $pkg..."
    pkg install -y "$pkg" || echo "Failed to install $pkg, skipping..."
done