extends Control

class_name PopUpInGame

@onready var _container : PanelContainer = $PanelContainer
@onready var _buttons : VBoxContainer  = $PanelContainer/VBoxContainer
@onready var _popup : PackedScene    = null
var capture : Image = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not _popup:
		_popup  = preload("res://ui/PopupInfo.tscn")

	for ui in _buttons.get_children():
		ui.connect("mouse_entered", _on_mouse_entered)

func _close() -> void:
	get_tree().paused = false
	visible = false
	capture = null

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
				_close()
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

func _on_mouse_entered() -> void:
	SFX.play_hover()

func _on_btn_reanudar_pressed() -> void:
	SFX.play_click()
	_close()

func _on_btn_guardar_pressed() -> void:
	SFX.play_click()
	if GameState.current():
		GameState.current().save_game(capture)

func _on_btn_guardar_salir_pressed() -> void:
	SFX.play_click()
	if GameState.current():
		GameState.current().save_game(capture)
	_load_scene_thread("res://ui/MenuPrincipal.tscn", "Cerrando...")

func _on_btn_terminar_pressed() -> void:
	SFX.play_click()
	# A lo mejor queremos mostrar un popup indicando que la partida no está
	# guardada y que confirme si quiere salir o no
	_load_scene_thread("res://ui/MenuPrincipal.tscn", "Cerrando...")

func _on_btn_exit_pressed() -> void:
	SFX.play_click()
	# A lo mejor queremos mostrar un popup para que el usuario ocnfirme
	_close()
	get_tree().call_deferred("quit")
