---------------------------------------------------------------------------------
-- SPLASH SCENE
-- The first screen user see when opening the game
---------------------------------------------------------------------------------

local storyboard = require( "composer" )
local scene = storyboard.newScene()

local ASSET_FOLDER = "assets/"

local phone_width = display.contentWidth
local phone_height = display.contentHeight

local scoreText
local pause_btn
local play_btn

---------------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view

	-- Hide Score & Pause Button
	scoreText = event.params.score_text
	scoreText.isVisible = false
	
	pause_btn = event.params.pause_btn
	pause_btn.isVisible = false
		
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	
	--Define the rectangle
	local bg = display.newRect( sceneGroup, phone_width/2, phone_height/2, phone_width, phone_height+100)
	bg:setFillColor(0,0,0)
	bg.alpha = 0.5
	
	play_btn = display.newImageRect( sceneGroup, ASSET_FOLDER .. "btn-play.png", pause_btn.width, pause_btn.height )
	play_btn.x = pause_btn.x
	play_btn.y = pause_btn.y
	
	local box =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "pause_btn_bg.png", 260, 340 )
	box.x = phone_width/2
	box.y = phone_height/2
	
	local btn_restart =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "btn_restart.png", 200, 85 )
	btn_restart.x = phone_width/2
	btn_restart.y = phone_height/2 + 5
	
	local btn_main_menu =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "btn_main_menu_2.png", 200, 85 )
	btn_main_menu.x = phone_width/2
	btn_main_menu.y = phone_height/2 + 100
	
	local function btnTapRestart(event)
		storyboard.gotoScene( "scene_restart" )
		return true
	end
	btn_restart:addEventListener("tap", btnTapRestart)

	local function btnTapBack(event)
		storyboard.hideOverlay()
		return true
	end
	play_btn:addEventListener("tap", btnTapBack)

	local function btnTapMainMenu(event)
		storyboard.gotoScene( "scene_splash" )
		return true
	end
	btn_main_menu:addEventListener("tap", btnTapMainMenu)
	
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
	
	display.remove(play_btn)
	phone_width = nil
	phone_height = nil
	ASSET_FOLDER = nil
	scoreText.isVisible = true
	pause_btn.isVisible = true
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene