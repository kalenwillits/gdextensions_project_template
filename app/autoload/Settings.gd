extends Node

enum RADIALS {
	W,
	NW,
	N,
	NE,
	E,
	SE,
	S,
	SW,
}

const ISOMETRIC_RATIO: float = 2.0
const NORTH_RADIANS: float = PI / 2.0

const CAMPAIGNS_DIR: String = "campaigns/"

const KWARGS_DELIMITER: String = "="
const HIDDEN_CHAR: String = "*"
const MISSING_VALUE: String = "[?]"

const INVITE_CODE_LENGTH: int = 6
const INVITE_CODE_CHAR_SET: = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" 

const SAVE_JSON_TAB_CHAR: String = "\t"
const PROFILE_LINE_TERMINATOR: String = ";"
const PROFILE_NEW_LINE_SEPERATOR: String = "\n"

const TILEMAP_TILESIZE: Vector2i = Vector2i(32, 16)
const TILESET_TILESIZE: Vector2i = Vector2i(32, 32)

const TILESET_TILESHAPE: TileSet.TileShape = TileSet.TILE_SHAPE_ISOMETRIC
const TILESET_LAYOUT: TileSet.TileLayout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
const TILESET_OFFSET_AXIS: TileSet.TileOffsetAxis = TileSet.TILE_OFFSET_AXIS_HORIZONTAL

const CAMERA_ZOOM_MIN: int = 1
const CAMERA_ZOOM_DEFAULT: int = 3
const CAMERA_ZOOM_MAX: int = 11

const CAMERA_MARGIN: int = 10
const CAMERA_SPEED: float = 600.0
const CAMERA_TOLERANCE: float  = 10.0
const CAMERA_GROUP: String = "Camera"

const CAMPAIGN_CONTROLLER_GROUP: String = "CampaignController"
const NETWORK_GROUP: String = "Network"
const WORLD_NODE_GROUP: String = "World"
const ZONE_NODE_GROUP: String = "Zone"
const ACTOR_GROUP: String = "Actor"
const TILEMAP_NODE_GROUP: String = "TileMap"

const DEFAULT_HEADING: String = "S"
const DESTINATION_PRECISION: float = 0.9999

const DEFAULT_PORT: int = 5000
const DEFAULT_URI: String = "127.0.0.1"
const DEFAULT_MAX_NUM_CLIENTS: int = 128

const BASE_ACTOR_SPEED: float = 10.0
