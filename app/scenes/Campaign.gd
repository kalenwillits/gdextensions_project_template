extends Node
var data: Dictionary = {
	"Start": {},
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
}

func reset() -> void:
	for key in data.keys():
		data[key].clear()

func get_Start() -> Dictionary:
	return data.Start

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
	
func add_obj(objdata: Dictionary) -> Result:
	for objtype in objdata.keys():
		if typeof(objdata[objtype]) == TYPE_DICTIONARY:
			if objtype == "Start":
				data["Start"] = objdata["Start"].duplicate()
			else:
				for objkey in objdata[objtype].keys():
					if typeof(objdata[objtype][objkey]) == TYPE_DICTIONARY:
						objdata[objtype][objkey]["key"] = objkey
						if data.get(objtype) != null:
							data[objtype][objkey] = objdata[objtype][objkey].duplicate()
						else:
							System.log("Unable to place object type [%s] from campaign. Typo in content creation?" % objtype)
	return Result.ok(OK)
