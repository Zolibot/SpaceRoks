class_name InstantGamesBridgeSocial
extends Reference

var _interface: JavaScriptObject

var _printerr_cb = JavaScript.create_callback(self, "printerr")


func _init(interface: JavaScriptObject) -> void:
	_interface = interface

var is_share_supported: bool setget , _is_share_supported_getter
func _is_share_supported_getter() -> bool:
	return _interface.isShareSupported if _interface != null else false

var is_community_supported: bool setget , _is_community_supported_getter
func _is_community_supported_getter() -> bool:
	return _interface.isCommunitySupported if _interface != null else false

var is_invite_friends_supported: bool setget , _is_invite_friends_supported_getter
func _is_invite_friends_supported_getter() -> bool:
	return _interface.isInviteFriendsSupported if _interface != null else false


func share(callback: JavaScriptObject = null, catch_callback: JavaScriptObject = null) -> void:
	if _interface == null: return
	
	_interface.share() \
		.then(callback) \
		.catch(catch_callback if catch_callback != null else _printerr_cb)


func join_community(callback: JavaScriptObject = null, catch_callback: JavaScriptObject = null) -> void:
	if _interface == null: return 
	
	_interface.joinCommunity() \
		.then(callback) \
		.catch(catch_callback if catch_callback != null else _printerr_cb)


func invite_friends(callback: JavaScriptObject = null, catch_callback: JavaScriptObject = null) -> void:
	if _interface == null: return
	
	_interface.inviteFriends() \
		.then(callback) \
		.catch(catch_callback if catch_callback != null else _printerr_cb)
