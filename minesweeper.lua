-----------------------------------------------------------------------------------------
-- minesweeper.lua
-----------------------------------------------------------------------------------------
local composer = require( "composer" )
local scene = composer.newScene()
local resources_folder = "resources/"
local sup_bar_color = {0.3647,0.2509,0.2156,0.7}
local widget = require( "widget" )
-----------------------------------------------------------------------------------------

------------------------------
-- VARIABLES 
------------------------------

-- Main variables
local grid = {}
local gridRows = 10 
local gridColumns = 10
local cellSize = 30 
local nBombs = 15

-- Screen Variables
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local supbarHeight = screenH/4 
local gridWidth = cellSize * gridColumns 
local xOffset = halfW/6.5 -- horizontal offset to center the grid

-- Sound
local sound = audio.loadStream(resources_folder.."clock.mp3")
local explosionSound = audio.loadSound(resources_folder.."explote.mp3")
local winSound = audio.loadSound(resources_folder.."win.mp3")

------------------------------
-- BACK-END  
------------------------------

-- Function to create the game grid (matrix representation)
local function createGameGrid()
    local gameGrid = {} 
    for i = 1, gridRows do
        gameGrid[i] = {} 
        for j = 1, gridColumns do
            gameGrid[i][j] = 0 
        end
    end
    return gameGrid
end

-- Function to set random bombs in the grid
local function setMines(gameGrid, nBombs)
	local bombs = 0
	while bombs < nBombs do
		local i = math.random(gridRows)
		local j = math.random(gridColumns)
		gameGrid[i][j] = -1
		bombs = bombs + 1
	end
end

-- Function that returns 1 if there is a mine in grid[i][j], 0 otherwise (useful for the addition of numbers in neighbors cells)
local function isMine(gameGrid, i, j)
	if i >= 1 and i <= gridRows and j >= 1 and j <= gridColumns then
		if gameGrid[i][j] == -1 then
			return 1
		end
	end
	return 0
end

-- Function to fill the grid with the number of bombs around each cell
local function fillGrid(gameGrid)
    for i = 1, gridRows do
        for j = 1, gridColumns do
			if gameGrid[i][j] == 0 then
				local count = 0
				count = count + isMine(gameGrid, i - 1, j - 1)
				count = count + isMine(gameGrid, i - 1, j)
				count = count + isMine(gameGrid, i - 1, j + 1)
				count = count + isMine(gameGrid, i, j - 1)
				count = count + isMine(gameGrid, i, j + 1)
				count = count + isMine(gameGrid, i + 1, j - 1)
				count = count + isMine(gameGrid, i + 1, j)
				count = count + isMine(gameGrid, i + 1, j + 1)
				gameGrid[i][j] = count
			end
        end
    end
end

------------------------------
-- Initialize the grid
------------------------------

local gameGrid = createGameGrid()
setMines(gameGrid, nBombs)
fillGrid(gameGrid)

------------------------------
-- MORE BACK-END  
------------------------------

local function restartGame(sceneGroup)
    composer.removeScene("minesweeper")
    composer.gotoScene("minesweeper")
    audio.stop()
end

local function showPopUp(message)
    audio.stop()
    local popup = display.newGroup()
    local popupBackground = display.newImageRect( resources_folder.."popup_bg.png", display.actualContentWidth * 0.8, display.actualContentHeight * 0.4 ) 
    popupBackground.x = display.contentCenterX
    popupBackground.y = display.contentCenterY
    popup:insert(popupBackground)
    
    local message_on_pu = display.newText({
        text = message,
        x = display.contentCenterX,
        y = display.contentCenterY - 40,
        width = popupBackground.width * 0.7,
        font = native.systemFont,
        fontSize = 20
    })
    popup:insert(message_on_pu)
    local retry_btn = widget.newButton({
        label = "Play again",
        defaultFile = resources_folder.."playagain_btn.png",
        overFile = resources_folder.."playagain_btn_over.png",
        onRelease = function()
            restartGame()
            popup:removeSelf()
            popupBackground:removeSelf()
        end,
        emboss = false,
        width = 200,
        height = 60,
        fontSize = 16,
        labelColor = { default={1,1,1}, over={0.5,0.5,0.5} }
    })
    retry_btn.x = display.contentCenterX
    retry_btn.y = display.contentCenterY + 15
    popup:insert(retry_btn)
    popup:toFront()
end

-- Function to remove the superior cells to show underneath and see the mines
local function showMines(grid, sceneGroup)
    for i = 1, gridRows do
        for j = 1, gridColumns do
            if gameGrid[i][j] < 0 then
                if grid[i][j].imageCell ~= nil then
                    grid[i][j].imageCell:removeSelf()
                    grid[i][j].imageCell = nil
                end
            end
        end
    end
