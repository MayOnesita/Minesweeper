-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local resources_folder = "resources/"

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local startBtn

-- 'onRelease' event listener for startBtn
local function onStartBtnRelease()
	
	-- go to minesweeper.lua scene
	composer.gotoScene( "minesweeper", "slideUp", 500 )
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- display a background image
	local background = display.newImageRect(resources_folder.."menu_bg.png", display.actualContentHeight, display.actualContentHeight)
	background.anchorX = 0.5
	background.anchorY = 0.5
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	
	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newImageRect( resources_folder.."game_title.png", 264, 42 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 100
	
	-- create a widget button (which will loads minesweeper.lua on release)
	startBtn = widget.newButton{
		label = "Start",
		labelColor = { default={ 1.0 }, over={ 0.5 } },
		defaultFile = resources_folder.."button.png",
		overFile = resources_folder.."button-over.png",
		width = 154, height = 40,
		onRelease = onStartBtnRelease
	}
	startBtn.x = display.contentCenterX
	startBtn.y = display.contentHeight - 125
		sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( startBtn )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	if event.phase == "will" then
	elseif phase == "did" then
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	if startBtn then
		startBtn:removeSelf()	-- widgets must be manually removed
		startBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene