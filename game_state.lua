local game_state = {}

local constants = require("constants")

game_state.new = function()
  local level_data = require("level.level_01").layers[1]

  local state =
  {
    width = level_data.width,
    height = level_data.height,
    data = level_data.data,

    player_pos = {0, 0},
    player_dir = "down",

    dirt = 3,
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

game_state._set = function(level_data, x, y, tile_id)
  assert(x >= 0 and x < level_data.width)
  assert(y >= 0 and y < level_data.height)

  local index = (x + y * level_data.width) + 1
  level_data.data[index] = tile_id + 1
end

game_state._get_target = function(state)
  local move = {0, 0}

  if state.player_dir == "right" then
    move[1] = 1
  elseif state.player_dir == "left" then
    move[1] = -1
  elseif state.player_dir == "down" then
    move[2] = 1
  elseif state.player_dir == "up" then
    move[2] = -1
  end

  local target = {state.player_pos[1] + move[1], state.player_pos[2] + move[2]}
  if target[1] < 0 or target[1] >= state.width  or target[2] < 0 or target[2] >= state.height then
    return nil
  end

  return target
end

game_state.move = function(state, direction)
  if state.player_dir ~= direction then
    state.player_dir = direction
    return
  end

  local target = game_state._get_target(state)
  if target == nil then return end

  local target_tile = game_state.index(state, target[1], target[2])
  if target_tile ~= constants.air_tile_id and target_tile ~= constants.spawn_tile_id then
    return
  end

  state.player_pos = target
end

game_state.activate = function(state)
  local target = game_state._get_target(state)
  if target == nil then return end

  local target_tile = game_state.index(state, target[1], target[2])

  if target_tile == constants.dirt_tile_id then
    if state.dirt == constants.max_dirt then
      return
    end

    game_state._set(state, target[1], target[2], constants.air_tile_id)
    state.dirt = state.dirt + 1
  elseif target_tile == constants.air_tile_id then
    if state.dirt == 0 then
      return
    end

    game_state._set(state, target[1], target[2], constants.dirt_tile_id)
    state.dirt = state.dirt - 1
  end

end

return game_state