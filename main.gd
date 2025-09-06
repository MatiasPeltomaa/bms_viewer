extends Node2D

const NOTE_SCENE = preload("res://note.tscn")

var bpm_definitions: Dictionary = {}
var bpm_events: Array = []
var notes: Array = []

var start_bpm: float = 120.0
var song_time: float = 0.0
var scroll_speed: float = 200.0 # pixels per second
var playing: bool = false

func _ready():
	get_viewport().files_dropped.connect(on_files_dropped)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			toggle_pause()

func toggle_pause():
	playing = !playing
	if playing:
		print("Resumed")
	else:
		print("Paused")
# --------------------------
# FILE LOADING
# --------------------------
func on_files_dropped(files):
	var file_path = "".join(files)
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Could not open ", file_path)
		return
	
	parse_bms(file.get_as_text())
	start_song()

# --------------------------
# PARSER
# --------------------------
func parse_bms(text: String):
	for line in text.split("\n"):
		line = line.strip_edges()
		if line == "" or not line.begins_with("#"):
			continue
		
		# BPM definitions (#BPMxx val)
		if line.begins_with("#BPM") and line.length() > 6 and line[4].is_valid_int() == false:
			var bpm_id = line.substr(4, 2)
			var bpm_val = float(line.split(" ")[1])
			bpm_definitions[bpm_id] = bpm_val
			continue
		
		# Parse measure/channel/data
		if line.length() < 7:
			continue
		var measure = int(line.substr(1, 3))
		var channel = int(line.substr(4, 2))
		var data = line.substr(7, line.length()).strip_edges()
		var total_divs = data.length() / 2
		
		for i in range(total_divs):
			var pair = data.substr(i * 2, 2)
			if pair == "00":
				continue
			var fraction = float(i) / float(total_divs)
			
			match channel:
				11: add_note(measure, fraction, 1)
				12: add_note(measure, fraction, 2)
				13: add_note(measure, fraction, 3)
				14: add_note(measure, fraction, 4)
				15: add_note(measure, fraction, 5)
				18: add_note(measure, fraction, 6)
				19: add_note(measure, fraction, 7)
				16: add_note(measure, fraction, 0) # scratch = lane 0
				
				2: # BPM hex
					var bpm_val = int("0x" + pair)
					bpm_events.append({ "measure": measure, "fraction": fraction, "bpm": bpm_val })
				3: # BPM reference
					if bpm_definitions.has(pair):
						var bpm_val2 = bpm_definitions[pair]
						bpm_events.append({ "measure": measure, "fraction": fraction, "bpm": bpm_val2 })

# --------------------------
# DATA HELPERS
# --------------------------
func add_note(measure: int, fraction: float, lane: int):
	notes.append({ "measure": measure, "fraction": fraction, "lane": lane })

func measure_to_time(measure: int, fraction: float) -> float:
	var time = 0.0
	var bpm = start_bpm
	var beat_len = 60.0 / bpm
	
	# Walk measures
	for m in range(measure):
		time += 4.0 * beat_len
	
	# BPM events in same measure
	for e in bpm_events:
		if e.measure == measure and e.fraction <= fraction:
			bpm = e.bpm
			beat_len = 60.0 / bpm
	
	time += 4.0 * beat_len * fraction
	return time

# --------------------------
# GAME LOOP
# --------------------------
func start_song():
	playing = true
	song_time = 0.0
	for note in notes:
		var t = measure_to_time(note.measure, note.fraction)
		note.time = t
		spawn_note(note)

# In Playfield.gd
func spawn_note(note):
	var n = NOTE_SCENE.instantiate()
	n.lane = note.lane
	n.time = note.time
	n.playfield = self   # give reference
	add_child(n)


func _process(delta):
	if not playing:
		return
	song_time += delta
