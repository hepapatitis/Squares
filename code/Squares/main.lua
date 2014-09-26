-----------------------------------------------------------------------------------------
--
-- SQUARES
-- By		: Aaron Samuel
--			  Christopher Adrian
--			  Stephanus Yanaputra
-- Version	: 2.0
--
-----------------------------------------------------------------------------------------

-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc.):
display.setStatusBar( display.HiddenStatusBar )

-- ASSETS FOLDERS
local ASSET_FOLDER = "assets/"
local ASSET_FOLDER_SOUND = ASSET_FOLDER .. "sounds/"

-- GLOBAL VARIABLES
local sceneGroup = display.newGroup()
local phone_width = display.contentWidth
local phone_height = display.contentHeight
local score_file = "scorefile.txt"
local swipe_sensitivity = 20

-- AUDIO & SOUNDS
local audio_menu_click = audio.loadSound( ASSET_FOLDER_SOUND .. "select_menu_click/menu_click.wav" )
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

-- Score Functions
local high_score = 0
local last_game_score = 0

function create_high_score_file()
	local path = system.pathForFile( score_file, system.DocumentsDirectory)
	local contents = "0"
	local file = io.open( path, "w" )
	file:write( contents )
	io.close( file )
	print("New Score File created: ", score_file, ".")
	return true
end

