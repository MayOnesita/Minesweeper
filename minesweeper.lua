-----------------------------------------------------------------------------------------
-- minesweeper.lua
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local resources_folder = "resources/"

local sup_bar_color = {0.3647,0.2509,0.2156,0.7}
local widget = require( "widget" )

-----------------------------------------------------------------------------------------

-- Screen Variables
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

-- Main variables
local grid = {} -- 2D array to hold our grid
local cellSize = 30 
local gridRows = 10 
local gridColumns = 10

local nBombs = 15

-- Function to create the game grid, 2D array to represent mathematically the grid
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

-- function that returns 1 if there is a mine in grid[i][j], 0 otherwise
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

-- CREATE THE GAME GRID
local gameGrid = createGameGrid()
setMines(gameGrid, nBombs)
fillGrid(gameGrid)

-- Recursive function to reveal adjacent cells
local function revealAdjacentCells(i, j)
    -- Check if the cell is within the grid and has not been revealed yet
    if i >= 1 and i <= gridRows and j >= 1 and j <= gridColumns and grid[i][j].imageCell ~= nil then
        -- Reveal the cell
        grid[i][j].imageCell:removeSelf()
        grid[i][j].imageCell = nil

        -- If the cell's value is 0, reveal its adjacent cells
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

-- Create the VISUAL grid
local function createGrid(sceneGroup)
    local supbarHeight = screenH/4 -- height of the supbar
    local gridWidth = cellSize * gridColumns -- total width of the grid
    local xOffset = (screenW - gridWidth) / 2 + 14 -- horizontal offset to center the grid
    for i = 1, gridRows do
        grid[i] = {} -- create a new row
        for j = 1, gridColumns do
            -- create a new cell for the background color
            local cell = display.newRect(xOffset + (j - 1) * cellSize, supbarHeight + (i - 1) * cellSize, cellSize, cellSize)
            cell:setFillColor(0.7) 
            cell.strokeWidth = 1 
            cell:setStrokeColor(1, 1, 1)
            sceneGroup:insert(cell)

            -- add the images and numbers based on the gameGrid values
			if gameGrid[i][j] < 0 then
				local mine = display.newImageRect(resources_folder.."mine.png", cellSize, cellSize)
                mine.x = xOffset + (j - 1) * cellSize
                mine.y = supbarHeight + (i - 1) * cellSize
                sceneGroup:insert(mine)
			elseif gameGrid[i][j] > 0 then
				local number = display.newText(gameGrid[i][j], xOffset + (j - 1) * cellSize, supbarHeight + (i - 1) * cellSize, native.systemFont, 16)
				number:setFillColor(0, 0, 0)
				sceneGroup:insert(number)
			end

            -- create a new cell for the image
            local imageCell = display.newImageRect(resources_folder.."cell.jpg", cellSize, cellSize)
            imageCell.x = xOffset + (j - 1) * cellSize
            imageCell.y = supbarHeight + (i - 1) * cellSize
            sceneGroup:insert(imageCell) -- add the image of the cell

                -- add a touch event listener to the image cell
			function imageCell:touch(event)
				if event.phase == "began" then
					self:removeSelf() -- remove the image cell when it's clicked
					self = nil
					-- Call the revealAdjacentCells function when a cell is clicked
					revealAdjacentCells(i, j)
				end
				return true
			end
			imageCell:addEventListener("touch", imageCell)


            grid[i][j] = {cell = cell, imageCell = imageCell} -- add the cells to the grid
        end
    end
end

local function createCronometer(sceneGroup)
	local clock = display.newImageRect( resources_folder.."cronometer.png", screenH/5+20, screenH/5)
	clock.x = display.contentCenterX - (screenW/4)
	clock.y = display.contentCenterY - (screenH/3)


	sceneGroup:insert(clock)
end

function scene:create( event )
    local sceneGroup = self.view
    local background = display.newImageRect(resources_folder.."game_bg.png", screenH+200, screenH)
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
    createGrid(sceneGroup)
	createCronometer(sceneGroup)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
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
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene