# pi_video_looper2
This is a forked & updated version of the original project [pi_video_looper](https://github.com/adafruit/pi_video_looper). It aims to support Raspberry Pi 4 & 5 and the latest Raspberry Pi OS.

This version uses VLC as the sole supported video playback engine. omxplayer and hello_video are not supported.

An application to turn your Raspberry Pi 4 or 5 into a dedicated looping video playback device.
Can be used in art installations, fairs, theatre, events, infoscreens, advertisements etc...

Works right out of the box, but also has a lot of customisation options to make it fit your use case. See the [video_looper.ini](https://github.com/adafruit/pi_video_looper2/blob/main/assets/video_looper.ini.template) configuration file for an overview of options. 

If you miss a feature just post an issue here on Github. (https://github.com/adafruit/pi_video_looper2)

## About this fork
This fork adds two features to Video Looper 2, aimed at motion-triggered installations
(Halloween props, haunted houses, museum exhibits):

* **`gpio_pin_mode`** – trigger polarity for mapped GPIO pins. Upstream always uses a pull-up and
  triggers when the pin is pulled to Ground. With `gpio_pin_mode = false` the pins use a pull-down
  and trigger when they go to 3.3V, so **active-high sensors such as the HC-SR501 PIR can be wired
  directly**, without a transistor inverter.
* **Relay output** – switches a relay together with GPIO triggers, e.g. a fog machine or humidifier.
  `relay_mode = timer` keeps it ON for a fixed time after each trigger; `relay_mode = follow` keeps it
  ON while the sensor detects people and turns it OFF a few seconds after they leave, with a
  safety limit.

All new settings default to upstream behaviour, so existing configurations are unaffected.
See [GPIO sensors and relay output](#gpio-sensors-and-relay-output-fork) below.

To install the fork instead of upstream, clone this repository in the install step:
```shell
git clone https://github.com/<your-github-user>/pi_video_looper2
```

## Feature Warning
The datetime display showing between videos during wait_time is not functioning properly in this version.
All other features from the original pi_video_looper are believed to be tested and working, please file an issue if you find something that isn't.

## Changelog
#### fork additions
 - `gpio_pin_mode` option for active-high GPIO triggers (e.g. HC-SR501 PIR)
 - optional relay output (`relay_pin`, `relay_active_low`, `relay_mode`, `relay_seconds`, `relay_max_seconds`)
 - documentation: `gpio_pin_map` uses Blinka pin names (`"D17"`), not BOARD numbers

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

### Disable USB Auto-mount dialog.
By default the Raspberry Pi OS file manager displays a pop-up dialog with options for what to do with the files found
on USB drives that have been inserted. This can overtake and minimize the pi_video_looper program. To disable the
dialog pop-up:

- Open the File Manager
- Click Edit -> Preferences
- Click Volume Management in the left navigation
- Uncheck the "Show available options for removable media when they are inserted"

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
Pins use Blinka board names: the BCM GPIO number with a `D` prefix, e.g. `"D17"` is GPIO17 on physical pin 11 - see: https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#gpio. With the default `gpio_pin_mode = true`, bridge a mapped pin with a Ground pin to trigger it.

The pin mapping has the form: "pinname" : "action". The action can be one of the following:
* a filename as a string to play 
* an absolute index number (starting with 0) 
* a string in the form of `+n` or `-n` (with n being an integer) for a relative jump
* a keyboard command (see above) in the form of a pygame key constant (see list: https://www.pygame.org/docs/ref/key.html)

Here are some examples that can be set: 
* `"D17" : 1`  -> GPIO17 (pin 11) will start the second file in the playlist
* `"D27" : 4` -> GPIO27 (pin 13) starts the 5th video
* `"D23" : "+2"` -> GPIO23 (pin 16) jumps 2 videos ahead
* `"D24" : "-1"` -> GPIO24 (pin 18) jumps one video back
* `"D22" : "video.mp4"` -> GPIO22 (pin 15) plays a file with name "video.mp4" (if it exists)
* `"D10" : "K_SPACE"` -> GPIO10 (pin 19) sends the "space" keyboard command, pausing the current video
* `"D9" : "K_p"` -> GPIO9 (pin 21) sends "p" keyboard command and thus triggers the shutdown of the Raspberry Pi

For your convenience, these exact mappings can be easily enabled by uncommenting the example line in the video_looper.ini. You can also define your own mappings.

Note: to be used as an absolute index the action needs to be an integer not a string.
Note 2: "keyboard_control" needs to be enabled in the ini for gpio to utilise keyboard commands.

#### GPIO sensors and relay output (fork)
**Active-high sensors.** Set `gpio_pin_mode = false` to use a pull-down and trigger when the pin goes to 3.3V.
Example with an HC-SR501 PIR sensor that starts the second video on motion:

```ini
[control]
gpio_pin_map = "D26" : 1
gpio_pin_mode = false
```

| HC-SR501 | Raspberry Pi |
|---|---|
| VCC | pin 2 (5V) |
| GND | pin 39 (GND) |
| OUT | pin 37 (GPIO26) |

The HC-SR501 output is 3.3V, so it is safe for the GPIO. Set its time potentiometer (Tx) a little longer than
the triggered video, otherwise a new trigger can restart the video before it ends.

**Relay output.** Switches a relay (fog machine, humidifier, lights) together with the GPIO triggers:

```ini
relay_pin = D16
relay_active_low = true
relay_mode = follow
relay_seconds = 10
relay_max_seconds = 300
```

| Setting | Meaning |
|---|---|
| `relay_pin` | Blinka name of the pin driving the relay input. Empty disables the relay. |
| `relay_active_low` | `true` for the common optocoupler relay boards (relay ON when the input is LOW). |
| `relay_mode` | `timer`: ON for `relay_seconds` after each trigger. `follow`: ON while a mapped pin is active, OFF `relay_seconds` after it clears. |
| `relay_seconds` | Timer length, or hold time after the sensor clears in follow mode. |
| `relay_max_seconds` | Follow mode only: maximum continuous ON time. Afterwards the relay stays OFF until the sensor clears. |

Wiring for a typical 5V optocoupler relay board, with the VCC/JD-VCC jumper removed so the GPIO side runs at 3.3V:

| Relay board | Raspberry Pi |
|---|---|
| JD-VCC | pin 4 (5V, relay coil) |
| VCC | pin 1 (3.3V, optocoupler) |
| GND | pin 6 (GND) |
| IN1 | pin 36 (GPIO16) |

Switch mains appliances on the live wire through COM/NO only inside an insulated enclosure, or use a low-voltage
appliance instead.

Note: in the ini file, put comments on their own line. A comment after a value becomes part of the value.


## Troubleshooting:
* nothing happening (screen flashes once) when in copymode and new drive is plugged in?
    * check if you have the "password file" on your drive (see copymode explained above)
* log output can be displayed with `journalctl -fu video_looper`. Enable detailed logging in the video_looper.ini with console_output = true.
