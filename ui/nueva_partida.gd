extends Control

@onready var _popup       : PackedScene       = null
@onready var _3d_view     : UINewPC      = $SubViewportContainer/SubViewport/NuevoPJ
@onready var _mesh_opt    : OptionButton = $AspectRatioContainer/VBoxContainer/MeshContainer/OBMesh
@onready var _skin_opt    : OptionButton = $AspectRatioContainer/VBoxContainer/SkinContainer/OBSkin
@onready var _clothes_opt : OptionButton = $AspectRatioContainer/VBoxContainer/ClothesContainer/OBClothes
@onready var _te_name     : TextEdit     = $AspectRatioContainer/VBoxContainer/TENombre
@onready var _btn_back    : Button       = $ButtonContainer/BtnBack
@onready var _btn_next    : Button       = $ButtonContainer/BtnNext

var _mesh_list : Array[GlobalDefs.CharacterType] = [
	GlobalDefs.CharacterType.PEASANT_01,
	GlobalDefs.CharacterType.PEASANT_02,
	GlobalDefs.CharacterType.PEASANT_03
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not _popup:
		_popup  = preload("res://ui/PopupInfo.tscn")

	_fill_mesh_options()
	_fill_skin_options()
	_fill_clothes_options()

	# Asigna el tamaño de los textos de los botones de abajo al mismo que el de
	# los elementos verticales
	var framed : UIFramedElement = $AspectRatioContainer/VBoxContainer/MeshContainer/Mesh
	_btn_back.add_theme_font_size_override("font_size", framed.label.get_theme_font_size("font_size"))
	_btn_next.add_theme_font_size_override("font_size", framed.label.get_theme_font_size("font_size"))
	_te_name.add_theme_font_size_override("font_size", framed.label.get_theme_font_size("font_size"))

	_initialize_character_from_game_data(GameState.current())

func _fill_mesh_options() -> void:
	_mesh_opt.clear()
	_mesh_opt.add_item("Aurora")
	_mesh_opt.add_item("Almudena")
	_mesh_opt.add_item("Leonardo")
	_on_ob_mesh_item_selected(0)

func _fill_skin_options() -> void:
	_skin_opt.clear()
	for skin in Character.TezStr:
		_skin_opt.add_item(skin)

func _fill_clothes_options() -> void:
	_clothes_opt.clear()
	for look in Character.LooksStr:
		_clothes_opt.add_item(look)

func _select_random_character() -> void:
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()

	var mesh_idx  = rnd.randi_range(0, _mesh_list.size() - 1)
	var skin_idx  = rnd.randi_range(0, _skin_opt.item_count - 1)
	var cloth_idx = rnd.randi_range(0, _clothes_opt.item_count - 1)
	_mesh_opt.select(mesh_idx)
	_skin_opt.select(skin_idx)
	_clothes_opt.select(cloth_idx)

	_on_ob_mesh_item_selected(_mesh_opt.selected)
	_update_pj_texture(skin_idx, cloth_idx)

func _initialize_character_from_game_data(game_data : GameData) -> void:
	if game_data != null:
		_te_name.text = game_data.character.nombre
		_mesh_opt.select(game_data.character.type - GlobalDefs.CharacterType.PEASANT_01)
		_skin_opt.select(game_data.character.tez)
		_clothes_opt.select(game_data.character.looks)
		# Actualizamos el estado del botón "continuar" y apariencia en vista 3D
		_on_te_nombre_text_changed()
		_on_ob_mesh_item_selected(_mesh_opt.selected)
		_update_pj_texture(_skin_opt.selected, _clothes_opt.selected)
	else:
		_select_random_character()

func _update_or_create_game_data() -> void:
	var game_data : GameData = GameState.current()
	if game_data == null:
		game_data = GameState.start_new_game()
	# Almacenamos en el objeto los datos hasta ahora cargados
	game_data.character.nombre = _te_name.text
	game_data.character.type   = _mesh_opt.selected + GlobalDefs.CharacterType.PEASANT_01
	game_data.character.tez    = _skin_opt.selected
	game_data.character.looks  = _clothes_opt.selected

func _update_pj_texture(skn_idx: int, clth_idx: int) -> void:
	var idx = 3 * clth_idx + skn_idx
	if idx >= 0 and idx < GlobalDefs.CharacterLook.LOOK_EMISSIVE:
		_3d_view.npc.looks = idx

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

func _on_ob_mesh_item_selected(index: int) -> void:
	if index >= 0 and index < _mesh_list.size():
		_3d_view.npc.type = _mesh_list[index]

func _on_ob_skin_item_selected(index: int) -> void:
	_update_pj_texture(index, _clothes_opt.selected)

func _on_ob_clothes_item_selected(index: int) -> void:
	_update_pj_texture(_skin_opt.selected, index)

func _on_mouse_entered() -> void:
	SFX.play_hover()

func _on_btn_back_pressed() -> void:
	SFX.play_click()
	_load_scene_thread("res://ui/MenuPrincipal.tscn")

func _on_btn_start_pressed() -> void:
	SFX.play_click()
	Tools.fade_out(self)
	# Creamos una instancia de "nueva partida" si no existe y actualizamos los datos
	_update_or_create_game_data()
	# Cargamos la nueva escena
	_load_scene_thread("res://ui/atributos.tscn", "Cargando...")

func _on_te_nombre_text_changed() -> void:
	_btn_next.disabled = (_te_name.text.length() == 0)
