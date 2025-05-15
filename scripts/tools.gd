extends Node

var _timestamp : String = ""

func _ready() -> void:
	_timestamp = Time.get_datetime_string_from_system(false). \
				replace(":", "").replace("-", "_").replace("T", " ")

func crear_click_mask_desde_textura(textura: Texture2D, path: String) -> Error:
	var imagen = textura.get_image()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(imagen, 0.1)  # Umbral de opacidad (0.0 a 1.0)
	return ResourceSaver.save(bitmap, "res://"+path+".res")

func dame_game_version_string() -> String :
	return ProjectSettings.get_setting("application/config/name") + \
			" v" + ProjectSettings.get_setting("application/config/version") + \
			" " + _timestamp

func fade_in(node : Node) -> Tween:
	if not node:
		return null
	# Empieza transparente
	node.modulate.a = 0.0
	# Creamos una animación
	var tween = create_tween()
	tween.tween_interval(GlobalDefs.UI_IN_TIME)
	tween.tween_property(node, "modulate:a", 1.0, GlobalDefs.UI_FADEIN_TIME)
	tween.tween_interval(GlobalDefs.UI_PAUSE_TIME)
	return tween

func fade_out(node : Node, fade_time : float = GlobalDefs.UI_FADEIN_TIME) -> Tween:
	if not node:
		return null
	# Creamos una animación
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, fade_time)
#	tween.tween_callback(Callable(get_tree(), "quit"))
	return tween
