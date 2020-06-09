-- LOAD VIEW AND UTILITY CLASSES
local composer = require "composer" 
local scene = composer.newScene()
local preference = require "preference"
local gameNetwork = require "gameNetwork" 

-- Global device specific coordinates
local _W = display.actualContentWidth
local _H = display.actualContentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local imOptions = {width=_W, height=480}

local backgroundImage
-- local admobNetwork = "admob"
-- local adMobInterstitialID = "ca-app-pub-1087735013942822/4222921993"

-- --local ads = require "ads"

-- local function admobListener( event )
    -- if event.isError then
    -- end
-- end

--ads.init( admobNetwork, adMobInterstitialID, admobListener )
-- game controls
local replayButton, menuButton

local gameTimer, gphsTime
local clickCounter = 0
local clickTotal = 26
local yellowSphere
local sphereClicked
local countdownText
local countdownLength = 4

local highScores = {}
local highScoreText = {}
local highScorePos

local medalLevel
local bronzeTime = 18
local silverTime = 10
local goldTime = 7
local platinumTime = 6

local backgroundImageWhite, backgroundImageBlack
local bronzeAlert, silverAlert, goldAlert, platinumAlert, xButton
local howToWhite, howToBlack, howToRect, howToOk

local firstPlay = true
local gameActive = true
local hasPlayerRated = preference.getValue("hasPlayerRated")
local totalClassic
local rateit = require("rateit")
  rateit.setiTunesURL(1234564) --insert appId
  rateit.setAndroidURL(1234564) --insert appId

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

local function unlockAchievement(achievement)
	
	local myAchievement = "com.ImpliedGamingStudios.PokeADot." .. achievement

	if ( system.getInfo("platformName") == "Android" ) then
	   --for GPGS, reset "myAchievement" to the string provided from the achievement setup in Google
		if achievement == "ACH_CLASSIC_PLATINUM" then
			myAchievement = "CgkIruCKpq0YEAIQBQ"
		elseif achievement == "ACH_CLASSIC_GOLD" then
			myAchievement = "CgkIruCKpq0YEAIQBA"
		elseif achievement == "ACH_CLASSIC_SILVER" then
			myAchievement = "CgkIruCKpq0YEAIQAw"
		elseif achievement == "ACH_CLASSIC_BRONZE" then
			myAchievement = "CgkIruCKpq0YEAIQAg"
		elseif achievement == "ACH_CLASSIC_NOVICE" then
			myAchievement = "CgkIruCKpq0YEAIQDg"
		elseif achievement == "ACH_CLASSIC_JOURNEYMAN" then
			myAchievement = "CgkIruCKpq0YEAIQDQ"
		elseif achievement == "ACH_CLASSIC_PRO" then
			myAchievement = "CgkIruCKpq0YEAIQDw"
		elseif achievement == "ACH_CLASSIC_VETERAN" then
			myAchievement = "CgkIruCKpq0YEAIQEA"
		elseif achievement == "ACH_CLASSIC_LEGEND" then
			myAchievement = "CgkIruCKpq0YEAIQEQ"
		elseif achievement == "ACH_POKE_A_DOT_MASTER" then
			myAchievement = "CgkIruCKpq0YEAIQCg"
		end
	else
		if achievement == "ACH_CLASSIC_PLATINUM" then
			myAchievement = "grp.pokeadot.cp"
		elseif achievement == "ACH_CLASSIC_GOLD" then
			myAchievement = "grp.pokeadot.cg"
		elseif achievement == "ACH_CLASSIC_SILVER" then
			myAchievement = "grp.pokeadot.cs"
		elseif achievement == "ACH_CLASSIC_BRONZE" then
			myAchievement = "grp.pokeadot.cb"
		elseif achievement == "ACH_CLASSIC_NOVICE" then
			myAchievement = "grp.pokeadot.cn"
		elseif achievement == "ACH_CLASSIC_JOURNEYMAN" then
			myAchievement = "grp.pokeadot.cj"
		elseif achievement == "ACH_CLASSIC_PRO" then
			myAchievement = "grp.pokeadot.cpr"
		elseif achievement == "ACH_CLASSIC_VETERAN" then
			myAchievement = "grp.pokeadot.cv"
		elseif achievement == "ACH_CLASSIC_LEGEND" then
			myAchievement = "grp.pokeadot.cl"
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
local alert = native.showAlert( "Rate Poke-A-Dot", "If you enjoy playing Poke-A-Dot, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your Support", { "OK", "Remind Me Later", "Never" }, rateAppListener )
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
	preference.save{classicHighScores = highScores}

	local myCategory = "com.ImpliedGamingStudios.PokeADot.ClassicHighScores"

	if ( system.getInfo( "platformName" ) == "Android" ) then
	   --for GPGS, reset "myCategory" to the string provided from the leaderboard setup in Google
	   myCategory = "CgkIruCKpq0YEAIQAA"
	else
		myCategory = "grp.pokeadot.classic"
	end

	gameNetwork.request( "setHighScore",
	{
	   localPlayerScore = { category=myCategory, value=gphsTime },
	   listener = postScoreSubmit
	} )
	
