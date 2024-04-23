extends Node

func _ready() -> void:
	arg("--campaign").then(func(v): Cache.campaign = v)
	arg("--uri").then(func(v): Cache.uri = v)
	arg("--port").then(func(v): Cache.port = v.to_int())

func arg(param: String) -> Result:
	if OS.get_cmdline_args().has(param):
		var i = OS.get_cmdline_args().find(param)
		if OS.get_cmdline_args().size() > i + 1:
			return Result.ok(OS.get_cmdline_args()[i + 1])
	return Result.fail(FAILED)
