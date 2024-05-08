extends Node

func _ready() -> void:
	kwarg("--uri").then(func(v): Cache.uri = v)
	kwarg("--port").then(func(v): Cache.port = v.to_int())
	kwarg("--profile").then(func(v): Cache.profile = v)
	kwarg("--campaign").then(func(v): Cache.campaign = v)
	arg("--host").then(func(_v): Cache.network_mode = Cache.NetworkMode.HOST)
	arg("--server").then(func(_v): Cache.network_mode = Cache.NetworkMode.SERVER)
	arg("--client").then(func(_v): Cache.network_mode = Cache.NetworkMode.CLIENT)

func kwarg(arg: String) -> Result:
	if OS.get_cmdline_args().has(arg):
		var i = OS.get_cmdline_args().find(arg)
		if OS.get_cmdline_args().size() > i + 1:
			return Result.ok(OS.get_cmdline_args()[i + 1])
	return Result.fail(FAILED)
	
func arg(arg: String) -> Result:
	if OS.get_cmdline_args().has(arg):
		return Result.ok(OK)
	return Result.fail(FAILED)
