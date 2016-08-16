# Taranis360Panorama
FrSky Taranis Script for 360° Panorama
---

#How to install the Script?
1. Put the script.lua file on your Taranis SD-Card at "\SCRIPTS\FUNCTIONS"
2. Edit your OpenTX Model and add a special function with the action "Play Script" and the Parameter "script.lua"
3. Assign a Switch to that special function
4. Go out and shoot some 360° Panorama!



#How to tune the Script?

You need to set the channel of your Pitch and Yaw Axis of your Gimbal as well as the Channel for your Camera Shutter.

`local shutCh			= 4` = Shutter @ Channel 4

`local yawCh			= 3` = Yaw @ Channel 3

`local pitchCh		= 2` = Pitch @ Channel 2

---

You can set the speed of one gimbal roation step with the parameters `yawStepValue` and `pitchStepValue`, default is 100 (=1sec)

---

You can set the duration of one gimbal roation step with the parameters `pitchStepDuration` and `pitchStepDuration`, default is 100 (=1sec)

---

You can set the amount of steps for one 360° rotation with the parameters `yawSteps` and `pitchSteps`

---

The script uses 3 Special Functions at index 60,61 and 62 as default, you can change them with the parameters `shutCFIndex`, `yawCFIndex` and `pitchCFIndex` if you want, but there is no need to if you aren't using them.