end

-- Recursive function to reveal adjacent cells
local function revealAdjacentCells(i, j, sceneGroup)
    if i >= 1 and i <= gridRows and j >= 1 and j <= gridColumns and grid[i][j].imageCell ~= nil then
        if grid[i][j].flag then
            grid[i][j].flag:removeSelf()
            grid[i][j].flag = nil
        end
        grid[i][j].imageCell:removeSelf()
        grid[i][j].imageCell = nil
        if gameGrid[i][j] < 0 then
            showMines(grid, sceneGroup)
            showPopUp("You lost")
            audio.play(explosionSound)
        end
        if gameGrid[i][j] == 0 then
            revealAdjacentCells(i - 1, j - 1)
            revealAdjacentCells(i - 1, j)
            revealAdjacentCells(i - 1, j + 1)
            revealAdjacentCells(i, j - 1)
            revealAdjacentCells(i, j + 1)
            revealAdjacentCells(i + 1, j - 1)
            revealAdjacentCells(i + 1, j)
            revealAdjacentCells(i + 1, j + 1)
        end
    end
end

-- Function that returns 1 if the cell has a flag, 0 otherwise
local function hasFlag(i, j)
    if i >= 1 and i <= gridRows and j >= 1 and j <= gridColumns then
        if grid[i][j].flag then
            return 1
        end
    end
    return 0
end

-- Function that counts the number of flags in the grid
local function countFlags()
    local flags = 0
    for i = 1, gridRows do
        for j = 1, gridColumns do
            flags = flags + hasFlag(i, j)
        end
    end
    return flags
end

-- Function that checks if all flags placed are on top of a bomb
local function checkFlags()
    for i = 1, gridRows do
        for j = 1, gridColumns do
            if gameGrid[i][j] < 0 and not grid[i][j].flag then
                return false
            end
        end
    end
    return true
end

------------------------------
-- BUTTONS and WIDGETS
------------------------------

-- Function to create the home button
local function onHometBtnRelease(sceneGroup)
    composer.removeScene("minesweeper")
	composer.gotoScene( "menu", "slideDown", 500 )
    audio.stop()
end
local function createHomeButton(sceneGroup)
    homeButton = widget.newButton{
        defaultFile = resources_folder.."home_btn.png",
        overFile = resources_folder.."home_btn_over.png",
        width = 40, height = 40,
        onEvent = function(event)
            if event.phase == "ended" then
                onHometBtnRelease(sceneGroup)
            end
        end,
        emboss = false,
    }
    homeButton.x = display.contentCenterX + screenW/2.5
    homeButton.y = display.contentCenterY - screenH/2.2
    sceneGroup:insert(homeButton)
end

-- Flag mode
local flagMode = false
local flagButton
local function toggleFlagMode(sceneGroup)
    flagMode = not flagMode
    if flagButton then
        local x, y = flagButton.x, flagButton.y
        flagButton:removeSelf()
        flagButton = nil
        local imageFile = flagMode and resources_folder.."flag_btn.png" or resources_folder.."flag_btn_off.png"
        flagButton = widget.newButton({
            labelColor = { default={ 0 }, over={ 0.5 } },
            fontSize = 47,
            defaultFile = imageFile,
            overFile = resources_folder.."flag_btn_over.png",
            width = 60, height = 60,
            onEvent = function(event)
                if event.phase == "ended" then
                    toggleFlagMode(sceneGroup)
                end
            end,
            emboss = false,
        })
        flagButton.x, flagButton.y = x, y
        sceneGroup:insert(flagButton)
    end
end

-- Function to create the flag button
local function createFlagButton(sceneGroup)
    flagButton = widget.newButton({
        labelColor = { default={ 0 }, over={ 0.5 } },
        fontSize = 47,
        defaultFile = resources_folder.."flag_btn_off.png",
        overFile = resources_folder.."flag_btn_over.png",
        width = 60, height = 60,
        onEvent = function(event)
            if event.phase == "ended" then
                toggleFlagMode(sceneGroup)
            end
        end,
        emboss = false,
    })
    flagButton.x = display.contentCenterX
    flagButton.y = display.contentCenterY - screenH/2.8

    sceneGroup:insert(flagButton)
end

