extends Node

func _ready():
	System.link("exec_profile", exec_profile)
	load_profile()

func load_profile() -> void:
	var args: Array = OS.get_cmdline_args()
	var profile_name: String
	if args.size() > 1:
		profile_name = args[0]
	else:
		profile_name = Settings.DEFAULT_PROFILE_NAME		
	var profile_file_path: String = io.get_dir() + Settings.PROFILES_DIR + profile_name
	io.use_file(profile_file_path, Settings.DEFAULT_PROFILE)
	io\
	.load_file(profile_file_path)\
	.then(func(data): System.invoke("exec_profile", {"profile": data}))
	
func exec_profile(kwargs: Dictionary) -> void:
	var preprocessed_profile: Array = kwargs.get("profile", "")\
	.replace(Settings.PROFILE_LINE_TERMINATOR, Settings.PROFILE_NEW_LINE_SEPERATOR)\
	.split(Settings.PROFILE_NEW_LINE_SEPERATOR)
	for line in preprocessed_profile:
		Console.parse(line).then(func(args): Console.exec(args))
