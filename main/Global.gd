extends Node

var _initialized_cb = JavaScript.create_callback(self, "_initialized")
var _get_data_cb = JavaScript.create_callback(self, "_apply_data")
var _set_data_cb = JavaScript.create_callback(self, "_saved")

var _adv
var _platform
var _game

var score = 0
var record = 0
var playing = false

signal pull_data(data)
signal set_game_pause()
signal close_full_screen()

var trriger_sound:bool = false


func _input(event: InputEvent):
    if OS.get_name() == "HTML5":
        if event.is_action_pressed("f5"):
            JavaScript.eval("window.location.reload();")

func tab_Open():
    AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), trriger_sound)

func tab_Close():
    AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

func _ready() -> void:
    if OS.has_feature("JavaScript"):
        logger("Init YSDK")
        if InstantGamesBridge.settings.initialize_automaticly:
            logger("Initialize automaticly: true")
            # In case the sdk has not had time to initialize yet
            while not InstantGamesBridge.is_initialized:
                yield(get_tree(), "idle_frame")
            _game = InstantGamesBridge.game
            _adv = InstantGamesBridge.advertisement
            _adv.set_minimum_delay_between_interstitial(60)
            _adv.connect("interstitial_state_changed", self, "_interstitial_state_changed")
            _adv.connect("rewarded_state_changed", self, "_rewarded_state_changed")
            logger("Init END")
            data_load()
        
#	# Init automaticly
#	if InstantGamesBridge.settings.initialize_automaticly:
#		logger("Initialize automaticly: true")
#
#		# In case the sdk has not had time to initialize yet
#		while not InstantGamesBridge.is_initialized:
#			yield(get_tree(), "idle_frame")
#
#		_initialized()
#
#	else:
#		# Init manual with signal
#		logger("Run manual init")
#
#		if InstantGamesBridge.initialize():
#			InstantGamesBridge.connect("initalized", self, "_initialized")
#			return
#		else:
#			logger("Can't initialized")
#			return

#		# Or use callback
#		logger("Try alternative init")
#
#	if !InstantGamesBridge.initialize(_initialized_cb):
#		logger("Already Initialized")


func _initialized() -> void:
    logger("Initialized")
    logger("\nPLATFORM:")
    _check_platform_info()
    logger("\nGAME:")
    

func _check_platform_info() -> void:
    _platform = InstantGamesBridge.platform
    logger("ID: " + _platform.id)
    logger("Lang: " + _platform.language)
    logger("SDK: " + str(_platform.sdk))
    logger("Payload: " + str(_platform.payload))


func data_save(value:int):
    _game.set_data("score", value, _set_data_cb)
    yield(get_tree().create_timer(0.2),"timeout")


func data_load()->void:
    _game.get_data("score", _get_data_cb)


func _apply_data(args) -> void:
    #print("Data is: "+ str(args[0]))
    if str(args[0]) == "Null":
        data_save(0)
        yield(get_tree().create_timer(0.2),"timeout")
        data_load()
    else:
        emit_signal("pull_data",int(args[0]))


func _saved(args) -> void:
    logger("Data was saved")


func _show_interstitial() -> void:
    _adv.show_interstitial(false)


func _interstitial_state_changed(state: String):
    logger("New Inter State: " + state)
     
    if state == InterstitialState.OPENED and playing:
        emit_signal("set_game_pause")
    
    if state == InterstitialState.FAILED:
       pass
    
    if state == InterstitialState.CLOSED and playing:
        emit_signal("close_full_screen")


func _rewarded_state_changed(state: String):
    logger("New Reward State: " + state)
    
    if state == RewardState.REWARDED:
        pass

func logger(text):
    #print(text)
    pass
    #$logger.add_text(str(text) + '\n')
