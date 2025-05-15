extends Node3D

@onready var _camera_rig  : CameraRig   = $CameraRig
@onready var _player      : Player      = $Player
@onready var _canvas      : CanvasLayer = $CanvasLayer
@onready var _ingame_menu : Control     = $CanvasLayer/PopupInGameMenu

var _is_cam_rotating : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_camera_rig.global_position = _player.global_position
	_ingame_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event : InputEvent):
	if _player and Input.is_action_just_pressed("mouse_click"):
		var space_state = get_world_3d().direct_space_state
		var ray_origin  = _camera_rig.camera.project_ray_origin(event.position)
		var ray_dir     = _camera_rig.camera.project_ray_normal(event.position)
		var ray_length  = 1000
		var rayQuery = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * ray_length)
		rayQuery.exclude = [_player, _camera_rig]
		var result = space_state.intersect_ray(rayQuery)
		if result and result.has("position"):
			_player.navigate_to(result.position)
	elif _is_cam_rotating and event is InputEventMouseMotion:
		_camera_rig.rotate_camera(event.relative)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_camera_rig.zoom_in_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera_rig.zoom_out_camera()

	if event is InputEventKey:
		if Input.is_action_just_pressed("cancel"):
			if not _ingame_menu.visible:
				_show_ingame_menu()
		elif Input.is_action_just_pressed("rotate_camera"):
			_is_cam_rotating = true
		elif Input.is_action_just_released("rotate_camera"):
			_is_cam_rotating = false

func _show_ingame_menu() -> void:
	if _ingame_menu.visible:
		return
	_is_cam_rotating  = false
	_ingame_menu.visible = true
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
