extends Node

signal loaded

var data: Dictionary = {
	"Main": {},
	"Actor": {},
	"TileMap": {},
	"Layer": {},
	"TileSet": {},
	"Tile": {},
	"Polygon": {},
	"Zone": {},
	"Vertex": {},
	"Deployment": {},
	"Sprite": {},
	"Animation": {},
	"Resource": {},
	"Scene": {},
}

func reset() -> void:
	for key in data.keys():
		data[key].clear()

func get_Main() -> Dictionary:
	return data.Main

func get_Actor(objkey: String) -> Dictionary:
	return data.get("Actor", {}).get(objkey, {})

func get_TileMap(objkey: String) -> Dictionary:
	return data.get("TileMap", {}).get(objkey, {})

func get_Layer(objkey: String) -> Dictionary:
	return data.get("Layer", {}).get(objkey, {})

func get_TileSet(objkey: String) -> Dictionary:
	return data.get("TileSet", {}).get(objkey, {})

func get_Tile(objkey: String) -> Dictionary:
	return data.get("Tile", {}).get(objkey, {})

func get_Polygon(objkey: String) -> Dictionary:
	return data.get("Polygon", {}).get(objkey, {})

func get_Zone(objkey: String) -> Dictionary:
	return data.get("Zone", {}).get(objkey, {})

func get_Vertex(objkey: String) -> Dictionary:
	return data.get("Vertex", {}).get(objkey, {})
	
func get_Deployment(objkey: String) -> Dictionary:
	return data.get("Deployment", {}).get(objkey, {})

func get_Sprite(objkey: String) -> Dictionary:
	return data.get("Sprite", {}).get(objkey, {})

func get_Animation(objkey: String) -> Dictionary:
	return data.get("Animation", {}).get(objkey, {})
	
func get_Resource(objkey: String) -> Dictionary:
	return data.get("Resource", {}).get(objkey, {})
	
func get_Scene(objkey: String) -> Dictionary:
	return data.get("Scene", {}).get(objkey, {})
	
func add_obj(objdata: Dictionary) -> Result:
	for objtype in objdata.keys():
		if typeof(objdata[objtype]) == TYPE_DICTIONARY:
			if objtype == "Main":
				data["Main"] = objdata["Main"].duplicate()
			else:
				for objkey in objdata[objtype].keys():
					if typeof(objdata[objtype][objkey]) == TYPE_DICTIONARY:
						if data.get(objtype) != null:
							data[objtype][objkey] = objdata[objtype][objkey].duplicate()
						else:
							Console.println("Unable to place object type [%s] from campaign. Typo in content creation?" % objtype)
	return Result.ok(OK)
	
func load_from_archive() -> Result:
	var archive: ZIPReader = ZIPReader.new()
	var campaign_path: String = io.get_dir() + Settings.CAMPAIGNS_DIR + Cache.campaign + ".zip"
	if archive.open(campaign_path) == OK:	
		var all_assets: Array = archive.get_files()
		archive.close()
		Console.println("Loading [%s] assets from campaign [%s]..." % [all_assets.size(), campaign_path])
		for key in all_assets:
			if key.ends_with(".json"):
				io\
				.load_asset(key)\
				.then(func(o): return add_obj(o))\
				.catch(func(_o): Console.println("Unable to load asset %s" % key))
		loaded.emit()
		return Result.ok(OK)
	return Result.fail(FAILED)
	#
#@rpc("authority", "reliable")
#func spawn_tilemap(campaign: String, tilemap_key: String) -> void:
	#Cache.campaign = campaign
	#if load_campaign().is_ok():
		#var isometric_tilemap: TileMap = Scene.IsometricTileMap.instantiate().build(self, tilemap_key)
		#get_parent().add_child(isometric_tilemap)
	#else:
		#push_error("FAILED TO LOAD CAMPAIGN")
	
#func plant_tilemap_seed(campaign_name: String):
	#var seed = Scene.TileMapSeed.instantiate()
	#seed.campaign_name = campaign_name
	## TEMPORARY TILEMAP HAS BEEN HARD CODED	get_tree().call_group("Zone", "add_child", TileMapNode)
	#seed.tilemap_key = "baseTileMap"
	#seed.campaign_node_path = self.get_path()
	#get_parent().add_child(seed)