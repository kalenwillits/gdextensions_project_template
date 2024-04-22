extends Node

var data: Dictionary = {
	"Main": {},
	"Actor": {},
	"TileMap": {},
	"Layer": {},
	"TileSet": {},
	"Tile": {},
	"Polygon": {},
	"Zone": {},
	"Vector": {},
	"Deployment": {},
	"Sprite": {},
	"Animation": {},
	"Resource": {},
}

func _ready() -> void:
	System.link("load_campaign", load_campaign)

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

func get_Vector(objkey: String) -> Dictionary:
	return data.get("Vector", {}).get(objkey, {})
	
func get_Deployment(objkey: String) -> Dictionary:
	return data.get("Deployment", {}).get(objkey, {})

func get_Sprite(objkey: String) -> Dictionary:
	return data.get("Sprite", {}).get(objkey, {})

func get_Animation(objkey: String) -> Dictionary:
	return data.get("Animation", {}).get(objkey, {})
	
func get_Resource(objkey: String) -> Dictionary:
	return data.get("Resource", {}).get(objkey, {})
	
func add_obj(objdata: Dictionary) -> Result:
	for objtype in objdata.keys():
		if typeof(objdata[objtype]) == TYPE_DICTIONARY:
			if objtype == "Main":
				data["Main"] = objdata["Main"].duplicate()
			else:
				for objkey in objdata[objtype].keys():
					if typeof(objdata[objtype][objkey]) == TYPE_DICTIONARY:
						objdata[objtype][objkey]["key"] = objkey
						if data.get(objtype) != null:
							data[objtype][objkey] = objdata[objtype][objkey].duplicate()
						else:
							System.log("Unable to place object type [%s] from campaign. Typo in content creation?" % objtype)
	return Result.ok(OK)
	
func load_campaign(kwargs: Dictionary) -> Result:
	var campaign_name: String = kwargs.get("name")
	var archive: ZIPReader = ZIPReader.new()
	var campaign_path: String = io.get_dir() + Settings.CAMPAIGNS_DIR + campaign_name + ".zip"
	if archive.open(campaign_path) == OK:	
		var all_assets: Array = archive.get_files()
		archive.close()
		System.log("Loading [%s] assets from campaign [%s]..." % [all_assets.size(), campaign_path])
		for key in all_assets:
			if key.ends_with(".json"):
				io\
				.load_asset(campaign_name, key)\
				.then(func(o): return add_obj(o))\
				.catch(func(_o): System.log("Unable to load asset %s" % key))
		return Result.ok(OK)
	return Result.fail(FAILED)


func _on_tree_exiting():
	System.drop("load_campaign")
