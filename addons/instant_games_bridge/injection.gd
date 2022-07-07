extends EditorExportPlugin
class_name InstantGamesBridgeInjection

const CDN_PATH = """\n<script type="text/javascript" src="https://cdn.jsdelivr.net/gh/instant-games-bridge/instant-games-bridge@1.2.1/dist/instant-games-bridge.js"></script>\n"""
const LOCAL_PATH = """\n<script type="text/javascript" src="instant-games-bridge.js"></script>\n"""

var _path = ""
var _is_web = false
var _injected = false

func _export_begin(features: PoolStringArray, is_debug: bool, path: String, flags: int) -> void:
	if Array(features).has("web"):
		_is_web = true
		_path = path
		_injected = false


func _export_end() -> void:
	if not _is_web or _injected:
		return
	
	_injected = true
	
	var includes = ""
	
	if ProjectSettings.has_setting("addons/instant_games_bridge/general/inject_sdk"):
		if ProjectSettings.get_setting("addons/instant_games_bridge/general/inject_sdk"):
			
			var script_path = LOCAL_PATH
			if ProjectSettings.has_setting("addons/instant_games_bridge/general/use_cdn"):
				if ProjectSettings.get_setting("addons/instant_games_bridge/general/use_cdn"):
					script_path = CDN_PATH
				else:
					var dir = Directory.new()
					dir.copy("res://addons/instant_games_bridge/include/instant-games-bridge.js", _path.get_base_dir()+"/instant-games-bridge.js")
			
			includes += script_path
			
	
			if ProjectSettings.has_setting("addons/instant_games_bridge/initialize/initialize_automatically"):
				if ProjectSettings.get_setting("addons/instant_games_bridge/initialize/initialize_automatically"):
					
					var vkId = 0
					if ProjectSettings.has_setting("addons/instant_games_bridge/vk/group_id"):
						vkId = ProjectSettings.get_setting("addons/instant_games_bridge/vk/group_id")
					
					var adv = ""
					if ProjectSettings.has_setting("addons/instant_games_bridge/initialize/show_interstitial_after_init"):
						if ProjectSettings.get_setting("addons/instant_games_bridge/initialize/show_interstitial_after_init"):
							adv = """instantGamesBridge.advertisement.showInterstitial().then(() => {}).catch(error => {})"""
					
					includes += """
					<script>
						let bridgeOptions = {
							platforms: {
								vk: {
									groupId: %d
								}
							}
						}
						
						instantGamesBridge.initialize(bridgeOptions)
							.then(() => {
								%s
							})
							.catch(error => {
								
							})
					</script>
					""" % [vkId, adv]
	
	if not includes.empty():
		var file = File.new()
		var err = file.open(_path, File.READ_WRITE) 
		if err == OK:
			var src = file.get_as_text()
			var pos = src.find("</head>")
			if pos != -1:
				src = src.insert(pos, includes)
				file.seek(0)
				file.store_string(src)
			file.close()
	
	_path = ""
	_is_web = false
