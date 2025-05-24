extends Node
class_name Character

enum Tez
{
	PALE = 0,
	TANNED = 1,
	DARK = 2
}
const TezStr : Array[String] = [ "Pálida", "Morena", "Oscura" ]

enum Looks
{
	STYLE_1 = 0,
	STYLE_2 = 1,
	STYLE_3 = 2,
	STYLE_4 = 3,
	STYLE_5 = 4
}
const LooksStr : Array[String] = [ "Estilo 1", "Estilo 2", "Estilo 3", "Estilo 4", "Estilo 5" ]

var nombre    : String     = "Alex"
var type      : GlobalDefs.CharacterType = GlobalDefs.CharacterType.PEASANT_01
var tez       : Tez        = Tez.PALE
var looks     : Looks      = Looks.STYLE_1
var atributos : Attributes = null

func init() -> void:
	atributos = Attributes.new()
