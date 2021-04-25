return {
  version = "1.5",
  luaversion = "5.1",
  tiledversion = "1.6.0",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 15,
  height = 15,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 2,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "tileset",
      firstgid = 1,
      filename = "../asset_sources/tileset.tsx"
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 15,
      height = 15,
      id = 1,
      name = "Tile Layer 1",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        1, 4, 1, 1, 9, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 4, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 4, 4,
        4, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1,
        4, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1,
        1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1, 4,
        3, 1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 4, 1, 4, 4,
        1, 3, 1, 4, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1, 1,
        1, 1, 1, 4, 1, 1, 1, 10, 1, 1, 1, 4, 1, 1, 4,
        1, 3, 2, 1, 4, 4, 4, 1, 1, 4, 4, 1, 1, 4, 4,
        1, 2, 2, 1, 1, 1, 1, 4, 4, 1, 1, 1, 3, 3, 4,
        1, 2, 2, 1, 1, 1, 1, 1, 4, 1, 1, 2, 2, 3, 1,
        1, 1, 1, 1, 3, 3, 1, 1, 4, 1, 2, 2, 3, 1, 1,
        1, 1, 3, 3, 3, 1, 3, 1, 4, 1, 1, 3, 1, 1, 1,
        1, 1, 3, 1, 1, 3, 2, 1, 1, 4, 1, 3, 3, 3, 1,
        1, 1, 1, 1, 1, 2, 2, 2, 1, 4, 1, 1, 3, 3, 1
      }
    }
  }
}
