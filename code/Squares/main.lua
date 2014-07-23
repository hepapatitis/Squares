-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require "composer"

-- load scenetemplate.lua
composer.gotoScene( "scene_splash" )

-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc.):
display.setStatusBar( display.HiddenStatusBar )