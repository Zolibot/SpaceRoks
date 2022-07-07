class_name InstantGamesBridgePlatform
extends Reference

var _interface: JavaScriptObject

func _init(interface: JavaScriptObject) -> void:
	_interface = interface


var id: String setget , _id_getter
func _id_getter() -> String:
	return _interface.id if _interface != null else "mock"

var sdk: JavaScriptObject setget , _sdk_getter
func _sdk_getter() -> JavaScriptObject:
	return _interface.sdk if _interface != null else null

var language: String setget , _language_getter
func _language_getter() -> String:
	return _interface.language if _interface != null else "en"

var payload: String setget , _payload_getter
func _payload_getter() -> String:
	return _interface.payload if _interface != null else ""
