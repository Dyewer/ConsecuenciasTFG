extends Control

@onready var _titulo : Label             = $Titulo
@onready var _popup  : PackedScene       = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not _popup:
		_popup  = preload("res://ui/PopupInfo.tscn")
	_titulo.text = ProjectSettings.get_setting("application/config/name")
	Tools.fade_in(self)

func _load_scene_thread(path : String, text : String = ""):
	var sl = SceneLoader.new()
	if text.length() > 0:
		var popup = _popup.instantiate() as UIPopupInfo
		popup.ready.connect(func(): _show_popup(popup, text))
		add_child(popup)
		sl.ready.connect(func():
			sl.load_scene(path, func():
				popup.hide()
				popup.queue_free()
				sl.queue_free()
			))
	else:
		sl.ready.connect(func():
			sl.load_scene(path, func():
				sl.queue_free()
			))
	add_child(sl)

func _show_popup(popup : UIPopupInfo, text : String) -> void:
	if not popup:
		return
	popup.size = Vector2i(int(size.x / 4), int(size.y / 5))
	popup.text = text
	popup.popup_centered()

func _on_btn_new_game_pressed() -> void:
	SFX.play_click()
	_load_scene_thread("res://ui/NuevaPartida.tscn")

func _on_btn_settings_pressed() -> void:
	SFX.play_click()
	_load_scene_thread("res://ui/ajustes.tscn") # Replace with function body.

func _on_btn_quit_pressed() -> void:
	SFX.play_click()
	var tween = Tools.fade_out(self, 1.0)
	if tween:
		tween.tween_callback(Callable(self, "_quit_game"))

func _on_btn_mouse_entered() -> void:
	SFX.play_hover()

func _quit_game() -> void:
	get_tree().call_deferred("quit")
