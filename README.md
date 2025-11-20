# pi_video_looper2
This is a forked & updated version of the original project [pi_video_looper](https://github.com/adafruit/pi_video_looper). It aims to support Raspberry Pi 5 and the latest Raspberry Pi OS.

This version uses VLC as the sole supported video playback engine. omxplayer and hello_video are not supported.

An application to turn your Raspberry Pi 5 into a dedicated looping video playback device.
Can be used in art installations, fairs, theatre, events, infoscreens, advertisements etc...

Works right out of the box, but also has a lot of customisation options to make it fit your use case. See the [video_looper.ini](https://github.com/adafruit/pi_video_looper2/blob/main/assets/video_looper.ini.template) configuration file for an overview of options. 

If you miss a feature just post an issue here on Github. (https://github.com/adafruit/pi_video_looper2)

## Feature Warning
Not all features from the original pi_video_looper have been implemented or tested yet.
Current known working functionality is limited to basic directory playback and keyboard controls. 
Looping, repeating, random playlists, GPIO, and usb_copymode are not implemented yet.

## Changelog
#### new in v0.1.0
 - Forked from original pi_video_looper
 - vlcplayer added
 - support for user other than pi
 - use systemd instead of supervisor
 - pyproject.toml instead of setup.py
 - uninstall.sh script
 - readonly drive mounted is not supported. Drive mounting is handled automatically by the OS.

## How to install
```shell
sudo apt-get install git
cd ~
git clone https://github.com/adafruit/pi_video_looper2  
cd pi_video_looper2
sudo ./install.sh
```

By default, the install.sh script assumes use of 'pi' user. To specify a different user pass the --user argument.
```shell
sudo ./install.sh --user myusername
```

Default player is vlcplayer.

## How to update
An update is always like a fresh installation so you will lose custom changes made to the /boot/video_looper.ini   

For backing up the current ini:     
`sudo cp /boot/video_looper.ini /boot/video_looper.ini_backup`  

For the update:
```shell
cd ~
sudo rm -rf pi_video_looper2
git clone https://github.com/adafruit/pi_video_looper2    
cd pi_video_looper2 
sudo ./install.sh 
```

## Features and settings
To change the settings of the video looper (e.g. random playback, copy mode, GPIO control, advanced features) edit the `/boot/video_looper.ini` file, i.e. by quitting the player with 'ESC' and logging in to the Raspberry with an attached keyboard, or remotely via ssh. Then edit the configuration file with `sudo nano /boot/video_looper.ini`.

Alternatively insert the SD card into your computer and edit it with your preferred text editor. 

#### copymode explained:
By default, the looper plays any video files from a USB drive in alphabetical order. With copymode, you only need a USB drive once, to copy the video files directly onto the RPi's SD card. Once enabled in the video_looper.ini, all files from an attached USB drive are copied onto the RPi. A progress bar shows you, well, the progress of the operation.

To protect the player from unauthorised access you need to create a file on the drive called "videopi". The extension doesn't matter. This file acts as a password. (The wording of this "password" can be changed in the video_looper.ini)

You might also want to decide if new files on the drive should replace existing files or get added. "Replace" means that any existing videofiles on the RPi get deleted, and only the new files remain.  
This setting can be overruled by placing a file named "replace" or "add" on the drive.  
The default mode is "replace".  

Note: files with the same name always get overwritten.  

#### notable things:
* you can have one video repeated X times before playing the next by adding _repeat_Nx to the filename of a video, where N is a positive number
    * with hello_video there is no gap when a video is repeated but there is a small gap between different videos
    * with omxplayer there will also be a short gap between the repeats
    
* if you have only one video then omxplayer will also loop seamlessly (and with audio)

* to reduce the wear of the SD card and potentially extend the lifespan of the player, you could enable the overlay filesystem via `raspi-config` and select Performance Options->Overlay Filesystem

### Control
The video looper can be controlled via keyboard input or via configured GPIO pins. 
Keyboard control is enabled by default via the `keyboard_control` setting in the video_looper.ini file. 

#### keyboard commands:
The following keyboard commands are active by default (can be disabled in the [video_looper.ini](https://github.com/adafruit/pi_video_looper2/blob/main/assets/video_looper.ini.template)):
* "ESC" - stops playback and exits video_looper
* "k" - sKip - stops the playback of current file and plays next file
* "b" - Back - stops the playback of current file and plays previous file
* "s" - Stop/Start - stops or starts playback of current file
* "p" - Power off - stop playback and shutdown RPi
* " " - (space bar) - Pause/Resume the player

#### GPIO control:
To enable GPIO control you need to set a GPIO pin mapping via the `gpio_pin_map` in the `control` section of the video_looper.ini. 
Pins numbers are in "BOARD" numbering - see: https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#gpio. Bridge a mapped pin with a Ground pin to trigger it.

The pin mapping has the form: "pinnumber" : "action”. The action can be one of the following:
* a filename as a string to play 
* an absolute index number (starting with 0) 
* a string in the form of `+n` or `-n` (with n being an integer) for a relative jump
* a keyboard command (see above) in the form of a pygame key constant (see list: https://www.pygame.org/docs/ref/key.html)

Here are some examples that can be set: 
* `"11" : 1`  -> pin 11 will start the second file in the playlist
* `"13" : "4"` -> pin 13 starts the 5th video
* `"16" : "+2"` -> pin 16 jumps 2 videos ahead
* `"18" : "-1"` -> pin 18 jumps one video back
* `"15" : "video.mp4"` -> pin 15 plays a file with name "video.mp4" (if it exists)
* `"19" : "K_SPACE"` -> pin 19 sends the "space" keyboard command, pausing the current video
* `"21" : "K_p"` -> pin 21 sends "p" keyboard command and thus triggers the shutdown of the Raspberry Pi

For your convenience, these exact mappings can be easily enabled by uncommenting the example line in the video_looper.ini. You can also define your own mappings.

Note: to be used as an absolute index the action needs to be an integer not a string.
Note 2: "keyboard_control" needs to be enabled in the ini for gpio to utilise keyboard commands.


## Troubleshooting:
* nothing happening (screen flashes once) when in copymode and new drive is plugged in?
    * check if you have the "password file" on your drive (see copymode explained above)
* log output can be displayed with `journalctl -fu video_looper`. Enable detailed logging in the video_looper.ini with console_output = true.
