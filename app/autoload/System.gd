extends Node
## Static systems to orchestrate application execution

var functions: Dictionary = {}

func link(funckey, function: Callable) -> void:
	functions[funckey] = function

func drop(funckey: String) -> void:
	functions.erase(funckey)
	
func invoke(funckey: String, kwargs: Dictionary):
	if funckey in functions:
		return functions[funckey].call(kwargs)
	push_error("No system [%s] referenced." % funckey)

func log(message: String) -> void:
	if OS.is_debug_build():
		print(message)
		Console.cout(message)
