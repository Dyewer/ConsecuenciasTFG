extends DirectionalLight3D
class_name OrbitalLight

@export_range(0, 45) var inclination : int      = 23  # Inclinación respecto de la vertical (grados)
@export_range(1, 30) var period      : int      = 1   # dias para dar una vuelta al planeta
@export              var color       : Gradient = null
@export              var intensity   : Curve    = null

var rate : float :
	get : return _rate

var tilt : float :
	get : return _tilt

var time : float :
	get : return _time
	set(value) :
		_time = value
		global_transform = Transform3D(_calcula_basis(_time), global_transform.origin)

var _time : float = 0.0
var _rate : float = 1.0
var _tilt : float = 1.0

func _ready() -> void:
	calculate_rate_and_tilt(get_parent())

func _process(delta: float) -> void:
	# El eje z es el que va en la dirección "norte-sur" (y si no lo es, lo va a
	# a ser porque lo decidimos nosotros), y es sobre el que rotará nuestro Sol.
	# Se podría simular estaciones rotando el Sol sobre el eje x.
	# Las rotaciones deben ser sobre el sistema de coordenadas global (del mundo)
	# y no sobre sistema de coordenadas local (Sol).
	# El ciclo diario va desde t = 0.0 (media noche) a t = 1.0 (media noche otra
	# vez), pasando por t = 0.5 (medio día)
	# Se considera 0º de rotación en el eje z el amanecer, lo que es 90º de desfase
	# con la media noche.
	
	# 1. Actualizamos el momento del día (de 0.0 a 1.0)
	_time += _rate * delta
	if _time > 1.0:
		_time -= 1.0
	global_transform = Transform3D(_calcula_basis(_time), global_transform.origin)
	if color:
		light_color = color.sample(_time)
	if intensity:
		light_energy = intensity.sample(_time)
		visible = light_energy > 0.0

func _calcula_basis(time : float) -> Basis:
	var basis = Basis(Vector3.BACK, deg_to_rad(time * 360.0 - 180.0)) * \
				Basis(Vector3.RIGHT, _tilt)
	return basis

func calculate_rate_and_tilt(world : DayNightEnvironment) -> void:
	# Ritmo al que avanza el día (i.e. Frecuencia 1/seg)
	_rate      = 1.0 / (world.day_length * 60.0)
	# Cada day_period, la Luna ha dado moon_period / 360º menos de vuelta
	# alrededor del planeta. Por tanto, cada day_period, la La luna da
	# 360 - (360 / moon_period), lo que es lo mismo que
	# 360 * (moon_period - 1) / moon_period. 360 equivale a 1 vuelta. por lo que
	# a vuelta del Sol es lo mismo que (moon_period - 1) / moon_period vueltas
	# de la Luna. Convertido a "rate" es 1/periodo. Y multiplicando por _rate
	# nos da los 1/seg de la Luna.
	if period > 1:
		_rate *= period / (period - 1.0)
	# Asigna la inclinación del cuerpo celeste de acuerdo a la latitud e
	# inclinación del eje de rotación del planeta
	_tilt  = deg_to_rad(world.latitude - 90.0 - inclination)
