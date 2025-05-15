extends Node

const MOUSE_SENSITIVIY : float = 0.002
const UI_IN_TIME       : float = 0.5
const UI_FADEIN_TIME   : float = 4.0
const UI_PAUSE_TIME    : float = 6.0

const RES_CURSOR_ARROW : Resource = preload("res://assets/synty/ui/Sprites/Cursors/SPR_FantasyMenus_Cursor_Pointer_03_32x32.png")

enum CharacterType
{
	BAIRD = 0,
	DRUID = 1,
	GYPSY = 2,
	KING = 3,
	PEASANT_01 = 4,
	PEASANT_02 = 5,
	PEASANT_03 = 6,
	QUEEN = 7,
	ROGUE = 8,
	SORCERER = 9,
	WITCH = 10,
	WIZARD = 11,
	NONE = 12
}

const CharacterMesh = [
	preload("res://assets/characters/meshes/Male_Baird.res"),
	preload("res://assets/characters/meshes/Female_Druid.res"),
	preload("res://assets/characters/meshes/Female_Gypsy.res"),
	preload("res://assets/characters/meshes/King.res"),
	preload("res://assets/characters/meshes/Female_Peasant_01.res"),
	preload("res://assets/characters/meshes/Female_Peasant_02.res"),
	preload("res://assets/characters/meshes/Male_Peasant_01.res"),
	preload("res://assets/characters/meshes/Queen.res"),
	preload("res://assets/characters/meshes/Male_Rogue_01.res"),
	preload("res://assets/characters/meshes/Sorcerer.res"),
	preload("res://assets/characters/meshes/Witch.res"),
	preload("res://assets/characters/meshes/Wizard.res")
]

enum CharacterLook
{
	LOOK_1_A = 0,
	LOOK_1_B = 1,
	LOOK_1_C = 2,
	LOOK_2_A = 3,
	LOOK_2_B = 4,
	LOOK_2_C = 5,
	LOOK_3_A = 6,
	LOOK_3_B = 7,
	LOOK_3_C = 8,
	LOOK_4_A = 9,
	LOOK_4_B = 10,
	LOOK_4_C = 11,
	LOOK_5_A = 12,
	LOOK_5_B = 13,
	LOOK_5_C = 14,
	LOOK_EMISSIVE = 15
}

const CharacterTexture = [
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_01_A.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_01_B.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_01_C.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_02_A.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_02_B.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_02_C.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_03_A.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_03_B.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_03_C.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_04_A.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_04_B.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_04_C.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_05_A.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_05_B.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_05_C.png"),
	preload("res://assets/synty/textures/Polygon_Fantasy_Characters_Texture_Emmision.png"),
]

func _ready() -> void:
	Input.set_custom_mouse_cursor(RES_CURSOR_ARROW, Input.CURSOR_ARROW, Vector2(3,3))

func CharacterMeshName(type : CharacterType) -> String:
	match type:
		CharacterType.BAIRD:
			return "res://assets/characters/meshes/Male_Baird.res"
		CharacterType.DRUID:
			return "res://assets/characters/meshes/Female_Druid.res"
		CharacterType.GYPSY:
			return "res://assets/characters/meshes/Female_Gypsy.res"
		CharacterType.KING:
			return "res://assets/characters/meshes/King.res"
		CharacterType.PEASANT_01:
			return "res://assets/characters/meshes/Female_Peasant_01.res"
		CharacterType.PEASANT_02:
			return "res://assets/characters/meshes/Female_Peasant_02.res"
		CharacterType.PEASANT_03:
			return "res://assets/characters/meshes/Male_Peasant_01.res"
		CharacterType.QUEEN:
			return "res://assets/characters/meshes/Queen.res"
		CharacterType.ROGUE:
			return "res://assets/characters/meshes/Male_Rogue_01.res"
		CharacterType.SORCERER:
			return "res://assets/characters/meshes/Sorcerer.res"
		CharacterType.WITCH:
			return "res://assets/characters/meshes/Witch.res"
		CharacterType.WIZARD:
			return "res://assets/characters/meshes/Wizard.res"
	return ""

func CharacterSkinName(type : CharacterLook) -> String:
	match type:
		CharacterLook.LOOK_1_A:
			return "Look 1 variante A"
		CharacterLook.LOOK_1_B:
			return "Look 1 variante B"
		CharacterLook.LOOK_1_C:
			return "Look 1 variante C"
		CharacterLook.LOOK_2_A:
			return "Look 2 variante A"
		CharacterLook.LOOK_2_B:
			return "Look 2 variante B"
		CharacterLook.LOOK_2_C:
			return "Look 2 variante C"
		CharacterLook.LOOK_3_A:
			return "Look 3 variante A"
		CharacterLook.LOOK_3_B:
			return "Look 3 variante B"
		CharacterLook.LOOK_3_C:
			return "Look 3 variante C"
		CharacterLook.LOOK_4_A:
			return "Look 4 variante A"
		CharacterLook.LOOK_4_B:
			return "Look 4 variante B"
		CharacterLook.LOOK_4_C:
			return "Look 4 variante C"
		CharacterLook.LOOK_5_A:
			return "Look 5 variante A"
		CharacterLook.LOOK_5_B:
			return "Look 5 variante B"
		CharacterLook.LOOK_5_C:
			return "Look 5 variante C"
	return ""
