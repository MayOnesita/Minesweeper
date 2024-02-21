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
local nBombs = 25
local win_cells = (gridRows * gridColumns) - nBombs

-- Screen Variables
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local supbarHeight = screenH/4 -- height of the supbar
local gridWidth = cellSize * gridColumns -- total width of the grid
local xOffset = halfW/6.5 -- horizontal offset to center the grid

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

-- Recursive function to reveal adjacent cells
local function revealAdjacentCells(i, j)
    if i >= 1 and i <= gridRows and j >= 1 and j <= gridColumns and grid[i][j].imageCell ~= nil then
        if grid[i][j].flag then 
            grid[i][j].flag:removeSelf()
            grid[i][j].flag = nil
        end
        grid[i][j].imageCell:removeSelf()
        grid[i][j].imageCell = nil
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


------------------------------
-- BUTTONS and WIDGETS
------------------------------

-- Function to create the home button
local function onHometBtnRelease(sceneGroup)
	composer.gotoScene( "menu", "fade", 500 )
	
	return true	-- indicates successful touch
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
local is_first_time = true
local off_layer

local function toggleFlagMode(first_off_layer, sceneGroup)
    flagMode = not flagMode
    -- Check if flagButton is not nil before using it
    if flagButton then
        off_layer = display.newImageRect( resources_folder.."flag_btn_off_layer.png", 60, 60 )
        off_layer.x = display.contentCenterX 
        off_layer.y = display.contentCenterY - screenH/2.8

        sceneGroup:insert(off_layer)

        if flagMode then
            off_layer:removeSelf()   

            if is_first_time then
                first_off_layer:removeSelf()
                is_first_time = false
            end         
        end
    end
end

-- Function to create the flag button
local function createFlagButton(sceneGroup)

    first_off_layer = display.newImageRect( resources_folder.."flag_btn_off_layer.png", 60, 60 )
    first_off_layer.x = display.contentCenterX
    first_off_layer.y = display.contentCenterY - screenH/2.8

    flagButton = widget.newButton({
        defaultFile = resources_folder.."flag_btn.png",
        overFile = resources_folder.."flag_btn_over.png",
        width = 60, height = 60,
        onEvent = function(event)
            if event.phase == "ended" then
                toggleFlagMode(first_off_layer, sceneGroup)
            end
        end,
        emboss = false,
    })
    flagButton.x = display.contentCenterX
    flagButton.y = display.contentCenterY - screenH/2.8

    sceneGroup:insert(flagButton)
    sceneGroup:insert(first_off_layer)
end
--[[
-- Define startBtn at a higher scope
local startBtn

local function onStartBtnRelease()
    -- Check if startBtn is not nil before using it
    if startBtn then
        if startBtn:getLabel() == "Start" then
            startBtn:setLabel("Stop")
            -- Add code here to perform when the button is toggled on
        else 
            startBtn:setLabel("Start")
            -- Add code here to perform when the button is toggled off
        end
    end
end

-- Later in your code, you can initialize startBtn
startBtn = widget.newButton{
    label = "Start",
    labelColor = { default={ 1.0 }, over={ 0.5 } },
    defaultFile = resources_folder.."button.png",
    overFile = resources_folder.."button-over.png",
    width = 154, height = 40,
    onRelease = onStartBtnRelease -- event listener function
}

-- Flag mode
local flagMode = false
local function toggleFlagMode()
    flagMode = not flagMode
end

-- Function to create the flag button
local function createFlagButton(sceneGroup)
    local flagButton = widget.newButton({
        label = "Flag Mode",
        onEvent = function(event)
            if event.phase == "ended" then
                toggleFlagMode()
            end
        end,
        emboss = false,
    })
    sceneGroup:insert(flagButton)
end
]]

