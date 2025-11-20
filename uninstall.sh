#!/bin/bash

# Error out if anything fails.
set -e

# Make sure script is run as root.
if [ "$(id -u)" != "0" ]; then
  echo "Must be run as root with sudo! Try: sudo ./uninstall.sh"
  exit 1
fi

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
    echo "User: $USERNAME home directory not found. Unable to delete venv Try: ./uninstall.sh --user <yourusername>"
else
  rm -r /home/$USERNAME/venvs/pi_video_looper2_venv
fi


# Stop and disable video_looper service
systemctl stop video_looper
systemctl disable video_looper

rm /etc/systemd/system/video_looper.service
rm /boot/video_looper.ini

echo "Uninstalling pi_video_looper2 complete"
