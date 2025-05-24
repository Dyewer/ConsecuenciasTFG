extends CharacterBody3D
class_name Player

@onready var _nav_agent : NavigationAgent3D = $NavigationAgent
@onready var _animation : AnimationPlayer = $AnimationPlayer
@onready var skeleton : MeshPlayer = %HumanSkeleton

const SPEED            : float   = 3.0
# Construimos un vector para aplicar velocidad al jugador solo en el plano
# horizontal (1,0,1)
const HORIZONTAL_PLANE : Vector3 = (Vector3.MODEL_FRONT + Vector3.MODEL_LEFT)

func _ready():
	_animation.play("Basic Locomotion/BL_Idle")

func _physics_process(delta):
	# Movimiento hacia el objetivo
	if not _nav_agent.is_navigation_finished():
		var next_pos  = _nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		# Mediante esta formula anulamos el movimiento en el eje de y
		# para calcular la velocidad horizontal, sin tener en cuenta la altura
		velocity = (direction * SPEED * HORIZONTAL_PLANE) + (velocity * Vector3.UP)
		# Ahora rotamos el personaje en la dirección del movimiento
		direction.y = 0
		if direction.length_squared() > 0.01:
			var angle = atan2(direction.x, direction.z)
			rotation.y = angle
		# Comenzamos la animación de moverse
		_animation.play("Basic Locomotion/BL_Walk")
	elif velocity.length_squared() > 0.01:
		velocity.x = 0.0
		velocity.z = 0.0
		# Paramos la animación de moverse
		_animation.play("Basic Locomotion/BL_Idle")

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity += get_gravity() * delta
	move_and_slide()

func navigate_to(position : Vector3) -> void:
	_nav_agent.set_target_position(position)
