---------------------------------------------------------------------------------
-- RESTART SCENE
-- The screen that almost show nothing to user, it's used to do restart
---------------------------------------------------------------------------------

local storyboard = require( "composer" )
storyboard.purgeScene("scene_game");
storyboard.removeAll();
local scene = storyboard.newScene()

local ASSET_FOLDER = "assets/"
local ASSET_FOLDER_SOUND = ASSET_FOLDER .. "sounds/"

local phone_width = display.contentWidth
local phone_height = display.contentHeight

local audio_menu_click = audio.loadSound( ASSET_FOLDER_SOUND .. "select_menu_click/menu_click.wav" )

---------------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	
	local btn_width = 780 / 4
	local btn_height = 300 / 4
	
	local play_btn =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "splash_play_btn.png", btn_width, btn_height )
	play_btn.x = phone_width/2
	play_btn.y = phone_height/2 + 45
	
	local function onTap_scene_game( event )
		storyboard.gotoScene( "scene_game" )
		audio.play(audio_menu_click)
		return true
	end
	play_btn:addEventListener( "tap", onTap_scene_game )
	
end

function scene:show( event )
	local sceneGroup = self.view
	
	if(storyboard.getPrevious() ~= nil) then
		storyboard.purgeScene(storyboard.getSceneName("previous"))
		storyboard.removeScene(storyboard.getSceneName("previous"))
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		
	elseif phase == "did" then
		-- Called when the scene is now off screen

	end	
end


function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	phone_width = nil
	phone_height = nil
	ASSET_FOLDER = nil
	ASSET_FOLDER_SOUND = nil
	
	scoreText = nil
	score = nil
	
    audio.stop(1)
    audio.dispose()
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene