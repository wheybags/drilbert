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
end

render._draw_tile = function(x, y, tile_index)
  assert(render.tileset_quads[tile_index])

  love.graphics.draw(render.tileset,
                     render.tileset_quads[tile_index],
                     x * constants.tile_size * constants.render_scale,
                     y * constants.tile_size * constants.render_scale,
                     0, constants.render_scale, constants.render_scale)
end

render._draw_on_tile = function(x, y, image, rotation_deg)
  if rotation_deg == nil then rotation_deg = 0 end

  love.graphics.draw(image,
                     (x + 0.5) * constants.tile_size * constants.render_scale,
                     (y + 0.5) * constants.tile_size * constants.render_scale,
                     rotation_deg * 0.01745329, constants.render_scale, constants.render_scale,
                     constants.tile_size/2, constants.tile_size/2)
end

render.render_level = function(state)
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
  end


  return render