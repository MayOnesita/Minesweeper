local composer = require( "composer" )
 
local scene = composer.newScene()
 
CW = display.contentWidth
CH = display.contentHeight
resources_folder = "resources/"

local bg, icon

function goToMenu()
    composer.gotoScene( "menu", "fade", 800 )
	
	return true
end

function scene:create( event )
 
    local sceneGroup = self.view
    
    bg = display.newRect( 0, 0, CW, CH )
    bg.anchorX = 0; bg.anchorY = 0
    bg:setFillColor( 0 )

    icon = display.newImageRect(resources_folder.. "sc_logo.png", 250, 250)
    icon.x = CW/2; icon.y = CH/2

    sceneGroup:insert(bg)
    sceneGroup:insert(icon)

end
 
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
 
    elseif ( phase == "did" ) then
        transition.to(icon, {rotation=0, time=800, onComplete=goToMenu})
    end
end
 
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
 
    elseif ( phase == "did" ) then
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene