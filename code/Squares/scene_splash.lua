---------------------------------------------------------------------------------
-- SPLASH SCENE
-- The first screen user see when opening the game
---------------------------------------------------------------------------------

local storyboard = require( "composer" )
local scene = storyboard.newScene()

local ASSET_FOLDER = "assets/"

local phone_width = display.contentWidth
local phone_height = display.contentHeight

---------------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	
	local bg =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "splash_bg.png", phone_width, phone_height )
	bg.x = phone_width/2
	bg.y = phone_height/2
	
	local btn_width = 780 / 4
	local btn_height = 300 / 4
	
	local play_btn =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "splash_play_btn.png", btn_width, btn_height )
	play_btn.x = phone_width/2
	play_btn.y = phone_height/2
	
	local credits_btn =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "splash_credits_btn.png", btn_width, btn_height )
	credits_btn.x = phone_width/2
	credits_btn.y = phone_height/2 + 100
		
	local function onTap( event )
		storyboard.gotoScene( "scene_game" )
		return true
	end
	play_btn:addEventListener( "tap", onTap )
	
end

function scene:show( event )
	local sceneGroup = self.view
	
	if(storyboard.getPrevious() ~= nil) then
		storyboard.purgeScene(storyboard.getPrevious())
		storyboard.removeScene(storyboard.getPrevious())
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
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene