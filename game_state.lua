local game_state = {}

local constants = require("constants")

local move_sfx = love.audio.newSource("/sfx/SFX_Jump_09.wav", "static")
local drill_sfx = love.audio.newSource("/sfx/drill.wav", "static")
local drop_sfx = love.audio.newSource("/sfx/drop.wav", "static")
local level_complete_sfx = love.audio.newSource("/sfx/level_complete.wav", "static")
local error_sfx = love.audio.newSource("/sfx/error_006.wav", "static")

local levels =
{
  require("level.basic_move").layers[1],
  require("level.basic_dig").layers[1],
  require("level.place_dirt").layers[1],
  require("level.gather_oxygen").layers[1],
  require("level.explain_3").layers[1],
  require("level.explain_push").layers[1],
  require("level.push_puzzle_basic").layers[1],
  require("level.winner").layers[1],
  require("level.secret").layers[1],
  require("level.puzzle_1").layers[1],
  require("level.puzzle_2").layers[1],
  require("level.puzzle_3").layers[1],
  require("level.winner_2").layers[1],
}

game_state.new = function()
  local state =
  {
    level_index = 1,

    width = 0,
    height = 0,
    data = {},

    dirt_layer = {},
    dirt_balls = {bs={}, fs={}},

    bedrock_layer = {},

    player_pos = {0, 0},
    player_dir = "down",

    dirt = 0,
    oxygen = constants.max_oxygen,
    connected = true,

    dead = false,
  }

  game_state.load_level(state, state.level_index)

  return state
end

game_state.load_level = function(state, level_index)
  local level_data = levels[level_index]

  state.level_index = level_index
  state.width = level_data.width
  state.height = level_data.height
  state.data = {unpack(level_data.data)}
  state.player_dir = "down"
  state.dirt = 0
  state.oxygen = constants.max_oxygen
  state.dead = false

  for y = 0, level_data.height-1 do
    for x = 0, level_data.width-1 do
      if game_state.index(state, x, y) == constants.spawn_tile_id then
        state.player_pos = {x, y}
      end
    end
  end

  game_state._on_update(state)
end

game_state.next_level = function(state)
  game_state.load_level(state, state.level_index + 1)
end

game_state.index = function(level_data, x, y, data)
  if data == nil then data = level_data.data end

  assert(x >= 0 and x < level_data.width)
  assert(y >= 0 and y < level_data.height)

  local index = (x + y * level_data.width) + 1
  return data[index] - 1
end

game_state._set = function(level_data, x, y, tile_id, data)
  if data == nil then data = level_data.data end

  assert(tile_id ~= nil)
  assert(x >= 0 and x < level_data.width)
  assert(y >= 0 and y < level_data.height)

  local index = (x + y * level_data.width) + 1
  data[index] = tile_id + 1
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
  if state.dead then
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

  local need_push = target_tile == constants.dirt_tile_id or target_tile == constants.stone_tile_id

  if need_push and target2_tile ~= constants.air_tile_id then
    error_sfx:clone():play()
    return
  end

  if need_push then
    game_state._set(state, target[1], target[2], constants.air_tile_id)
    game_state._set(state, target2[1], target2[2], target_tile)
  end

  target = game_state._get_target(state)
  target_tile = game_state.index(state, target[1], target[2])

  if target_tile ~= constants.air_tile_id and target_tile ~= constants.spawn_tile_id and target_tile ~= constants.exit_tile_id then
    error_sfx:clone():play()
    return
  end

  state.player_pos = target
  move_sfx:clone():play()

  game_state._on_update(state)

  if target_tile == constants.exit_tile_id and not state.dead then
    level_complete_sfx:clone():play()
    game_state.next_level(state)
  end

  if not state.connected then
    state.oxygen = state.oxygen - 1
    if state.oxygen == 0 then
      state.dead = true
    end
  end
end

game_state.activate = function(state)
  if state.dead then
    return
  end

  local target = game_state._get_target(state)
  if target == nil then return end

  local target_tile = game_state.index(state, target[1], target[2])

  if target_tile == constants.dirt_tile_id then
    if state.dirt == constants.max_dirt then
      error_sfx:clone():play()
      return
    end

    game_state._set(state, target[1], target[2], constants.air_tile_id)
    state.dirt = state.dirt + 1
    drill_sfx:clone():play()
  elseif target_tile == constants.air_tile_id then
    if state.dirt == 0 then
      error_sfx:clone():play()
      return
    end

    game_state._set(state, target[1], target[2], constants.dirt_tile_id)
    state.dirt = state.dirt - 1
    drop_sfx:clone():play()
  end

  game_state._on_update(state)
end

game_state._on_update = function(state)
  state.connected = game_state._is_connected(state)
  if state.connected then
    state.oxygen = constants.max_oxygen
  end

  game_state._generate_dirt_transitions(state)
  game_state._generate_bedrock_transitions(state)
end

game_state._generate_bedrock_transitions = function(state)
  local get = function(x, y)
    if x < 0 or x >= state.width or y < 0 or y >= state.height then
      return "1"
    end

    local tile = game_state.index(state, x, y)
    if tile == constants.bedrock_tile_id then
      return "1"
    end

    return "0"
  end

  state.bedrock_layer = {unpack(state.data)}
  for y = 0, state.height-1 do
    for x = 0, state.width-1 do

      local tile = game_state.index(state, x, y)
      if tile ~= constants.bedrock_tile_id then
        game_state._set(state, x, y, constants.air_tile_id, state.bedrock_layer)
      else
        local key = get(x,y-1) .. get(x,y+1) .. get(x-1,y) .. get(x+1,y)
        game_state._set(state, x, y, constants.bedrock_transitions[key], state.bedrock_layer)
      end
    end
  end
end

game_state._generate_dirt_transitions = function(state)
  local get = function(x, y)
    if x < 0 or x >= state.width or y < 0 or y >= state.height then
      return "1"
    end

    local tile = game_state.index(state, x, y)
    if tile == constants.air_tile_id or tile == constants.spawn_tile_id or tile == constants.exit_tile_id then
      return "0"
    end

    return "1"
  end

  state.dirt_layer = {unpack(state.data)}
  state.dirt_balls = {bs={}, fs={}}

  for y = 0, state.height-1 do
    for x = 0, state.width-1 do

      local tile = game_state.index(state, x, y)
      if tile == constants.air_tile_id or tile == constants.spawn_tile_id or tile == constants.exit_tile_id then
        game_state._set(state, x, y, constants.air_tile_id, state.dirt_layer)
      else

        if get(x, y-1) == "0" and get(x-1, y) == "0" and get(x-1, y-1) == "1" then
          table.insert(state.dirt_balls.bs, {x-0.5, y-0.5})
        end

        if get(x, y-1) == "0" and get(x+1, y) == "0" and get(x+1, y-1) == "1" then
          table.insert(state.dirt_balls.fs, {x+0.5, y-0.5})
        end

        local key = get(x,y-1) .. get(x,y+1) .. get(x-1,y) .. get(x+1,y)
        game_state._set(state, x, y, constants.dirt_transitions[key], state.dirt_layer)
      end
    end
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