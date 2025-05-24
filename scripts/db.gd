extends Node

# Miembros "publicos"
var sqlite: SQLite:		# Instancia SQLite
	get: return _db
var data_path: String:	# Directorio donde se almacena la BD
	get: return _data_path
var is_empty: bool:		# true si la BD está vacía
	get = _isDatabaseEmpty

# Miembros "privados"
const _data_path : String = "res://data/"
const _db_name : String = "gamedata"
const _db_tbl_graphics : String = "graphics"
const _db_tbl_sound : String = "sound"
const _db_tbl_character_types : String = "character_types"
const _db_tbl_character_tez : String = "character_tez"
const _db_tbl_character_looks : String = "character_looks"
const _db_tbl_characters : String = "characters"
const _db_tbl_games : String = "games"
const _db_tbl_saved_games : String = "games_saved"
const _db_view_config : String = "configuration"

var _db : SQLite = null

func _ready() -> void:
	# Si no existe la carpeta donde almacenar los datos, se crea
	_createDirIfNotExists(_data_path)

	# Nueva instancia de SQLite. Intentamos abrir la base de datos _db_name
	_db = SQLite.new()
	_db.foreign_keys = true
	_db.path = _data_path + _db_name
	if _db.open_db():
		# Si la BD está vacía, es nueva. Creamos las tablas
		if _isDatabaseEmpty():
			_createTables()
			_createViewConfig()
		# A lo mejor no queremos aplicar aquí la configuración inicial
		applyInitialConfigFromDB()
 
func _notification(what) -> void:
	if what == NOTIFICATION_PREDELETE:
		_db.close_db()

func _isDatabaseEmpty() -> bool:
	if _db and _db.query("SELECT COUNT(*) AS 'num_tables' FROM sqlite_master WHERE type='table';"):
		return _db.query_result[0]["num_tables"] == 0
	print("No se ha podido leer de la base de datos o la query ha dado error")
	return false

func _createDirIfNotExists(absolute_path : String) -> void:
	if not DirAccess.dir_exists_absolute(absolute_path):
		DirAccess.make_dir_absolute(absolute_path)

func applyInitialConfigFromDB() -> void:
	if not _db:
		return
	var config : Array = _db.select_rows(_db_view_config, "", ["*"])
	if not config.size():
		print("Tabla ", _db_tbl_graphics, " está vacía")
		return
	# Es Fullscreen?
	if config[0]["fullscreen"] == 1:
		print("FULLSCREEN!")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# Qué resolución tiene?
		if config[0]["resolution"].length() > 0:
			var size = config[0]["resolution"].split("x")
			if size.size() == 2:
				print("size=", size)
				DisplayServer.window_set_size(Vector2i(int(size[0]), int(size[1])))
		# En qué posición se quedó la última vez
	var viewport_rid = get_viewport().get_viewport_rid()
	match config[0]["quality"]:
		0:  # Baja
			RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		1:  # Media
			RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_2X)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		2:  # Alta
			RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_4X)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	
	Engine.max_fps = config[0]["refresh"]
	if config[0]["synch"]:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	# todo: MUSIC VOLUME
	Music.set_volume_percent(float(config[0]["general"]) / 100.0)
	
	#Pendiente implementar volúmenes de los diferentes sonidos
	#Music.set_volume_percent(float(config[0]["music"]) / 100.0)
	#Music.set_volume_percent(float(config[0]["environment"]) / 100.0)
	#Music.set_volume_percent(float(config[0]["effects"]) / 100.0)
	#Music.set_volume_percent(float(config[0]["combat"]) / 100.0)
	

func saveGame(capture : Image , save_name : String = "autosave") -> void:
	# 1. Check if game already exists. If so, update contents, else create
	#    new and fill in information
	var game_data = GameState.current()
	var game_id : int = getGameId(game_data.game_name)
	var saved_game_id : int = getSavedGameId(game_id, save_name, game_data, capture)
	# 2. Guarda los datos del personaje
	saveCharacterSnapshot(saved_game_id, game_data)

