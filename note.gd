extends Node2D

var lane: int
var time: float
var scroll_speed: float = 200.0
var playfield: Node = null
var vertical_scale: float = 1.0 # 1.0 = default spacing
var playing: bool = true

const NOTE_WIDTH: float = 128.0
const LANE_COUNT: int = 8

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# Zoom out: spread notes further
			vertical_scale *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			# Zoom in: tighten notes
			vertical_scale /= 1.1

func _process(_delta):
	if playfield == null:
		return
	
	var song_time = playfield.song_time
	
	# Scroll DOWN with adjustable spacing
	position.y = (song_time - time) * scroll_speed * vertical_scale
	
	# Horizontal position: offset by half a note
	var screen_width = get_viewport_rect().size.x
	var lane_spacing = (screen_width - NOTE_WIDTH) / (LANE_COUNT - 1)
	position.x = lane * lane_spacing + NOTE_WIDTH / 2
