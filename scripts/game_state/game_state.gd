extends Node

var _current: GameData = null

func current() -> GameData:
	return _current

func start_new_game() -> GameData:
	if _current != null:
		_current = null
	_current = GameData.new()
	_current.init()
	return _current
