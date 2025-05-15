@tool
extends Skeleton3D

#@onready var node = $"."
@export var rename_bones : bool = false : set = _start_rename_bones
#extends EditorScript
# Diccionario de traducción de nombres de huesos
var bone_name_mapping = {
	"Pelvis": "Hips",
	"spine_01": "Spine_01",
	"spine_02": "Spine_02",
	"spine_03": "Spine_03",
	"neck_01": "Neck",
	"head": "Head",
	"eyes": "Eyes",
	"eyebrows": "Eyebrows",

	"clavicle_l": "Clavicle_L",
	"UpperArm_L": "Shoulder_L",
	"lowerarm_l": "Elbow_L",
#	"Hand_L": "Hand_L",
	"thumb_01_l": "Thumb_01",
	"thumb_02_l": "Thumb_02",
	"thumb_03_l": "Thumb_03",
	"indexFinger_01_l": "IndexFinger_01",
	"indexFinger_02_l": "IndexFinger_02",
	"indexFinger_03_l": "IndexFinger_03",
	"indexFinger_04_l": "IndexFinger_04",
	"finger_01_l": "Finger_01",
	"finger_02_l": "Finger_02",
	"finger_03_l": "Finger_03",
	"finger_04_l": "Finger_04",

	"clavicle_r": "Clavicle_R",
	"UpperArm_R": "Shoulder_R",
	"lowerarm_r": "Elbow_R",
#	"Hand_R": "Hand_R",
	"thumb_01_r": "Thumb_01_1",
	"thumb_02_r": "Thumb_02_1",
	"thumb_03_r": "Thumb_03_1",
	"indexFinger_01_r": "IndexFinger_01_1",
	"indexFinger_02_r": "IndexFinger_02_1",
	"indexFinger_03_r": "IndexFinger_03_1",
	"indexFinger_04_r": "IndexFinger_04_1",
	"finger_01_r": "Finger_01_1",
	"finger_02_r": "Finger_02_1",
	"finger_03_r": "Finger_03_1",
	"finger_04_r": "Finger_04_1",

	"Thigh_L": "UpperLeg_L",
	"calf_l": "LowerLeg_L",
	"Foot_L": "Ankle_L",
	"ball_l": "Ball_L",
	"toes_l": "Toes_L",

	"Thigh_R": "UpperLeg_R",
	"calf_r": "LowerLeg_R",
	"Foot_R": "Ankle_R",
	"ball_r": "Ball_R",
	"toes_r": "Toes_R"
}

#func _ready():
func _start_rename_bones(new_value : bool):
	if new_value:
		var node : Node3D = get_node(".")
		if node and node is Skeleton3D:# and Engine.is_editor_hint():  # Solo ejecuta en el editor
			do_rename_bones(node)
			do_rebind_skin(node)
		else:
			print("¡Error! No se puede reasignar huesos")

func do_rename_bones(skeleton : Skeleton3D):
	# Añadimos un bone Root como padre de todos
	var root = -1
#	if skeleton.find_bone("Root") == -1:
#		root = skeleton.add_bone("Root")
#		print("Hueso nuevo: Root")

	for i in range(skeleton.get_bone_count()):
		var old_name = skeleton.get_bone_name(i)
		if root != -1 and old_name == "Pelvis":
			skeleton.set_bone_parent(i, root)
			print("Hueso reasignado: ", old_name)
		elif root != -1 and old_name == "Hips":
			if get_bone_parent(i) != root:
				skeleton.set_bone_parent(i, root)
				print("Hueso reasignado: ", old_name)
		elif old_name.contains("ik_"):
			skeleton.set_bone_enabled(i, false)
			print("Hueso deshabilitado: ", old_name)
		elif old_name in bone_name_mapping:
			var new_name = bone_name_mapping[old_name]
			skeleton.set_bone_name(i, new_name)
			print("Hueso renombrado: ", old_name, " -> ", new_name)
		else:
			print("Hueso sin cambio: ", old_name)

func do_rebind_skin(parent : Node3D):
	for node in parent.get_children():
		if node is MeshInstance3D:
			var skin = node.get_skin()
			for i in skin.get_bind_count():
				var old_name = skin.get_bind_name(i)
				if old_name in bone_name_mapping:
					var new_name = bone_name_mapping[old_name]
					skin.set_bind_name(i, new_name)
					print("Skin Bond renombrado: ", old_name, " -> ", new_name)
				else:
					print("Skin Bond sin cambio: ", old_name)
