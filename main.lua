local render = require("render")
local game_state = require("game_state")
local constants = require("constants")

local state

function love.load()
  render.setup()
  state = game_state.new()
end

function love.draw()
  if state then
    render.render_level(state)
  end
end

function love.resize()

end

function love.keypressed(key)
  local move = {0, 0}

  if key == "right" then
    move[1] = 1
  elseif key == "left" then
    move[1] = -1
  elseif key == "down" then
    move[2] = 1
  elseif key == "up" then
    move[2] = -1
  end

  local target = {state.player_pos[1] + move[1], state.player_pos[2] + move[2]}
  if target[1] < 0 or target[1] >= state.width  or target[2] < 0 or target[2] >= state.height then
    return
  end

  local target_tile = game_state.index(state, target[1], target[2])
  if target_tile ~= constants.air_tile_id and target_tile ~= constants.spawn_tile_id then
    return
  end

  state.player_pos = target
end


function love.mousemoved(x,y)

end

function love.wheelmoved(x,y)

end

function love.mousepressed(x,y,button)

end

function love.quit()

end

local fixed_update = function()
end

local accumulatedDeltaTime = 0
function love.update(deltaTime)
  accumulatedDeltaTime = accumulatedDeltaTime + deltaTime

  local tickTime = 1/60

  while accumulatedDeltaTime > tickTime do
    fixed_update()
    accumulatedDeltaTime = accumulatedDeltaTime - tickTime
  end
end
