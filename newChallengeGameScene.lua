local function screenshot()

	--I set the filename to be "widthxheight_time.png"
	--e.g. "1920x1080_20140923151732.png"
	local date = os.date( "*t" )
	local timeStamp = table.concat({date.year .. date.month .. date.day .. date.hour .. date.min .. date.sec})
	local fname = display.pixelWidth.."x"..display.pixelHeight.."_"..timeStamp..".png"

	--capture screen
	local capture = display.captureScreen(false)

	--make sure image is right in the center of the screen
	capture.x, capture.y = display.contentWidth * 0.5, display.contentHeight * 0.5

	--save the image and then remove
	local function save()
		display.save( capture, { filename=fname, baseDir=system.DocumentsDirectory, isFullResolution=true } )
		capture:removeSelf()
		capture = nil
	end
	timer.performWithDelay( 100, save, 1)

	return true
end

--works in simulator too
local function onKeyEvent(event)
	if event.phase == "up" then
		--press s key to take screenshot which matches resolution of the device
    	    if event.keyName == "s" then
    		screenshot()
    	    end
        end
end

Runtime:addEventListener("key", onKeyEvent)

-- LOAD VIEW AND UTILITY CLASSES
local composer = require "composer"
local scene = composer.newScene()
local preference = require "preference"
local gameNetwork = require "gameNetwork" 

--admob IDs for ImpliedGaming
local admobNetwork = "admob"
local adMobInterstitialID = "ca-app-pub-1087735013942822/4222921993"
local adMobBannerID = "ca-app-pub-1087735013942822/7036787591"

-- vungle IDs for ImpliedGaming *NOTE* only serves interstitial
local vungleNetwork = "vungle"
local vungleID = "53d69991725e76ab7700007c"

--iAds IDs for ImpliedGaming
-- local iAdsNetwork = "iads"
-- local iAdsBannerID = ""

-- Load Corona 'ads' library
--local ads = require "ads"

-- local function admobListener( event )
    -- if event.isError then
        -- ads:setCurrentProvider(vungleNetwork)
    -- end
-- end

-- local function vungleListener( event )
    -- if event.isError then
        -- -- Failed to receive an ad.
    -- end
-- end

-- ads.init( admobNetwork, adMobInterstitialID, admobListener )
-- ads.init( vungleNetwork, vungleID );
-- ads.init( iadsNetwork, iAdsBannerID, iAdsListener)
-- ads.init( inmobiNetwork, inmobiBannerID, inmobiListener )


-- Global device specific coordinates
local _W = display.actualContentWidth
local _H = display.actualContentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local imOptions = {width=_W, height=480}

local backgroundImage

-- game controls
local replayButton, menuButton, gameTimerText

local totalChallenge
local gameTimer, gphsTime, tempTime
local clickCounter = 0
local clickTotal = 26
local yellowSphere, bombSphere, doubleSphere1, doubleSphere2, dragSphere1, dragSphere2
local sphereClicked
local countdownText
local countdownLength = 4

local chanceBomb = .2
local chanceDouble = .15
local chanceDrag = .2
local drag1Active, drag2Active = false
--local double1Active, double2Active = false
local double1Pressed = false
local double2Pressed = false
local blueLine, blackLine
local touchCount = 0

local finalRoundSpheres = 5
local finalRoundSpheresRemaining = 5

local currentSpheres = {}
local highScores = {}
local highScoreText = {}
local highScorePos

local medalLevel
local bronzeTime = 24
local silverTime = 16
local goldTime = 12
local platinumTime = 10

local bronzeAlert, silverAlert, goldAlert, platinumAlert, xButton, backgroundImageWhite, backgroundImageBlack
local howToGreenYellowWhite, howToGreenYellowBlack, howToGreenYellowRect, howToGreenYellowOk
local howToDragWhite, howToDragBlack, howToDragRect, howToDragOk
local howToDoubleWhite, howToDoubleBlack, howToDoubleRect, howToDoubleOk
local howToBombWhite, howToBombBlack, howToBombRect, howToBombOk

local audioOn, audioOff
local audioState = true
local hasPlayerRated = preference.getValue("hasPlayerRated")
local firstPlay = true
local gameActive = true
local sphereTouchEnabled = true
local rateit = require("rateit")
  rateit.setiTunesURL(1234564) --insert appId
  rateit.setAndroidURL(1234564) --insert appId


