extends Node
class_name CurrentGame

# Este nodo almacena la información relativa a la partida en curso, de manera
# que al pedir grabar, se pueda alamcenar en BBDD la información de la misma
var game_name    : String   = "Nueva partida"
var created_time : DateTime = null
var last_saved   : DateTime = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	created_time = DateTime.now()

func new_game(nombre : String) -> void:
	created_time = DateTime.now()
	game_name    = nombre

# Guarda la partida en curso
func save_game() -> void:
	last_saved = DateTime.now()
	pass
