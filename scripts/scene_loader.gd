# Script que se encarga de cargar una escena usando un hilo, lo que nos permite
# mostrar información mientras se procesa la carga. Además nos notifica del
# final de carga (con éxito) mediante una señal o una callback que le pasemos
extends Node
class_name SceneLoader

# Creamos un tipo enumerado para saber el estado de carga de la escena
enum LoadStatus {
	IDLE = 0,
	LOADING = 1,
	LOADED = 2
}

# Ruta y nombre de la escena a cargar
var _scene_path : String     = ""
# Estado de la carga
var _status     : LoadStatus = LoadStatus.IDLE
# Función callback a llamar cuando se termine de cargar la escena
var _on_end     : Callable   = Callable()
# Señal que se emite cuando se termina de cargar de la escena
signal on_loaded

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Comprobamos el estado de la carga (si aplica) y cuando haya terminado
# cambiamos el estado de la carga.
func _process(_delta: float) -> void:
	# Si estamos cargando una escena, comprobamos si ya ha terminado de cargar
	# y actualizamos el _status.
	if _status == LoadStatus.LOADING:
		var status = ResourceLoader.load_threaded_get_status(_scene_path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			_status = LoadStatus.LOADED
	# Si la escena ya se ha cargado, comprobamos que hay escena cargada y si la
	# hay, emitimos señal de escena cargada, llamamos a la callable si nos han
	# pasado una en la función load_scene() y finalmente cambiamos a la escena.
	elif _status == LoadStatus.LOADED:
		var scene = ResourceLoader.load_threaded_get(_scene_path)
		if scene:
			emit_signal("on_loaded")
			if _on_end.is_valid():
				_on_end.call()
			get_tree().change_scene_to_packed(scene)
		_status = LoadStatus.IDLE
	# Si no estamos cargando escena dejamos de procesar (de llamar a esta
	# función _process(_delta), para no sobrecargar el sistema innecesariamente
	elif _status == LoadStatus.IDLE:
		set_process(true)

# Cargamos la escena indicada en path en segundo plano. Si nos pasan una función
# (on_end) nos la guardamos para invocarla cuando terminemos de cargar la escena.
func load_scene(path : String, on_end : Callable = Callable()):
	# Sólo si no estábamos ocupados cargando una escena hacemos caso.
	if _status == LoadStatus.IDLE:
		# Guardamos la ruta de la escena a cargar
		_scene_path = path
		# Si nos han pasado una función como segundo parámetro, lo guardamos
		if on_end.is_valid():
			_on_end = on_end
		else:
			_on_end = Callable()
		# Comenzamos la carga en segundo plano de la escena. Si es correcto,
		# cambiamos el estado a "LOADING" y reactivamos la función _process()
		# que el sistema llama cada frame del juego
		if ResourceLoader.load_threaded_request(path) == OK:
			_status = LoadStatus.LOADING
			set_process(true)