function save_high_score()
	local path = system.pathForFile( score_file, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = tostring( high_score )
        file:write( contents )
        io.close( file )
		print("Saved! Score is: " .. high_score)
        return true
    else
		local contents = tostring( high_score )
		file = io.open( path, "w" )
		file:write( contents )
		io.close( file )
    	print("Error: could not read ", score_file, ".")
        return false
    end
end

function load_high_score()
    local path = system.pathForFile( score_file, system.DocumentsDirectory)
    local contents = ""
    local file = io.open( path, "r" )
    if file then
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        local score = tonumber(contents);
        io.close( file )
		print("Load! Score is: " .. score)
        return score
	else
		create_high_score_file()
        return 0
    end
	
    print("Could not read scores from ", score_file, ".")
    return 0
end

-- SPLASH SCREEN
-----------------------------------------------------------------------------------------
local splash_bg
local splash_highscore_container
local splash_play_btn
local splash_credits_btn
local splash_scene_group
local splash_high_score_text

function create_splash_screen() 
	splash_scene_group = display.newGroup()
	
	splash_bg =  display.newImageRect( splash_scene_group, ASSET_FOLDER .. "splash_bg.png", phone_width, phone_height )
	splash_bg.x = phone_width/2
	splash_bg.y = phone_height/2
	
	local btn_width = 780 / 4
	local btn_height = 300 / 4

	splash_play_btn =  display.newImageRect( splash_scene_group, ASSET_FOLDER .. "splash_play_btn.png", btn_width, btn_height )
	splash_play_btn.x = phone_width/2
	splash_play_btn.y = phone_height/2 + 70
	splash_play_btn:toFront()

	splash_credits_btn =  display.newImageRect( splash_scene_group, ASSET_FOLDER .. "splash_credits_btn.png", btn_width, btn_height )
	splash_credits_btn.x = phone_width/2
	splash_credits_btn.y = phone_height/2 + 170
	splash_credits_btn:toFront()
		
	local function onTap_scene_game( event )
		create_game_screen()
		remove_splash_screen()
		audio.play(audio_menu_click)
		return true
	end
	splash_play_btn:addEventListener( "tap", onTap_scene_game )

	local function onTap_scene_credits( event )
		audio.play(audio_menu_click)
		create_credits_screen()
		return true
	end
	splash_credits_btn:addEventListener( "tap", onTap_scene_credits )
	
	splash_highscore_container =  display.newImageRect( splash_scene_group, ASSET_FOLDER .. "hiscore_banner.png", phone_width, 55 )
	splash_highscore_container.x = phone_width/2
	splash_highscore_container.y = phone_height/2 - 20
	
	high_score = load_high_score()
	local splash_highscore_text_options = 
	{  
		text = high_score,
		parent = splash_scene_group,
		x = phone_width/2 + 100,
		y = phone_height/2 - 20,
		width = phone_width,
		font = native.systemFontBold,   
		fontSize = 25,
		align = "center"  --new alignment parameter
	}
	splash_high_score_text = display.newText(splash_highscore_text_options)
end

function remove_splash_screen()
	display.remove(splash_bg);
	display.remove(splash_highscore_container);
	display.remove(splash_play_btn);
	display.remove(splash_credits_btn);
	display.remove(splash_high_score_text);
	display.remove(splash_scene_group);
end

-- GAME SCREEN
-----------------------------------------------------------------------------------------
local game_scene_group
local game_scene_block_group

local game_timer
local game_timer_bar
local game_time
local game_is_paused = 0
local TIMER_MULTIPLIER = 100
local TIME_LIMIT = 10 -- 19
local TIME_BAR = (TIME_LIMIT-1) * TIMER_MULTIPLIER
local TIMER_RIGHT_BONUS = 0.5 * TIMER_MULTIPLIER
local TIMER_FPS = 1000 / TIMER_MULTIPLIER
local BLOCK_LIMIT = {
	[0] = 2, -- red
	[1] = 2, -- blue
	[2] = 2, -- green
	[3] = 2, -- yellow
}

local game_current_score
local game_top_menu
local game_btn_pause
local game_playing_field1
local game_playing_field2
local game_playing_field3
local game_color_req

-- Start & Pause & Resume Game
local function start_game()
	game_timer = timer.performWithDelay( TIMER_FPS, game_loop, 0 )
	game_loop()
	game_is_paused = 0
end

local function pause_game()
	local result = timer.pause(game_timer)
	create_pause_screen()
	game_is_paused = 1
end

local function resume_game()
	timer.resume(game_timer)
	game_is_paused = 0
end

-- Game Over Game Function
local function game_over()
	timer.cancel(game_timer)
	create_gameover_screen()
end

function create_game_screen()
	-- Helpful Variables for design purposes
	local playing_field_height = 250
	local playing_field_width = phone_width
	local pause_btn_width = 50
	local top_menu_width = phone_width - pause_btn_width
	local top_menu_height = 50
	local color_request_height = 155
	local local_timer_height = 25
	local local_timer_width = phone_width

	game_scene_group = display.newGroup()
	game_scene_block_group = display.newGroup()
	
	-- Init Block Counter
	local block_counter = {
		[0] = 0, -- red
		[1] = 0, -- blue
		[2] = 0, -- green
		[3] = 0, -- yellow
	}
	local block_total_count = 0
	
	-- Clear Block Counter
	local function clear_block_counter()
		block_counter = {
			[0] = 0, -- red
			[1] = 0, -- blue
			[2] = 0, -- green
			[3] = 0, -- yellow
		}
	end
	
	-- Create Top Menu (Display)
	game_top_menu = display.newImageRect( game_scene_group, ASSET_FOLDER .. "top_menu.png", top_menu_width, top_menu_height )
	game_top_menu.x = top_menu_width/2
	game_top_menu.y = top_menu_height/2
	
	-- Create Pause Button
	game_btn_pause = display.newImageRect( game_scene_group, ASSET_FOLDER .. "btn-pause.png", pause_btn_width, top_menu_height )
	game_btn_pause.x = top_menu_width+(pause_btn_width/2)
	game_btn_pause.y = top_menu_height/2
	
	-- Pause Function
	local function pause_listener( event )
		if event.numTaps == 1 then
			pause_game()
		end
		return true
	end
	game_btn_pause:addEventListener( "tap", pause_listener )
	
	-- Init Score
	last_game_score = 0
	local game_score_text_options = 
	{  
		text = last_game_score,
		parent = game_scene_group,
		x = 75,
		y = top_menu_height/2,
		font = native.systemFontBold,   
		fontSize = 18,
		width = 100,
	}
	game_current_score = display.newText(game_score_text_options)
	
	local function add_score(amount)
		last_game_score = last_game_score + amount
		game_current_score.text = tostring(last_game_score)
		print(last_game_score)
	end
	
	local function minus_score(amount)
		last_game_score = last_game_score - amount
		game_current_score.text = tostring(last_game_score)
		print(last_game_score)
	end
	game_current_score:toFront()
	
	-- TIMER
	game_time = 0
	game_timer_bar = display.newImageRect( game_scene_group, ASSET_FOLDER .. "timer.png", local_timer_width, local_timer_height )
	game_timer_bar.x = phone_width/2 - 1000
	game_timer_bar.y = (color_request_height)+(top_menu_height)+(local_timer_height/2)
	
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
		game_timer_bar.width = local_timer_width - (local_timer_width * game_time / TIME_BAR)
		game_timer_bar.x = game_timer_bar.width / 2
	end
	
	-- Create Question
	function create_question(color, sceneGroup)
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
	
	-- Random Sound during Swipe
	function play_swipe()
		audio.play(audio_swipe["swipe" .. math.random(1,6)])
	end
	
	-- Create Block Function
	function create_block(color, sceneGroup, disableVertical, disableHorizontal, startGame)
		local image
		
		if color == -2 then
			image = ASSET_FOLDER .. "block-tutorial-2-red.png"
			color = 0
		elseif color == -1 then
			image = ASSET_FOLDER .. "block-tutorial-1-blue.png"
			color = 1
		elseif color == 0 then
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
			
			if game_playing_field1~=nil then 
				game_playing_field1 = create_block(random_color, sceneGroup)
				game_playing_field1:toBack()
			elseif game_playing_field2~=nil then 
				game_playing_field2 = create_block(random_color, sceneGroup)
				game_playing_field2:toBack()
			elseif game_playing_field3~=nil then 
				game_playing_field3 = create_block(random_color, sceneGroup)
				game_playing_field3:toBack()
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
					if disableVertical ~= nil and disableVertical == 1 then
						-- Do Nothing
					else
						self.tmpX = event.x - event.xStart + self.markX
						if self.tmpX > self.markX then
							self.tmpDiffX = self.tmpX - self.markX
						elseif self.tmpX < self.markX then
							self.tmpDiffX = self.markX - self.tmpX
						end
					end
					
					if disableHorizontal ~= nil and disableHorizontal == 1 then
						-- Do Nothing
					else
						self.tmpY = event.y - event.yStart + self.markY
						if self.tmpY > self.markY then
							self.tmpDiffY = self.tmpY - self.markY
						elseif self.tmpY < self.markY then
							self.tmpDiffY = self.markY - self.tmpY
						end
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
					if self.diffX > (self.width / swipe_sensitivity) then
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
					if self.diffY > (self.height / swipe_sensitivity) then
						-- Removed
						transition.to( self, { time=100, transition=easing.linear, y=(phone_height + (playing_field_height * 0.5)), onComplete=listener_remove_block })
						
						if game_color_req.color == self.color then
							add_score(1)
							game_time = game_time - TIMER_RIGHT_BONUS
							if game_time > TIME_BAR then
								game_time = TIME_BAR
							end
							
							audio.play(audio_plus_point)
							
							if startGame ~= nil and startGame == 1 then
								start_game()
							end
						else
							minus_score(1)
							audio.play(audio_minus_point)
						end
						
						random_color = math.random(0, 3)
						if (game_color_req ~= nil) then
							game_color_req:removeSelf()
						end
						clear_block_counter()
						game_color_req = create_question(random_color, sceneGroup)
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
	
	function run_tutorial()
		refresh_time_look()
		game_color_req = create_question(0, game_scene_group, scoreText)
		game_playing_field1 = create_block(-2, game_scene_block_group, 1, 0, 1)
		game_playing_field2 = create_block(-1, game_scene_block_group, 0, 1)
	end
	
	-- Create Tutorials
	run_tutorial()
	
	-- Let's Start the game
	--game_color_req = create_question(0, game_scene_group, scoreText)
	--game_playing_field1 = create_block(2, game_scene_block_group, scoreText)
	--game_playing_field2 = create_block(3, game_scene_block_group, scoreText)
	--start_game()
end

function remove_game_screen()
	display.remove(game_btn_pause);
	display.remove(game_top_menu);
	display.remove(game_timer_bar);
	display.remove(game_color_req);
	display.remove(game_playing_field1);
	display.remove(game_playing_field2);
	display.remove(game_playing_field3);
	display.remove(game_current_score);
	display.remove(game_scene_group);
	display.remove(game_scene_block_group);
	
end

-- CREDITS SCREEN
-----------------------------------------------------------------------------------------
local credits
local credits_scene_group
function create_credits_screen()
	splash_scene_group = display.newGroup()
	
	credits = display.newImageRect( splash_scene_group, ASSET_FOLDER .. "credits_scene.png", phone_width, phone_height )
	credits.x = phone_width/2
	credits.y = phone_height/2
	
	local function onTap_scene_splash( event )
		remove_credits_screen()
		audio.play(audio_menu_click)
		return true
	end
	credits:addEventListener( "tap", onTap_scene_splash )
end

function remove_credits_screen()
	display.remove(credits);
	display.remove(credits_scene_group);
end

-- PAUSE SCREEN
-----------------------------------------------------------------------------------------
local pause_overlay
local pause_btn_play
local pause_btn_resume
local pause_btn_main_menu
local pause_box
local pause_scene_group
function create_pause_screen()
	pause_scene_group = display.newGroup()
	
	pause_overlay = display.newRect( pause_scene_group, phone_width/2, phone_height/2, phone_width, phone_height+100)
	pause_overlay:setFillColor(0,0,0)
	pause_overlay.alpha = 0.5
	pause_overlay:addEventListener("touch", function() return true end)
	pause_overlay:addEventListener("tap", function() return true end)
	
	pause_btn_play = display.newImageRect( pause_scene_group, ASSET_FOLDER .. "btn-play.png", 50, 50 )
	pause_btn_play.x = phone_width - 25
	pause_btn_play.y = 25
	
	pause_box =  display.newImageRect( pause_scene_group, ASSET_FOLDER .. "pause_btn_bg.png", 260, 340 )
	pause_box.x = phone_width/2
	pause_box.y = phone_height/2
		
	pause_btn_resume =  display.newImageRect( pause_scene_group, ASSET_FOLDER .. "btn_resume.png", 200, 85 )
	pause_btn_resume.x = phone_width/2
	pause_btn_resume.y = phone_height/2 + 5
	
	pause_btn_main_menu =  display.newImageRect( pause_scene_group, ASSET_FOLDER .. "btn_main_menu_2.png", 200, 85 )
	pause_btn_main_menu.x = phone_width/2
	pause_btn_main_menu.y = phone_height/2 + 100
	
	
	local function btnTapBack(event)
		remove_pause_screen()
		resume_game()
		return true
	end
	pause_btn_play:addEventListener("tap", btnTapBack)
	pause_btn_resume:addEventListener("tap", btnTapBack)

	local function btnTapMainMenu(event)
		remove_pause_screen()
		remove_game_screen()
		create_splash_screen()
		return true
	end
	pause_btn_main_menu:addEventListener("tap", btnTapMainMenu)
	
end

function remove_pause_screen()
	display.remove(pause_overlay);
	display.remove(pause_btn_play);
	display.remove(pause_btn_resume);
	display.remove(pause_btn_main_menu);
	display.remove(pause_box);
end


-- GAME OVER SCREEN
-----------------------------------------------------------------------------------------
local gameover_overlay
local gameover_btn_main_menu
local gameover_box
local gameover_highscore_text
local gameover_lastscore_text
local gameover_scene_group
function create_gameover_screen()
	local btn_main_menu_width = 200
	local btn_main_menu_height = 50
	
	gameover_scene_group = display.newGroup()

	gameover_overlay = display.newRect( gameover_scene_group, phone_width/2, phone_height/2, phone_width, phone_height+100)
	gameover_overlay:setFillColor(0,0,0)
	gameover_overlay.alpha = 0.5
	gameover_overlay:addEventListener("touch", function() return true end)
	gameover_overlay:addEventListener("tap", function() return true end)
	
	gameover_box =  display.newImageRect( gameover_scene_group, ASSET_FOLDER .. "game_over_scene.png", 260, 340 )
	gameover_box.x = phone_width/2
	gameover_box.y = phone_height/2
	
	gameover_btn_main_menu =  display.newImageRect( gameover_scene_group, ASSET_FOLDER .. "btn-main-menu.png", btn_main_menu_width, btn_main_menu_height )
	gameover_btn_main_menu.x = phone_width/2
	gameover_btn_main_menu.y = phone_height/2 + 118
	
	local function btnTapMainMenu(event)
		create_splash_screen()
		remove_gameover_screen()
		return true
	end
	gameover_btn_main_menu:addEventListener("tap", btnTapMainMenu)
	
	if high_score < last_game_score then
		high_score = last_game_score
		save_high_score()
	end
	
	local gameover_highscore_text_options = 
	{  
		text = high_score,
		parent = gameover_scene_group,
		x = display.contentCenterX,
		y = phone_height/2 + 68,
		width = btn_main_menu_width,     --required for multi-line and alignment
		font = native.systemFontBold,   
		fontSize = 30,
		align = "right"  --new alignment parameter
	}
	gameover_highscore_text = display.newText( gameover_highscore_text_options )
	
	local gameover_lastscore_text_options = 
	{  
		text = last_game_score,
		parent = gameover_scene_group,
		x = display.contentCenterX,
		y = phone_height/2 + 21,
		width = btn_main_menu_width,     --required for multi-line and alignment
		font = native.systemFontBold,   
		fontSize = 50,
		align = "right"  --new alignment parameter
	}
	gameover_lastscore_text = display.newText( gameover_lastscore_text_options )
end

function remove_gameover_screen()
	display.remove(gameover_overlay);
	display.remove(gameover_btn_main_menu);
	display.remove(gameover_box);
	display.remove(gameover_highscore_text);
	display.remove(gameover_lastscore_text);
	
	remove_game_screen()
end


-- Let's Start the game
create_splash_screen() 