local function addCurrentSpheres(sphere)
	for i=1, 10 do
		if currentSpheres[i] == nil then 
			currentSpheres[i] = sphere
			--print("adding" .. currentSpheres[i].color)
			--print("size " .. #currentSpheres)
			break
		end
	end

	-- for i=1, #currentSpheres	do
		-- print(currentSpheres[i].color)
	-- end
end

local function removeCurrentSpheres(sphere)
	for i=1, 10 do
		if currentSpheres[i] == sphere then 
			--print("deleting" .. currentSpheres[i].color)
			currentSpheres[i] = nil
			--print("size " .. #currentSpheres)
		end
	end

end

local function getDistance(x,y,x2,y2)
	return math.sqrt((x2 - x) * (x2 - x) + (y2 - y) * (y2 - y))
end

local function spotAvailable(x,y)
	for i=1, 10 do
		if currentSpheres[i] ~= nil then
			if getDistance(currentSpheres[i].x, currentSpheres[i].y, x, y) < 50 then
				return false
			
			end
		end
	end
	
	return true
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult) / mult
end

function resumeMusic(event)
	audio.fade({channel=3, time=1000, volume=1.0})
end

local function showXButton()
	xButton.isVisible = true
end

local function enableSphereTouch()
	sphereTouchEnabled = true
end
local function howToDragOkTouched (event)
	if event.phase == "began" then
		howToDragBlack.isVisible = false
		howToDragWhite.isVisible = false
		howToDragOk.isVisible = false
		howToDragRect.isVisible = false
		gameTimer = tempTime
		preference.save{howToDrag = true}
		timer.performWithDelay(200, enableSphereTouch)
	end
end

function showHowToDrag()
	howToDragOk.isVisible = true
	howToDragRect.isVisible = true
	
	if preference.getValue("bgWhite") then
		howToDragWhite.isVisible = true
		howToDragOk:setFillColor(0)
		howToDragRect:setFillColor(1)
		howToDragRect:setStrokeColor(0)
	else
		howToDragBlack.isVisible = true
		howToDragOk:setFillColor(1)
		howToDragRect:setFillColor(0)
		howToDragRect:setStrokeColor(1)			
	end
	howToDragRect:toFront()
	howToDragBlack:toFront()
	howToDragWhite:toFront()
	howToDragOk:toFront()
	sphereTouchEnabled = false
	tempTime = gameTimer
	howToDragOk:addEventListener("touch", howToDragOkTouched)
end

local function howToDoubleOkTouched (event)
	if event.phase == "began" then
		howToDoubleBlack.isVisible = false
		howToDoubleWhite.isVisible = false
		howToDoubleOk.isVisible = false
		howToDoubleRect.isVisible = false
		gameTimer = tempTime
		preference.save{howToDouble = true}
		timer.performWithDelay(200, enableSphereTouch)
	end
end
function showHowToDouble()
	howToDoubleOk.isVisible = true
	howToDoubleRect.isVisible = true
	
	if preference.getValue("bgWhite") then
		howToDoubleWhite.isVisible = true
		howToDoubleOk:setFillColor(0)
		howToDoubleRect:setFillColor(1)
		howToDoubleRect:setStrokeColor(0)
	else
		howToDoubleBlack.isVisible = true
		howToDoubleOk:setFillColor(1)
		howToDoubleRect:setFillColor(0)
		howToDoubleRect:setStrokeColor(1)			
	end
	howToDoubleRect:toFront()
	howToDoubleBlack:toFront()
	howToDoubleWhite:toFront()
	howToDoubleOk:toFront()
	sphereTouchEnabled = false
		
	tempTime = gameTimer	
	howToDoubleOk:addEventListener("touch", howToDoubleOkTouched)
end

local function howToBombOkTouched (event)
	if event.phase == "began" then
		howToBombBlack.isVisible = false
		howToBombWhite.isVisible = false
		howToBombOk.isVisible = false
		howToBombRect.isVisible = false
		gameTimer = tempTime
		preference.save{howToBomb = true}
		timer.performWithDelay(200, enableSphereTouch)
	end
end
function showHowToBomb()
	howToBombOk.isVisible = true
	howToBombRect.isVisible = true
	
	if preference.getValue("bgWhite") then
		howToBombWhite.isVisible = true
		howToBombOk:setFillColor(0)
		howToBombRect:setFillColor(1)
		howToBombRect:setStrokeColor(0)
	else
		howToBombBlack.isVisible = true
		howToBombOk:setFillColor(1)
		howToBombRect:setFillColor(0)
		howToBombRect:setStrokeColor(1)			
	end
	howToBombRect:toFront()
	howToBombBlack:toFront()
	howToBombWhite:toFront()
	howToBombOk:toFront()
	sphereTouchEnabled = false
	
	tempTime = gameTimer	
	howToBombOk:addEventListener("touch", howToBombOkTouched)
end

local function unlockAchievement(achievement)
	
	local myAchievement = "com.ImpliedGamingStudios.PokeADot." .. achievement

	if ( system.getInfo("platformName") == "Android" ) then
	   --for GPGS, reset "myAchievement" to the string provided from the achievement setup in Google
		if achievement == "ACH_CHALLENGE_PLATINUM" then
			myAchievement = "CgkIruCKpq0YEAIQCQ"
		elseif achievement == "ACH_CHALLENGE_GOLD" then
			myAchievement = "CgkIruCKpq0YEAIQCA"
		elseif achievement == "ACH_CHALLENGE_SILVER" then
			myAchievement = "CgkIruCKpq0YEAIQBw"
		elseif achievement == "ACH_CHALLENGE_BRONZE" then
			myAchievement = "CgkIruCKpq0YEAIQBg"
		elseif achievement == "ACH_CHALLENGE_NOVICE" then
			myAchievement = "CgkIruCKpq0YEAIQEg"
		elseif achievement == "ACH_CHALLENGE_JOURNEYMAN" then
			myAchievement = "CgkIruCKpq0YEAIQEw"
		elseif achievement == "ACH_CHALLENGE_PRO" then
			myAchievement = "CgkIruCKpq0YEAIQFA"
		elseif achievement == "ACH_CHALLENGE_VETERAN" then
			myAchievement = "CgkIruCKpq0YEAIQFQ"
		elseif achievement == "ACH_CHALLENGE_LEGEND" then
			myAchievement = "CgkIruCKpq0YEAIQFw"
		elseif achievement == "ACH_POKE_A_DOT_MASTER" then
			myAchievement = "CgkIruCKpq0YEAIQCg"
		end
	else
		if achievement == "ACH_CHALLENGE_PLATINUM" then
			myAchievement = "grp.pokeadot.chp"
		elseif achievement == "ACH_CHALLENGE_GOLD" then
			myAchievement = "grp.pokeadot.chg"
		elseif achievement == "ACH_CHALLENGE_SILVER" then
			myAchievement = "grp.pokeadot.chs"
		elseif achievement == "ACH_CHALLENGE_BRONZE" then
			myAchievement = "grp.pokeadot.chb"
		elseif achievement == "ACH_CHALLENGE_NOVICE" then
			myAchievement = "grp.pokeadot.chn"
		elseif achievement == "ACH_CHALLENGE_JOURNEYMAN" then
			myAchievement = "grp.pokeadot.chj"
		elseif achievement == "ACH_CHALLENGE_PRO" then
			myAchievement = "grp.pokeadot.chpr"
		elseif achievement == "ACH_CHALLENGE_VETERAN" then
			myAchievement = "grp.pokeadot.chv"
		elseif achievement == "ACH_CHALLENGE_LEGEND" then
			myAchievement = "grp.pokeadot.chl"
		elseif achievement == "ACH_POKE_A_DOT_MASTER" then
			myAchievement = "grp.pokeadot.padm"
		end
	end

	gameNetwork.request( "unlockAchievement",
	{
	   achievement = { identifier=myAchievement, percentComplete=100, showsCompletionBanner=true },
	   listener = achievementRequestCallback
	} )

end

local function rateAppListener(event) 
	if "clicked" == event.action then
		local i = event.index
		if i == 1 then -- OK as pressed
			rateit.openURL()
			hasPlayerRated = true
			preference.save{hasPlayerRated=true}
		elseif i == 2 then  -- Will ask again in another 100 rounds
			hasPlayerRated = false
			preference.save{hasPlayerRated=false}
		elseif i == 3 then -- Will never ask again
			hasPlayerRated = true
			preference.save{hasPlayerRated=true}
		end
	end
	
end

local function rateApp()
local alert = native.showAlert( "Rate Poke-A-Dot", "If you enjoy playing Poke-A-Dot, would you mind taking a moment to rate it? Thanks for your Support", { "OK", "Remind Me Later", "Never" }, rateAppListener )
end

local function updateHighScores(score)
	
	local updated = false
	
	for i = 1, 10 do
		if highScores[i] == nil then
			highScores[i] = score
			updated = true
			highScorePos = i
			break
		elseif score < highScores[i] then
			for j = 10, i + 1, -1 do
				highScores[j] = highScores[j-1]
			end
		highScores[i] = score
		updated = true
		highScorePos = i
		
		break
		end				
	end
	
	if updated then
		gameTimerText:setFillColor(.2,.4,0)
	else
		gameTimerText:setFillColor(1,0,0)
	end
	
	preference.save{challengeHighScores = highScores}
	
	local myCategory = "com.ImpliedGamingStudios.PokeADot.ChallengeHighScores"

	if ( system.getInfo( "platformName" ) == "Android" ) then
	   --for GPGS, reset "myCategory" to the string provided from the leaderboard setup in Google
	   myCategory = "CgkIruCKpq0YEAIQAQ"
	else
		myCategory = "grp.pokeadot.challenge"
	end

	gameNetwork.request( "setHighScore",
	{
	   localPlayerScore = { category=myCategory, value=gphsTime },
	   listener = postScoreSubmit
	} )

end

local function gameFinished()
	local temp = system.getTimer() - gameTimer
	gphsTime = math.floor(temp)
	gameTimer = round((temp) / 1000, 3)
	gameTimerText.text = gameTimer
	updateHighScores(gameTimer)
	showScores()
end

local function flickerBomb()
	
	if bombSphere.isVisible then
		bombSphere.isVisible = false
	else 
		bombSphere.isVisible = true
	end
	
end

local function gameLost()
	gameTimerText.text = "GAME OVER"
	gameTimerText:setFillColor(1,0,0)
	for i=1, #currentSpheres do
		if currentSpheres[i] ~= nil and currentSpheres[i] ~= bombSphere then
			currentSpheres[i]:removeSelf()
			removeCurrentSpheres(currentSpheres[i])
		end
	end
	if audioState then
		audio.fade({channel=3, time=1, volume=0.0})
		audio.play( audio.loadSound("media/audio/GameLost.mp3"), {loops=0, channel=5})
		audio.fade({channel=5, time=1, volume=1.0})
		timer.performWithDelay(1800, resumeMusic)
	end
	timer.performWithDelay(200, flickerBomb, 7)
	timer.performWithDelay(1600, showScores)
end

local function newSphere(sphereType)
	local newPos = false
	local x, y
	
	while not newPos do
		x = math.random(0, 3) * ((_W - 40) / 4) + 55
		y = math.random(0, 5) * ((_H - 35)/ 6) + 60
		if yellowSphere == nil and clickCounter == 0 then
			newPos = true
		elseif spotAvailable(x,y) then
			newPos = true
		end
	end
	
	local sphere = display.newCircle(x, y, 32)
	sphere:addEventListener("touch", sphereClicked)
	if sphereType == "final" then
		sphere:setFillColor(.2,.4,0)
		sphere.color = "final"
		sphere:setStrokeColor(0,0,0)
		sphere.strokeWidth = 4
	else
		sphere:setFillColor(1,1,0)
		sphere:setStrokeColor(0,0,0)
		sphere.strokeWidth = 4
		sphere.color = "yellow"
		if sphereType == "bomb" then
			bombSphere = sphere
		elseif sphereType == "double1" then
			doubleSphere1 = sphere
		elseif sphereType == "double2" then
			doubleSphere2 = sphere
		elseif sphereType == "drag1" then
			dragSphere1 = sphere
		elseif sphereType == "drag2" then
			dragSphere2 = sphere
		else
			yellowSphere = sphere
		end
	end
	addCurrentSpheres(sphere)
	screenGroup:insert(sphere)
end

local function changeColor()
	if yellowSphere ~= nil then
		yellowSphere:setFillColor(.2,.4,0)
		yellowSphere.color = "green"
		if clickCounter ~= 0 then
			yellowSphere = nil
		end
	end
	
	if  bombSphere ~= nil then
		bombSphere:setFillColor(1,0,0)
		bombSphere.color = "red"
		if not preference.getValue("howToBomb") then
			showHowToBomb()
		end
	end
	
	if  doubleSphere1 ~= nil then
		doubleSphere1:setFillColor(1,.5,0)
		doubleSphere2:setFillColor(1,.5,0)
		doubleSphere1.color = "orange1"
		doubleSphere2.color = "orange2"
		if not preference.getValue("howToDouble") then
			showHowToDouble()
		end
	end
	
	if  dragSphere1 ~= nil then
		dragSphere1:setFillColor(0,.4,1)
		dragSphere2:setFillColor(0,.4,1)
		dragSphere1.color = "blue1"
		dragSphere2.color = "blue2"
		
		blackLine = display.newLine(dragSphere1.x, dragSphere1.y, dragSphere2.x, dragSphere2.y)
		blackLine:setStrokeColor(0,0,0,1)
		blackLine.strokeWidth = 12
		screenGroup:insert(blackLine)
		
		blueLine = display.newLine(dragSphere1.x, dragSphere1.y, dragSphere2.x, dragSphere2.y)
		blueLine:setStrokeColor(0,.4,1)
		blueLine.strokeWidth = 5
		screenGroup:insert(blueLine)
		
		if not preference.getValue("howToDrag") then
			showHowToDrag()
		end
	end
end

local function nextRound()
	clickCounter = clickCounter + 1
	
	changeColor()
		
	if clickCounter < clickTotal then
		if math.random (1, 1/chanceDouble) == 1 and doubleSphere1 == nil then
			newSphere("double1")
			newSphere("double2")
		
		elseif math.random (1, 1/(chanceDrag / (1 - chanceDouble))) == 1 and dragSphere1 == nil then
			newSphere("drag1")
			newSphere("drag2")		
		else
			newSphere()
		
			if math.random (1, 1/(chanceBomb / (1 - chanceDouble - chanceDrag))) == 1 and bombSphere == nil then
				newSphere("bomb")
			end
		end
		
	elseif clickCounter == clickTotal then
		yellowSphere = nil
	
	elseif clickCounter == clickTotal + 1 then
		for i = 1, finalRoundSpheres do
			newSphere("final")
		end
	end
	
	if blackLine ~= null then
		blackLine:toFront()
		dragSphere1:toFront()
		dragSphere2:toFront()
		blueLine:toFront()
	end
	
	howToDragRect:toFront()
	howToDragBlack:toFront()
	howToDragWhite:toFront()
	howToDragOk:toFront()
	howToDoubleRect:toFront()
	howToDoubleBlack:toFront()
	howToDoubleWhite:toFront()
	howToDoubleOk:toFront()
	howToBombRect:toFront()
	howToBombBlack:toFront()
	howToBombWhite:toFront()
	howToBombOk:toFront()
end

function blueDragging() 
	blackLine:removeSelf()
	blackLine = display.newLine(dragSphere1.x, dragSphere1.y, dragSphere2.x, dragSphere2.y)
	blackLine:setStrokeColor(0,0,0,1)
	screenGroup:insert(blackLine)
	blackLine.strokeWidth = 12
	
	blueLine:removeSelf()
	blueLine = display.newLine(dragSphere1.x, dragSphere1.y, dragSphere2.x, dragSphere2.y)
	blueLine:setStrokeColor(0,.4,1)
	screenGroup:insert(blueLine)
	blueLine.strokeWidth = 5
	
	blackLine:toFront()
	dragSphere1:toFront()
	dragSphere2:toFront()
	blueLine:toFront()
	
	if getDistance(dragSphere1.x, dragSphere1.y, dragSphere2.x, dragSphere2.y) < 60 then
		removeCurrentSpheres(dragSphere1)
		removeCurrentSpheres(dragSphere2)
		dragSphere1:removeSelf()
		dragSphere2:removeSelf()
		dragSphere1, dragSphere2 = nil
		drag1Active, drag2Active = false
		blackLine:removeSelf()
		blackLine = nil
		blueLine:removeSelf()
		blueLine = nil
		nextRound()
	end

end

function orangeComplete()
	removeCurrentSpheres(doubleSphere1)
	removeCurrentSpheres(doubleSphere2)
	doubleSphere1:removeSelf()
	doubleSphere2:removeSelf()
	doubleSphere1, doubleSphere2 = nil
	double1Pressed, double2Pressed = false
	nextRound()

end

function sphereClicked(event)
	if sphereTouchEnabled then
		if event.phase == "began" and event.target.color == "red" then
			--bombSphere:removeSelf()
			gameLost()
		
		elseif event.phase == "began" and event.target.color == "orange1" then
			double1Pressed = true
			if double2Pressed and touchCount > 1 then
				orangeComplete()
			end
		elseif event.phase == "ended" and event.target.color == "orange1" then
			--must touch at same time (for phone)
			double1Pressed = false
		elseif event.phase == "moved" and event.target.color == "orange1" then
			double1Pressed = true
			if double2Pressed and touchCount > 1 then
				orangeComplete()
			end
			
		elseif event.phase == "began" and event.target.color == "orange2" then
			double2Pressed = true
			if double1Pressed and touchCount > 1 then
				orangeComplete()
			end
		elseif event.phase == "ended" and event.target.color == "orange2" then
			--must touch at same time (for phone)
			double2Pressed = false
		elseif event.phase == "moved" and event.target.color == "orange2" then
			double2Pressed = true
			if double1Pressed and touchCount > 1 then
				orangeComplete()
			end
			
			
		elseif event.phase == "moved" and event.target.color == "blue1" then
			drag1Active = true
			drag2Active = false
			dragSphere1.x, dragSphere1.y = math.max( 55, math.min( _W - 55, event.x )), math.max( 60, math.min( _H - 60, event.y ))
			blueDragging()
			
		elseif event.phase == "moved" and event.target.color == "blue2" then
			drag1Active = false
			drag2Active = true
			dragSphere2.x, dragSphere2.y = math.max( 55, math.min( _W - 55, event.x )), math.max( 60, math.min( _H - 60, event.y ))
			blueDragging()		
		
		elseif event.phase == "began" and event.target.color == "final" then
			finalRoundSpheresRemaining = finalRoundSpheresRemaining - 1
			removeCurrentSpheres(event.target)
			event.target:removeSelf()
			if finalRoundSpheresRemaining == 0 then
				gameFinished()
			end
		
		elseif event.phase == "began" and event.target.color == "green" then
			removeCurrentSpheres(event.target)
			event.target:removeSelf()
			
			if bombSphere ~= nil then
				if bombSphere.color == "red" then
					removeCurrentSpheres(bombSphere)
					bombSphere:removeSelf()
					bombSphere = nil
			end
		end
			
			nextRound()	
		end
	end
end

local function subtractTouchCount()
	if touchCount > 0 then
		touchCount = touchCount - 1
	end
end
function backgroundTouched(event)

	if event.phase == "began" then
		touchCount = touchCount + 1
	elseif event.phase == "ended" then
		timer.performWithDelay(100, subtractTouchCount)
	end

	if event.phase == "moved" and (drag1Active or drag2Active) then
		if drag1Active and dragSphere1.color == "blue1" and getDistance(event.x, event.y, dragSphere1.x, dragSphere1.y) < 140 then
			dragSphere1.x, dragSphere1.y = math.max( 55, math.min( _W - 55, event.x )), math.max( 60, math.min( _H - 60, event.y ))
			blueDragging()
		
		elseif drag2Active and dragSphere2.color == "blue2" and getDistance(event.x, event.y, dragSphere2.x, dragSphere2.y) < 140 then
			dragSphere2.x, dragSphere2.y = math.max( 55, math.min( _W - 55, event.x )), math.max( 60, math.min( _H - 60, event.y ))
			blueDragging()
		end
	end
	if event.phase == "moved" and (double1Pressed or double2Pressed) then
		if  getDistance(event.x, event.y, doubleSphere1.x, doubleSphere1.y) > 32 and getDistance(event.x, event.y, doubleSphere2.x, doubleSphere2.y) > 32 then
			if  getDistance(event.x, event.y, doubleSphere1.x, doubleSphere1.y) > getDistance(event.x, event.y, doubleSphere2.x, doubleSphere2.y) then
				double2Pressed = false
			else
				double1Pressed = false
			end
			
		end
	end

end

local function countdown()
	countdownText.isVisible = true
	countdownLength = countdownLength - 1
	countdownText.text = countdownLength
	if audioState and countdownLength == 3 and firstPlay then
		audio.play( countdownSound, {loops=0, channel=2, onComplete=disposeCountdownSound })
	end
	if(countdownLength < 1 and gameActive) then
		if audioState and firstPlay then
			audio.play( backgroundSound, {loops=-1, channel=3, onComplete=disposeSound })
			audio.fade({channel=3, time=1, volume=1.0})
			firstPlay = false
		end
		countdownText.isVisible = false
		newSphere()
		changeColor()
		newSphere()
		--if not ads.isLoaded("interstitial") then
			--ads.load( "interstitial", { appId = adMobInterstitialID} )
		--end
		gameTimer = system.getTimer()
		
	end
end


function playAgain(event)
	if event.phase == "began" then
		--audio.fadeOut({channel=3, time=380})
		--audio.rewind( { channel=3 } )
		clickCounter = 0
		finalRoundSpheresRemaining = finalRoundSpheres
		replayButton.isVisible = false
		menuButton.isVisible = false
		gameTimerText.isVisible = false
		
		bronzeAlert.isVisible, silverAlert.isVisible, goldAlert.isVisible, platinumAlert.isVisible, xButton.isVisible = false
		highScorePos = nil
		for i = 1, #highScores do
			highScoreText[i].text = ""
			highScoreText[i].isVisible = false
		end
		countdownLength = 4
		for i=1, 10 do
			currentSpheres[i] = nil
		end
		yellowSphere, bombSphere, doubleSphere1, doubleSphere2, dragSphere1, dragSphere2 = nil
		timer.performWithDelay(462, countdown, countdownLength)
	end
end

local function backToMenu(event)
	if event.phase == "began" then
		audio.fadeOut({channel=3, time=1000})
		audio.fadeOut({channel=4, time=1000})
		composer.gotoScene( "menuScene", "slideDown", 200  )
		
	return true
	end
end

local function disableScoreboardButtons()
	replayButton:removeEventListener( "touch", playAgain )
	menuButton:removeEventListener( "touch", backToMenu )
end

local function xButtonTouched(event)
	if event.phase == "began" then
		bronzeAlert.isVisible, silverAlert.isVisible, goldAlert.isVisible, platinumAlert.isVisible, xButton.isVisible = false
		replayButton:addEventListener( "touch", playAgain )
		menuButton:addEventListener( "touch", backToMenu )
	end
end

function showScores()
	totalChallenge = preference.getValue("totalChallengePlays") + 1
	preference.save{totalChallengePlays = totalChallenge}
	
		
	local yPos = 135
	local hsText	
	for i = 1, #highScores do
		if i == 10 then
			hsText =  i .. ". " .. highScores[i]
		else
			hsText = "  " .. i .. ". " .. highScores[i]
		end
		highScoreText[i].text = hsText
		highScoreText[i].y = yPos
		if i == highScorePos then
			highScoreText[i]:setFillColor(.2,.4,0)
		elseif preference.getValue("bgWhite") then
			highScoreText[i]:setFillColor( 0,0,0,1 )
		else
			highScoreText[i]:setFillColor( 255,255,255,1 )
		end
		yPos = yPos + 30
		highScoreText[i].isVisible = true
	end
	
	if gameTimer < platinumTime then
		if medalLevel ~= "platinum" then
			unlockAchievement("ACH_CHALLENGE_PLATINUM")
			unlockAchievement("ACH_CHALLENGE_GOLD")
			unlockAchievement("ACH_CHALLENGE_SILVER")
			unlockAchievement("ACH_CHALLENGE_BRONZE")
			if preference.getValue("classicMedalLevel") == "platinum" then
				unlockAchievement("ACH_POKE_A_DOT_MASTER")
			end
			medalLevel = "platinum"
			platinumAlert.isVisible = true
			disableScoreboardButtons()
			timer.performWithDelay( 2000, showXButton )
			if audioState then
				audio.fade({channel=3, time=1, volume=0.0})
				audio.play( audio.loadSound("media/audio/PlatinumClip.mp3"), {loops=0, channel=4})
				audio.fade({channel=4, time=1, volume=1.0})
				timer.performWithDelay(10000, resumeMusic)
			end
		end
	elseif gameTimer < goldTime then
		if medalLevel ~= "gold" and medalLevel ~= "platinum" then
			unlockAchievement("ACH_CHALLENGE_GOLD")
			unlockAchievement("ACH_CHALLENGE_SILVER")
			unlockAchievement("ACH_CHALLENGE_BRONZE")
			medalLevel = "gold"
			goldAlert.isVisible = true
			disableScoreboardButtons()
			timer.performWithDelay( 2000, showXButton )
			if audioState then
				audio.fade({channel=3, time=1, volume=0.0})
				audio.play( audio.loadSound("media/audio/GoldClip.mp3"), {loops=0, channel=4})
				audio.fade({channel=4, time=1, volume=1.0})
				timer.performWithDelay(5000, resumeMusic)
			end
		end
	elseif gameTimer < silverTime then
		if medalLevel ~= "silver" and medalLevel ~= "gold" and medalLevel ~= "platinum" then
			unlockAchievement("ACH_CHALLENGE_SILVER")
			unlockAchievement("ACH_CHALLENGE_BRONZE")
			medalLevel = "silver"
			silverAlert.isVisible = true
			disableScoreboardButtons()
			timer.performWithDelay( 2000, showXButton )
			if audioState then
				audio.fade({channel=3, time=1, volume=0.0})
				audio.play( audio.loadSound("media/audio/SilverClip.mp3"), {loops=0, channel=4})
				audio.fade({channel=4, time=1, volume=1.0})
				timer.performWithDelay(4000, resumeMusic)
			end
		end
	elseif gameTimer < bronzeTime then
		if medalLevel ~= "bronze" and medalLevel ~= "silver" and medalLevel ~= "gold" and medalLevel ~= "platinum" then
			unlockAchievement("ACH_CHALLENGE_BRONZE")
			medalLevel = "bronze"
			bronzeAlert.isVisible = true
			disableScoreboardButtons()
			timer.performWithDelay( 2000, showXButton )
			if audioState then
				audio.fade({channel=3, time=1, volume=0.0})
				audio.play( audio.loadSound("media/audio/BronzeClip.mp3"), {loops=0, channel=4})
				audio.fade({channel=4, time=1, volume=1.0})
				timer.performWithDelay(2000, resumeMusic)
			end
			
		end
	end
	
	if totalChallenge == 10 then
		unlockAchievement("ACH_CHALLENGE_NOVICE")
	elseif totalChallenge == 50 then
		unlockAchievement("ACH_CHALLENGE_JOURNEYMAN")
	elseif totalChallenge == 100 then
		unlockAchievement("ACH_CHALLENGE_PRO")
	elseif totalChallenge == 500 then
		unlockAchievement("ACH_CHALLENGE_VETERAN")
	elseif totalChallenge == 1000 then
		unlockAchievement("ACH_CHALLENGE_LEGEND")
	end
	
	preference.save{challengeMedalLevel = medalLevel}
	gameTimerText.isVisible = true
	replayButton.isVisible = true
	menuButton.isVisible = true
	
	if totalChallenge % 100 == 0 and not hasPlayerRated then
		rateApp()
	end
	
	-- if totalChallenge > 1 and totalChallenge % 5 == 1 and ads.isLoaded("interstitial") then 
		-- ads.show( "interstitial", { appId = adMobInterstitialID} )
	-- end
end

local function onKeyEvent(event)
	if event.keyName == "back" then
		for i=1, #currentSpheres do
			if currentSpheres[i] ~= nil then
				currentSpheres[i]:removeSelf()
				removeCurrentSpheres(currentSpheres[i])
			end
		end
		gameActive = false
		audio.fadeOut({channel=3, time=1000})
		audio.fadeOut({channel=2, time=10})
		audio.fadeOut({channel=4, time=1000})
		composer.gotoScene( "menuScene", "slideDown", 200  )
		return true
	end
end

local function disposeSound( event )
    audio.stop( 3 )
    audio.dispose( backgroundSound )
    backgroundSound = nil
end

local function disposeCountdownSound( event )
    audio.stop( 2 )
    audio.dispose( countdownSound )
    countdownSound = nil
end

local function howToGreenYellowOkTouched(event) 
	if event.phase == "began" then
		howToGreenYellowBlack.isVisible = false
		howToGreenYellowWhite.isVisible = false
		howToGreenYellowOk.isVisible = false
		howToGreenYellowRect.isVisible = false
		timer.performWithDelay(462, countdown, countdownLength)
	end
	
end

-- -- Called when the scene's view does not exist:
 function scene:create( event )
	
	--ads:setCurrentProvider(admobNetwork)
	
	if not preference.getValue("challengeHighScores") then
		preference.save{challengeHighScores = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}}
	end
	
	if not preference.getValue("challengeMedalLevel") then
		preference.save{challengeMedalLevel = "none"}
	end
	
	screenGroup = self.view
	backgroundImageWhite = display.newImageRect(screenGroup, "media/challengeBackground.png", _W, _H)
	backgroundImageWhite.y = centerY
	backgroundImageWhite.x = centerX
	
	backgroundImageBlack = display.newImageRect(screenGroup, "media/challengeBackgroundBlack.png", _W, _H)
	backgroundImageBlack.y = centerY
	backgroundImageBlack.x = centerX
	-- backgroundRectangle = display.newRect(centerX, centerY, _W, _H)
	-- backgroundRectangle:setFillColor(255, 255, 255, 255)
	-- screenGroup:insert(backgroundRectangle)
	
	howToGreenYellowRect = display.newRect(screenGroup, centerX, centerY - 20, 180, 220)
	howToGreenYellowRect.strokeWidth = 4
	howToGreenYellowRect.isVisible = false
	
	howToGreenYellowWhite = display.newImageRect("media/howToGreenYellowWhite.png", 130, 120)
	howToGreenYellowWhite.x = centerX; howToGreenYellowWhite.y = centerY - 50
	screenGroup:insert(howToGreenYellowWhite)
	howToGreenYellowWhite.isVisible = false
	
	howToGreenYellowBlack = display.newImageRect("media/howToGreenYellowBlack.png", 130, 120)
	howToGreenYellowBlack.x = centerX; howToGreenYellowBlack.y = centerY - 50
	screenGroup:insert(howToGreenYellowBlack)
	howToGreenYellowBlack.isVisible = false
	
	howToGreenYellowOk = display.newText({text="OK", x=centerX, y=centerY + 50, fontSize=25, font="FFF Forward"})
	screenGroup:insert(howToGreenYellowOk)
	howToGreenYellowOk.isVisible = false
	
	howToDragRect = display.newRect(screenGroup, centerX, centerY - 20, 180, 220)
	howToDragRect.strokeWidth = 4
	howToDragRect.isVisible = false
	
	howToDragWhite = display.newImageRect("media/howToDragWhite.png", 130, 100)
	howToDragWhite.x = centerX; howToDragWhite.y = centerY - 50
	screenGroup:insert(howToDragWhite)
	howToDragWhite.isVisible = false
	
	howToDragBlack = display.newImageRect("media/howToDragBlack.png", 130, 100)
	howToDragBlack.x = centerX; howToDragBlack.y = centerY - 50
	screenGroup:insert(howToDragBlack)
	howToDragBlack.isVisible = false
	
	howToDragOk = display.newText({text="OK", x=centerX, y=centerY + 50, fontSize=25, font="FFF Forward"})
	screenGroup:insert(howToDragOk)
	howToDragOk.isVisible = false
	
	
	howToDoubleRect = display.newRect(screenGroup, centerX, centerY - 20, 180, 220)
	howToDoubleRect.strokeWidth = 4
	howToDoubleRect.isVisible = false
	
	howToDoubleWhite = display.newImageRect("media/howToDoubleWhite.png", 130, 100)
	howToDoubleWhite.x = centerX; howToDoubleWhite.y = centerY - 50
	screenGroup:insert(howToDoubleWhite)
	howToDoubleWhite.isVisible = false
	
	howToDoubleBlack = display.newImageRect("media/howToDoubleBlack.png", 130, 100)
	howToDoubleBlack.x = centerX; howToDoubleBlack.y = centerY - 50
	screenGroup:insert(howToDoubleBlack)
	howToDoubleBlack.isVisible = false
	
	howToDoubleOk = display.newText({text="OK", x=centerX, y=centerY + 50, fontSize=25, font="FFF Forward"})
	screenGroup:insert(howToDoubleOk)
	howToDoubleOk.isVisible = false
	
	
	howToBombRect = display.newRect(screenGroup, centerX, centerY - 20, 180, 220)
	howToBombRect.strokeWidth = 4
	howToBombRect.isVisible = false
	
	howToBombWhite = display.newImageRect("media/howToBombWhite.png", 100, 140)
	howToBombWhite.x = centerX; howToBombWhite.y = centerY - 50
	screenGroup:insert(howToBombWhite)
	howToBombWhite.isVisible = false
	
	howToBombBlack = display.newImageRect("media/howToBombBlack.png", 100, 140)
	howToBombBlack.x = centerX; howToBombBlack.y = centerY - 50
	screenGroup:insert(howToBombBlack)
	howToBombBlack.isVisible = false
	
	howToBombOk = display.newText({text="OK", x=centerX, y=centerY + 50, fontSize=25, font="FFF Forward"})
	screenGroup:insert(howToBombOk)
	howToBombOk.isVisible = false

	countdownText = display.newText({text='',  x=centerX, y=centerY - 30, fontSize=80, font="FFF Forward" })
	screenGroup:insert(countdownText)
	countdownText.isVisible = false
	
	gameTimerText = display.newText({parent=self.view, text='', x=centerX, y=75, font="FFF Forward", fontSize=35 })
	gameTimerText.isVisible = false
	
	for i=1, 10 do
		highScoreText[i] = display.newText({parent=self.view, text='',  x=centerX + 5, y=100, align = "left", width = 140, height = 35, anchorX = 0, fontSize=20, font="FFF Forward"}) 
		if i == 1 or i == 10 then
			highScoreText[i].x = centerX+10
		end
		highScoreText[i].isVisible = false
	end
	
	menuButton = display.newText({text="Menu",  x= _W - 80, y= _H - 50, fontSize=25, font="FFF Forward"})  --display.newImage("media/menuButtonTransparent.png")
	--menuButton.x = _W - 80; menuButton.y = _H - 50;
	screenGroup:insert(menuButton)
	menuButton.isVisible = false
	
	replayButton = display.newText({text="Replay",  x= 90, y= _H - 50, fontSize=25, font="FFF Forward"}) --display.newImage("media/replayButtonTransparent.png")
	--replayButton.width = 150
	--replayButton.x = 80; replayButton.y = _H - 50;
	screenGroup:insert(replayButton)
	replayButton.isVisible = false
	
	goldAlert = display.newImage("media/goldAlert.png")
	goldAlert.x = centerX; goldAlert.y = centerY - 60;
	screenGroup:insert(goldAlert)
	goldAlert.isVisible = false
	
	silverAlert = display.newImage("media/silverAlert.png")
	silverAlert.x = centerX; silverAlert.y = centerY - 60;
	screenGroup:insert(silverAlert)
	silverAlert.isVisible = false
	
	bronzeAlert = display.newImage("media/bronzeAlert.png")
	bronzeAlert.x = centerX; bronzeAlert.y = centerY - 60;
	screenGroup:insert(bronzeAlert)
	bronzeAlert.isVisible = false
	
	platinumAlert = display.newImage("media/platinumAlert.png")
	platinumAlert.x = centerX; platinumAlert.y = centerY - 60;
	screenGroup:insert(platinumAlert)
	platinumAlert.isVisible = false
	
	xButton = display.newImage("media/xButton.png")
	xButton.x = centerX + 120; xButton.y = centerY - 120;
	screenGroup:insert(xButton)
	xButton.isVisible = false
	
	if preference.getValue("bgWhite") then
		backgroundImageWhite.isVisible = true
		backgroundImageBlack.isVisible = false
		replayButton:setFillColor(0,0,0,1)
		menuButton:setFillColor(0,0,0,1)
		countdownText:setFillColor( 0,0,0,1 )
	else
		backgroundImageBlack.isVisible = true
		backgroundImageWhite.isVisible = false
		replayButton:setFillColor(255,255,255,1)
		menuButton:setFillColor(255,255,255,1)
		countdownText:setFillColor(255,255,255,1)
	end
 end


