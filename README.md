#FrSky Taranis Script for 360° Panorama
---

##How to install the Script?
1. Put the script.lua file on your Taranis SD-Card at "\SCRIPTS\FUNCTIONS"
2. Edit your OpenTX Model and add a special function with the action "Play Script" and the Parameter "script.lua"
3. Assign a Switch to that special function
4. Go out and shoot some 360° Panorama!



##How to setup the Script?

You need to edit the script and set the channel of your Pitch and Yaw Axis of your Gimbal as well as the Channel for your Camera Shutter.

`local shutCh			= 4` = Shutter @ Channel 4

`local yawCh			= 3` = Yaw @ Channel 3

`local pitchCh		= 2` = Pitch @ Channel 2

##How to tune the Script?

The script adds custom inputs at Input17 on your Taranis that you can edit to adapt it to your gimbal

---

You can set the speed of one gimbal roation step with the inputs `yawVal` and `pitchVal`, default is 10 (Max. PWM)

---

You can set the duration of one gimbal roation step with the parameters `pitchDur` and `yawDur`, default is 10 (1sec)

---

You can set the amount of steps for one 360° rotation with the parameters `yawStp` and `pitchStp`

###Advanced Setup

The script uses 3 Special Functions at index 60,61 and 62 as default, you can change them with the parameters `shutCFIndex`, `yawCFIndex` and `pitchCFIndex` if you want, but there is no need to if you aren't using them.

---

The script inserts inputs at at index 16 (Input17) at default. If you already use this input, you can change the index with the `inputIndex` parameter.
