@tool
extends Node3D

@export var pegar_al_terreno := false:
	set(value):
		pegar_al_terreno = value
		if value and Engine.is_editor_hint():
			ajustar_altura_al_terreno()

func ajustar_altura_al_terreno():
	var terrain = get_tree().get_root().find_child("Terrain3D", true, false)
	if terrain:
		var pos = global_position
		pos.y = terrain.get_height_at(pos.x, pos.z)
		global_position = pos
