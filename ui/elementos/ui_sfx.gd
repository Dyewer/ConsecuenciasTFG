extends AudioStreamPlayer

@export var click_streams : Array[AudioStream] = [
	preload("res://assets/sfx/ui/ui_button_simple_click_01.wav"),
	preload("res://assets/sfx/ui/ui_button_simple_click_02.wav"),
	preload("res://assets/sfx/ui/ui_button_simple_click_03.wav"),
	preload("res://assets/sfx/ui/ui_button_simple_click_04.wav"),
	preload("res://assets/sfx/ui/ui_button_simple_click_05.wav"),
	preload("res://assets/sfx/ui/ui_button_simple_click_06.wav"),
	preload("res://assets/sfx/ui/ui_button_simple_click_07.wav")
]
@export var hover_streams : Array[AudioStream] = [
	preload("res://assets/sfx/ui/ui_menu_popup_01.wav"),
	preload("res://assets/sfx/ui/ui_menu_popup_02.wav"),
	preload("res://assets/sfx/ui/ui_menu_popup_03.wav"),
	preload("res://assets/sfx/ui/ui_menu_popup_04.wav")
]

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func _play_random_sfx(array :  Array[AudioStream]) -> void:
	if array and array.size() > 0:
		if array.size() > 1:
			stream = array[rng.randi_range(0, array.size() - 1)]
		else:
			stream = array[0]
		play()

func play_click() -> void:
	_play_random_sfx(click_streams)

func play_hover() -> void:
	_play_random_sfx(hover_streams)
