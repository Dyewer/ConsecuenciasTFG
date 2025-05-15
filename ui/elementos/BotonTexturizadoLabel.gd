@tool
extends TextureButton

@export var text: String :
	get: return _text
	set(value): _set_label_text(value)

@export var min_font_size : int    = 8
@export var max_font_size : int    = 120

@onready var label : Label = $Texto

# La variable que guarda el texto del botón.
# No usamos directamente la de Label porque los cambios en el editor NO se
# reflejan en runtime. Esto es porque el valor de los nodos hijos no se guarda
# como parte del script que exportas, sino como parte del recurso de la escena
var _text : String = ""

# Con esto conseguimos que la variable _text se guarde al exportar el proyecto
func _get_property_list() -> Array:
	return [{
		"name"  : "_text",
		"type"  : TYPE_STRING,
		"usage" : PROPERTY_USAGE_STORAGE
	}]

func _ready() -> void:
	_set_label_text(text)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED or what == NOTIFICATION_THEME_CHANGED:
		update_font_size()

# Cambia el texto del botón
func _set_label_text(value : String) -> void:
	_text = value
	if label:
		label.text = value
		if value.length() > 0:
			update_font_size()

# Esta función ajusta el tamaño de la fuente del texto
func update_font_size():
	if not label or not label.text or label.text.length() == 0:
		return
	# 1. Obtener la fuente desde el Theme del TextButton
	var font = get_theme_font("font")
	if not font:
		return
	# 2. Almacenamos el texto que tiene el label actualmente
	var texto = label.text
	# 3. Obtener el tamaño disponible
	# 3.1 Limpiamos el texto actual del label, y cambiamos el tamaño de fuente
	#     actual al mínimo, porque puede modificar el tamaño del rect que lo
	#     contiene si es muy grande y nos estropearía saber el tamaño del que
	#     disponemos.
	label.text = ""
	label.add_theme_font_size_override("font_size", min_font_size)
	# 3.2 Cogemos el tamaño disponible para el label
	var lbl_size = label.get_rect().size
	# 4. Calculamos el tamaño de fuente máximo que hace que el texto nos quepa
	var font_size = min_font_size
	# 4.1 Intentamos aumentar el tamaño de la fuente mientras que el texto
	#     encaje en el área disponible
	while font_size <= max_font_size:
		var text_size = font.get_multiline_string_size(texto, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, 1)
		if text_size.x > lbl_size.x or text_size.y > lbl_size.y:
			# El tamaño del texto se sale de sus límites. Salimos del bucle
			break
		font_size += 1
	# 5. Usamos el último tamaño válido (por eso -1)
	font_size = max(font_size - 1, min_font_size)
	# 6. Asignamos el nuevo tamaño de la fuente al Label y recuperamos su texto
	label.text = texto
	label.add_theme_font_size_override("font_size", font_size)
