-- LOAD VIEW AND UTILITY CLASSES
local composer = require "composer"
local scene = composer.newScene()
local preference = require "preference"

-- Global device specific coordinates
local _W = display.actualContentWidth
local _H = display.actualContentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local imOptions = {width=_W, height=480}

local backButton, resetButton, logoutButton, logRect, logConfirm, logYes, logNo


local function gotoMenu(event)
	if event.phase == "began" then
		composer.gotoScene( "menuScene", "slideRight", 200  )
		
		return true
	end

end

local function logoutFromGooglePlay(event)
	if event.phase == "began" then
		if preference.getValue("useGPGS") then
			native.showAlert( "Logout of GPGS?", "Logout of Google Play Game Services?", { "Yes", "No" }, GPGSListener )
		end
	end
end

local function openDialogue(event)
	if event.phase == "began" then
		logRect.isVisible=true; logConfirm.isVisible=true; logYes.isVisible=true; logNo.isVisible=true
	end
end

local function exitDialog(event)
	if event.phase == "began" then
		logRect.isVisible=false; logConfirm.isVisible=false; logYes.isVisible=false; logNo.isVisible=false
	end
end		

local function resetScores(event)
	if event.phase == "began" then
		preference.save{classicMedalLevel = "none"}
		preference.save{challengeMedalLevel = "none"}
		preference.save{classicHighScores = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}}
		preference.save{challengeHighScores = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}}
	end
	logRect.isVisible=false; logConfirm.isVisible=false; logYes.isVisible=false; logNo.isVisible=false	
end

local function onKeyEvent(event)
	if event.keyName == "back" then
		composer.gotoScene( "menuScene", "slideRight", 200  )
		return true
	end
end

function GPGSListener(event)
	if "clicked" == event.action then
        local i = event.index
        if 1 == i then
			preference.save{useGPGS = false}
			-- logoutButton.alpha = .5
        elseif 2 == i then
        end
    end
end

function scene:create( event )
	local screenGroup = self.view
	
	backgroundImageWhite = display.newImageRect(screenGroup, "media/menuBackground.png", _W, _H)
	backgroundImageWhite.y = centerY
	backgroundImageWhite.x = centerX
	
	backgroundImageBlack = display.newImageRect(screenGroup, "media/menuBackgroundBlack.png", _W, _H)
	backgroundImageBlack.y = centerY
	backgroundImageBlack.x = centerX
	
	instImageWhite = display.newImageRect(screenGroup, "media/instructionsWhite.png", _W-60, _H-70)
	instImageWhite.y = centerY
	instImageWhite.x = centerX
	
	instImageBlack = display.newImageRect(screenGroup, "media/instructionsBlack.png", _W-60, _H-70)
	instImageBlack.y = centerY
	instImageBlack.x = centerX
	
	instructionsText = display.newText({text="Instructions",  x=centerX, y=80, fontSize=25, font="FFF Forward"})  
	screenGroup:insert(instructionsText)
	
	backButton = display.newText({text="Back",  x=50, y=45, fontSize=15, font="FFF Forward"})       --Image("media/classicButtonTransparent.png")
	screenGroup:insert(backButton)
	
	-- logoutButton = display.newText({text="Logout", x=75, y=_H-80, fontSize=15, font="FFF Forward"})
    -- screenGroup:insert(logoutButton)
	-- if not preference.getValue("useGPGS") then
	-- 	logoutButton.alpha = .5
	-- end
	
	resetButton = display.newText({text="Reset Times",  x=_W /2, y=_H-80, fontSize=15, font="FFF Forward"})
	screenGroup:insert(resetButton)
	
	logRect = display.newRect(screenGroup, centerX, centerY - 20, 250, 150)
	logRect.strokeWidth = 4
	
	logConfirm = display.newText({text="Confirm", x=centerX, y=centerY-60, fontSize=25, font="FFF Forward"})
	screenGroup:insert(logConfirm)
	
	logYes = display.newText({text="Yes", x=centerX-80, y=centerY+20, fontSize=25, font="FFF Forward"})
	screenGroup:insert(logYes)
	
	logNo = display.newText({text="No", x=centerX+80, y=centerY+20, fontSize=25, font="FFF Forward"})
	screenGroup:insert(logNo)
	logRect.isVisible, logConfirm.isVisible, logYes.isVisible, logNo.isVisible = false
	
	
	if preference.getValue("bgWhite") then
		backgroundImageWhite.isVisible = true
		backgroundImageBlack.isVisible = false
		instImageBlack.isVisible = false
		instImageWhite.isVisible = true
		backButton:setFillColor(0,0,0,1)
		-- logoutButton:setFillColor(0,0,0,1)
		instructionsText:setFillColor(0,0,0,1)
		resetButton:setFillColor(0,0,0,1)
		logConfirm:setFillColor(0,0,0,1)
		logYes:setFillColor(0,0,0,1)
		logNo:setFillColor(0,0,0,1)
		logRect:setFillColor(255,255,255,1)
		logRect:setStrokeColor(0,0,0)
		
	else
		backgroundImageWhite.isVisible = false
		backgroundImageBlack.isVisible = true
		instImageBlack.isVisible = true
		instImageWhite.isVisible = false
		backButton:setFillColor(255,255,255,1)
		instructionsText:setFillColor(255,255,255,1)
		resetButton:setFillColor(255,255,255,1)
		-- logoutButton:setFillColor(255,255,255,1)
		logConfirm:setFillColor(255,255,255,1)
		logYes:setFillColor(255,255,255,1)
		logNo:setFillColor(255,255,255,1)
		logRect:setFillColor(0,0,0,1)
		logRect:setStrokeColor(255,255,255)
	
	end
	
	
 end


-- -- Called immediately after scene has moved onscreen:
 function scene:show( event )
	
	if event.phase == "did" then
		
		backButton:addEventListener( "touch", gotoMenu)
		resetButton:addEventListener( "touch", openDialogue)
		-- logoutButton:addEventListener( "touch", logoutFromGooglePlay)
		logYes:addEventListener( "touch", resetScores)
		logNo:addEventListener( "touch", exitDialog)
		Runtime:addEventListener("key", onKeyEvent)
		--system.activate( "multitouch" )
		
	end
 end


-- -- Called when scene is about to move offscreen:
 function scene:hide( event )
	
	if event.phase == "will" then
		-- print( "2: exitScene event" )
		resetButton:removeEventListener( "touch", openDialogue)
		-- logoutButton:removeEventListener( "touch", logoutFromGooglePlay)
		backButton:removeEventListener( "touch", gotoMenu)
		logYes:removeEventListener( "touch", resetScores)
		logNo:removeEventListener( "touch", exitDialog)
		Runtime:removeEventListener("key", onKeyEvent)
		
		
		composer.removeScene("instructionsScene")
	end

 end


-- -- Called prior to the removal of scene's "view" (display group)
 function scene:destroy( event )
	
	 print( "((destroying scene 2's view))" )
 end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "create", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "show", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "hide", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene