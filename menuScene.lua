
local composer = require( "composer" )
local scene = composer.newScene()
local preference = require "preference"
local gameNetwork = require "gameNetwork" 
local http = require "socket.http"

-- application IDs

--admob IDs for ImpliedGaming
-- local admobNetwork = "admob"
-- local adMobInterstitialID = "ca-app-pub-1087735013942822/4222921993"
-- local adMobBannerID = "ca-app-pub-1087735013942822/7036787591"

-- --inmobi IDs for ImpliedGaming
-- local inmobiNetwork = "inmobi"
-- local inmobiInterstitialID = ""
-- local inmobiBannerID = ""

-- vungle IDs for ImpliedGaming *NOTE* only serves interstitial
-- local vungleNetwork = "vungle"
-- local vungleID = "53d69991725e76ab7700007c"

-- --iAds IDs for ImpliedGaming
-- local iAdsNetwork = "iads"
-- local iAdsBannerID = ""

-- -- Load Corona 'ads' library
-- local ads = require "ads"

-- local function admobListener( event )
    -- if event.isError then
        -- -- ads:setCurrentProvider(inmobiNetwork)
    -- end
-- end

-- local function iAdsListener( event )
    -- if event.isError then
        -- -- ads:setCurrentProvider(inmobiNetwork)
    -- end
-- end

-- -- local function vungleListener( event )
    -- -- if event.isError then
        -- -- -- Failed to receive an ad.
    -- -- end
-- -- end

-- local function inmobiListener( event )
	-- if event.isError then
        -- -- Failed to receive an ad.
    -- end
-- end

--ads.init( admobNetwork, adMobBannerID, admobListener )
-- ads.init( vungleNetwork, vungleID );
-- ads.init( inmobiNetwork, inmobiBannerID, inmobiListener )
-- ads.init( iadsNetwork, iAdsBannerID, iAdsListener)


---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

--------------------------------------------
-- Game Network

local platform = system.getInfo('platform')

local gameCenter = nil
local gpgs = nil

if platform == 'ios' then
	gameCenter = require('gameNetwork')
elseif platform == 'android' then
	gpgs = require('plugin.gpgs.v2')
	-- local licensing = require( "licensing" )

	-- local function licensingListener( event )
	-- 	print('license listener', event.isVerified)

	-- 	if not ( event.isVerified ) then
	-- 		-- Failed to verify app from the Google Play store; print a message
	-- 		print( "Pirates!!!" )
	-- 	end
	-- end

	-- local licensingInit = licensing.init( "google" )

	-- if ( licensingInit == true ) then
	-- 	licensing.verify( licensingListener )
	-- end
end

local function gcInitListener( event )
    if ( event.type == "showSignIn" ) then
        -- This is an opportunity to pause your game or do other things you might need to do while the Game Center Sign-In controller is up.
    elseif ( event.data ) then
		preference.save{useGPGS = true}

		-- gameCenter.request( "setHighScore", {
		-- 	localPlayerScore = { category="pivot.leaderboard", value=saveData.highscore }
		-- })
    end
end

local function initGameCenter ()
	gameCenter.init( "gamecenter", gcInitListener )
end

local function gpgsInitListener (event)
	print('listener', event)
	if event.data then  -- Successful login event
		print('logged in', event.data)
		preference.save{useGPGS = true}
    end
end

local function initGPGS ()
	-- print('login gpgps')
    -- gpgs.login( { userInitiated=true, listener=gpgsInitListener } )
end

local function initSocialLeaderboards ()
	-- Initialize game network based on platform
	if ( gpgs ) then
		-- Initialize Google Play Games Services
		initGPGS()
	elseif ( gameCenter ) then
		-- Initialize Apple Game Center
		initGameCenter()
	end
end

initSocialLeaderboards()
-- Runtime:addEventListener( "system", onSystemEvent )
--------------------------------------------

local _W = display.actualContentWidth
local _H = display.actualContentHeight
print(_W, _H)
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local audioOn, audioOff, audioOnBlack, audioOffBlack
local audioState

local backgroundWhite
local bgRect, titleImage, backgroundImageWhite, backgroundImageBlack
local backgroundSound, blackOrWhite, whiteTitle, blackTitle, ghsWhite, ghsBlack
local challengeMedal, classicMedal, achievementWhite, achievementBlack

local fonts = native.getFontNames()

count = 0

-- Count the number of total fonts
for i,fontname in ipairs(fonts) do
    count = count+1
end

print( "\rFont count = " .. count )

local name = "FF"     -- part of the Font name we are looking for

name = string.lower( name )

-- Display each font in the terminal console
for i, fontname in ipairs(fonts) do
    j, k = string.find( string.lower( fontname ), name )

    if( j ~= nil ) then

        print( "fontname = " .. tostring( fontname ) )

    end
end

-- Touch event listener for background image

local function showLeaderboards( event )
	if event.phase == "began" then
		if preference.getValue("useGPGS") then
			if ( system.getInfo("platformName") == "Android" ) then
				gameNetwork.show( "leaderboards" )
			else
				gameNetwork.show( "leaderboards", { leaderboard = {timeScope="AllTime"} } )
			end
			return true
		else 
			initSocialLeaderboards()
		end
	end
end

local function showAchievements(event)
	if event.phase == "began" then
		if preference.getValue("useGPGS") then
			gameNetwork.show( "achievements" )
			return true	
		else 
			initSocialLeaderboards()
		end
	end
end

local function gotoClassic(event )
	if event.phase == "began" then
		audio.fadeOut({channel=1, time=1000})
		--ads.hide()
		composer.gotoScene( "newClassicGameScene", "slideDown", 200  )
		
		return true
	end
end

local function gotoChallenge(event )
	if event.phase == "began" then
		--ads.hide()
		audio.fadeOut({channel=1, time=1000})
		composer.gotoScene( "newChallengeGameScene", "slideUp", 200  )
		
		return true
	end
end

local function gotoInstructions(event )
	if event.phase == "began" then
		composer.gotoScene( "instructionsScene", "slideLeft", 200  )
		
		return true
	end
end

		

local function toggleAudio(event)
	if event.phase == "began" then
		audioState = not audioState
		if preference.getValue("bgWhite") then
			audioOff.isVisible = not audioState
			audioOn.isVisible = audioState
		else
			audioOffBlack.isVisible = not audioState
			audioOnBlack.isVisible = audioState
		end
		if audioState then
			audio.setVolume( 1, {channel=1} )
		else
			audio.setVolume( 0, {channel=1} )
		end
		
		preference.save{audioState = audioState}
		return true
	end
end

local function setBackgroundColors()
	
	if backgroundWhite then
		audioOff.isVisible = not audioState
		audioOn.isVisible = audioState		
		audioOffBlack.isVisible = false
		audioOnBlack.isVisible = false
		whiteTitle.isVisible = true
		blackTitle.isVisible = false
		backgroundImageWhite.isVisible = true
		backgroundImageBlack.isVisible = false
		if preference.getValue("useGPGS") or preference.getValue("useGPGS") == nil then
			ghsWhite.isVisible = true
			ghsBlack.isVisible = false
			achievementWhite.isVisible = true
			achievementBlack.isVisible = false
		else
			ghsWhite.isVisible = true
			ghsBlack.isVisible = false
			achievementWhite.isVisible = true
			achievementBlack.isVisible = false
		end
		if classicMedal == "none" or classicMedal == nil then
			classicNoneIconWhite.isVisible = true
			classicNoneIconBlack.isVisible = false
		end
		if challengeMedal == "none" or challengeMedal == nil then
			challengeNoneIconWhite.isVisible = true
			challengeNoneIconBlack.isVisible = false
		end
		classicButton:setFillColor(0,0,0,1)
		challengeButton:setFillColor(0,0,0,1)
		instructionsButton:setFillColor(0,0,0,1)

	else
		audioOffBlack.isVisible = not audioState
		audioOnBlack.isVisible = audioState		
		audioOff.isVisible = false
		audioOn.isVisible = false	
		blackTitle.isVisible = true
		whiteTitle.isVisible = false
		backgroundImageWhite.isVisible = false
		backgroundImageBlack.isVisible = true
		if preference.getValue("useGPGS") or preference.getValue("useGPGS") == nil then
			ghsWhite.isVisible = false
			ghsBlack.isVisible = true
			achievementWhite.isVisible = false
			achievementBlack.isVisible = true
		else
			ghsWhite.isVisible = false
			ghsBlack.isVisible = true
			achievementWhite.isVisible = false
			achievementBlack.isVisible = true
			ghsBlack.alpha = 0.50
			achievementBlack.alpha = 0.50
		end
		if classicMedal == "none" or classicMedal == nil then
			classicNoneIconWhite.isVisible = false
			classicNoneIconBlack.isVisible = true
		end
		if challengeMedal == "none" or challengeMedal == nil then
			challengeNoneIconWhite.isVisible = false
			challengeNoneIconBlack.isVisible = true
		end
		classicButton:setFillColor(255,255,255,1)
		challengeButton:setFillColor(255,255,255,1)
		instructionsButton:setFillColor(255,255,255,1)
	end
end

local function toggleBackground(event)
	--backgroundImage:removeSelf()
	if event.phase == "began" then
		backgroundWhite = not backgroundWhite
		setBackgroundColors()
		blackOrWhite:toFront()
		preference.save{bgWhite = backgroundWhite}
	end
end

local function disposeSound( event )
    audio.stop( 1 )
    audio.dispose( backgroundSound )
    backgroundSound = nil
end

local function onKeyEvent(event)
	if event.keyName == "back" then
		os.exit()
	end
end

local function loadLocalPlayerCallback( event )
	if event.isError then
	end
   playerName = event.data.alias
   saveSettings()  --save player data locally using your own "saveSettings()" function
end

local function gameNetworkLoginCallback( event )
   gameNetwork.request( "loadLocalPlayer", { listener=loadLocalPlayerCallback } )
   return true
end

local function gpgsInitCallback( event )
	if event.isError then
	end
   gameNetwork.request( "login", { userInitiated=true, listener=gameNetworkLoginCallback } )
end

local function gameNetworkSetup()
   if ( system.getInfo("platformName") == "Android" ) then
      gameNetwork.init( "google", gpgsInitCallback )
   else
      gameNetwork.init( "gamecenter", gameNetworkLoginCallback )
   end
end

function GPGSListener(event)
	if "clicked" == event.action then
        local i = event.index
        if 1 == i then
            gameNetworkSetup()
			preference.save{useGPGS = true}
        elseif 2 == i then
            preference.save{useGPGS = false}
			
        end
    end

end

-- Called when the scene's view does not exist:
function scene:create( event )

	if preference.getValue("audioState") == nil then
		preference.save{audioState = true}
	end
	
	if preference.getValue("bgWhite") == nil then
		preference.save{bgWhite = true}
	end
	
	if preference.getValue("totalClassicPlays") == nil then
		preference.save{totalClassicPlays = 0}
	end
	
	if preference.getValue("totalChallengePlays") == nil then
		preference.save{totalChallengePlays = 0}
	end
		
	if preference.getValue("howToDrag") == nil then
		preference.save{howToDrag = false}
	end
	
	if preference.getValue("howToDouble") == nil then
		preference.save{howToDouble = false}
	end
	
	if preference.getValue("howToBomb") == nil then
		preference.save{howToBomb = false}
	end
	
	if preference.getValue("hasPlayerRated") == nil then
		preference.save{hasPlayerRated = false}
	end
		
	--if preference.getValue("useGPGS") == nil then
		--preference.save{useGPGS = "maybe"}
	--end
	
	
	--local isTall = ( "iPhone" == system.getInfo( "model" ) ) and ( display.pixelHeight > 960 )
	
	local screenGroup = self.view
	
	bgRect = display.newRect(screenGroup, centerX, centerY, _W, _H)
	bgRect:setFillColor(255, 255, 255, 255)
	local imOptions = {width=_W, height=480}
	--[[
	if isTall then
		imOptions.height = 480
	else
		imOptions.height = _H
	end
	]]	
	--image.width = _W

	--need to center this vertically
	--screenGroup:insert(image)
	
	backgroundImageWhite = display.newImageRect(screenGroup, "media/menuBackground.png", _W, _H)
	backgroundImageWhite.anchorX = 0
	backgroundImageWhite.anchorY = 0
	backgroundImageWhite.x = 0 + display.screenOriginX
	backgroundImageWhite.y = 0 + display.screenOriginY
	
	backgroundImageBlack = display.newImageRect(screenGroup, "media/menuBackgroundBlack.png", _W, _H)
	backgroundImageBlack.anchorX = 0
	backgroundImageBlack.anchorY = 0
	backgroundImageBlack.x = 0 + display.screenOriginX
	backgroundImageBlack.y = 0 + display.screenOriginY
	
	whiteTitle = display.newImageRect(screenGroup, "media/WhiteTitle.png", 250, 55)
	whiteTitle.y = 180
	whiteTitle.x = centerX
	
	blackTitle = display.newImageRect(screenGroup, "media/WhiteTitle.png", 250, 55)
	blackTitle.y = 180
	blackTitle.x = centerX
	
	titleImage = display.newImageRect(screenGroup, "media/Logo.png", 150, 150)
	titleImage.y = 100
	titleImage.x = centerX - 20
	
	ghsWhite = display.newImageRect(screenGroup, "media/highScoresWhite.png", 50, 50) 
	ghsWhite.x = centerX + 10
	ghsWhite.y = centerY + 155
	ghsWhite.isVisible = false
	
	ghsBlack = display.newImageRect(screenGroup, "media/highScoresBlack.png", 50, 50) 
	ghsBlack.x = centerX + 10
	ghsBlack.y = centerY + 155
	ghsBlack.isVisible = false
	
	achievementWhite = display.newImageRect(screenGroup, "media/achievementsWhite.png", 50, 50) 
	achievementWhite.x = centerX + 80
	achievementWhite.y = centerY + 155
	achievementWhite.isVisible = false
	
	achievementBlack = display.newImageRect(screenGroup, "media/achievementsBlack.png", 50, 50) 
	achievementBlack.x = centerX + 80
	achievementBlack.y = centerY + 155
	achievementBlack.isVisible = false
	
	classicButton = display.newText({text="Classic",  x=centerX , y=centerY + 23, fontSize=30, font="FFF Forward"})       
	--classicButton.x = centerX; classicButton.y = centerY+20;
	screenGroup:insert(classicButton)
	
	challengeButton = display.newText({text="Challenge",  x=centerX + 22, y=centerY + 93, fontSize=30, font="FFF Forward"})  
	--challengeButton.x = centerX; challengeButton.y = centerY+90;
	screenGroup:insert(challengeButton)
	
	instructionsButton = display.newText({text="?",  x=centerX - 55, y=centerY + 160, fontSize=30, font="FFF Forward"})  
	--challengeButton.x = centerX; challengeButton.y = centerY+90;
	screenGroup:insert(instructionsButton)
	
	

	--logRect.isVisible, logConfirm.isVisible, logYes.isVisible, logNo.isVisible = true
	
	audioOn = display.newImage('media/audio-on.png')
	audioOn.width = 30; audioOn.height = 30; audioOn.x = _W-40; audioOn.y = 45
	audioOn:toFront()
	screenGroup:insert(audioOn)
	
	audioOff = display.newImage('media/audio-off.png')
	audioOff.width = 30; audioOff.height = 30; audioOff.x = _W-40; audioOff.y = 45
	audioOff:toFront()
	screenGroup:insert(audioOff)
	
	audioOnBlack = display.newImage('media/audio-onBlack.png')
	audioOnBlack.width = 30; audioOnBlack.height = 30; audioOnBlack.x = _W-40; audioOnBlack.y = 45
	audioOnBlack:toFront()
	screenGroup:insert(audioOnBlack)
	
	audioOffBlack = display.newImage('media/audio-offBlack.png')
	audioOffBlack.width = 30; audioOffBlack.height = 30; audioOffBlack.x = _W-40; audioOffBlack.y = 45
	audioOffBlack:toFront()
	screenGroup:insert(audioOffBlack)
	
	blackOrWhite = display.newImage('media/BlackOrWhite.png')
	blackOrWhite.width = 30; blackOrWhite.height = 30; blackOrWhite.x = 40; blackOrWhite.y = 45
	blackOrWhite:toFront()
	screenGroup:insert(blackOrWhite)
	
	classicBronzeIcon = display.newImageRect(screenGroup, "media/classicBronzeIcon.png", 38, 38)
	classicBronzeIcon.x = centerX - 108; classicBronzeIcon.y = centerY+22;
	classicBronzeIcon.isVisible = false
	
	classicSilverIcon = display.newImageRect(screenGroup, "media/classicSilverIcon.png", 38, 38)
	classicSilverIcon.x = centerX - 108; classicSilverIcon.y = centerY+22;
	classicSilverIcon.isVisible = false
	
	classicGoldIcon = display.newImageRect(screenGroup, "media/classicGoldIcon.png", 38, 38)
	classicGoldIcon.x = centerX - 108; classicGoldIcon.y = centerY+22;
	classicGoldIcon.isVisible = false
	
	classicPlatinumIcon = display.newImageRect(screenGroup, "media/classicPlatinumIcon.png", 38, 38)
	classicPlatinumIcon.x = centerX - 108; classicPlatinumIcon.y = centerY+22;
	classicPlatinumIcon.isVisible = false
	
	challengeBronzeIcon = display.newImageRect(screenGroup, "media/challengeBronzeIcon.png", 38, 38)
	challengeBronzeIcon.x = centerX - 108; challengeBronzeIcon.y = centerY+92;
	challengeBronzeIcon.isVisible = false
	
	challengeSilverIcon = display.newImageRect(screenGroup, "media/challengeSilverIcon.png", 38, 38)
	challengeSilverIcon.x = centerX - 108; challengeSilverIcon.y = centerY+92;
	challengeSilverIcon.isVisible = false	
	
	challengeGoldIcon = display.newImageRect(screenGroup, "media/challengeGoldIcon.png", 38, 38)
	challengeGoldIcon.x = centerX - 108; challengeGoldIcon.y = centerY+92;
	challengeGoldIcon.isVisible = false
	
	challengePlatinumIcon = display.newImageRect(screenGroup, "media/challengePlatinumIcon.png", 38, 38)
	challengePlatinumIcon.x = centerX - 108; challengePlatinumIcon.y = centerY+92;
	challengePlatinumIcon.isVisible = false
	
	classicNoneIconWhite = display.newImageRect(screenGroup, "media/noneIconWhite.png", 38, 38)
	classicNoneIconWhite.x = centerX - 108; classicNoneIconWhite.y = centerY+22;
	classicNoneIconWhite.isVisible = false
	
	challengeNoneIconWhite = display.newImageRect(screenGroup, "media/noneIconWhite.png", 38, 38)
	challengeNoneIconWhite.x = centerX - 108; challengeNoneIconWhite.y = centerY+92;
	challengeNoneIconWhite.isVisible = false
	
	classicNoneIconBlack = display.newImageRect(screenGroup, "media/noneIconBlack.png", 38, 38)
	classicNoneIconBlack.x = centerX - 108; classicNoneIconBlack.y = centerY+22;
	classicNoneIconBlack.isVisible = false
	
	challengeNoneIconBlack = display.newImageRect(screenGroup, "media/noneIconBlack.png", 38, 38)
	challengeNoneIconBlack.x = centerX - 108; challengeNoneIconBlack.y = centerY+92;
	challengeNoneIconBlack.isVisible = false
	
		
	audioState = preference.getValue("audioState")
	backgroundWhite = preference.getValue("bgWhite")
	
	

	classicMedal = preference.getValue("classicMedalLevel")
	challengeMedal = preference.getValue("challengeMedalLevel")
	
	if classicMedal == "none" or classicMedal == nil then
		classicNoneIconWhite.isVisible = true
	elseif classicMedal == "bronze" then
		classicBronzeIcon.isVisible = true
	elseif classicMedal == "silver" then
		classicSilverIcon.isVisible = true
	elseif classicMedal == "gold" then
		classicGoldIcon.isVisible = true
	elseif classicMedal == "platinum" then
		classicPlatinumIcon.isVisible = true
	end
	
	if challengeMedal == "none" or challengeMedal == nil then
		challengeNoneIconWhite.isVisible = true
	elseif challengeMedal == "bronze" then
		challengeBronzeIcon.isVisible = true
	elseif challengeMedal == "silver" then
		challengeSilverIcon.isVisible = true
	elseif challengeMedal == "gold" then
		challengeGoldIcon.isVisible = true
	elseif challengeMedal == "platinum" then
		challengePlatinumIcon.isVisible = true
	end

	setBackgroundColors()
end


-- Called immediately after scene has moved onscreen:
function scene:show( event )
	
	if event.phase == "did" then
		print( "1: enterScene event" )
		--http.request("https://www.googleapis.com/games/v1management/achievements/reset")
		--ads:setCurrentProvider(admobNetwork)
		--ads.show("banner", { x=0, y=_H - 43, appId = adMobBannerID} )
		--ads.show( "interstitial", { isBackButtonEnabled = true } )
		backgroundSound = audio.loadStream( "media/audio/Theme.mp3" )
		
		audio.play( backgroundSound, {loops=-1, channel=1, onComplete=disposeSound })
		
		if audioState then
			audio.fade({channel=1, time=1000, volume=1.0})
		else
			audio.setVolume(0.0, {channel = 1})
		end
		
		-- reset medals
		--preference.save{classicMedalLevel = "none"}
		--preference.save{challengeMedalLevel = "none"}
		
		
		
		-- Update Lua memory text display
		
			classicButton:addEventListener("touch", gotoClassic)
	challengeButton:addEventListener("touch", gotoChallenge)
	audioOn:addEventListener( "touch", toggleAudio)
	audioOff:addEventListener( "touch", toggleAudio)
	audioOnBlack:addEventListener( "touch", toggleAudio)
	audioOffBlack:addEventListener( "touch", toggleAudio)
	blackOrWhite:addEventListener( "touch", toggleBackground)
	instructionsButton:addEventListener( "touch", gotoInstructions)
	ghsWhite:addEventListener( "touch", showLeaderboards)
	ghsBlack:addEventListener( "touch", showLeaderboards)
	achievementWhite:addEventListener( "touch", showAchievements)
	achievementBlack:addEventListener( "touch", showAchievements)
	Runtime:addEventListener("key", onKeyEvent)
	end

end


-- Called when scene is about to move offscreen:
function scene:hide( event )
	
	if event.phase == "will" then
		print( "1: exitScene event" )
		
		-- remove touch listener for image
		classicButton:removeEventListener("touch", gotoClassic)
		challengeButton:removeEventListener("touch", gotoChallenge)
		Runtime:removeEventListener("key", onKeyEvent)
		blackOrWhite:removeEventListener( "touch", toggleBackground)
		instructionsButton:removeEventListener( "touch", gotoInstructions)
		ghsWhite:removeEventListener( "touch", showLeaderboards)
		ghsBlack:removeEventListener( "touch", showLeaderboards)
		achievementWhite:removeEventListener( "touch", showAchievements)
		achievementBlack:removeEventListener( "touch", showAchievements)
		composer.removeScene( "menuScene" )
	end
	
	-- if event.phase == "did" then
	-- print("removing")
		-- composer.removeScene("menuScene")
	-- end
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroy( event )
	print( "((destroying scene 1's view))" )
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