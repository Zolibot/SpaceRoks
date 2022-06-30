extends Node


var win

var _close_fullads = JavaScript.create_callback(self,"close_FullAds")
var _error_fullads = JavaScript.create_callback(self,"error_FullAds")
var _open_fullads = JavaScript.create_callback(self,"open_FullAds")

var _close_rewads = JavaScript.create_callback(self,"close_Rewads")
var _error_rewads = JavaScript.create_callback(self,"error_Rewads")
var _open_rewads = JavaScript.create_callback(self,"open_Rewads")
var _on_rewads = JavaScript.create_callback(self,"on_Rewads")



signal rewarded_close(success)
signal close_full_screen()
signal show_full_screen()

func _ready() -> void:
	if OS.has_feature("JavaScript"):
		# Проверяем начличе SDK. Если null, ждём секунду и повторяем
		while win == null:
			yield(get_tree().create_timer(1), "timeout")
			win = JavaScript.get_interface("window")
			
		print("Ysdk init")
		win.FullClose = _close_fullads
		win.FullError = _error_fullads
		win.FullOpen = _open_fullads 
		
		win.RewardedClose = _close_rewads
		win.RewardedError = _error_rewads
		win.RewardedOpen = _open_rewads
		win.onRewarded = _on_rewads
		
func ShowRewardedAds()->void:
	win.ShowRewarded()
	
func ShowFullScreenAds()->void:
	win.ShowAdFull()
	

## for fullscreen ads
func close_FullAds(args)->void:
	if str(args[0]) == "True":
		emit_signal("close_full_screen")
	pass

func open_FullAds(args)->void:
	#print("Open Full ads")
	emit_signal("show_full_screen")

func error_FullAds(args)->void:
	print("Error fullscreen "+ str(args[0]))

	
# for rewarded sds
func close_RewAds(args)->void:
	pass

func open_RewAds(args)->void:
	pass 

func error_RewAds(args)->void:
	pass
	
func on_Rewads(args)->void:
	pass


	

