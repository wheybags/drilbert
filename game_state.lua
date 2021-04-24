local game_state = {}

local constants = require("constants")

game_state.new = function()
  local level_data = require("level.level_01").layers[1]

  local state =
  {
    width = level_data.width,
    height = level_data.height,
    data = level_data.data,
  }

  for y = 0, level_data.height-1 do
    for x = 0, level_data.width-1 do
      if game_state.index(state, x, y) == constants.spawn_tile_id then
        state.player_pos = {x, y}
      end
    end
  end

  return state
end

game_state.index = function(level_data, x, y)
  assert(x >= 0 and x < level_data.width)
  assert(y >= 0 and y < level_data.height)

  local index = (x + y * level_data.width) + 1
  return level_data.data[index] - 1
end

return game_state