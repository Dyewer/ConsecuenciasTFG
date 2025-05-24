extends Control

@onready var _popup : PackedScene = null
@onready var points : Label  = $ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2/VBoxContainer/HBoxContainer/TextureRect2/points
@onready var start  : Button = $ScrollContainer/VBoxContainer/ButtonContainer/BtnStart

@onready var at_dex : BtnAtributo = $ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_attributes/DESTREZA
@onready var at_int : BtnAtributo = $ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_attributes/INTELIGENCIA
@onready var at_fis : BtnAtributo = $ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_attributes/FISICO
@onready var at_pod : BtnAtributo = $ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_attributes/PODER
@onready var at_per : BtnAtributo = $ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_attributes/PERCEPCION
@onready var at_mor : BtnAtributo = $ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_attributes/MORAL

func _ready() -> void:
	start.disabled = true
	var contenedor = $ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_attributes
	for nodo in contenedor.get_children():
		if nodo is BtnAtributo and nodo.name != "MORAL":
			nodo.less.connect(Callable(self, "_less").bind(nodo))
			nodo.more.connect(Callable(self, "_more").bind(nodo))
			nodo.get_node("less").disabled = true
	if not _popup:
		_popup  = preload("res://ui/PopupInfo.tscn")
	_initialize_attributes_from_game_data(GameState.current())

func _initialize_attributes_from_game_data(game_data : GameData) -> void:
	if game_data != null:
		at_dex._set_value(game_data.character.atributos.destreza)
		at_int._set_value(game_data.character.atributos.inteligencia)
		at_fis._set_value(game_data.character.atributos.fisico)
		at_pod._set_value(game_data.character.atributos.poder)
		at_per._set_value(game_data.character.atributos.percepcion)
		# at_mor._set_value(5)
		# Llamar a _set_value lanza la señal "less" o "more" de cada botón lo que
		# desencadena la actualización visual de cada botón, deshabilitado o
		# habilitado de los mismos, etc...

func _update_game_data() -> void:
	var game_data : GameData = GameState.current()
	if game_data == null:	# ESTO NO DEBERIA OCURRIR NUNCA
		game_data = GameState.start_new_game()
	# Almacenamos en el objeto los datos hasta ahora cargados
	game_data.character.atributos.destreza     = at_dex.value
	game_data.character.atributos.inteligencia = at_int.value
	game_data.character.atributos.fisico       = at_fis.value
	game_data.character.atributos.poder        = at_pod.value
	game_data.character.atributos.percepcion   = at_per.value
	game_data.character.atributos.moral        = at_mor.value

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
	_update_game_data()
	_load_scene_thread("res://ui/NuevaPartida.tscn", "Cargando...")
	SFX.play_click()

func _on_btn_start_pressed() -> void:
	_update_game_data()
	Tools.fade_out(self)
	_load_scene_thread("res://levels/World.tscn",  "Cargando...")
	SFX.play_click()

func _less(origen : BtnAtributo) -> void:
	if origen.value == 1:
		origen.get_node("less").disabled = true
	if origen.value < 5:
		origen.get_node("more").disabled = false
	var used : int = at_dex.value + at_int.value + at_fis.value + at_pod.value + at_per.value
	points.set_value(15 - used)
	_enable_btns()

func _more(origen : BtnAtributo) -> void:
	if origen.value == 5:
		origen.get_node("more").disabled = true
	if origen.value > 1 :
		origen.get_node("less").disabled = false
	var used : int = at_dex.value + at_int.value + at_fis.value + at_pod.value + at_per.value
	points.set_value(15 - used)
	_disable_btns()

func _disable_btns() -> void:
	if points.avaliable == 0:
		start.disabled = false
		var contenedor = $ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_attributes
		for nodo in contenedor.get_children():
			if nodo is BtnAtributo and nodo.name != "MORAL":
				nodo.get_node("more").disabled = true

func _enable_btns() -> void:
	if points.avaliable > 0:
		start.disabled = true
		var contenedor = $ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer_attributes
		for nodo in contenedor.get_children():
			if nodo is BtnAtributo and nodo.name != "MORAL":
				if nodo.value < 5:
					nodo.get_node("more").disabled = false
