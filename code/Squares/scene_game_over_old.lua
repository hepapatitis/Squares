---------------------------------------------------------------------------------
-- GAME OVER SCENE
-- The screen user see when the game is over
---------------------------------------------------------------------------------

local storyboard = require( "composer" )
storyboard.removeAll();
local scene = storyboard.newScene()

local ASSET_FOLDER = "assets/"
local ASSET_FOLDER_SOUND = ASSET_FOLDER .. "sounds/"

local phone_width = display.contentWidth
local phone_height = display.contentHeight

local btn_main_menu_width = 240
local btn_main_menu_height = 60

local audio_menu_click = audio.loadSound( ASSET_FOLDER_SOUND .. "select_menu_click/menu_click.wav" )

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
	
	local bg =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "game_over_scene.png", phone_width, phone_height )
	bg.x = phone_width/2
	bg.y = phone_height/2
	
	scoreText = score.init({
		fontSize = 40,
		font = native.systemFont,
		x = display.contentCenterX,
		y = phone_height/2 + 94,
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
		y = phone_height/2 + 30,
		width = btn_main_menu_width,     --required for multi-line and alignment
		font = native.systemFontBold,   
		fontSize = 60,
		align = "right"  --new alignment parameter
	}
	
	last_game_score_text = display.newText( text_options )
	last_game_score_text.text = last_game_score
	
	local btn_main_menu =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "btn-main-menu.png", btn_main_menu_width, btn_main_menu_height )
	btn_main_menu.x = phone_width/2
	btn_main_menu.y = phone_height - btn_main_menu_height - 15
	
	local function btnTapMainMenu(event)
		local parent = event.parent 
		storyboard.gotoScene( "scene_splash" )
		return true
	end
	btn_main_menu:addEventListener("tap", btnTapMainMenu)
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