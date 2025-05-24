@tool
extends Node3D

func _ready():
	if not Engine.is_editor_hint():
		return

	var material : Material = null
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for child in get_children():
		if child is MeshInstance3D:
			var mesh: Mesh = child.mesh
			if mesh == null:
				continue

			var array_mesh := mesh as ArrayMesh
			for i in range(array_mesh.get_surface_count()):
				st.append_from(array_mesh, i, child.global_transform)

				if material == null:
					material = array_mesh.surface_get_material(i)

	var combined_mesh := st.commit()
	var new_instance := MeshInstance3D.new()
	new_instance.mesh = combined_mesh
	if material:
		new_instance.material_override = material
	add_child(new_instance)
	new_instance.owner = get_tree().edited_scene_root
