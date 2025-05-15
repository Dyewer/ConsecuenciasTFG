extends Node

# Miembros "publicos"
var sqlite: SQLite:		# Instancia SQLite
	get: return _db
var data_path: String:	# Directorio donde se almacena la BD
	get: return _data_path
var is_empty: bool:		# true si la BD está vacía
	get = _isDatabaseEmpty

# Miembros "privados"
const _data_path           : String = "res://data/"
const _db_name             : String = "gamedata"
const _db_tbl_opencfg_name : String = "opencfg"

var _db : SQLite = null

func _ready() -> void:
	# Si no existe la carpeta donde almacenar los datos, se crea
	_createDirIfNotExists(_data_path)

	# Nueva instancia de SQLite. Intentamos abrir la base de datos _db_name
	_db = SQLite.new()
	_db.path = _data_path + _db_name
	if _db.open_db():
		# Si la BD está vacía, es nueva. Creamos las tablas
		if _isDatabaseEmpty():
			_createTables()
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

func _createTables() -> void:
	if not _db:
		return
	# Tabla "opencfg" que almacena un solo elemento con
	# la configuración inicial del juego: resolución, fullscreen, music...
	var tbd_config : Dictionary = {
		"id" : { "data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true },
		"fullscreen"   : { "data_type" : "int",     "not_null" : true, "default" : 1 },
		"resolution"   : { "data_type" : "char(9)", "not_null" : true },
		"position"     : { "data_type" : "char(9)", "not_null" : true },
		"music_volume" : { "data_type" : "int",     "not_null" : true, "default" : 100 }
	}
	if _db.create_table(_db_tbl_opencfg_name, tbd_config):
#		DisplayServer.get_primary_screen().size()
		_db.insert_row(_db_tbl_opencfg_name,
					{ "resolution" : "1920x1080",
					"position" : "0x0" })
	else:
		print(_db.error_message)

func _createDirIfNotExists(absolute_path : String) -> void:
	if not DirAccess.dir_exists_absolute(absolute_path):
		DirAccess.make_dir_absolute(absolute_path)

func applyInitialConfigFromDB() -> void:
	if not _db:
		return
	var config : Array = _db.select_rows(_db_tbl_opencfg_name, "", ["*"])
	if not config.size():
		print("Tabla ", _db_tbl_opencfg_name, " está vacía")
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
		if config[0]["position"].length() > 0:
			var size = config[0]["position"].split("x")
			if size.size() == 2:
				var window_pos : Vector2i = Vector2i.ZERO
				if size[0] == "-1" and size[1] == "-1":
					var window_size = DisplayServer.window_get_size()
					var screen_size = DisplayServer.screen_get_size()
					window_pos = (screen_size - window_size) / 2
				else:
					window_pos = Vector2i(int(size[0]), int(size[1]))
				DisplayServer.window_set_position(window_pos)
	# todo: MUSIC VOLUME
	Music.set_volume_percent(float(config[0]["music_volume"]) / 100.0)
