import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/crank"

-- Game State
local probeY = 0
local depth = 0
local creatures = {}
local hazards = {}
local battery = 100
local score = 0
local gameOver = false

-- Constants
local MAX_DEPTH = 3000
local PROBE_SPEED = 0.5
local CRANK_SENSITIVITY = 0.5

-- Sounds
local captureSound = playdate.sound.sampleplayer.new("sounds/capture")
local hazardSound = playdate.sound.sampleplayer.new("sounds/hazard")
local batterySound = playdate.sound.sampleplayer.new("sounds/battery")

function setup()
    playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
    spawnCreature()
end

-- Crank Controls
function updateCrank()
    local crankChange = playdate.getCrankChange() * CRANK_SENSITIVITY
    probeY += crankChange
    probeY = math.clamp(probeY, 0, 120)  -- Keep probe within screen
    depth += math.abs(crankChange) * PROBE_SPEED
end

function spawnCreature()
    -- Random creature properties
    local creature = {
        y = math.random(20, 100),
        pattern = math.random(1, 3),
        frame = 1,
        captured = false
    }
    table.insert(creatures, creature)
end

function checkCapture()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        for _,creature in ipairs(creatures) do
            -- Simple proximity check
            if math.abs(probeY - creature.y) < 10 and not creature.captured then
                creature.captured = true
                score += 10
                captureSound:play()
            end
        end
    end
end

function updateGame()
    if not gameOver then
        updateCrank()
        checkCapture()
        battery -= 0.1  -- Battery drain
        
        -- Spawn hazards at depth thresholds
        if depth % 500 == 0 then
            table.insert(hazards, {y = math.random(20, 100)})
        end
        
        -- Battery pickup
        if math.random(200) == 1 then
            battery = math.min(battery + 30, 100)
            batterySound:play()
        end
    end
end

function drawProbe()
    playdate.graphics.fillRect(10, probeY, 20, 10)  -- Simple probe sprite
end

function drawCreatures()
    for _,creature in ipairs(creatures) do
        -- Animate based on pattern
        local size = 10 + (creature.frame % 3)*2
        playdate.graphics.drawCircleAtPoint(200, creature.y, size)
    end
end

function drawUI()
    playdate.graphics.drawText("Depth: " .. math.floor(depth), 5, 5)
    playdate.graphics.drawText("Battery: " .. math.floor(battery), 5, 25)
    playdate.graphics.drawText("Score: " .. score, 200, 5)
end

function playdate.update()
    playdate.graphics.clear()
    updateGame()
    drawProbe()
    drawCreatures()
    drawUI()
    
    -- Simple game over check
    if battery <= 0 then
        gameOver = true
        playdate.graphics.drawTextAligned("GAME OVER", 200, 60)
    end
end

-- Initialize
setup()