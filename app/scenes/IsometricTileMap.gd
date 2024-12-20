extends TileMap
# TODO - THis code is COMPLEX!!! break it up

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(Settings.TILEMAP_NODE_GROUP) # TODO - does nothing until refactor
	pass # Replace with function body.

func build(CampaignController: Node) -> TileMap:  # TODO - we can now assume that this is the tilemap node and we don't need to return another one
	#var Campaign: Node = get_node(campaign_controller)
	var map_data: Dictionary = CampaignController.get_TileMap(Cache.tilemap)
	var tileset_cols: int = 1
	var tilemap: TileMap = TileMap.new()  # TODO - use packed scene
	tilemap.y_sort_enabled = true
	tilemap.set_name("TileMap")
	tilemap.cell_quadrant_size = 16
	var tileset: TileSet = TileSet.new() # TODO - use packed scene
	tileset.set_tile_shape(Settings.TILESET_TILESHAPE)
	tileset.set_tile_layout(Settings.TILESET_LAYOUT)
	tileset.set_tile_offset_axis(Settings.TILESET_OFFSET_AXIS)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 4)  # set the second int as value, not bit or index.
	var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
	var tileset_key = map_data.get("tileset")
	var tileset_data = CampaignController.get_TileSet(tileset_key)
	atlas.set_texture(io.load_asset(tileset_data.get("texture")).unwrap())
	atlas.set_texture_region_size(Settings.TILESET_TILESIZE)
	tileset.add_source(atlas)
	tileset.set_tile_size(Settings.TILEMAP_TILESIZE)
	for tile_key in tileset_data.get("tiles", []):
		var tile_data: Dictionary = CampaignController.get_Tile(tile_key)
		tileset_cols = tileset_data.get("columns", 1)
		var tile_index: int = int(tile_data.get("index", 0))
		var coords = Vector2i(tile_index % tileset_cols, tile_index / tileset_cols)
		var tile_pos: Vector2i = Vector2i(tile_index % tileset_cols, tile_index / tileset_cols)
		tileset.get_source(0).create_tile(tile_pos)
		var atlas_tile = atlas.get_tile_data(coords, 0)
		atlas.set("%s:%s/0/y_sort_origin" % [coords.x, coords.y], tile_data.get("origin", 0))
		if tile_data.get("polygon") != null:
			var polygon_key = tile_data.get("polygon")
			if polygon_key != null:
				var polygon: Dictionary = CampaignController.get_Polygon(polygon_key)
				if polygon != null:
					var verticies: Array = []
					if polygon.keys().size() > 0:
						if "default" in polygon.keys():
							verticies = polygon["polygon"].map(vec2_from)
						else:
							verticies = polygon.values()[0].map(vec2_from)
					atlas_tile.set("physics_layer_0/polygon_0/points", verticies)
		tilemap.tile_set = tileset
	var layer_index: int = 0
	for layer_key in map_data.get("layers", []):
		var layer_data: Dictionary = CampaignController.get_Layer(layer_key)
		if layer_data != null:
			var layer_string: String = io.load_asset(layer_data.get("source")).unwrap()
			tilemap.add_layer(layer_index)
			tilemap.set_layer_y_sort_enabled(layer_index, layer_data.get("ysort", false))
			var coords: Vector2i = Vector2i()
			
			for row in layer_string.split("\n"):
				coords.y = 0
				for tile_char in row:
					var tile_data = lookup_tile_by_char(CampaignController, tileset_key, tile_char)
					if tile_data != null:
						# TODO - handle when columns = 0
						var atlas_coords: Vector2i = Vector2i( 
							(int(tile_data.get("index", 0))) % int(tileset_data.get("columns", 1)),
							(int(tile_data.get("index", 0))) / int(tileset_data.get("columns", 1)),
						)
						tilemap.set_cell(layer_index, coords, 0, atlas_coords)
					coords.y -= 1
				coords.x += 1
			layer_index += 1
	return tilemap


func lookup_tile_by_char(CampaignController: Node, tileset_key: String, tile_char):
	var tileset_data = CampaignController.get_TileSet(tileset_key)
	if tileset_data != null:
		for tile_key in CampaignController.data.Tile.keys():
			var tile_data = CampaignController.get_Tile(tile_key)
			if tile_data != null:
				if tile_data.get("char") == tile_char and tile_key in tileset_data.get("tiles", []):
					return tile_data

func vec2_from(value) -> Vector2:
	var vec: Vector2 = Vector2()
	match typeof(value):
		TYPE_ARRAY:
			if value.size() >= 1:
				if typeof(value[0]) == TYPE_INT or typeof(value[0]) == TYPE_FLOAT:
					vec.x = float(value[0])
			if value.size() >= 2:
				if typeof(value[1]) == TYPE_INT or typeof(value[1]) == TYPE_FLOAT:
					vec.y = float(value[1])
		TYPE_DICTIONARY:
			var x = value.get("x")
			var y = value.get("y")
			if typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT:
				vec.x = float(x)
			if typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT:
				vec.y = float(y)
	return vec