func updateConfig(arrayListGraphics : Dictionary, arrayListSound : Dictionary) -> bool:
	if not _db.update_rows(_db_tbl_graphics, "id = 1", arrayListGraphics):
		print("Update tabla graphics. " + _db.error_message)
		return false
	if not _db.update_rows(_db_tbl_sound, "id = 1", arrayListSound):
		print("Update tabla sound. " + _db.error_message)
		return false
	return true
########### Funciones auxiliares de consulta de tablas ###########

func getViewConfiguration() -> Dictionary:
	var config : Array = _db.select_rows(_db_view_config, "", ["*"])
	return config[0]

func getGameId(game_name : String) -> int:
	#   1.1 select id from games where name = GameState.current().game_name
	var q_res : Array = _db.select_rows(_db_tbl_games, "name = '"+game_name+"'", ["id"])
	#   1.2 if id == null --> _db.insert_row("games", { "name" : GameState.current().game_name }) 
	if q_res.is_empty():
		if _db.insert_row(_db_tbl_games, { "name" : game_name }):
			q_res = _db.select_rows(_db_tbl_games, "name = '"+game_name+"'", ["id"])
		else:
			print(_db.error_message)
	if q_res.size() > 0:
		return q_res[0]["id"]
	print("No se pudo encontrar ni crear la partida")
	return -1

func getSavedGameId(game_id : int, saved_game_name : String, game_data : GameData, capture : Image) -> int:
	#   1.1 select id from games where name = GameState.current().game_name
	var q_res : Array = _db.select_rows(_db_tbl_saved_games, "game = "+str(game_id)+" and name = '"+saved_game_name+"'", ["id"])
	#   1.2 if id == null --> _db.insert_row("games", { "name" : GameState.current().game_name }) 
	if q_res.is_empty():
		if _db.insert_row(_db_tbl_saved_games, { "game" : game_id, "created" : game_data.created_time.toString(), "name" : saved_game_name, "capture" : capture.save_png_to_buffer() }):
			q_res = _db.select_rows(_db_tbl_saved_games, "game = "+str(game_id)+" and name = '"+saved_game_name+"'", ["id"])
		else:
			print(_db.error_message)
	else:
		if not _db.update_rows(_db_tbl_saved_games, "id = "+str(q_res[0]["id"])+" and game = "+str(game_id), { "created" : game_data.created_time.toString(), "capture" : capture.save_png_to_buffer()  }):
			print("Could not update saved game date:" + _db.error_message)
	if q_res.size() > 0:
		return q_res[0]["id"]
	print("No se pudo guardar la partida '" + saved_game_name + "'")
	return -1

func getCharacterIdFromSavedGame(saved_game_id : int) -> int:
	var q_res : Array = _db.select_rows(_db_tbl_characters, "saved_game = "+str(saved_game_id), ["id"])
	if q_res.size() > 0:
		return q_res[0]["id"]
	return -1

func saveCharacterSnapshot(saved_game_id : int, game_data : GameData) -> bool:
	var character_id : int  = getCharacterIdFromSavedGame(saved_game_id)
	var result : bool = true
	if character_id == -1:
		result = _db.insert_row(_db_tbl_characters,
			{
			"name"         : game_data.character.nombre,
			"type"         : game_data.character.type,
			"tez"          : game_data.character.tez,
			"look"         : game_data.character.looks,
			"destreza"     : game_data.character.atributos.destreza,
			"inteligencia" : game_data.character.atributos.inteligencia,
			"fisico"       : game_data.character.atributos.fisico,
			"poder"        : game_data.character.atributos.poder,
			"percepcion"   : game_data.character.atributos.percepcion,
			"moral"        : game_data.character.atributos.moral,
			"saved_game"   : saved_game_id
			})
	else:
		result = _db.update_rows(_db_tbl_characters, "saved_game = "+str(saved_game_id),
			{
			"name"         : game_data.character.nombre,
			"type"         : game_data.character.type,
			"tez"          : game_data.character.tez,
			"look"         : game_data.character.looks,
			"destreza"     : game_data.character.atributos.destreza,
			"inteligencia" : game_data.character.atributos.inteligencia,
			"fisico"       : game_data.character.atributos.fisico,
			"poder"        : game_data.character.atributos.poder,
			"percepcion"   : game_data.character.atributos.percepcion,
			"moral"        : game_data.character.atributos.moral
			})
	if not result:
		print(_db.error_message)
	return result

