extends Node

func _ready():
	cli_arg("--campaign").then(func(campaign_name): Cache.campaign = campaign_name)
	Route.to(Scene.World)

func cli_arg(arg: String) -> Result:
	if OS.get_cmdline_args().has(arg):
		var i = OS.get_cmdline_args().find(arg)
		if OS.get_cmdline_args().size() > i + 1:
			return Result.ok(OS.get_cmdline_args()[i + 1])
	return Result.fail(FAILED)