end

local function gameFinished()
	yellowSphere = nil
	local temp = system.getTimer() - gameTimer
	gphsTime = math.floor(temp)
	gameTimer = round((temp) / 1000, 3)
	gameTimerText.text = gameTimer
	updateHighScores(gameTimer)
	showScores()
end

local function getDistance(x,y,x2,y2)
	return math.sqrt((x2 - x) * (x2 - x) + (y2 - y) * (y2 - y))
end

local function newSphere()
	local newPos = false
	local x, y
	
	while not newPos do
		x = math.random(0, 3) * ((_W - 40) / 4) + 55
		y = math.random(0, 5) * ((_H - 35)/ 6) + 60
		if yellowSphere == nil then
			newPos = true
		elseif getDistance(x, y, yellowSphere.x, yellowSphere.y) > 50 then
			newPos = true
		end
	end

	
	local sphere = display.newCircle(x, y, 32)
	sphere:setFillColor(1,1,0)
	sphere.color = "yellow"
--if preference.getValue("bgWhite") then
		sphere:setStrokeColor(0,0,0)
	--else
	--	sphere:setStrokeColor(200,100,0)
	--end
	sphere.strokeWidth = 4
	sphere:addEventListener("touch", sphereClicked)
	yellowSphere = sphere
	screenGroup:insert(yellowSphere)
end

local function changeColor()
	yellowSphere:setFillColor(.2,.4,0)
	yellowSphere.color = "green"
end

function sphereClicked(event)
	if event.phase == "began" and event.target.color == "green" then
		clickCounter = clickCounter + 1
		event.target:removeSelf()
		changeColor()
		if clickCounter < clickTotal then
		newSphere()
		elseif clickCounter > clickTotal then
		gameFinished()
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
			--ads.load( "interstitial", { appId = adMobInterstitialID} )
			gameTimer = system.getTimer()
	end
end

function playAgain(event)
	if event.phase == "began" then
		--audio.fadeOut({channel=3, time=380})
		--audio.rewind( { channel=3 } )
		clickCounter = 0
		replayButton.isVisible = false
		menuButton.isVisible = false
		gameTimerText.isVisible = false
		highScorePos = nil
		bronzeAlert.isVisible, silverAlert.isVisible, goldAlert.isVisible, platinumAlert.isVisible, xButton.isVisible = false
		for i = 1, #highScores do
			highScoreText[i].text = ""
			highScoreText[i].isVisible = false
		end
		countdownLength = 4
		timer.performWithDelay(462, countdown, countdownLength)
	end

end