-- -- Called immediately after scene has moved onscreen:
 function scene:show( event )
	if event.phase == "did" then	

		system.activate( "multitouch" )
		
		backgroundSound = audio.loadStream( "media/audio/ChallengeGame.mp3" )
		countdownSound = audio.loadStream("media/audio/Countdown.mp3")
		audioState = preference.getValue("audioState")
		
		if preference.getValue("totalClassicPlays") == 0 and preference.getValue("totalChallengePlays") == 0 then
			howToGreenYellowOk.isVisible = true
			howToGreenYellowRect.isVisible = true
			
			if preference.getValue("bgWhite") then
				howToGreenYellowWhite.isVisible = true
				howToGreenYellowOk:setFillColor(0)
				howToGreenYellowRect:setFillColor(1)
				howToGreenYellowRect:setStrokeColor(0)
			else
				howToGreenYellowBlack.isVisible = true
				howToGreenYellowOk:setFillColor(1)
				howToGreenYellowRect:setFillColor(0)
				howToGreenYellowRect:setStrokeColor(1)			
			end
			
			howToGreenYellowOk:addEventListener("touch", howToGreenYellowOkTouched)
		else
			timer.performWithDelay(462, countdown, countdownLength)
		end
		
		replayButton:addEventListener( "touch", playAgain )
		menuButton:addEventListener( "touch", backToMenu )
		backgroundImageWhite:addEventListener("touch", backgroundTouched)
		backgroundImageBlack:addEventListener("touch", backgroundTouched)
		xButton:addEventListener("touch", xButtonTouched)
		Runtime:addEventListener("key", onKeyEvent)
		
		--preference.save{challengeHighScores = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}}
		--preference.save{challengeMedalLevel = "none"}
		highScores = preference.getValue("challengeHighScores")
		medalLevel = preference.getValue("challengeMedalLevel")
		
	end
 end


-- -- Called when scene is about to move offscreen:
 function scene:hide(event)
	if event.phase == "will" then
	
		-- print( "2: exitScene event" )
		
		-- remove touch listener for image
		replayButton:removeEventListener( "touch", playAgain )
		menuButton:removeEventListener( "touch", backToMenu )
		backgroundImageWhite:addEventListener("touch", backgroundTouched)
		backgroundImageBlack:addEventListener("touch", backgroundTouched)
		xButton:removeEventListener("touch", xButtonTouched)
		Runtime:removeEventListener("key", onKeyEvent)
		composer.removeScene("newChallengeGameScene")
		--timer.cancel(gameTimer)
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