-- Chronometer 
local function createChronometer(sceneGroup)
	local clock = display.newImageRect( resources_folder.."chronometer.png", screenH/(6.5)+20, screenH/6.5)
	clock.x = display.contentCenterX - (screenW/4)
	clock.y = display.contentCenterY - (screenH/2.93)

	local start_time = os.time()  -- Obtiene el tiempo de inicio en segundos

    local chronometer_text = display.newText("00   00", display.contentCenterX - screenW/4, display.contentCenterY - screenH/2.81, native.systemFont, 20)
	chronometer_text:setFillColor(0.9921,0.8470,0.2078)

	local function updateChronometer()
		local past_time = os.difftime(os.time(), start_time)  
		local min = math.floor(past_time / 60)
		local segs = past_time % 60
	
		local time_format = string.format("%02d   %02d", min, segs)
	
		chronometer_text.text = time_format
	end
    -- Actualiza el cronómetro en cada cuadro de animación
    Runtime:addEventListener("enterFrame", updateChronometer)
	sceneGroup:insert(clock)
	sceneGroup:insert(chronometer_text)
end

local function restartGame()
    -- Aquí colocas el código para reiniciar el juego, reiniciando todas las variables y estados de la escena
end

local function showPopUp(message)
    local popupOptions = {
        isModal = true,
        effect = "fade",
        time = 400,
    }

    local popup = display.newGroup()
    local popupBackground = display.newRect(display.contentCenterX, display.contentCenterY, display.actualContentWidth * 0.8, display.actualContentHeight * 0.3)
    popupBackground:setFillColor(0.5, 0.5, 0.5)
    popup:insert(popupBackground)

    local message_on_pu = display.newText({
        text = message,
        x = display.contentCenterX,
        y = display.contentCenterY - 20,
        width = popupBackground.width * 0.8,
        font = native.systemFont,
        fontSize = 16
    })

    popup:insert(message_on_pu)

    local retry_btn = widget.newButton({
        label = "Play again",
        onRelease = function()
            restartGame()
            popup:removeSelf()
        end,
        emboss = false,
        shape = "rectangle",
        width = 200,
        height = 40,
        fontSize = 16,
        fillColor = { default={1,1,1}, over={0.5,0.5,0.5} },
        labelColor = { default={0,0,0} }
    })
    retry_btn.x = display.contentCenterX
    retry_btn.y = display.contentCenterY
    popup:insert(retry_btn)

    popup:toFront()
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

            -- add the images and numbers based on the gameGrid values
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

            -- create a new cell for the image
            local imageCell = display.newImageRect(resources_folder.."cell.jpg", cellSize, cellSize)
            imageCell.x = xOffset + (j - 1) * cellSize
            imageCell.y = supbarHeight + (i - 1) * cellSize
            sceneGroup:insert(imageCell) -- add the image of the cell

			-- add a touch event listener to the image cell
			function imageCell:touch(event)
                if event.phase == "began" then
                    if flagMode then -- If flag mode is on
                        if not grid[i][j].flag then -- If there is no flag on the cell
                            local flag = display.newImageRect(resources_folder.."flag.png", cellSize, cellSize)
                            flag.x = self.x
                            flag.y = self.y
                            sceneGroup:insert(flag)
                            grid[i][j].flag = flag -- Store the flag in the grid
                        end
                    else -- If flag mode is off, reveal the cell
                        if grid[i][j].flag then -- If there is a flag on the cell
                            grid[i][j].flag:removeSelf() -- Remove the flag
                            grid[i][j].flag = nil
                        end
                        revealAdjacentCells(i, j)
                    end
                end
                return true
            end
			imageCell:addEventListener("touch", imageCell)
            grid[i][j] = {cell = cell, imageCell = imageCell} -- add the cells to the grid
        end
    end
end

function scene:create( event )
    local sceneGroup = self.view
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
    createGrid(sceneGroup)
	createChronometer(sceneGroup)
	createFlagButton(sceneGroup)
    createHomeButton(sceneGroup)
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

    if homeButton then
		homeButton:removeSelf()
		homeButton = nil
	end
    if flagButton then
		flagButton:removeSelf()
		flagButton = nil
	end
    if flagButton then
		flagButton:removeSelf()
		flagButton = nil
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