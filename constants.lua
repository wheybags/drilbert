local constants = {}

constants.tile_size = 16

constants.spawn_tile_id = 8
constants.exit_tile_id = 9
constants.air_tile_id = 1
constants.dirt_tile_id = 0
constants.stone_tile_id = 2
constants.bedrock_tile_id = 3

constants.max_dirt = 3
constants.max_oxygen = 6

constants.level_area = {15, 15}
constants.screen_size = {15, 18}


constants.dirt_transitions = {}
--                          UDLR
constants.dirt_transitions["0000"] = 0
constants.dirt_transitions["0001"] = 37
constants.dirt_transitions["0010"] = 39
constants.dirt_transitions["0011"] = 38
constants.dirt_transitions["0100"] = 20
constants.dirt_transitions["0101"] = 17
constants.dirt_transitions["0110"] = 19
constants.dirt_transitions["0111"] = 18
constants.dirt_transitions["1000"] = 36
constants.dirt_transitions["1001"] = 33
constants.dirt_transitions["1010"] = 35
constants.dirt_transitions["1011"] = 34
constants.dirt_transitions["1100"] = 28
constants.dirt_transitions["1101"] = 25
constants.dirt_transitions["1110"] = 27
constants.dirt_transitions["1111"] = 26

local bedrock_gap = 24

constants.bedrock_transitions = {}
constants.bedrock_transitions["0000"] = 3
constants.bedrock_transitions["0001"] = constants.dirt_transitions["0001"] + bedrock_gap
constants.bedrock_transitions["0010"] = constants.dirt_transitions["0010"] + bedrock_gap
constants.bedrock_transitions["0011"] = constants.dirt_transitions["0011"] + bedrock_gap
constants.bedrock_transitions["0100"] = constants.dirt_transitions["0100"] + bedrock_gap
constants.bedrock_transitions["0101"] = constants.dirt_transitions["0101"] + bedrock_gap
constants.bedrock_transitions["0110"] = constants.dirt_transitions["0110"] + bedrock_gap
constants.bedrock_transitions["0111"] = constants.dirt_transitions["0111"] + bedrock_gap
constants.bedrock_transitions["1000"] = constants.dirt_transitions["1000"] + bedrock_gap
constants.bedrock_transitions["1001"] = constants.dirt_transitions["1001"] + bedrock_gap
constants.bedrock_transitions["1010"] = constants.dirt_transitions["1010"] + bedrock_gap
constants.bedrock_transitions["1011"] = constants.dirt_transitions["1011"] + bedrock_gap
constants.bedrock_transitions["1100"] = constants.dirt_transitions["1100"] + bedrock_gap
constants.bedrock_transitions["1101"] = constants.dirt_transitions["1101"] + bedrock_gap
constants.bedrock_transitions["1110"] = constants.dirt_transitions["1110"] + bedrock_gap
constants.bedrock_transitions["1111"] = constants.dirt_transitions["1111"] + bedrock_gap

return constants