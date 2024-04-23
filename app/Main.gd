extends Node

func _ready():
	#System.link("exec_profile", exec_profile)
	add_child(Scene.RoutingSystems.instantiate())
	#load_profile()
	Route.to(Scene.World)
	cli_arg("--campaign").then(func(campaign_name): Cache.campaign = campaign_name)

func _on_tree_exiting():
	System.drop("exec_profile")
		
func cli_arg(arg: String) -> Result:
	if OS.get_cmdline_args().has(arg):
		var i = OS.get_cmdline_args().find(arg)
		if OS.get_cmdline_args().size() > i + 1:
			return Result.ok(OS.get_cmdline_args()[i + 1])
	return Result.fail(FAILED)
