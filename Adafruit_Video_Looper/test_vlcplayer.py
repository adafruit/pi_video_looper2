import os

from .vlcplayer import VLCPlayer
from .model import Movie

os.environ["DISPLAY"] = ':0.0'

mv = Movie("/home/timc/Videos/3.mp4")
vlc_player = VLCPlayer({})

vlc_player.play(mv)
print("after")