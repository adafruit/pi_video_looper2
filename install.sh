#!/bin/bash

# Error out if anything fails.
set -e

# Parse command line arguments
USERNAME=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --user)
      USERNAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 --user <username>"
      exit 1
      ;;
  esac
done

# Check if username was provided
if [ -z "$USERNAME" ]; then
  USERNAME="pi"
fi

if [ ! -d /home/$USERNAME ]; then
    echo "User: $USERNAME home directory not found. Try: ./install.sh --user <yourusername>"
    exit 1
fi

# Make sure script is run as root.
if [ "$(id -u)" != "0" ]; then
  echo "Must be run as root with sudo! Try: sudo ./install.sh"
  exit 1
fi


echo "Installing linux dependencies..."
echo "=========================="
apt update && apt -y install python3 python3-pip

echo "Making virtualenv ..."
echo "=========================="
python -m venv /home/$USERNAME/venvs/pi_video_looper2_venv
chown -R $USERNAME:$USERNAME /home/$USERNAME/venvs/pi_video_looper2_venv


echo "Installing python dependencies..."
echo "=========================="
source /home/$USERNAME/venvs/pi_video_looper2_venv/bin/activate


echo "Installing pi_video_looper2 program..."
echo "=================================="

# change the directory to the script location
cd "$(dirname "$0")"

pip install ./

# Copy the ini template file
cp ./assets/video_looper.ini.template ./assets/video_looper.ini

# Replace {USERNAME} with the actual username
sed -i "s/{USERNAME}/$USERNAME/g" ./assets/video_looper.ini

# Copy the updated ini file to /boot/
cp ./assets/video_looper.ini /boot/video_looper.ini

echo "Configuring video_looper to run on start..."
echo "==========================================="

# Copy the ini template file
cp ./assets/video_looper.service.template ./assets/video_looper.service

# Replace {USERNAME} with the actual username
sed -i "s/{USERNAME}/$USERNAME/g" ./assets/video_looper.service

cp ./assets/video_looper.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable video_looper
systemctl start video_looper
echo "Finished!"
