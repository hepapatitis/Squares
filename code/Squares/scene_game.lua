---------------------------------------------------------------------------------
-- GAME SCENE
-- The game :D
---------------------------------------------------------------------------------

local storyboard = require( "composer" )
local scene = storyboard.newScene()

local ASSET_FOLDER = "assets/"
local ASSET_FOLDER_SOUND = ASSET_FOLDER .. "sounds/"

local phone_width = display.contentWidth
local phone_height = display.contentHeight
local playing_field_height = 250
local playing_field_width = phone_width
local pause_btn_width = 50
local top_menu_width = phone_width - pause_btn_width
local top_menu_height = 50
local color_request_height = 155
local local_timer_height = 25
local local_timer_width = phone_width

local playing_field1
local playing_field2
local playing_field3
local color_req

local blockGroup = display.newGroup()

local game_timer
local game_time
local is_paused = 0
local TIMER_MULTIPLIER = 20
local TIME_LIMIT = 19 -- 19
local TIME_BAR = TIME_LIMIT * TIMER_MULTIPLIER
local TIMER_FPS = 1000 / TIMER_MULTIPLIER

-- Count block cycle
local BLOCK_LIMIT = {
	[0] = 2, -- red
	[1] = 2, -- blue
	[2] = 2, -- green
	[3] = 2, -- yellow
}
local block_counter = {
	[0] = 0, -- red
	[1] = 0, -- blue
	[2] = 0, -- green
	[3] = 0, -- yellow
}
local block_total_count = 0

local score = require( "score" )
local scoreText = score.init({
	fontSize = 18,
	font = native.systemFont,
	x = 75,
	y = top_menu_height/2,
	maxDigits = 7,
	leadingZeros = false,
	filename = "scorefile.txt",
	align = "left",
})

local audio_plus_point = audio.loadSound( ASSET_FOLDER_SOUND .. "score_plus/score_plus.wav" )
local audio_minus_point = audio.loadSound( ASSET_FOLDER_SOUND .. "score_minus/score_minus.wav" )
local audio_swipe = {
    swipe1 = audio.loadSound( ASSET_FOLDER_SOUND .. "swipe_squares/whip_01.wav" ),
    swipe2 = audio.loadSound( ASSET_FOLDER_SOUND .. "swipe_squares/whip_02.wav" ),
    swipe3 = audio.loadSound( ASSET_FOLDER_SOUND .. "swipe_squares/whip_03.wav" ),
    swipe4 = audio.loadSound( ASSET_FOLDER_SOUND .. "swipe_squares/whip_04.wav" ),
    swipe5 = audio.loadSound( ASSET_FOLDER_SOUND .. "swipe_squares/whip_05.wav" ),
    swipe6 = audio.loadSound( ASSET_FOLDER_SOUND .. "swipe_squares/whip_06.wav" )
}


-- Start & Pause Game Function
local pause_btn
local function pause_game()
	local result = timer.pause(game_timer)
	local options =
	{
		params = { score_text = scoreText, pause_btn = pause_btn }
	}
	storyboard.showOverlay( "scene_pause", options )
end

local function resume_game()
	timer.resume(game_timer)
end
---------------------------------------------------------------------------------

-- Game Over Game Functionlocal function pause_game()
local function game_over()
	local result = timer.pause(game_timer)
	scoreText.isVisible = false
	local options =
	{
		params = { last_game_score = score.get() }
	}
	storyboard.showOverlay( "scene_game_over", options )
	
end

