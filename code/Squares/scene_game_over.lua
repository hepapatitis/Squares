---------------------------------------------------------------------------------
-- GAME OVER SCENE
-- The first screen user see when the game is over
---------------------------------------------------------------------------------

local storyboard = require( "composer" )
local scene = storyboard.newScene()

local ASSET_FOLDER = "assets/"
local ASSET_FOLDER_SOUND = ASSET_FOLDER .. "sounds/"

local phone_width = display.contentWidth
local phone_height = display.contentHeight

local btn_main_menu_width = 200
local btn_main_menu_height = 50

local audio_menu_click = audio.loadSound( ASSET_FOLDER_SOUND .. "select_menu_click/menu_click.wav" )

local btn_main_menu

local score = require( "score" )
local scoreText

local last_game_score = 0
local last_game_score_text

---------------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view
	
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	
	--Define the rectangle
	local overlay_bg = display.newRect( sceneGroup, phone_width/2, phone_height/2, phone_width, phone_height+100)
	overlay_bg:setFillColor(0,0,0)
	overlay_bg.alpha = 0.5
	overlay_bg:addEventListener("touch", function() return true end)
	overlay_bg:addEventListener("tap", function() return true end)
	
	local bg =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "game_over_scene.png", 260, 340 )
	bg.x = phone_width/2
	bg.y = phone_height/2
	
	scoreText = score.init({
		fontSize = 30,
		font = native.systemFont,
		x = display.contentCenterX,
		y = phone_height/2 + 68,
		maxDigits = 7,
		leadingZeros = false,
		filename = "scorefile.txt",
		align = "right",
		width = btn_main_menu_width,
	})
	
	local highscore = score.load()
	score.set(highscore)
	
	last_game_score = event.params.last_game_score
	if tonumber(highscore) < tonumber(last_game_score) then
		score.set(tonumber(last_game_score))
		score.save()
	end
	
	local text_options = 
	{  
		text = "",
		parent = sceneGroup,
		x = display.contentCenterX,
		y = phone_height/2 + 21,
		width = btn_main_menu_width,     --required for multi-line and alignment
		font = native.systemFontBold,   
		fontSize = 50,
		align = "right"  --new alignment parameter
	}
	
	last_game_score_text = display.newText( text_options )
	last_game_score_text.text = last_game_score
	
	btn_main_menu =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "btn-main-menu.png", btn_main_menu_width, btn_main_menu_height )
	btn_main_menu.x = phone_width/2
	btn_main_menu.y = phone_height/2 + 118
	
	local function btnTapMainMenu(event)
		local parent = event.parent 
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
	
	display.remove(scoreText)
	display.remove(btn_main_menu)
	btn_main_menu = nil
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