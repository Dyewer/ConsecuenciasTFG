extends HBoxContainer

@export_range(1,10) var value : int = 1
@export var atribute : String = "Atribute"
@onready var label : Label = $TextureRect2/Value

func _ready() -> void:
	label.text = str(value)
	$TextureRect/ATRIBUTE.text = atribute

func _set_value(number : int) -> void:
	if number <= 10 and number >=1:
		value = number
		label.text = str(value)

func _on_button_less_pressed() -> void:
	_set_value(value-1)
	SFX.play_click()

func _on_button_more_pressed() -> void:
	_set_value(value+1)
	SFX.play_click()
