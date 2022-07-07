extends Node

signal initalized

var _instant_games_bridge_interface

var _initialized_cb = JavaScript.create_callback(self, "_on_initialized")
var _printerr_cb = JavaScript.create_callback(self, "printerr")

var settings: InstantGamesBridgeSettings = InstantGamesBridgeSettings.new()

var is_initialized: bool setget , _is_initialized_getter
func _is_initialized_getter() -> bool:
	if not _check_sdk(): return false
	
	return _instant_games_bridge_interface.isInitialized


var _advertisement: InstantGamesBridgeAdvertisement
var advertisement: InstantGamesBridgeAdvertisement setget , _advertisement_getter
func _advertisement_getter() -> InstantGamesBridgeAdvertisement:
	if _advertisement != null: return _advertisement
	if not _check_sdk(): return null
	
	_advertisement = InstantGamesBridgeAdvertisement.new(_instant_games_bridge_interface.advertisement)
	return _advertisement


var _platform: InstantGamesBridgePlatform
var platform: InstantGamesBridgePlatform setget , _platform_getter
func _platform_getter() -> InstantGamesBridgePlatform:
	if _platform != null: return _platform 
	if not _check_sdk(): return null
	
	_platform = InstantGamesBridgePlatform.new(_instant_games_bridge_interface.platform)
	return _platform


var _game: InstantGamesBridgeGame
var game: InstantGamesBridgeGame setget , _game_getter
func _game_getter() -> InstantGamesBridgeGame:
	if _game != null: return _game
	if not _check_sdk(): return null
	
	_game = InstantGamesBridgeGame.new(_instant_games_bridge_interface.game)
	return _game


var _social: InstantGamesBridgeSocial
var social: InstantGamesBridgeSocial setget , _social_getter
func _social_getter() -> InstantGamesBridgeSocial:
	if _social != null: return _social
	if not _check_sdk(): return null
	
	_social = InstantGamesBridgeSocial.new(_instant_games_bridge_interface.social)
	return _social


func _check_sdk() -> bool:
	if _instant_games_bridge_interface != null: return true
	if not OS.has_feature("JavaScript"): return false
	if JavaScript.get_interface("window").instantGamesBridge == null: return false
	
	_instant_games_bridge_interface = JavaScript.get_interface("instantGamesBridge")
	
	return true


func _on_initialized(args) -> void:
	emit_signal("initalized")


func initialize(callback: JavaScriptObject = null, catch_callback: JavaScriptObject = null) -> bool:
	if OS.has_feature("JavaScript"):
		if not _check_sdk(): return false
		if is_initialized: return false
		
		_instant_games_bridge_interface.initialize(_generate_bridge_options()) \
			.then(_initialized_cb if callback == null else callback) \
			.catch(_printerr_cb if catch_callback == null else catch_callback)
		
		return true
	else:
		pass
#		printerr("Can't initialize SDK. (Not HTML5?)")
	return false


func _generate_bridge_options() -> JavaScriptObject:
	var options = JavaScript.create_object("Object")
	options.platform = JavaScript.create_object("Object")
	options.platform.vk = ProjectSettings.get_setting("addons/instant_games_bridge/vk/group_id") if ProjectSettings.has_setting("addons/instant_games_bridge/vk/group_id") else 0
	
	return options
