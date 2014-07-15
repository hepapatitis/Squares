----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local playing_field1
local playing_field2
local playing_field3
local ASSET_FOLDER = "assets/"

local phone_width = display.contentWidth
local phone_height = display.contentHeight
local playing_field_height = 275
local playing_field_width = phone_width
local pause_btn_width = 50
local top_menu_width = phone_width - pause_btn_width
local top_menu_height = 50
local color_request_height = 200
local local_timer_height = 25
local local_timer_width = phone_width

local score = 0

---------------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	
	-- START
	display.setStatusBar( display.HiddenStatusBar )
	
	-- Create Top Menu
	local top_menu = display.newImageRect( sceneGroup, ASSET_FOLDER .. "top_menu.png", top_menu_width, top_menu_height )
	top_menu.x = top_menu_width/2
	top_menu.y = 0
	
	-- Create Playing Field
	playing_field1 = display.newImageRect( sceneGroup, ASSET_FOLDER .. "block-blue.png", playing_field_width, playing_field_height )
	playing_field1.x = phone_width/2
	playing_field1.y = (color_request_height)+(top_menu_height/2)+(local_timer_height)+(playing_field_height/2)
end

function scene:show( event )
	local sceneGroup = self.view
	local blockGroup = display.newGroup()
	local phase = event.phase
	local game_timer
	local game_time
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		
		-- START
		score = 0
		local scoreText = display.newText( sceneGroup, score, 20, 0, native.systemFont, 16 )
		scoreText:setFillColor( 255, 255, 255 )
		
		-- Create Timer
		local create_timer = display.newImageRect( sceneGroup, ASSET_FOLDER .. "timer.png", local_timer_width, local_timer_height )
		create_timer.x = phone_width/2
		create_timer.y = (color_request_height)+(top_menu_height/2)+(local_timer_height/2)
		
		-- Timer START
		game_time = 0
		function game_loop()
			refresh_time_look()
			game_time = game_time + 0.25
			if game_time >= 100 then
				game_time = 0
			end
		end
		
		function reset_time()
			game_time = 0
			refresh_time_look()
		end
		
		function refresh_time_look()
			create_timer.width = local_timer_width * game_time / 100
			create_timer.x = create_timer.width / 2
		end

		game_timer = timer.performWithDelay( 1, game_loop, 0 )
		
		-- Pause Function
		local function pause_game( event )
			if event.phase == "began" then
				timer.pause(game_timer)
			end
			return true
		end
		
		-- Create Pause Button
		local pause_btn = display.newImageRect( sceneGroup, ASSET_FOLDER .. "btn-pause.png", pause_btn_width, top_menu_height )
		pause_btn.x = top_menu_width+(pause_btn_width/2)
		pause_btn.y = 0
		
		pause_btn:addEventListener( "touch", pause_game )
	
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
			
			local color_req = display.newImageRect( sceneGroup, image, phone_width, color_request_height )
			color_req.x = phone_width/2
			color_req.y = (color_request_height/2)+(top_menu_height/2)
			color_req.color = color
			
			return color_req
		end
		
		-- Create Color Request
		local color_req = create_question(0, sceneGroup, scoreText)
		
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
			
			local block = display.newImageRect( sceneGroup, image, playing_field_width, playing_field_height )
			block.x = phone_width/2
			block.y = (color_request_height)+(top_menu_height/2)+(local_timer_height)+(playing_field_height/2)
			block.color = color;
			
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
				elseif self.isFocus then
				
					if event.phase == "moved" then
						-- then drag our object
						self.x = event.x - event.xStart + self.markX
						
						if event.y - event.yStart + self.markY > self.markY then
							self.y = event.y - event.yStart + self.markY
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
						
						if self.diffX > (self.width / 2) then
							-- Removed
							self.isVisible = false
							
							local random_color = math.random(0, 3)
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
							
							self:removeSelf()
						else
							self.x = self.markX
						end
						
						if self.diffY > (self.height / 2) then
							-- Removed
							self.isVisible = false
							
							local random_color = math.random(0, 3)
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
							
							if color_req.color == self.color then
								score = score + 1
							else
								score = score - 1
							end
							
							random_color = math.random(0, 3)
							color_req = create_question(random_color, sceneGroup, scoreText)
							reset_time()
							scoreText.text = score
							self:removeSelf()
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
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene