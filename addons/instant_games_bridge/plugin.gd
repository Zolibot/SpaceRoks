tool
extends EditorPlugin

var _injection = InstantGamesBridgeInjection.new()

func _enter_tree():
	add_autoload_singleton("InstantGamesBridge", "res://addons/instant_games_bridge/singleton.gd")
	add_export_plugin(_injection)
	
	_add_custom_project_setting(
		"addons/instant_games_bridge/general/inject_sdk", 
		true, 
		TYPE_BOOL, 
		PROPERTY_HINT_NONE, 
		"If the option is active, the required code will be added automatically to the html file during project export.")
	_add_custom_project_setting(
		"addons/instant_games_bridge/general/use_cdn", 
		false, 
		TYPE_BOOL, 
		PROPERTY_HINT_NONE, 
		"If the option is active, the plugin will be loaded from the CDN. Otherwise, a local file will be used (recommended).")
	
	_add_custom_project_setting(
		"addons/instant_games_bridge/initialize/initialize_automatically", 
		false, 
		TYPE_BOOL, 
		PROPERTY_HINT_NONE, 
		"If the option is active, the plugin will be initialized during the launch of the game, and not at its start.")
	_add_custom_project_setting(
		"addons/instant_games_bridge/initialize/show_interstitial_after_init", 
		false, 
		TYPE_BOOL, 
		PROPERTY_HINT_NONE, 
		"If initialization occurs automatically, an interstitial advertisement will be requested after successful initialization.")
	
	_add_custom_project_setting(
		"addons/instant_games_bridge/vk/group_id", 
		0, 
		TYPE_INT, 
		PROPERTY_HINT_NONE, 
		"The `groupID` identifier is used on the VK platform for some social functions.")

	var error: int = ProjectSettings.save()
	if error: push_error("Encountered error %d when saving project settings." % error)


func _exit_tree():
	remove_autoload_singleton("InstantGamesBridge")
	remove_export_plugin(_injection)


func _add_custom_project_setting(name: String, default_value, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = "") -> void:

	if ProjectSettings.has_setting(name): return

	var setting_info: Dictionary = {
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string
	}

	ProjectSettings.set_setting(name, default_value)
	ProjectSettings.add_property_info(setting_info)
	ProjectSettings.set_initial_value(name, default_value)
