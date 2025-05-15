extends Control

@export var path : String = "ui/Mask"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Tools.crear_click_mask_desde_textura($TextureRect.texture, path)
	pass # Replace with function body.