-- Clear Block Counter
local function clear_block_counter()
	block_counter = {
		[0] = 0, -- red
		[1] = 0, -- blue
		[2] = 0, -- green
		[3] = 0, -- yellow
	}
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	
	-- START
	
	-- Create Top Menu
	local top_menu = display.newImageRect( sceneGroup, ASSET_FOLDER .. "top_menu.png", top_menu_width, top_menu_height )
	top_menu.x = top_menu_width/2
	top_menu.y = top_menu_height/2
	
	score.reset()
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	blockGroup:toBack()
	if(storyboard.getPrevious() ~= nil) then
		storyboard.purgeScene(storyboard.getSceneName("previous"))
		storyboard.removeScene(storyboard.getSceneName("previous"))
	end
	
	local create_timer
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		
	elseif phase == "did" then
		storyboard.removeScene("scene_splash", true)
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		
		-- START
		
		-- Create Timer
		local create_timer = display.newImageRect( sceneGroup, ASSET_FOLDER .. "timer.png", local_timer_width, local_timer_height )
		create_timer.x = phone_width/2 - 1000
		create_timer.y = (color_request_height)+(top_menu_height)+(local_timer_height/2)
		
		-- Timer START
		game_time = 0
		function game_loop()
			refresh_time_look()
			game_time = game_time + 1
			if game_time > TIME_BAR then
				-- When timer reaches the TIME_BAR, it's GAMEOVER
				game_over()
			end
		end
		
		function reset_time()
			game_time = 0
			refresh_time_look()
		end
		
		function refresh_time_look()
			create_timer.width = local_timer_width - (local_timer_width * game_time / TIME_BAR)
			create_timer.x = create_timer.width / 2
		end
		
		
		-- Pause Function
		local function pause_listener( event )
			if event.numTaps == 1 then
				if is_paused == 0 then
					pause_game()
					is_paused = 1
				else
					resume_game()
					is_paused = 0
				end
			end
			return true
		end
		
		local function start_game()
			game_timer = timer.performWithDelay( TIMER_FPS, game_loop, 0 )
			is_paused = 0
		end
		
		start_game()
		
		-- Create Pause Button
		pause_btn = display.newImageRect( sceneGroup, ASSET_FOLDER .. "btn-pause.png", pause_btn_width, top_menu_height )
		pause_btn.x = top_menu_width+(pause_btn_width/2)
		pause_btn.y = top_menu_height/2
		
		pause_btn:addEventListener( "tap", pause_listener )
	
		-- Create Question
		function create_question(color, sceneGroup, scoreText)
			local image
			
			if color == 0 then
				image = ASSET_FOLDER .. "text-red.png"
			elseif color == 1 then
				image = ASSET_FOLDER .. "text-blue.png"
			elseif color == 2 then
				image = ASSET_FOLDER .. "text-green.png"
			else
				image = ASSET_FOLDER .. "text-yellow.png"
			end
			
			
			local crq = display.newImageRect( sceneGroup, image, phone_width, color_request_height )
			crq.x = phone_width/2
			crq.y = (color_request_height/2)+(top_menu_height)
			crq.color = color
			
			return crq
		end
		
		-- Create Color Request
		color_req = create_question(0, sceneGroup, scoreText)
		
		function play_swipe()
			audio.play(audio_swipe["swipe" .. math.random(1,6)])
		end
		
		-- Create Block Function
		function create_block(color, sceneGroup, scoreText)
			local image
			
			if color == 0 then
				image = ASSET_FOLDER .. "block-red.png"
			elseif color == 1 then
				image = ASSET_FOLDER .. "block-blue.png"
			elseif color == 2 then
				image = ASSET_FOLDER .. "block-green.png"
			else
				image = ASSET_FOLDER .. "block-yellow.png"
			end
			
			block_counter[color] = block_counter[color] + 1
			block_total_count = block_total_count + 1
			
			local block = display.newImageRect( sceneGroup, image, playing_field_width, playing_field_height )
			block.x = phone_width/2
			block.y = (color_request_height)+(top_menu_height)+(local_timer_height)+(playing_field_height/2)
			block.color = color;
			
			-- Function to remove block
			-- Called after transition
			function remove_block( block )
				block.isVisible = false
				
				local random_color = math.random(0, 3)
				local finish_check = 0
				
				while finish_check == 0 do
					if (block_counter[random_color] >= BLOCK_LIMIT[random_color]) then
						finish_check = 0
						random_color = math.random(0, 3)
					else
						finish_check = 1
					end
					
					if block_total_count >= 8 then
						block_total_count = 0
						clear_block_counter()
					end
				end
				
				if playing_field1~=nil then 
					playing_field1 = create_block(random_color, sceneGroup, scoreText)
					playing_field1:toBack()
				elseif playing_field2~=nil then 
					playing_field2 = create_block(random_color, sceneGroup, scoreText)
					playing_field2:toBack()
				elseif playing_field3~=nil then 
					playing_field3 = create_block(random_color, sceneGroup, scoreText)
					playing_field3:toBack()
				end
				
				block:removeSelf()
			end
			
			function block:touch( event )
				if event.phase == "began" then
					-- first we set the focus on the object
					display.getCurrentStage():setFocus( self, event.id )
					self.isFocus = true
			 
					-- then we store the original x and y position
					self.markX = self.x
					self.markY = self.y
					self.diffX = 0
					self.diffY = 0
					self.tmpX = 0
					self.tmpY = 0
					self.tmpDiffX = 0
					self.tmpDiffY = 0
				elseif self.isFocus then

					if event.phase == "moved" then
						-- then drag our object
						
						-- do a bit of test
						self.tmpX = event.x - event.xStart + self.markX
						self.tmpY = event.y - event.yStart + self.markY
						if self.tmpX > self.markX then
							self.tmpDiffX = self.tmpX - self.markX
						elseif self.tmpX < self.markX then
							self.tmpDiffX = self.markX - self.tmpX
						end
						
						if self.tmpY > self.markY then
							self.tmpDiffY = self.tmpY - self.markY
						elseif self.tmpY < self.markY then
							self.tmpDiffY = self.markY - self.tmpY
						end
						
						-- Now we know whether we can move horizontally or vertically
						if self.tmpDiffX > self.tmpDiffY then
							self.x = event.x - event.xStart + self.markX
							self.y = self.markY
						else
							if event.y - event.yStart + self.markY > self.markY then
								self.y = event.y - event.yStart + self.markY
								self.x = self.markX
							end
						end
					elseif event.phase == "ended" or event.phase == "cancelled" then
						-- we end the movement by removing the focus from the object
						display.getCurrentStage():setFocus( self, nil )
						self.isFocus = false
						
						if self.x > self.markX then
							self.diffX = self.x - self.markX
						elseif self.x < self.markX then
							self.diffX = self.markX - self.x
						end
						
						if self.y > self.markY then
							self.diffY = self.y - self.markY
						elseif self.y < self.markY then
							self.diffY = self.markY - self.y
						end
						
						-- Create Remove Block Listener
						local listener_remove_block = function( obj )
							remove_block(obj)
						end
						
						-- Remove by Horizontal
						if self.diffX > (self.width / 10) then
							play_swipe()
							-- Removed
							if self.x < self.markX then
								transition.to( self, { time=100, transition=easing.outInCirc, x=(0 - (phone_width/2)), onComplete=listener_remove_block })
							else
								transition.to( self, { time=100, transition=easing.outInCirc, x=(phone_width * 1.5), onComplete=listener_remove_block })
							end
						else
							self.x = self.markX
						end
						
						-- Remove by Vertical
						if self.diffY > (self.height / 10) then
							-- Removed
							transition.to( self, { time=100, transition=easing.linear, y=(phone_height + (playing_field_height * 0.5)), onComplete=listener_remove_block })
							
							if color_req.color == self.color then
								score.add(1)
								audio.play(audio_plus_point)
							else
								score.minus(1)
								audio.play(audio_minus_point)
							end
							
							random_color = math.random(0, 3)
							if (color_req ~= nil) then
								color_req:removeSelf()
							end
							clear_block_counter()
							color_req = create_question(random_color, sceneGroup, scoreText)
						else
							self.y = self.markY
						end
					end
				end
			 
				-- return true so Corona knows that the touch event was handled propertly
				return true
			end
			block:addEventListener( "touch", block )
			
			return block;
		end
		
		-- Create Playing Field (a.k.a Block)
		playing_field1 = create_block(2, blockGroup, scoreText)
		playing_field2 = create_block(3, blockGroup, scoreText)
		
	end	
end

-- Custom function for resuming the game (from pause state)
function scene:resumeGame()
    timer.resume(game_timer)
	is_paused = 0
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
	
	display.remove(scoreText)
	display.remove(playing_field1)
	display.remove(playing_field2)
	display.remove(playing_field3)
	display.remove(color_req)
	display.remove(pause_btn)
	display.remove(blockGroup)
	color_req = nil
	timer.cancel(game_timer)
	
    audio.stop(1)
    audio.dispose()
end

function scene:overlayBegan( event )
	local sceneGroup = self.view
	
	local bg =  display.newImageRect( sceneGroup, ASSET_FOLDER .. "splash_bg.png", phone_width, phone_height )
	bg.x = phone_width/2
	bg.y = phone_height/2
	
	print( "The overlay scene is showing: " .. event.sceneName )
    print( "We get custom params too! " .. event.params.sample_var )
end

function scene:overlayEnded( event )
	print( "The following overlay scene was removed: " .. event.sceneName )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

scene:addEventListener( "overlayBegan", scene )
scene:addEventListener( "overlayEnded", scene )

---------------------------------------------------------------------------------

return scene