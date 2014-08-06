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
	
	--Define the rectangle
	local bg = display.newRect( sceneGroup, phone_width/2, phone_height/2, phone_width, phone_height+100)
	bg:setFillColor(0,0,0)
	bg.alpha = 0.5
	
	local box =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "pause_block.png", 275, 400 )
	box.x = phone_width/2
	box.y = phone_height/2
	
	local btn_back =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "btn-main-menu.png", 200, 50 )
	btn_back.x = phone_width/2
	btn_back.y = phone_height/2
	
	local function btnTap(event)
		storyboard.hideOverlay("fade", 300)
		return true
	end
	btn_back:addEventListener("tap", btnTap)
	
	sceneGroup:toFront()
end

function scene:show( event )
	local sceneGroup = self.view
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
    local parent = event.parent 
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		
	elseif phase == "did" then
		-- Called when the scene is now off screen
		parent:resumeGame()
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