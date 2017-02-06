-- SETTINGS --
local shutCh						= 10
local shutTime					= 6
local shutValue					= 10
local shutDelay					= 1
local shutModified			= 0
local shutCFIndex				= 60
local shutInputDurIndex	= 0
local shutInputValIndex	= 1
local shutInputDelIndex	= 2

local yawCh							= 13
local yawStepDuration		= 10
local yawStepValue			= 10
local yawSteps					= 5
local yawModified				= 0
local yawCFIndex				= 61
local yawInputDurIndex	= 3
local yawInputValIndex	= 4
local yawInputStpIndex	= 5

local pitchCh						= 12
local pitchStepDuration	= 10
local pitchStepValue		= 10
local pitchSteps				= 3
local pitchModified			= 0
local pitchLastStepOneShot = 1
local pitchCFIndex			= 62
local pitchInputDurIndex= 6
local pitchInputValIndex= 7
local pitchInputStpIndex= 8

local sourceMax					= 84	--source 84 is max
local switchOn					= 115
local inputIndex				= 16

local scriptRunning			= false
local scriptName				= "360 Panorama 2.0 by SkyGarage.de"

--#####################################################################--
--## DO NOT CHANGE BELOW HERE IF YOU DO NOT KNOW WHAT YOU ARE DOING! ##--
--#####################################################################--
local scriptTimer				= 0
local curYawStep				= 0
local curPitchStep			= 0

local function setCFState(index, active)
	local modCF = model.getCustomFunction(index)
	modCF.active = active
	model.setCustomFunction(index, modCF)
end

local function updateInput(index, line, name, weight)
	local input = model.getInput(index, line)
	if input == nil or input.name ~= name then
		value = {name=name ; source=sourceMax; weight=weight ; offset=0 ; switch=0}
		model.insertInput(index, line, value)
		return weight
	else
		--Update Input
		return input.weight
	end
end

-- Reset function
local function reset(beep)
	-- Reset vars
	scriptTimer = 0
	curYawStep = 1
	curPitchStep = 1
	pitchModified = 1 --for initial shutter release
	scriptRunning = false

	--Disable all custom functions
	setCFState(shutCFIndex, 0)
	setCFState(yawCFIndex, 0)
	setCFState(pitchCFIndex, 0)

	if beep then
		playTone(1800, 50, 180, 0, 0 )
		playTone(1800, 50, 180, 0, 0 )
	end
end

-- Init function
local function init()
	-- Setup Inputs and create them if they do not exist
	shutTime						= updateInput(inputIndex, shutInputDurIndex, "shutDur", shutTime)
	shutValue						= updateInput(inputIndex, shutInputValIndex, "shutVal", shutValue)
	shutDelay						= updateInput(inputIndex, shutInputDelIndex, "shutDel", shutDelay)
	yawStepDuration			= updateInput(inputIndex, yawInputDurIndex, "yawDur", yawStepDuration)
	yawStepValue				= updateInput(inputIndex, yawInputValIndex, "yawVal", yawStepValue)
	yawSteps						= updateInput(inputIndex, yawInputStpIndex, "yawStp", yawSteps)
	pitchStepDuration		= updateInput(inputIndex, pitchInputDurIndex, "pitchDur", pitchStepDuration)
	pitchStepValue			= updateInput(inputIndex, pitchInputValIndex, "pitchVal", pitchStepValue)
	pitchSteps					= updateInput(inputIndex, pitchInputStpIndex, "pitchStp", pitchSteps)

	shutCF	=	{switch=switchOn ; func=0 ; value=shutValue*10		; mode=0 ; active=0 ; param=shutCh-1}
	yawCF	=	{switch=switchOn ; func=0 ; value=yawStepValue*10	; mode=0 ; active=0 ; param=yawCh-1}
	pitchCF	=	{switch=switchOn ; func=0 ; value=pitchStepValue*10	; mode=0 ; active=0 ; param=pitchCh-1}

	-- Setup Custom Functions and create them if they do not exist
	model.setCustomFunction(shutCFIndex, shutCF)
	model.setCustomFunction(yawCFIndex, yawCF)
	model.setCustomFunction(pitchCFIndex, pitchCF)

	reset(false)
