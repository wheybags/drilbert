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

render._draw_on_tile = function(x, y, image)
   love.graphics.draw(image,
                      x * constants.tile_size * constants.render_scale,
                      y * constants.tile_size * constants.render_scale,
                      0, constants.render_scale, constants.render_scale)
end

render.render_level = function(level_data)
  for y = 0, level_data.height-1 do
    for x = 0, level_data.width-1 do
      render._draw_tile(x, y, game_state.index(level_data, x, y))
    end
  end

  render._draw_on_tile(level_data.player_pos[1], level_data.player_pos[2], render.player)
end


return render