local function backToMenu(event)
	if event.phase == "began" then
		audio.fadeOut({channel=3, time=1000})
		audio.fadeOut({channel=4, time=1000})
		composer.gotoScene( "menuScene", "slideUp", 200  )
	
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
		if highScorePos == i then
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
			unlockAchievement("ACH_CLASSIC_PLATINUM")
			unlockAchievement("ACH_CLASSIC_GOLD")
			unlockAchievement("ACH_CLASSIC_SILVER")
			unlockAchievement("ACH_CLASSIC_BRONZE")
			if preference.getValue("challengeMedalLevel") == "platinum" then
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
			unlockAchievement("ACH_CLASSIC_GOLD")
			unlockAchievement("ACH_CLASSIC_SILVER")
			unlockAchievement("ACH_CLASSIC_BRONZE")
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
			unlockAchievement("ACH_CLASSIC_SILVER")
			unlockAchievement("ACH_CLASSIC_BRONZE")
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
			unlockAchievement("ACH_CLASSIC_BRONZE")
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
	
	totalClassic = preference.getValue("totalClassicPlays") + 1
	preference.save{totalClassicPlays = totalClassic}
	
	if totalClassic == 10 then
		unlockAchievement("ACH_CLASSIC_NOVICE")
	elseif totalClassic == 50 then
		unlockAchievement("ACH_CLASSIC_JOURNEYMAN")
	elseif totalClassic == 100 then
		unlockAchievement("ACH_CLASSIC_PRO")
	elseif totalClassic == 500 then
		unlockAchievement("ACH_CLASSIC_VETERAN")
	elseif totalClassic == 1000 then
		unlockAchievement("ACH_CLASSIC_LEGEND")
	end
	
	preference.save{classicMedalLevel = medalLevel}
	
	if totalClassic % 100 == 0 and not hasPlayerRated then
		rateApp()
	end
	
	gameTimerText.isVisible = true 
	replayButton.isVisible = true
	menuButton.isVisible = true
	
	-- if totalClassic > 1 and totalClassic % 8 == 1 and ads.isLoaded("interstitial") then 
		-- ads.show( "interstitial", { appId = adMobInterstitialID} )
	-- end
end

local function onKeyEvent(event)
	if event.keyName == "back" then
		audio.fadeOut({channel=3, time=1000})
		audio.fadeOut({channel=2, time=10})
		audio.fadeOut({channel=4, time=1000})
		gameActive = false
		composer.gotoScene( "menuScene", "slideUp", 200  )
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

local function howToOkTouched(event) 
	if event.phase == "began" then
		howToBlack.isVisible = false
		howToWhite.isVisible = false
		howToOk.isVisible = false
		howToRect.isVisible = false
		timer.performWithDelay(462, countdown, countdownLength)
	end
	
