#!/bin/bash

# Error out if anything fails.
set -e

# Make sure script is run as root.
if [ "$(id -u)" != "0" ]; then
  echo "Must be run as root with sudo! Try: sudo ./install.sh"
  exit 1
fi


echo "Installing linux dependencies..."
echo "=========================="
apt update && apt -y install python3 python3-pip supervisor

echo "Making virtualenv ..."
echo "=========================="
python -m venv venvs/pi5_video_looper_venv


echo "Installing python dependencies..."
echo "=========================="
source venvs/pi5_video_looper_venv/bin/activate
pip install python-vlc
pip install setuptools
pip install pygame

echo "Installing video_looper program..."
echo "=================================="

# change the directory to the script location
cd "$(dirname "$0")"

python setup.py install --force

cp ./assets/video_looper.ini /boot/video_looper.ini

echo "Configuring video_looper to run on start..."
echo "==========================================="

cp ./assets/video_looper.conf /etc/supervisor/conf.d/

service supervisor restart

echo "Finished!"
