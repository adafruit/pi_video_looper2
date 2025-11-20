# Copyright 2025 Adafruit Industries.
# Author: Tim Cocks
# License: GNU GPLv2, see LICENSE.txt

import shutil

import tempfile
import time

import pygame
import vlc

from .alsa_config import parse_hw_device

class VLCPlayer:

    def __init__(self, config):
        """Create an instance of a video player that runs omxplayer in the
        background.
        """
        self._process = None
        self._temp_directory = None
        self._vlc_instance = vlc.Instance()
        self._video_player = self._vlc_instance.media_player_new()
        self._video_directory = config.get("directory", "path")

        self._load_config(config)

        # set the player into pygame's window so that
        # pygame still has control over key events
        win_id = pygame.display.get_wm_info()['window']
        self._video_player.set_xwindow(win_id)


    def __del__(self):
        if self._temp_directory:
            shutil.rmtree(self._temp_directory)

    def _get_temp_directory(self):
        if not self._temp_directory:
            self._temp_directory = tempfile.mkdtemp()
        return self._temp_directory

    def _load_config(self, config):
        self._extensions = "avi, mov, mkv, mp4, m4v".split(", ")

    def supported_extensions(self):
        """Return list of supported file extensions."""
        return self._extensions

    def play(self, movie, loop=None, vol=0):
        print(f"play called on {movie} - {movie.filename} - target: {movie.target}")
        """Play the provided movie file, optionally looping it repeatedly."""
        media = self._vlc_instance.media_new(movie.target)
        self._video_player.set_media(media)
        self._video_player.play()

        # wait until the video starts
        while not self._video_player.is_playing():
            time.sleep(0.1)

    def pause(self):
        self._video_player.pause()
    
    def sendKey(self, key: str):
        # if self.is_playing():
        #     self._process.stdin.write(key.encode())
        #     self._process.stdin.flush()
        pass

    def is_playing(self):
        """Return true if the video player is running or paused, false otherwise.
        Becomes false automatically after video finishes."""
        return self._video_player.is_playing() or self._video_player.get_state() == vlc.State.Paused

    def stop(self, block_timeout_sec=0):
        self._video_player.stop()

    @staticmethod
    def can_loop_count():
        return False


def create_player(config, **kwargs):
    """Create new video player based on omxplayer."""
    return VLCPlayer(config)
