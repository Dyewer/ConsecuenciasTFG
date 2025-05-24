extends Node3D
class_name CameraRig

@export var target : Node3D = null
@export_range(1.0, 5.0) var follow_speed : float  = 2.0

# Creamos grupo zoom para englobar nuestras variables
@export_group("Zoom")
# Limitamos los saltos del zoom para que no salte al minimo y al maximo
# de una vez
@export_range(10, 40) var zoom_step : int   = 20
# Distancia minima de la camara al jugador
@export var min_zoom_distance : float = 50.0
# Distancia máxima de la camara al jugador
@export var max_zoom_distance : float = 200.0

# Añadido renderizado de distancia a la camara para seguir dibujando
# los assets desde mas lejos
@export_group("Renderizado")
@export_range(100.0, 5000.0) var far_clip_distance: float = 5000.0

@onready var pivot : Node3D   = $Pivot
@onready var tilt : Node3D   = $Pivot/Tilt
@onready var camera : Camera3D = $Pivot/Tilt/Camera3D

var _sensitivity : float = GlobalDefs.MOUSE_SENSITIVIY
# Ángulo inicial de la cámara
var _tilt_angle : float = deg_to_rad(45.0) 
var _camera_position : Vector3

# Velocidad de movimiento de la camara
const CAM_ROT_SPEED  : float = 1.5
const CAM_TILT_SPEED : float = 1.0
const CAM_ZOOM_SPEED : float = 5.0

func _ready() -> void:
	_camera_position = camera.position
	if target is Player:
		# Ralentizamos la velocidad de la camara
		follow_speed = target.SPEED / 2.0

func _process(delta) -> void:
	if not target:
		return
	global_position = global_position.lerp(target.global_position, delta * follow_speed)

	var curr_cam_pos : Vector3 = camera.position.lerp(_camera_position, delta * CAM_ZOOM_SPEED)
	camera.position = curr_cam_pos

func rotate_camera(relative : Vector2) -> void:
	pivot.rotate_y(relative.x * _sensitivity)
	
	var new_tilt = tilt.rotation.x + relative.y * _sensitivity
	new_tilt = clamp(new_tilt, deg_to_rad(10), deg_to_rad(85))
	tilt.rotation.x = new_tilt

func _zoom_camera(delta: float):
	# La cámara está desplazada en el eje z negativo, por tanto, clampf debe
	# cambiar los signos de los valores min y max y el orden
	var new_z = clampf(camera.position.z + delta, -max_zoom_distance, -min_zoom_distance)
	_camera_position.z = new_z
	

func zoom_in_camera():
	_zoom_camera(zoom_step)

func zoom_out_camera():
	_zoom_camera(-zoom_step)