########### Funciones de creación de tablas y vistas ###########
func _createTables() -> void:
	if not _db:
		return
	# Tabla "games_saved" y la principal "games"
	if not _createSaveGamesTable():
		return
	# Tabla "opencfg"
	if not _createTablesConfig():
		return
	# Tabla "characters" y sus asociadas
	if not _createCharacterTable():
		return

func _createViewConfig() -> void:
	_db.query("CREATE VIEW " + _db_view_config + " AS 
	SELECT g.*, s.general, s.music, s.environment, 
	s.effects, s.combat FROM " + _db_tbl_graphics + " AS g, " + 
	_db_tbl_sound + " AS s WHERE g.id = s.id;")

func _createTablesConfig()-> bool:
	if not _createTableGraphics():
		return false
	return _createTableSound()

func _createTableGraphics() -> bool:
	# Tabla "opencfg" que almacena un solo elemento con
	# la configuración inicial del juego: resolución, fullscreen, music...
	var tbd_config : Dictionary = {
		"id" : { "data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true },
		"resolution"   : { "data_type" : "char(10)", "not_null" : true },
		"quality"     : { "data_type" : "int", "not_null" : true, "default" : 1 },
		"fullscreen"   : { "data_type" : "int",     "not_null" : true, "default" : 1 },
		"refresh" : { "data_type" : "int",     "not_null" : true, "default" : 60 },
		"synch"     : { "data_type" : "int", "not_null" : true, "default" : 0 }
	}
	if _db.create_table(_db_tbl_graphics, tbd_config):
#		DisplayServer.get_primary_screen().size()
		_db.insert_row(_db_tbl_graphics,
					{ "resolution" : "1920x1080",
					"quality" : 1 })
		return true
# Este es el "else", puesto que el if hace un return, el código a continuación
# solo se llama en caso de que el if no se cumpla (i.e. como si fuera un "else")
	print(_db.error_message)
	return false

func _createTableSound() -> bool:
	var tbd_config : Dictionary = {
		"id" : { "data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true },
		"general"   : { "data_type" : "int", "not_null" : true, "default" : 100 },
		"music"     : { "data_type" : "int", "not_null" : true, "default" : 100 },
		"environment"   : { "data_type" : "int",     "not_null" : true, "default" : 100},
		"effects" : { "data_type" : "int",     "not_null" : true, "default" : 100 },
		"combat"     : { "data_type" : "int", "not_null" : true, "default" : 100 }
	}
	if _db.create_table(_db_tbl_sound, tbd_config):
#		DisplayServer.get_primary_screen().size()
		_db.insert_row(_db_tbl_sound, { "general" : 100 })
		return true
# Este es el "else", puesto que el if hace un return, el código a continuación
# solo se llama en caso de que el if no se cumpla (i.e. como si fuera un "else")
	print(_db.error_message)
	return false

func _createCharacterTable() -> bool:
	# Necesitamos que algunas otras tablas existan primero
	if not _createCharacterTypeTable():
		return false
	if not _createCharacterTezTable():
		return false
	if not _createCharacterLooksTable():
		return false

	# Tabla "characters"
	# Cada entrada en esta tabla sirve como un "snapshot" de un personaje en
	# momento dado de una partida. Cada vez que se graba una partida, se añade
	# una entrada en esta tabla, con las características del personaje y se
	# enlaza con la partida guardada.
	var table : Dictionary = {
		"id" : { "data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true },
		"name"         : { "data_type" : "char(64)", "not_null" : true },
		"type"         : { "data_type" : "int",      "not_null" : true, "foreign_key" : _db_tbl_character_types+".id" },
		"tez"          : { "data_type" : "int",      "not_null" : true, "foreign_key" : _db_tbl_character_tez+".id" },
		"look"         : { "data_type" : "int",      "not_null" : true, "foreign_key" : _db_tbl_character_looks+".id" },
		"destreza"     : { "data_type" : "int",      "not_null" : true, "default" : 1 },
		"inteligencia" : { "data_type" : "int",      "not_null" : true, "default" : 1 },
		"fisico"       : { "data_type" : "int",      "not_null" : true, "default" : 1 },
		"poder"        : { "data_type" : "int",      "not_null" : true, "default" : 1 },
		"percepcion"   : { "data_type" : "int",      "not_null" : true, "default" : 1 },
		"moral"        : { "data_type" : "int",      "not_null" : true, "default" : 1 },
		"saved_game"   : { "data_type" : "int",      "not_null" : true, "foreign_key" : _db_tbl_saved_games+".id" }
	}
	if _db.create_table(_db_tbl_characters, table):
		return true
	print(_db.error_message)
	return false

func _createCharacterTypeTable() -> bool:
	# Tabla "character_types" que almacena la lista de tipos de meshes:
	# resolución, fullscreen, music...
	var table : Dictionary = {
		"id" : { "data_type" : "int", "primary_key" : true, "not_null" : true },
		"name" : { "data_type" : "char(16)", "not_null" : true },
	}
	if _db.create_table(_db_tbl_character_types, table):
		_db.insert_row(_db_tbl_character_types, { "id" : GlobalDefs.CharacterType.PEASANT_01, "name" : "Aurora" })
		_db.insert_row(_db_tbl_character_types, { "id" : GlobalDefs.CharacterType.PEASANT_02, "name" : "Almudena" })
		_db.insert_row(_db_tbl_character_types, { "id" : GlobalDefs.CharacterType.PEASANT_03, "name" : "Leonardo" })
		return true
	print(_db.error_message)
	return false

func _createCharacterTezTable() -> bool:
	# Tabla "character_types" que almacena la lista de tipos de meshes:
	# resolución, fullscreen, music...
	var table : Dictionary = {
		"id" : { "data_type" : "int", "primary_key" : true, "not_null" : true },
		"name" : { "data_type" : "char(8)", "not_null" : true },
	}
	if _db.create_table(_db_tbl_character_tez, table):
		for tez in Character.Tez.values():
			_db.insert_row(_db_tbl_character_tez,
				{ "id" : tez, "name" : Character.TezStr[tez] })
		return true
	print(_db.error_message)
	return false

func _createCharacterLooksTable() -> bool:
	# Tabla "character_types" que almacena la lista de tipos de meshes:
	# resolución, fullscreen, music...
	var table : Dictionary = {
		"id" : { "data_type" : "int", "primary_key" : true, "not_null" : true },
		"name" : { "data_type" : "char(8)", "not_null" : true },
	}
	if _db.create_table(_db_tbl_character_looks, table):
		for look in Character.Looks.values():
			_db.insert_row(_db_tbl_character_looks,
				{ "id" : look, "name" : Character.LooksStr[look] })
		return true
	print(_db.error_message)
	return false

func _createGameTable() -> bool:
	# Tabla "Game" que almacena la lista de partidas. Ojo: Una partida puede
	# tener más de un "saved" sobre ella.
	var table : Dictionary = {
		"id" : { "data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true },
		"name" : { "data_type" : "char(64)", "not_null" : true },
	}
	if not _db.create_table(_db_tbl_games, table):
		print(_db.error_message)
		return false
	return true

func _createSaveGamesTable() -> bool:
	# Necesitamos que la tabla Game exista primero
	if not _createGameTable():
		return false
	# Tabla "SaveGames" que almacena la lista de partidas. Ojo: Una partida puede
	# tener más de un "saved" sobre ella.
	var table : Dictionary = {
		"id" : { "data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true },
		"game" : { "data_type" : "int", "not_null" : true, "foreign_key" : _db_tbl_games+".id" },
		"created" : { "data_type" : "TEXT", "not_null" : true },
		"name" : { "data_type" : "char(64)", "not_null" : true },
		"capture" : { "data_type" : "blob", "not_null" : true }
	}
	if not _db.create_table(_db_tbl_saved_games, table):
		print(_db.error_message)
		return false
	return true
