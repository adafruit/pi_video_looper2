# Copyright 2015, 2025 Adafruit Industries.
# Author: Tony DiCola, Tim Cocks
# License: GNU GPLv2, see LICENSE.txt
import glob
import os


class USBDriveReader:

    def __init__(self, config):
        """Create an instance of a file reader that watches drives that have
        been automatically mounted for reading videos.
        """
        self._load_config(config)
        self._mount_dir_state = os.listdir(self._mount_path)


    def _load_config(self, config):
        self._mount_path = config.get('usb_drive', 'mount_path')


    def search_paths(self):
        """Return a list of paths to search for files. Will return a list of all
        mounted USB drives.
        """
        return glob.glob(self._mount_path + '*')

    def is_changed(self):
        """Return true if the file search paths have changed, like when a new
        USB drive is inserted.
        """
        currrent_state = os.listdir(self._mount_path)
        changed = currrent_state != self._mount_dir_state
        self._mount_dir_state = currrent_state

        return changed

    def idle_message(self):
        """Return a message to display when idle and no files are found."""
        return 'Insert USB drive with compatible movies.'


def create_file_reader(config, screen):
    """Create new file reader based on mounting USB drives."""
    return USBDriveReader(config)
