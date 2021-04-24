local game_state = {}

local constants = require("constants")

local levels =
{
  require("level.gather_oxygen").layers[1],
  require("level.explain_push").layers[1],
  require("level.push_puzzle_basic").layers[1],
}

game_state.new = function()
  local level_data = levels[1]

  local state =
  {
    width = level_data.width,
    height = level_data.height,
    data = level_data.data,

    player_pos = {0, 0},
    player_dir = "down",

    dirt = 0,
    oxygen = constants.max_oxygen,
    connected = true,

    dead = false,
    level_win = false,
  }

  for y = 0, level_data.height-1 do
    for x = 0, level_data.width-1 do
      if game_state.index(state, x, y) == constants.spawn_tile_id then
        state.player_pos = {x, y}
      end
    end
  end

  game_state._on_update(state)

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

game_state._get_target = function(state, offset)
  if offset == nil then offset = 1 end

  local move = {0, 0}

  if state.player_dir == "right" then
    move[1] = offset
  elseif state.player_dir == "left" then
    move[1] = -offset
  elseif state.player_dir == "down" then
    move[2] = offset
  elseif state.player_dir == "up" then
    move[2] = -offset
  end

  local target = {state.player_pos[1] + move[1], state.player_pos[2] + move[2]}
  if target[1] < 0 or target[1] >= state.width  or target[2] < 0 or target[2] >= state.height then
    return nil
  end

  return target
end

game_state.move = function(state, direction)
  if state.dead or state.level_win then
    return
  end

  if state.player_dir ~= direction then
    state.player_dir = direction
    return
  end

  local target = game_state._get_target(state)
  if target == nil then return end
  local target_tile = game_state.index(state, target[1], target[2])


  local target2 = game_state._get_target(state, 2)
  local target2_tile
  if target2 ~= nil then target2_tile = game_state.index(state, target2[1], target2[2]) end

  local need_push = target_tile ~= constants.air_tile_id and target_tile ~= constants.spawn_tile_id and target_tile ~= constants.exit_tile_id

  if need_push and target2_tile ~= constants.air_tile_id then
    return
  end

  if need_push then
    game_state._set(state, target[1], target[2], constants.air_tile_id)
    game_state._set(state, target2[1], target2[2], target_tile)
  end

  state.player_pos = target

  game_state._on_update(state)

  if not state.connected then
    state.oxygen = state.oxygen - 1
    if state.oxygen == 0 then
      state.dead = true
    end
  end

  if target_tile == constants.exit_tile_id and not state.dead then
    state.level_win = true
  end
end

game_state.activate = function(state)
  if state.dead or state.level_win then
    return
  end

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

  game_state._on_update(state)
end

game_state._on_update = function(state)
  state.connected = game_state._is_connected(state)
  if state.connected then
    state.oxygen = constants.max_oxygen
  end
end

game_state._is_connected = function(state)
  local spawn_pos
  for y = 0, state.height-1 do
    for x = 0, state.width-1 do
      if game_state.index(state, x, y) == constants.spawn_tile_id then
        spawn_pos = {x, y}
      end
    end
  end

  assert(spawn_pos ~= nil)

  local visited = {}
  local proc
  proc = function(x, y)
    local key = tostring(x) .. "," .. tostring(y)
    if visited[key] then
      return false
    end

    visited[key] = true

    if x < 0 or x >= state.width or y < 0 or y >= state.height then
      return false
    end

    if x == state.player_pos[1] and y == state.player_pos[2] then
      return true
    end

    local tile_id = game_state.index(state, x, y)
    if tile_id == constants.air_tile_id or tile_id == constants.spawn_tile_id then
      if proc(x+1, y) then return true end
      if proc(x-1, y) then return true end
      if proc(x, y+1) then return true end
      if proc(x, y-1) then return true end
    end

    return false
  end

  return proc(spawn_pos[1], spawn_pos[2])

end

return game_state