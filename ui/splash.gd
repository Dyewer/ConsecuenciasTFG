extends Control

@export var load_scene : PackedScene = null
@export var inout_time : float = GlobalDefs.UI_IN_TIME
@export var fade_time  : float = GlobalDefs.UI_FADEIN_TIME
@export var pause_time : float = GlobalDefs.UI_PAUSE_TIME

@onready var small_info : Label = $FooterContainer/FooterMargins/SmallInfo

var _load_complete : bool        = false
var _loaded_scene  : PackedScene = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	small_info.text  = Tools.dame_game_version_string()
	# Inicia la carga en segundo plano
	ResourceLoader.load_threaded_request(load_scene.resource_path)
	fadein()

func _process(_delta):
	if not _load_complete:
		var status = ResourceLoader.load_threaded_get_status(load_scene.resource_path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			_loaded_scene = ResourceLoader.load_threaded_get(load_scene.resource_path)
			if _loaded_scene:
				_load_complete = true
	else:
		_load_complete = false
		fadeout()

func fadein() -> void:
	# Empieza transparente
	self.modulate.a = 0.0
	# Creamos una animación
	var tween = create_tween()
	tween.tween_interval(inout_time)
	tween.tween_property(self, "modulate:a", 1.0, fade_time)
	tween.tween_interval(pause_time)

func fadeout() -> void:
	# Creamos una animación
	var tween = create_tween()
	tween.tween_interval(pause_time)
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	tween.tween_interval(inout_time)
	tween.tween_callback(Callable(self, "_on_fade_finished"))

func _on_fade_finished() -> void:
	# Cargamos la escena que nos piden
	if _loaded_scene:
		get_tree().change_scene_to_packed(_loaded_scene)
