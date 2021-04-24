local render = {}

local constants = require("constants")

render.setup = function()
  render.tileset = love.graphics.newImage('gfx/tileset.png')
  render.tileset:setFilter("nearest")

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

local index_level = function(level_data, x, y)
  assert(x >= 0 and x < level_data.width)
  assert(y >= 0 and y < level_data.height)

  local index = (x + y * level_data.width) + 1
  return level_data.data[index] - 1
end

render._draw_tile = function(x, y, tile_index)
  assert(render.tileset_quads[tile_index])

  love.graphics.draw(render.tileset,
                     render.tileset_quads[tile_index],
                     x * constants.tile_size * constants.render_scale,
                     y * constants.tile_size * constants.render_scale,
                     0, constants.render_scale, constants.render_scale)
end

render.render_level = function(level_data)
  for y = 0, level_data.height-1 do
    for x = 0, level_data.width-1 do
      render._draw_tile(x, y, index_level(level_data, x, y))
    end
  end
end


return render