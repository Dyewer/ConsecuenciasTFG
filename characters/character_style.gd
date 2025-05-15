@tool
extends Skeleton3D
class_name MeshPlayer

@export var type : GlobalDefs.CharacterType = GlobalDefs.CharacterType.BAIRD :
	set = _assign_mesh
@export var looks : GlobalDefs.CharacterLook = GlobalDefs.CharacterLook.LOOK_1_A :
	set =_assign_look
#@onready var mesh : MeshInstance3D = $HumanSkeleton/Mesh

func _assign_mesh(value : GlobalDefs.CharacterType):
	if not is_inside_tree():  # Evita errores si el nodo no está en la escena
		return

	var mesh = $Mesh #get_node_or_null("HumanSkeleton/Mesh")
	if mesh:
		type = value
		if value > 11:
			mesh.mesh = null
		else:
			mesh.mesh = GlobalDefs.CharacterMesh.get(type)
	else:
		print("Mesh NOT ready!!")

	notify_property_list_changed()

func _assign_look(value : GlobalDefs.CharacterLook):
	if not is_inside_tree():  # Evita errores si el nodo no está en la escena
		return

	var mesh = $Mesh
	if mesh:
		if value < 15:
			looks = value
#			var mat = mesh.get_surface_override_material(0) # StandardMaterial3D.new()
			var mat = StandardMaterial3D.new()
			mat.albedo_texture = GlobalDefs.CharacterTexture.get(looks)
			mesh.set_surface_override_material(0, mat)
	else:
		print("Mesh NOT ready!!")

	notify_property_list_changed()
