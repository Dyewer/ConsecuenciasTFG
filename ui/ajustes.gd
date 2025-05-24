extends Control

@onready var _popup  : PackedScene = null
@onready var saved : bool = true
@onready var save_dialog := $GuardarCambios
@onready var sound : UISound = $TabContainer/Sonido
@onready var graphics : UIGraphics = $TabContainer/Graficos
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sound.settings_changed.connect(_on_settings_changed)
	graphics.settings_changed.connect(_on_settings_changed)
	var arrayList : Dictionary = DB.getViewConfiguration()
	var vectorString = arrayList["resolution"].split("x")
	var vector : Vector2i = Vector2i(int(vectorString[0]),int(vectorString[1]))
	
	for i in graphics.resolution.size():
		if graphics.resolution[i] == vector:
			graphics.resolutionButton.select(i)
			break
	
	graphics.qualityButton.select(arrayList["quality"])
	graphics.screenMode.select(arrayList["fullscreen"])
	
	for i in graphics.refresh_rate.size():
		if graphics.refresh_rate[i] == arrayList["refresh"]:
			graphics.refreshButton.select(i)
			break
	
	graphics.synchronizationButton.set_pressed_no_signal(arrayList["synch"])
	sound.general.set_value(arrayList["general"])
	
	# Falta añadir el resto de modificaciones a los ajustes de sonido
	

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
	var arrayListGraphics : Dictionary = {
		"resolution" : graphics.resolutionButton.get_item_text(graphics.resolutionButton.selected),
		"quality" : graphics.qualityButton.selected,
		"fullscreen" : graphics.screenMode.selected,
		"refresh" : graphics.refresh_rate[graphics.refreshButton.selected],
		"synch" : int(graphics.synchronizationButton.button_pressed)
	}
	var arrayListSound : Dictionary = {
		"general" : sound.general.value,
		"music" : 100,
		"environment" : 100,
		"effects" : 100,
		"combat" : 100
	}
	
	DB.updateConfig(arrayListGraphics, arrayListSound)
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
	_back_to_menu()
