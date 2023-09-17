--
-- Abstract: Storyboard Sample
--
-- Version: 1.0
-- 
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2011 Corona Labs Inc. All Rights Reserved.
--
-- Demonstrates use of the Storyboard API (scene events, transitioning, etc.)
--

-- hide device status bar
display.setStatusBar( display.HiddenStatusBar )

-- require controller module
local composer = require "composer"
local widget = require "widget"
local preference = require "preference"
local gameNetwork = require "gameNetwork" 

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local logNo, logYes


if preference.getValue("showGPGSError") == nil then
	preference.save{showGPGSError = false}
end

local playerName

local function saveSettings()
	preference.save{playerInfo = playerName}

end



-- local function exitDialogYes(event)
	-- if event.phase == "began" then
		-- logRect.isVisible=false; logConfirm.isVisible=false; logYes.isVisible=false; logNo.isVisible=false
		-- gameNetworkSetup()  --login to the network here
	-- end
-- end	

-- local function exitDialogNo(event)
	-- preference.save{useGPGS = false}
	-- if event.phase == "began" then
		-- logRect.isVisible=false; logConfirm.isVisible=false; logYes.isVisible=false; logNo.isVisible=false
	-- end
-- end	

-- local function showDialogue()

	-- logRect = display.newRect(centerX, centerY - 20, 250, 150)
	-- logRect.strokeWidth = 4
	
	-- logConfirm = display.newText({text="Use Google Play Game Services? \n (needed for global high scores and achievements)", align = "center", x=centerX, y=centerY + 20, fontSize=11, width = 240, height = 200, font="FFF Forward"})
	
	-- logYes = display.newText({text="Yes", x=centerX-80, y=centerY+20, fontSize=25, font="FFF Forward"})
	
	-- logNo = display.newText({text="No", x=centerX+80, y=centerY+20, fontSize=25, font="FFF Forward"})
	-- logRect.isVisible=true; logConfirm.isVisible=true; logYes.isVisible=true; logNo.isVisible=true
	
	
	-- logConfirm:setFillColor(0,0,0,1)
	-- logYes:setFillColor(0,0,0,1)
	-- logNo:setFillColor(0,0,0,1)
	-- logRect:setFillColor(255,255,255,1)
	-- logRect:setStrokeColor(0,0,0)

	-- logNo:addEventListener("touch", exitDialogNo)
	-- logYes:addEventListener("touch", exitDialogYes)

-- end


------HANDLE SYSTEM EVENTS------
local function systemEvents( event )
   print("systemEvent " .. event.type)
   if ( event.type == "applicationSuspend" ) then
	  print( "suspending..........................." )
   elseif ( event.type == "applicationResume" ) then
	  print( "resuming............................." )
   elseif ( event.type == "applicationExit" ) then
	  print( "exiting.............................." )
   elseif ( event.type == "applicationStart" ) then
	
		--showDialogue()
	  --showDialogue()
   end
   return true
end
	
Runtime:addEventListener( "system", systemEvents )
--buttonSound = audio.loadSound( "media/audio/buttonpress.mp3" )


--local gameLoadSound = audio.loadSound("media/audio/gamestart.mp3")
--audio.play(gameLoadSound)

--[[
local fonts = native.getFontNames()
for i,fontname in ipairs(fonts) do
    print(fontname)
end
]]




-- load first scene
composer.gotoScene( "menuScene", "fade", 100 )