-- Chronometer 
local function createChronometer(sceneGroup)
	local clock = display.newImageRect( resources_folder.."chronometer.png", screenH/(6.5)+20, screenH/6.5)
	clock.x = display.contentCenterX - (screenW/4)
	clock.y = display.contentCenterY - (screenH/2.93)
	local start_time = os.time()
    local chronometer_text = display.newText("00   00", display.contentCenterX - screenW/4, display.contentCenterY - screenH/2.81, native.systemFont, 20)
	chronometer_text:setFillColor(0.9921,0.8470,0.2078)
	local function updateChronometer()
		local past_time = os.difftime(os.time(), start_time)  
		local min = math.floor(past_time / 60)
		local segs = past_time % 60
		local time_format = string.format("%02d   %02d", min, segs)
		chronometer_text.text = time_format
	end
    Runtime:addEventListener("enterFrame", updateChronometer)
	sceneGroup:insert(clock)
	sceneGroup:insert(chronometer_text)
end

------------------------------
-- FRONT-END  
------------------------------

-- Create the VISUAL grid
local function createGrid(sceneGroup)
    for i = 1, gridRows do
        grid[i] = {}
        for j = 1, gridColumns do
            local cell = display.newImageRect( resources_folder.."back_cell.jpg", cellSize, cellSize ) 
			cell.x = xOffset + (j - 1) * cellSize
            cell.y = supbarHeight + (i - 1) * cellSize
            cell.strokeWidth = 1 
            cell:setStrokeColor(0.7, 0.7, 0.7, 0.4)
            sceneGroup:insert(cell)
			if gameGrid[i][j] < 0 then
				local mine = display.newImageRect(resources_folder.."mine.png", cellSize, cellSize)
                mine.x = xOffset + (j - 1) * cellSize
                mine.y = supbarHeight + (i - 1) * cellSize
                sceneGroup:insert(mine)
			elseif gameGrid[i][j] > 0 then
				local number = display.newText(gameGrid[i][j], xOffset + (j - 1) * cellSize, supbarHeight + (i - 1) * cellSize, native.systemFont, 16)
				number:setFillColor(1, 1, 1)
				sceneGroup:insert(number)
			end
            local imageCell = display.newImageRect(resources_folder.."cell.jpg", cellSize, cellSize)
    
            imageCell.x = xOffset + (j - 1) * cellSize
            imageCell.y = supbarHeight + (i - 1) * cellSize
            sceneGroup:insert(imageCell)
			function imageCell:touch(event)
                nFlags = countFlags()
                print(nFlags)
                areFlagsCorrect = checkFlags()
                print(areFlagsCorrect)
                if areFlagsCorrect then
                    showMines(grid, sceneGroup)
                    showPopUp("You won")
                    audio.play(winSound)
                end
                if event.phase == "began" then
                    if flagMode then
                        if grid[i][j].flag then
                            grid[i][j].flag:removeSelf()
                            grid[i][j].flag = nil
                        else
                            local flag = display.newImageRect(resources_folder.."flag.png", cellSize, cellSize)
                            flag.x = self.x
                            flag.y = self.y
                            sceneGroup:insert(flag)
                            grid[i][j].flag = flag
                        end
                    else 
                        if grid[i][j].flag then
                            grid[i][j].flag:removeSelf()
                            grid[i][j].flag = nil
                        end
                        revealAdjacentCells(i, j, sceneGroup)
                    end
                end
                return true
            end
			imageCell:addEventListener("touch", imageCell)
            grid[i][j] = {cell = cell, imageCell = imageCell}
        end
    end
    return sceneGroup
end

function scene:create( event )
    local sceneGroup = self.view

    audio.setVolume( 0.05 )

    local background = display.newImageRect(resources_folder.."game_bg.jpg", screenH+200, screenH)
    background.anchorX = 0.5
    background.anchorY = 0.5
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    local game_supbar = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH/5 )
    game_supbar.anchorX = 0
    game_supbar.anchorY = 0
    game_supbar:setFillColor(unpack(sup_bar_color))
	sceneGroup:insert( background )
    sceneGroup:insert( game_supbar )
    local advice = display.newImageRect(resources_folder.."advice.png", screenW, screenH/4)
    advice.x = display.contentCenterX
    advice.y = display.contentCenterY + screenH/2.1
    sceneGroup:insert( advice )
    local advice_text = display.newText("Use the flags to mark the location of all the bombs. \nIntelligence indicates that there are 15 of them ", display.contentCenterX, display.contentCenterY + screenH/2.4, native.systemFont, 14)
    advice_text:setFillColor(0, 0, 0)
	sceneGroup:insert(advice_text)
    createGrid(sceneGroup)
	createChronometer(sceneGroup)
	createFlagButton(sceneGroup)
    createHomeButton(sceneGroup)

end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    if phase == "will" then
        audio.play(sound, { loops = -1 })
    elseif phase == "did" then
    end    
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    if event.phase == "will" then
        audio.stop()
    elseif phase == "did" then
    end    
end

function scene:destroy( event )
	local sceneGroup = self.view
	if startBtn then
		startBtn:removeSelf()
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