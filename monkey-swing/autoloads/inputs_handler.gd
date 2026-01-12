extends Node
class_name InputSettings

# setting file path
var settings_folder_name := "settings"
var settings_folder_path := "user://%s/" % settings_folder_name
var controls_file_name := "controls.cfg"
var controls_file_path := "%s%s" % [settings_folder_path, controls_file_name]

@onready var user_folder = DirAccess.open("user://")
@onready var input_file = ConfigFile.new()

@onready var possible_actions: Array[StringName] = InputMap.get_actions().filter(is_user_action)

var camera_sensitivity: float = 0.5

signal input_mode_changed(new_input_mode: INPUT_MODE)

@export var last_input_mode: INPUT_MODE = INPUT_MODE.KEYBOARD
enum INPUT_MODE {
	KEYBOARD,
	CONTROLLER,
}

func _ready():
	var err = input_file.load(controls_file_path)
	if err != OK:
		printerr("Something happened at %s, error code [%d], creating new input settings file..." % [controls_file_path, err])

		var err_create = create_input_file()
		if err_create != OK:
			printerr("Could not load the settings, using default configuration instead")
		return # default action are set in the editor directly, so we do not need to set them if the input file wasn't found, as we are falling back to default.
	#load_player_actions_from_file()

#region Inputs

func _unhandled_input(event: InputEvent):
	if (event is InputEventJoypadButton or event is InputEventJoypadMotion) && last_input_mode != INPUT_MODE.CONTROLLER:
		last_input_mode = INPUT_MODE.CONTROLLER
		input_mode_changed.emit(last_input_mode)
	if (event is InputEventMouseMotion or event is InputEventMouseButton or event is InputEventKey) && last_input_mode != INPUT_MODE.KEYBOARD:
		last_input_mode = INPUT_MODE.KEYBOARD
		input_mode_changed.emit(last_input_mode)

func handle_mouse(mode: bool) -> void:
	if last_input_mode == INPUT_MODE.KEYBOARD:
		if mode:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

#endregion


#region Actions
func is_user_action(action: String) -> bool:
	return not action.begins_with("ui_")

func convert_json_to_input_event(json_string) -> InputEvent:
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data_received = json.data
		var input_event = JSON.to_native(data_received, true)
		if input_event is InputEvent:
			return(input_event)
		else:
			printerr("Unexpected data of type %s with value %s" % [typeof(input_event), input_event])
	else:
		printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	return null

func change_action_from_string(action_name: String, action_value: String, key: String) -> void:
	var input_event: InputEvent = convert_json_to_input_event(action_value)
	if input_event == null:
		return printerr("Failed to create action %s with value %s" % [action_name, action_value])
	## Create the input event if it doesn't exist
	if InputMap.action_has_event(action_name, input_event):
		return
	update_event(action_name, input_event, int(key))
	
## Loop and recreate each event at the "end", replacing the one we want, so the order is still the same every time we run it.
func update_event(action_name: String, new_event: InputEvent, key: int) -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action_name)
	if events.size() >= key:
		var i = 0
		for event in events:
			InputMap.action_erase_event(action_name, event)
			if i == key:
				InputMap.action_add_event(action_name, new_event)
			else:
				InputMap.action_add_event(action_name, event)
			i += 1
	## If the key is bigger than the number of event, this means that we must add the event.
	else:
		InputMap.action_add_event(action_name, new_event)
		

func add_action_from_event(action_name: String, action_event: InputEvent) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if not InputMap.action_has_event(action_name, action_event):
		InputMap.action_add_event(action_name, action_event)

func print_actions() -> void:
	for act in InputMap.get_actions():
		if not act.begins_with("ui_"):
			print(act)
	print_debug("___________")

func convert_event_to_human_readable(event: InputEvent) -> String:
	var event_name: String = event.as_text()
	if event_name.contains("Joypad"):
		return convert_joypad_input_to_human_readable(event_name)
	else:
		return "keyboard/" + localize_keyboard_input(event).to_lower()

func convert_joypad_input_to_human_readable(event_name: String) -> String:
	if event_name.contains("Left Stick") and event_name.contains("Joypad Motion"):
		return "xbox/left_stick"
	if event_name.contains("Right Stick") and event_name.contains("Joypad Motion"):
		return "xbox/right_stick"
	if event_name.contains("Xbox A"):
		return "xbox/a"
	if event_name.contains("Xbox B"):
		return "xbox/b"
	if event_name.contains("Xbox X"):
		return "xbox/x"
	if event_name.contains("Xbox Y"):
		return "xbox/y"
	if event_name.contains("Button 4"):
		return "xbox/view"
	if event_name.contains("Button 15"):
		return "xbox/share"
	if event_name.contains("Xbox RT"):
		return "xbox/rt"
	if event_name.contains("Xbox LT"):
		return "xbox/lt"
	if event_name.contains("Xbox RB"):
		return "xbox/rb"
	if event_name.contains("Xbox LB"):
		return "xbox/lb"
	if event_name.contains("Xbox Menu"):
		return "xbox/menu"
	if event_name.contains("D-pad Left"):
		return "xbox/dpad_left"
	if event_name.contains("D-pad Right"):
		return "xbox/dpad_right"
	if event_name.contains("D-pad Up"):
		return "xbox/dpad_up"
	if event_name.contains("D-pad Down"):
		return "xbox/dpad_down"
	return ""

func localize_keyboard_input(event: InputEvent):
	if event is InputEventKey:
		return event.as_text().substr(0, event.as_text().find(" "))
	if event is InputEventMouseButton:
		return event.as_text().replace(" ", "_")

#endregion

#region File
func create_input_file() -> int:
	if not DirAccess.open(settings_folder_path):
		user_folder.make_dir(settings_folder_name)
	return save_actions_to_file()

func load_player_actions_from_file() -> void:
	for action in possible_actions:
		load_player_action_from_file(action)

func load_player_action_from_file(action: String) -> void:
	for key in input_file.get_section_keys(action):
		var action_value = get_value(action, key)
		if action_value:
			change_action_from_string(action, action_value, key)

func get_value(section: String, setting: String) -> Variant:
	return input_file.get_value(section, setting, false)

func set_value(section: String, setting: String, value: Variant) -> void:
	input_file.set_value(section, setting, value)

func save_actions_to_file() -> int:
	for action_name: StringName in InputMap.get_actions():
		if is_user_action(action_name):
			var i := 0
			for event: InputEvent in InputMap.action_get_events(action_name):
				set_value(action_name, str(i), JSON.stringify(JSON.from_native(event, true)))
				i += 1
	return save_file()

func save_file() -> int:
	print_debug('Saving player controls file at %s.' % controls_file_path )
	var err = input_file.save(controls_file_path)

	if err != OK:
		printerr("Error code [%d]. Something went wrong saving the player input file at %s." % [err, controls_file_path])
	return err

#endregion
