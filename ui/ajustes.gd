extends Control

@onready var _popup  : PackedScene = null
@onready var saved : bool = true
@onready var save_dialog := $GuardarCambios

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sound = $TabContainer/Sonido
	sound.settings_changed.connect(_on_settings_changed)
	var graphics = $TabContainer/Graficos
	graphics.settings_changed.connect(_on_settings_changed)

func _on_settings_changed():
	saved = false
	print("Ajustes modificados")

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


func _on_btn_back_pressed() -> void:
	_save_data()
	SFX.play_click()

func _back_to_menu() -> void:
	SFX.play_click()
	_load_scene_thread("res://ui/MenuPrincipal.tscn")

func _on_btn_save_pressed() -> void:
	saved = true
	_save_on_DB()
	SFX.play_click()

func _save_on_DB() -> void:
	#Guardar cambios en la base de datos
	print("Guardando en base de datos")
	pass

func _save_data() -> void:
	if saved :
		_load_scene_thread("res://ui/MenuPrincipal.tscn")
	else :
		save_dialog.dialog_text = "¿Deseas guardar los cambios antes de salir?"
		save_dialog.popup_centered()

func _on_save_changes_confirmed() -> void:
	print("Datos guardados")
	_save_on_DB()
	_back_to_menu()


func _on_save_changes_canceled() -> void:
	print("Datos NO guardados")
