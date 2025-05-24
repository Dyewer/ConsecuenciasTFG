extends Node
class_name GameData

# Este nodo almacena la información relativa a la partida en curso, de manera
# que al pedir grabar, se pueda alamcenar en BBDD la información de la misma
var game_name    : String    = "Nueva partida"
var created_time : DateTime  = null
var last_saved   : DateTime  = null
var character    : Character = null

# Called when the node enters the scene tree for the first time.
func init() -> void:
	created_time = DateTime.now()
	character    = Character.new()
	character.init()

# Guarda la partida en curso
func save_game(capture : Image) -> void:
	last_saved = DateTime.now()
	# Necesitamos obtener el nombre de la paetida antes de grabar: Nueva UI
	# que muestre un listado con todas las partidas guardadas y que permita
	# sobreescribir, borrar, añadir nueva partida.
	DB.saveGame(capture, "nombre_partida")
