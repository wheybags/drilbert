local render = {}

local constants = require("constants")
local game_state = require("game_state")

render._load_tex = function(path)
  local tex = love.graphics.newImage(path)
  tex:setFilter("nearest")
  return tex
end

render.setup = function()
  render.tileset = render._load_tex("gfx/tileset.png")
  render.player = render._load_tex("gfx/player.png")
  render.oxygen = render._load_tex("gfx/oxygen.png")
  render.dead = render._load_tex("gfx/dead.png")

  render.level_messages = {}
  render.level_messages[2] = render._load_tex("gfx/spacebar.png")

  render.tileset_quads = {}

  local w
  local h
  w, h = render.tileset:getDimensions()

  local idx = 0

  for y = 0, (h/constants.tile_size)-1 do
    for x = 0, (w/constants.tile_size)-1 do
      local quad = love.graphics.newQuad(x * constants.tile_size, y * constants.tile_size,
        constants.tile_size, constants.tile_size,
        render.tileset:getDimensions()
      )

      render.tileset_quads[idx] = quad
      idx = idx + 1
    end
  end

  if love.system.getOS() == "Windows" then
    local ffi = require("ffi")
    ffi.cdef[[
    int SetProcessDPIAware();
    ]]

    ffi.C.SetProcessDPIAware()
  end

  local _, _, flags = love.window.getMode()
  local width, height = love.window.getDesktopDimensions(flags.display)

  local usable_width = width * 0.8
  local usable_height = height * 0.8

  local target_tile_size = constants.screen_size

  local size = {target_tile_size[1] * constants.tile_size, target_tile_size[2] * constants.tile_size}
  render.scale = 1

  while true do
    local next_size = {size[1] * (render.scale+1), size[2] * (render.scale+1)}

    if next_size[1] > usable_width or next_size[2] > usable_height then
      break
    end

    render.scale = render.scale + 1
  end

  love.window.setMode(size[1] * render.scale, size[2] * render.scale)
end

render._draw_tile = function(x, y, tile_index)
  assert(render.tileset_quads[tile_index])

  love.graphics.draw(render.tileset,
                     render.tileset_quads[tile_index],
                     x * constants.tile_size * render.scale,
                     y * constants.tile_size * render.scale,
                     0, render.scale, render.scale)
end

render._draw_on_tile = function(x, y, image, rotation_deg)
  if rotation_deg == nil then rotation_deg = 0 end

  love.graphics.draw(image,
                     (x + 0.5) * constants.tile_size * render.scale,
                     (y + 0.5) * constants.tile_size * render.scale,
                     rotation_deg * 0.01745329, render.scale, render.scale,
                     constants.tile_size/2, constants.tile_size/2)
end

render._render_level = function(state, render_tick)
  for y = 0, state.height-1 do
    for x = 0, state.width-1 do
      render._draw_tile(x, y, game_state.index(state, x, y, state.dirt_layer))
    end
  end
  for _, ball_pos in pairs(state.dirt_balls.bs) do
    render._draw_tile(ball_pos[1], ball_pos[2], constants.dirt_backslash)
  end
  for _, ball_pos in pairs(state.dirt_balls.fs) do
    render._draw_tile(ball_pos[1], ball_pos[2], constants.dirt_slash)
  end


  for y = 0, state.height-1 do
    for x = 0, state.width-1 do
      render._draw_tile(x, y, game_state.index(state, x, y, state.bedrock_layer))

      local real_tile = game_state.index(state, x, y)
      if real_tile ~= constants.dirt_tile_id and real_tile ~= constants.bedrock_tile_id then
        render._draw_tile(x, y, real_tile)
      end
    end
  end

  local y_off = 0
  local x_off = 0
  local rotation = 0

  if not state.dead then
    if state.player_dir == "right" then
      rotation = 90
      x_off = 1/constants.tile_size
    elseif state.player_dir == "down" then
      rotation = 180
      y_off = 1/constants.tile_size
    elseif state.player_dir == "left" then
      rotation = 270
      x_off = -1/constants.tile_size
    elseif state.player_dir == "up" then
      rotation = 0
      y_off = -1/constants.tile_size
    end

    if render_tick % 60 < 30 then
      x_off = 0
      y_off = 0
    end
  end

  if not state.dead or render_tick % 30 < 15 then
    render._draw_on_tile(state.player_pos[1] + x_off, state.player_pos[2] + y_off, render.player, rotation)
  end
end

render._render_gui = function(state, render_tick)

  render._draw_tile(0, constants.level_area[2], constants.frame_tl)
  render._draw_tile(constants.level_area[1]-1, constants.level_area[2], constants.frame_tr)
  render._draw_tile(0, constants.screen_size[2]-1, constants.frame_bl)
  render._draw_tile(constants.level_area[1]-1, constants.screen_size[2]-1, constants.frame_br)

  for x=1,constants.level_area[1]-2 do
    render._draw_tile(x, constants.level_area[2], constants.frame_t)
    render._draw_tile(x, constants.screen_size[2]-1, constants.frame_b)
  end

  for y=constants.level_area[2]+1, constants.screen_size[2]-2 do
    render._draw_tile(0, y, constants.frame_l)
    render._draw_tile(constants.level_area[1]-1, y, constants.frame_r)
  end

  if not state.dead and render.level_messages[state.level_index] and render_tick % 60 < 30 then
    render._draw_on_tile(0, constants.level_area[2], render.level_messages[state.level_index])
  end

  local hud_y = constants.level_area[2] + 1

  local dirt_x = 3
  for d=0, state.dirt-1 do
    local x = dirt_x + d
    render._draw_tile(x, hud_y, constants.dirt_tile_id)
  end

  local oxy_x = 8

  if state.dead then
    if render_tick % 60 < 30 then
      render._draw_on_tile(oxy_x - 1, hud_y, render.dead)
    end
  else
    local do_oxy = state.level_win or state.connected or render_tick % 60 < 30

    if do_oxy then
      for d=0, state.oxygen-1 do
        local x = oxy_x + d
        render._draw_on_tile(x, hud_y, render.oxygen)
      end
    end
  end
end

render.render = function(state, render_tick)
  love.graphics.clear(16/255, 25/255, 28/255)

  render._render_level(state, render_tick)
  render._render_gui(state, render_tick)
end


return render