end

-- Main
local function run(event)
	local shotCount = pitchSteps * yawSteps + pitchLastStepOneShot
	local curShot = (yawSteps * (curPitchStep-1)) + curYawStep
	local shutter = "#"

	if shutModified > 0 then
		shutter = "-"
	end

	--Handle event
	if event == EVT_PLUS_BREAK then
		--Start script
		init()
		scriptRunning = true
		playTone(1100, 40, 250, 0, 0 )
		playTone(1100, 40, 250, 0, 0 )
	end

	if event == EVT_MINUS_BREAK then
		--End script
		scriptRunning = false
		reset(true)
	end


	--Output LCD
	lcd.clear()
	lcd.drawScreenTitle(scriptName, 1, 1)

	if scriptRunning then
		lcd.drawText(5, 27,"Photo ", MIDSIZE)
		lcd.drawNumber(62, 27, curShot, BLINK + MIDSIZE + RIGHT)
		lcd.drawText(65, 27,"of ", MIDSIZE)
		lcd.drawNumber(98, 27, shotCount, MIDSIZE + RIGHT)

		lcd.drawLine(110, 10, 110, 61, SOLID, 0)

		lcd.drawText(123, 20,"Yaw Step:", 0)
		lcd.drawNumber(196, 20, curYawStep, RIGHT)

		lcd.drawText(123, 30,"Pitch Step:", 0)
		lcd.drawNumber(196, 30, curPitchStep, RIGHT)

		lcd.drawText(123, 40,"Shutter:", 0)
		lcd.drawText(196, 40, shutter, RIGHT)
	else
		lcd.drawText(7, 21,"Press + to start the Script ", MIDSIZE)
		lcd.drawText(17, 39,"You can stop it with the '-' Button! ", 0)
	end

end

local function bg_func()
	if not scriptRunning then
		return 0
	end

	-- Sleep
	if scriptTimer > getTime() then
		return 0
	end

	-- Shutter
	if yawModified == 1 or pitchModified == 1 then
		yawModified = 0;
		pitchModified = 0;
		setCFState(yawCFIndex, 0)
		setCFState(pitchCFIndex, 0)
		shutModified = 1
		scriptTimer = getTime() + shutDelay*10
		return 0
	end

	--Add Shutter Delay
	if shutModified == 1 then
		shutModified = 2
		setCFState(shutCFIndex, 1)
		scriptTimer = getTime() + shutTime*10
		playTone(800, 80, 0, PLAY_BACKGROUND, 0 )
		return 0
	end

	--Modify SHUTTER
	if shutModified == 2 then
		shutModified = 0
		setCFState(yawCFIndex, 0)
		setCFState(pitchCFIndex, 0)
		setCFState(shutCFIndex, 0)
		scriptTimer = getTime() + shutTime*10
		return 0
	end


	-- Modify YAW
	if curYawStep < yawSteps then
		yawModified = 1
		setCFState(yawCFIndex, 1)
		curYawStep = curYawStep+1

		scriptTimer = getTime() + yawStepDuration*10
		return 0
	else
		-- Modify PITCH
		if curPitchStep < pitchSteps then
			curYawStep = 1	--reset yaw steps
			pitchModified = 1
			setCFState(pitchCFIndex, 1)
			curPitchStep = curPitchStep+1

			-- Check if it's the last pitch step
			if (pitchLastStepOneShot == 1 and curPitchStep == pitchSteps) then
				curYawStep = yawSteps	-- No Yaw movement on last step if pitchLastStepOneShot is set
			end

			scriptTimer = getTime() + pitchStepDuration*10
			return 0
		else
			--finished!!
			playTone(1500, 80, 250, 0, 0 )
			playTone(1500, 80, 250, 0, 0 )
			playTone(1500, 80, 0, 0, 0 )

			reset(false)
			return 0
		end
	end
	return 0
end

return { run=run, background=bg_func, init=init  }
