extends AudioStreamPlayer

@export var playlist: Array[AudioStream] = [
	preload("res://assets/music/CelticFantasyMusic-TheLonelyRoad.mp3"),
	preload("res://assets/music/CelticFantasyMusic-WelcomeHome.mp3"),
	preload("res://assets/music/CelticForestMusic-TheEndlessWoods.mp3"),
	preload("res://assets/music/CelticMedievalFantasyMusic-Lenzing.mp3"),
	preload("res://assets/music/CelticMedievalMusic-OnceUponATime.mp3"),
	preload("res://assets/music/CelticMusic-DaydreamMelody.mp3"),
	preload("res://assets/music/CelticMusic-Dreampath.mp3"),
	preload("res://assets/music/CelticMusic-Legend.mp3"),
	preload("res://assets/music/CelticMusic-SwordOfKings.mp3"),
	preload("res://assets/music/CelticMusic-Sylvani.mp3"),
	preload("res://assets/music/Emotional Fantasy Music - Enathar.mp3"),
	preload("res://assets/music/Emotional Fantasy Music - The Secret Wedding (128kbit_AAC).mp3"),
	preload("res://assets/music/Emotional Fantasy Music - The Sending.mp3"),
	preload("res://assets/music/Emotional Fantasy Music - To Die With Honour.mp3"),
	preload("res://assets/music/Emotional Music - Fare Thee Well.mp3"),
	preload("res://assets/music/EmotionalFantasyMusic-Bound.mp3"),
	preload("res://assets/music/FantasyFilmMusic-FatefulReunion.mp3"),
	preload("res://assets/music/FantasyFilmMusic-Foreboding.mp3"),
	preload("res://assets/music/FantasyMusic-TheCurtainRises.mp3"),
	preload("res://assets/music/FantasyMusic-TheElderLords.mp3"),
	preload("res://assets/music/FantasyMusic-VictoryOrDeath.mp3"),
	preload("res://assets/music/NordicFantasyMusic-PrideOfTheScillin.mp3"),
	preload("res://assets/music/RomanticMusic-Ethelo-iel.mp3")
]
@export var music_folder_path: String = "res://assets/music/"

var rndm = RandomNumberGenerator.new()
var remaining_songs: Array[AudioStream] = []
var supported_extensions := ["ogg", "mp3", "wav"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rndm.randomize()
	_reset_remaining_songs()
	_play_random_song()

# Escoge una canción al azar de la lista de canciones no tocadas todavía y
# la reproduce.
func _play_random_song() -> void:
	# Si ya se han tocado todas las canciones, volvemos a llenar la lista
	if remaining_songs.is_empty():
		_reset_remaining_songs()
	# Seleccionamos una canción al azar y la quitamos de la lista de canciones
	# ya reproducidas. Así evitamos tocar canciones duplicadas.
	var next_index = rndm.randi_range(0, remaining_songs.size() - 1)
	var next_song = remaining_songs[next_index]
	remaining_songs.remove_at(next_index)
	# Reproducimos la canción
	stream = next_song
	play()

# Volvemos a cargar la lista de canciones a la lista de canciones NO reproducidas
func _reset_remaining_songs() -> void:
	# Si la lista no se ha rellenado a mano, la llenamos con el contenido
	# de la carpeta especificada
	if playlist.is_empty():
		print("is empty!!")
		_load_music_from_folder()
	remaining_songs = playlist.duplicate()

# Rellenamos la lista de canciones desde una carpeta
func _load_music_from_folder() -> void:
	playlist.clear()
	var dir := DirAccess.open(music_folder_path)
	if not dir:
		push_error("No se pudo abrir la carpeta: " + music_folder_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var ext = file_name.get_extension().to_lower()
			if ext in supported_extensions:
				var path = music_folder_path + file_name
				var stream = load(path)
				if stream is AudioStream:
					playlist.append(stream)
		file_name = dir.get_next()
	dir.list_dir_end()

# Se llama automáticamente cuando se ha terminado de reproducir una canción.
# Reproducimos una nueva
func _on_song_finished() -> void:
	_play_random_song()

func set_volume_percent(percent: float) -> void:
	# Asegura que esté entre 0 y 100
	percent = clamp(percent, 0.0, 100.0)
	if percent <= 0.0:
		volume_db = -80.0  # Silencio total
	else:
		volume_db = linear_to_db(percent)
