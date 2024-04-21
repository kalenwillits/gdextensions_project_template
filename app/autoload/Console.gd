extends CanvasLayer

const MAX_LINES: int = 16

@export var InputNodePath: NodePath
@onready var InputPrompt: LineEdit = get_node(InputNodePath)
@export var LinesNodePath: NodePath
@onready var Lines: VBoxContainer = get_node(LinesNodePath)

var inputs_index: int = 0

var functions: Dictionary = {}
var inputs: Array = []
var outputs: Array = []

func _ready():
	hide()
	
func link(funckey, function: Callable) -> void:
	functions[funckey] = function

func drop(funckey: String) -> void:
	functions.erase(funckey)
	
func invoke(funckey: String, kwargs: Dictionary) -> Variant:
	return functions[funckey].call(kwargs)

func _process(_deleta: float):
	if Input.is_action_just_pressed("toggle_developer_console"):
		visible = !visible
		if visible:
			InputPrompt.grab_focus()
	if Input.is_action_just_pressed("ui_up"):
		if inputs.size() > 0:
			inputs_index = clamp(inputs_index, 0, inputs.size() - 1)
			InputPrompt.set_text(inputs[(inputs.size() - 1) - inputs_index])
	if Input.is_action_just_pressed("ui_down"):
		inputs_index = clamp(inputs_index - 1, 0, inputs.size() - 1)
		if inputs_index > 0:
			InputPrompt.set_text(inputs[(inputs.size() - 1) - inputs_index])
		else:
			InputPrompt.set_text("")


func cout(line: String):
	outputs.append(line)
	var new_line: Label = Label.new()
	new_line.set_text(line)
	Lines.add_child(new_line)
	clear_extra_lines()
		
func clear_extra_lines():
	while Lines.get_child_count() > MAX_LINES:
		var line_to_remove = Lines.get_child(0)
		Lines.remove_child(line_to_remove)
		line_to_remove.queue_free()

func exec(kwargs: Dictionary):
	if kwargs.size() > 0:
		var command = kwargs.get(0)
		if command in functions.keys():
			functions[command].call(kwargs)
		elif command == "?":
			functions["help"].call(kwargs)
		elif OS.is_debug_build():
			push_error("No command [%s] linked to Console" % command)

func parse(line: String) -> Result:
	if line == "":
		return Result.fail(FAILED)
	inputs.append(line)
	inputs_index = 0
	var args: Array = line.split(" ")
	var kwargs: Dictionary = {}
	for i in range(args.size()):
		if "=" in args[i]:
			var split_arg: Array = args[i].split("=", 1)
			kwargs[split_arg[0].strip_edges()] = split_arg[1].strip_edges()
		else:
			kwargs[i] = args[i]
	if len(args) > 0:
		return Result.ok(kwargs)
	return Result.fail(FAILED)

func _on_input_text_submitted(line: String):
	InputPrompt.set_text("")
	parse(line).then(func(args): exec(args))

func _on_tree_exiting():
	if OS.is_debug_build():
		System.invoke("save_logs", {})
