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

render.render_level = function(state, render_tick)
  for y = 0, state.height-1 do
    for x = 0, state.width-1 do
      render._draw_tile(x, y, game_state.index(state, x, y))
    end
  end

  local rotation = 0
  if state.player_dir == "right" then
    rotation = 90
  elseif state.player_dir == "down" then
    rotation = 180
  elseif state.player_dir == "left" then
    rotation = 270
  end

  render._draw_on_tile(state.player_pos[1], state.player_pos[2], render.player, rotation)


  local hud_y = constants.level_area[2] + 1

  local dirt_x = 3
  for d=0, state.dirt-1 do
    local x = dirt_x + d
    render._draw_tile(x, hud_y, constants.dirt_tile_id)
  end

  local oxy_x = 8

  if state.dead then
    render._draw_on_tile(oxy_x, hud_y, render.dead)
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


return render