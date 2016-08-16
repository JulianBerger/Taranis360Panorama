local scriptTimer		= -1
local curYawStep		= 0
local curPitchStep		= 0

local shutCh			= 4
local shutTime			= 100
local shutValue			= 100
local shutDelay			= 35
local shutModified		= 0;
local shutCFIndex		= 60;

local yawCh				= 3
local yawStepDuration	= 100
local yawStepValue		= 100
local yawSteps			= 8
local yawModified		= 0;
local yawCFIndex		= 61;

local pitchCh			= 2
local pitchStepDuration	= 100
local pitchStepValue	= 100
local pitchSteps		= 4
local pitchModified		= 0;
local pitchCFIndex		= 62;

-- Init function
local function init()
	shutCF	=	{switch=83 ; func=0 ; value=shutValue		; mode=0 ; active=0 ; param = shutCh-1}
	yawCF	=	{switch=83 ; func=0 ; value=yawStepValue	; mode=0 ; active=0 ; param = yawCh-1}
	pitchCF	=	{switch=83 ; func=0 ; value=pitchStepValue	; mode=0 ; active=0 ; param = pitchCh-1}
	
	model.setCustomFunction(shutCFIndex, shutCF)
	model.setCustomFunction(yawCFIndex, yawCF)
	model.setCustomFunction(pitchCFIndex, pitchCF)		
end


local function setCFState(index, active)
	local modCF = model.getCustomFunction(index)
	modCF.active = active
	model.setCustomFunction(index, modCF)
end

-- Main
local function run(event)	
	-- Start Timer
	if scriptTimer < 0 then
		scriptTimer = getTime()
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
		scriptTimer = getTime() + shutDelay
		return 0
	end
	
	--Add Shutter Delay
	if shutModified == 1 then
		shutModified = 2
		setCFState(shutCFIndex, 1)
		scriptTimer = getTime() + shutTime
		playTone(800, 80, 0, PLAY_BACKGROUND, 0 )
		return 0
	end
	
	--Modify SHUTTER
	if shutModified == 2 then
		shutModified = 0
		setCFState(yawCFIndex, 0)
		setCFState(pitchCFIndex, 0)
		setCFState(shutCFIndex, 0)
		scriptTimer = getTime() + shutDelay
		return 0
	end
	
	
	-- Modify YAW
	if curYawStep < yawSteps then
		yawModified = 1
		setCFState(yawCFIndex, 1)
		curYawStep = curYawStep+1
		
		scriptTimer = getTime() + yawStepDuration
		return 0
	else
		-- Modify PITCH
		if curPitchStep < pitchSteps then
			curYawStep = 0	--reset yaw steps
			pitchModified = 1
			setCFState(pitchCFIndex, 1)
			curPitchStep = curPitchStep+1
			
			scriptTimer = getTime() + pitchStepDuration
			return 0
		else
		--finished!!
			playTone(1500, 80, 250, 0, 0 )
			playTone(1500, 80, 250, 0, 0 )
			playTone(1500, 80, 0, 0, 0 )
			
			curYawStep = 0
			curPitchStep = 0
			
			scriptTimer = getTime() + 10000
			return 0
		end
		
	end
	
	return 0
end

return { init=init, run=run }
