extends PopupPanel
class_name UIPopupInfo

const min_font_size : int = 8
const max_font_size : int = 300
const max_num_lines : int = 15

var text : String = "" :
	get : return info.text
	set(value) : _set_text(value)

@onready var info      : Label = $PanelContainer/Texto
@onready var container : PanelContainer = $PanelContainer

var _pending_text : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _pending_text.length():
		info.text = _pending_text
		_set_contents_size()

func _set_text(value : String) -> void:
	_pending_text = value
	if info:
#		_pending_text = ""
		info.text = value
		_set_contents_size()

func _set_contents_size() -> void:
	if not info or not info.text or info.text.length() == 0:
		return
	# 1. Obtener la fuente desde el Theme del TextButton
	var font = get_theme_font("font")
	if not font:
		return
	# 2. Almacenamos el texto que tiene el label actualmente
	var texto = info.text
	# 3. Obtener el tamaño disponible
	var pc_size = container.get_rect().size
	# 3.1 Obtenemos los margenes puestos por el contenedor (el tamaño de los bordes)
	var sbox    = container.get_theme_stylebox("panel")
	var margin  = (sbox.content_margin_left + sbox.content_margin_right)
	# 3.2 Si el tamaño de los márgenes no ocupa mucho en relación con el ancho
	#     total del contenedor, los aplicamos.
	if margin < (0.3 * pc_size.x):
		pc_size.x -= 2 * margin
	
	# 4. Calculamos el tamaño de fuente máximo que hace que el texto nos quepa
	var font_size = min_font_size
	# 4.1 Intentamos aumentar el tamaño de la fuente mientras que el texto
	#     encaje en el área disponible
	while font_size <= max_font_size:
		var text_size = font.get_multiline_string_size(texto,
							HORIZONTAL_ALIGNMENT_CENTER,
							-1, font_size, max_num_lines)
		if text_size.x > pc_size.x or text_size.y > pc_size.y:
			# El tamaño del texto se sale de sus límites. Salimos del bucle
			break
		font_size += 1
	# 5. Usamos el último tamaño válido (por eso -1)
	font_size = max(font_size - 1, min_font_size)
	# 6. Asignamos el nuevo tamaño de la fuente al Label y recuperamos su texto
#	info.text = texto
	info.add_theme_font_size_override("font_size", font_size)
