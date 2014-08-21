---------------------------------------------------------------------------------
-- RESTART SCENE
-- The screen that almost show nothing to user, it's used to do restart
---------------------------------------------------------------------------------

local storyboard = require( "composer" )
local scene = storyboard.newScene()

---------------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
end

function scene:show( event )
	local sceneGroup = self.view
	
	if(storyboard.getPrevious() ~= nil) then
		storyboard.removeScene(storyboard.getSceneName("previous"))
	end
	
	storyboard.gotoScene( "scene_game" )
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		
		phone_width = nil
		phone_height = nil
		ASSET_FOLDER = nil
		ASSET_FOLDER_SOUND = nil
		
		display.remove(scoreText)
		scoreText = nil
		
		audio.stop(1)
		audio.dispose()
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
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene