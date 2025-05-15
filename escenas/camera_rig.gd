extends Node3D
class_name CameraRig

@export                 var target            : Node3D = null
@export_range(1.0, 5.0) var follow_speed      : float  = 2.0

@export_group("Zoom")
@export_range(10, 40) var zoom_step         : int   = 20
@export               var min_zoom_distance : float = 50.0
@export               var max_zoom_distance : float = 200.0

@onready var pivot  : Node3D   = $Pivot
@onready var tilt   : Node3D   = $Pivot/Tilt
@onready var camera : Camera3D = $Pivot/Tilt/Camera3D

var _sensitivity     : float = GlobalDefs.MOUSE_SENSITIVIY
var _tilt_angle      : float = deg_to_rad(45.0) # Ángulo inicial de la cámara
var _camera_position : Vector3

const CAM_ROT_SPEED  : float = 1.5
const CAM_TILT_SPEED : float = 1.0
const CAM_ZOOM_SPEED : float = 5.0

func _ready() -> void:
	_camera_position = camera.position
	if target is Player:
		follow_speed = target.SPEED / 2.0

func _process(delta) -> void:
	if not target:
		return
	global_position = global_position.lerp(target.global_position, delta * follow_speed)

	var curr_cam_pos : Vector3 = camera.position.lerp(_camera_position, delta * CAM_ZOOM_SPEED)
#	curr_cam_pos = curr_cam_pos.lerp(_camera_position, delta * CAM_ZOOM_SPEED)
	camera.position = curr_cam_pos
#	camera.postion = camera.position.lerp(_camera_position, delta * zoom_speed)

func rotate_camera(relative : Vector2) -> void:
	pivot.rotate_y(relative.x * _sensitivity)
	var new_tilt = tilt.rotation.x + relative.y * _sensitivity
	new_tilt = clamp(new_tilt, deg_to_rad(10), deg_to_rad(85))
	tilt.rotation.x = new_tilt

func _zoom_camera(delta: float):
	# La cámara está desplazada en el eje z negativo, por tanto, clampf debe
	# cambiar los signos de los valores min y max y el orden
	var new_z = clampf(camera.position.z + delta, -max_zoom_distance, -min_zoom_distance)
	_camera_position.z = new_z#clampf(new_pos.z, -max_zoom_distance, -min_zoom_distance)

func zoom_in_camera():
	_zoom_camera(zoom_step)

func zoom_out_camera():
	_zoom_camera(-zoom_step)