end
-- -- Called when the scene's view does not exist:
 function scene:create( event )
	--ads:setCurrentProvider(admobNetwork)
 
	if not preference.getValue("classicHighScores") then
		preference.save{classicHighScores = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}}
	end
	
	if not preference.getValue("classicMedalLevel") then
		preference.save{classicMedalLevel = "none"}
	end
	
	screenGroup = self.view

	backgroundImageWhite = display.newImageRect(screenGroup, "media/classicBackground.png", _W, _H)
	backgroundImageWhite.y = centerY
	backgroundImageWhite.x = centerX
	
	backgroundImageBlack = display.newImageRect(screenGroup, "media/classicBackgroundBlack.png", _W, _H)
	backgroundImageBlack.y = centerY
	backgroundImageBlack.x = centerX
	-- backgroundRectangle = display.newRect(centerX, centerY, _W, _H)
	-- backgroundRectangle:setFillColor(255, 255, 255, 255)
	-- screenGroup:insert(backgroundRectangle)
	 

	countdownText = display.newText({text='',  x=centerX, y=centerY - 30, fontSize=80, font="FFF Forward"})
	screenGroup:insert(countdownText)
	countdownText.isVisible = false
	
	gameTimerText = display.newText({parent=self.view, text='', x=centerX, y=75, fontSize=35, font="FFF Forward"})
	gameTimerText.isVisible = false
	
	for i=1, 10 do
		highScoreText[i] = display.newText({parent=self.view, text='',  x=centerX + 5, y=100, align = "left", width = 140, height = 35, anchorX = 0, fontSize=20, font="FFF Forward"}) 
		if i == 1 or i == 10 then
			highScoreText[i].x = centerX+10
		end
		highScoreText[i].isVisible = false
	end
	
	
	howToRect = display.newRect(screenGroup, centerX, centerY - 20, 180, 220)
	howToRect.strokeWidth = 4
	howToRect.isVisible = false
	
	howToWhite = display.newImageRect("media/howToGreenYellowWhite.png", 130, 120)
	howToWhite.x = centerX; howToWhite.y = centerY - 50
	screenGroup:insert(howToWhite)
	howToWhite.isVisible = false
	
	howToBlack = display.newImageRect("media/howToGreenYellowBlack.png", 130, 120)
	howToBlack.x = centerX; howToBlack.y = centerY - 50
	screenGroup:insert(howToBlack)
	howToBlack.isVisible = false
	
	howToOk = display.newText({text="OK", x=centerX, y=centerY + 50, fontSize=25, font="FFF Forward"})
	screenGroup:insert(howToOk)
	howToOk.isVisible = false
	
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
		--gameTimerText:setFillColor( 0,0,0,1 )
		countdownText:setFillColor( 0,0,0,1 )
	else
		backgroundImageBlack.isVisible = true
		backgroundImageWhite.isVisible = false
		replayButton:setFillColor(255,255,255,1)
		menuButton:setFillColor(255,255,255,1)
		--gameTimerText:setFillColor( 0,0,0,1 )
		countdownText:setFillColor(255,255,255,1)
	end
 end


-- -- Called immediately after scene has moved onscreen:
 function scene:show( event )
	
	if event.phase == "did" then
	
		system.activate( "multitouch" )
		
		countdownSound = audio.loadStream("media/audio/Countdown.mp3")
		backgroundSound = audio.loadStream( "media/audio/ClassicGame.mp3" )
		audioState = preference.getValue("audioState")
			
		if preference.getValue("totalClassicPlays") == 0 and preference.getValue("totalChallengePlays") == 0 then
			howToOk.isVisible = true
			howToRect.isVisible = true
			
			if preference.getValue("bgWhite") then
				howToWhite.isVisible = true
				howToOk:setFillColor(0)
				howToRect:setFillColor(1)
				howToRect:setStrokeColor(0)
			else
				howToBlack.isVisible = true
				howToOk:setFillColor(1)
				howToRect:setFillColor(0)
				howToRect:setStrokeColor(1)			
			end
			
			howToOk:addEventListener("touch", howToOkTouched)
		else
			timer.performWithDelay(462, countdown, countdownLength)
		end
		
		replayButton:addEventListener( "touch", playAgain )
		menuButton:addEventListener( "touch", backToMenu )
		xButton:addEventListener("touch", xButtonTouched)
		Runtime:addEventListener("key", onKeyEvent)
		
		--preference.save{classicHighScores = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}}
		--preference.save{classicMedalLevel = "none"}
		highScores = preference.getValue("classicHighScores")
		medalLevel = preference.getValue("classicMedalLevel")
	end
 end


-- -- Called when scene is about to move offscreen:
 function scene:hide( event )
	
	if event.phase == "will" then
		-- print( "2: exitScene event" )
		
		-- remove touch listener for image
		replayButton:removeEventListener( "touch", playAgain )
		menuButton:removeEventListener( "touch", backToMenu )
		xButton:removeEventListener("touch", xButtonTouched)
		Runtime:removeEventListener("key", onKeyEvent)
		--timer.cancel(gameTimer)
		
		composer.removeScene("newClassicGameScene")
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