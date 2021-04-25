local render = require("render")
local game_state = require("game_state")

local state
local render_tick = 0

local music

mod_music = function()
  music:setVolume(0.8)
  music:setPitch(0.7)
end

music_normal = function()
  music:setVolume(1)
  music:setPitch(1)
end

function love.load()
  render.setup()
  state = game_state.new()

  music = love.audio.newSource("/sfx/Coming After You.wav", "stream")
  music:setLooping(true)
  music:play()
end

function love.draw()
  if state then
    render.render(state, render_tick)
  end
end

function love.resize()

end

function love.keypressed(key)
  if key == "right" or key == "left" or key == "up" or key == "down" then
    game_state.move(state, key)
  end

  if key == "space" then
    game_state.activate(state)
  end

  if key == "r" then
    music_normal()
    game_state.load_level(state, state.level_index)
  end
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
  render_tick = render_tick + 1
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
