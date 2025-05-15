extends Control

# Este array contiene las resoluciones aplicables desde el menu de ajustes
var resolution := [
	Vector2i(5120, 2160),
	Vector2i(3840, 2160),
	Vector2i(3440, 1440),
	Vector2i(2560, 1440),
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1280, 720)
]

# Este array contiene los dos modos de ventana disponibles
var screen_mode := [
	DisplayServer.WINDOW_MODE_FULLSCREEN,
	DisplayServer.WINDOW_MODE_WINDOWED
]

var refresh_rate := [
	60,
	75,
	120,
	144,
	165
]

var synchronization := [
	30,
	60,
	90,
	120,
	144,
	165
]

@onready var refreshButton: OptionButton = $ScrollContainer/VBoxContainer/TextureRect4/RefreshButton
@onready var resolutionButton: OptionButton = $ScrollContainer/VBoxContainer/TextureRect/ResolutionButton
@onready var synchronizationButton: CheckButton = $ScrollContainer/VBoxContainer/TextureRect6/SynchronizationButton
signal settings_changed

func _ready() -> void:
	_check_screenMode()
	_check_synchronization()

func _on_changes():
	emit_signal("settings_changed")

func _check_screenMode() -> void:
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		resolutionButton.disabled = true
	else:
		resolutionButton.disabled = false

func _check_synchronization() -> void:
	if synchronizationButton.button_pressed:
		refreshButton.disabled = true
	else:
		refreshButton.disabled = false
	

# Funcion que aplica el tipo de resolución seleccionada
func _on_ResolutionButton_item_selected(index: int) -> void:
	if index >= 0 and index < resolution.size():
		var res = resolution[index]
		DisplayServer.window_set_size(res)
		_on_changes()
		SFX.play_click()


func _on_ScreenModeButton_item_selected(index: int) -> void:
	var sm = screen_mode[index]
	DisplayServer.window_set_mode(sm)
	_check_screenMode()
	_on_changes()
	SFX.play_click()


func _on_RefreshButton_item_selected(index: int) -> void:
	var selected_hz = refresh_rate[index]
	Engine.max_fps = selected_hz
	_on_changes()
	SFX.play_click()


func _on_QualityButton_item_selected(index: int) -> void:
	var viewport_rid = get_viewport().get_viewport_rid()
	match index:
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
			
	_on_changes()
	SFX.play_click()


func _on_synchronization_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		refreshButton.disabled = true
	else: 
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		refreshButton.disabled = false
	_on_changes()
	SFX.play_click()
