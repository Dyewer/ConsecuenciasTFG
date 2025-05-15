extends Node3D
class_name DayNightEnvironment

@export_range(1, 45)    var day_length  : float = 15
@export_range(0.0, 1.0) var start_time  : float = 0.3 # (0.0 = media noche, 0.5 medio día)
@export_range(-90, 90)  var latitude    : int   = 40  # grados (+vo = Norte, -vo = Sur, 0º = Ecuador)

@export var sky_top_color     : Gradient = null
@export var sky_horizon_color : Gradient = null

@onready var _sun  = $Sun
@onready var _moon = $Moon
@onready var _env  = $WorldEnvironment

func _ready() -> void:
	_sun.calculate_rate_and_tilt(self)
	_moon.calculate_rate_and_tilt(self)

	_sun.time  = start_time
	_moon.time = start_time + 0.5

func _process(_delta: float) -> void:
	if sky_top_color or sky_horizon_color:
		var time = _sun.time
		if sky_top_color:
			var top_color  = sky_top_color.sample(time)
			_env.environment.sky.sky_material.set("sky_top_color", top_color)
			_env.environment.sky.sky_material.set("ground_bottom_color", top_color)
		if sky_horizon_color:
			var horz_color = sky_horizon_color.sample(time)
			_env.environment.sky.sky_material.set("sky_horizon_color", horz_color)
			_env.environment.sky.sky_material.set("ground_horizon_color", horz_color)
