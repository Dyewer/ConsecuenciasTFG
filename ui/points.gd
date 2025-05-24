extends Label

class_name PointsLabel
@export var avaliable : int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_value(value : int) -> void:
	print("Value enviado a set value: ", value, " Valor de avaliable: ", avaliable)
	
	if value >= 0 :
		avaliable = value
		print ("Valor de avaliable en el if: ", avaliable)
		text = str(value)
