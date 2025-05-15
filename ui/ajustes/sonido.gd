extends Control

@onready var general : HSlider = $ScrollContainer/VBoxContainer/TextureRect/TextureRect/General
@onready var music : HSlider = $ScrollContainer/VBoxContainer/TextureRect3/TextureRect/Music
@onready var enviroment : HSlider = $ScrollContainer/VBoxContainer/TextureRect5/TextureRect/Enviroment
@onready var effects : HSlider = $ScrollContainer/VBoxContainer/TextureRect4/TextureRect/Effects
@onready var combat : HSlider = $ScrollContainer/VBoxContainer/TextureRect2/TextureRect/Combat
signal settings_changed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_changes() -> void:
	emit_signal("settings_changed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_music_value_changed(value: float) -> void:
	print(value)
	Music.set_volume_percent(value/100)
	_on_changes()


func _on_general_drag_ended(value_changed: bool) -> void:
	var value = general.value/100
	if value < music.value:
		value = value * music.value
		Music.set_volume_percent(value/100)
	if value < enviroment.value:
		value = value * enviroment.value
		#Modificar sonido de entorno al igual que el de música
	if value < effects.value:
		value = value * effects.value
		#Modificar sonido de efectos
	if value < combat.value:
		value = value * combat.value
		#Modificar sonido de combate
	emit_signal("settings_changed")
