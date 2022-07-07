class_name InstantGamesBridgeSettings


var initialize_automaticly: bool setget , _initialize_automaticly_getter
func _initialize_automaticly_getter() -> bool:
	if not ProjectSettings.has_setting("addons/instant_games_bridge/initialize/initialize_automatically"):
		return false
		
	return ProjectSettings.has_setting("addons/instant_games_bridge/initialize/initialize_automatically")


var vk_group_id: int setget , _vk_group_id_getter
func _vk_group_id_getter() -> int:
	if not ProjectSettings.has_setting("addons/instant_games_bridge/vk/group_id"):
		return 0
		
	return ProjectSettings.get_setting("addons/instant_games_bridge/vk/group_id")
