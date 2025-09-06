extends Node2D

var lane: int
var time: float
var scroll_speed: float = 300.0
var playfield: Node = null
var playing: bool = true

const NOTE_WIDTH: float = 128.0
const LANE_COUNT: int = 8
const PLAYFIELD_WIDTH: float = 1024.0  # fixed playfield width

func _process(_delta):
	if playfield == null:
		return

	var song_time = playfield.song_time
	position.y = (playfield.song_time - time) * scroll_speed * playfield.vertical_scale

	var lane_spacing = (PLAYFIELD_WIDTH - NOTE_WIDTH) / (LANE_COUNT - 1)
	position.x = lane * lane_spacing + NOTE_WIDTH / 2
