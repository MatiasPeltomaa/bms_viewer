extends Node2D

# Preload your note scene
var NoteScene := preload("res://note.tscn")

# Storage
var lane7_notes: Array = []
var lane1_notes: Array = []
var lane2_notes: Array = []
var lane3_notes: Array = []
var lane5_notes: Array = []
var lane4_notes: Array = []
var lane6_notes: Array = []

# Visual settings
var lane_width: float = 128   # width per lane
var lane7_number: int = 7
var lane1_number: int = 1
var lane2_number: int = 1
var lane3_number: int = 1
var lane4_number: int = 1
var lane5_number: int = 1
var lane6_number: int = 1

# Current visible measure
var current_measure: int = 1
var total_measures: int = 1

func _ready():
	var file_path = "res://_DoomeyTunes_MARYTHER.bms"
	parse_bms(file_path)

	# Determine total measures across both lanes
	for note in lane7_notes:
		total_measures = max(total_measures, note.measure)
	for note in lane1_notes:
		total_measures = max(total_measures, note.measure)

	# Show the first measure
	show_measure(current_measure)

func _input(event):
	if event.is_action_pressed("ui_up"):
		current_measure = max(current_measure - 1, 1)
		show_measure(current_measure)
	elif event.is_action_pressed("ui_down"):
		current_measure = min(current_measure + 1, total_measures)
		show_measure(current_measure)

func parse_bms(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Could not open file: %s" % path)
		return

	file.seek(0)
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if not line.begins_with("#") or line.length() <= 7:
			continue

		var measure_num = int(line.substr(1, 3))
		if measure_num == 0:
			continue

		var channel = line.substr(4, 2)
		var data = line.substr(7)

		# --- Lane 7 ---
		if channel == "19":
			var divisions = data.length() / 2
			for i in range(divisions):
				var pair = data.substr(i * 2, 2)
				if pair != "00":
					lane7_notes.append({
						"measure": measure_num,
						"slot": i + 1,
						"total_slots": divisions
					})

		# --- Lane 1 ---
		if channel == "11":
			var divisions = data.length() / 2
			for i in range(divisions):
				var pair = data.substr(i * 2, 2)
				if pair != "00":
					lane1_notes.append({
						"measure": measure_num,
						"slot": i + 1,
						"total_slots": divisions
					})

		if channel == "12":
			var divisions = data.length() / 2
			for i in range(divisions):
				var pair = data.substr(i * 2, 2)
				if pair != "00":
					lane2_notes.append({
						"measure": measure_num,
						"slot": i + 1,
						"total_slots": divisions
					})

		if channel == "13":
			var divisions = data.length() / 2
			for i in range(divisions):
				var pair = data.substr(i * 2, 2)
				if pair != "00":
					lane3_notes.append({
						"measure": measure_num,
						"slot": i + 1,
						"total_slots": divisions
					})

		if channel == "14":
			var divisions = data.length() / 2
			for i in range(divisions):
				var pair = data.substr(i * 2, 2)
				if pair != "00":
					lane4_notes.append({
						"measure": measure_num,
						"slot": i + 1,
						"total_slots": divisions
					})

		if channel == "15":
			var divisions = data.length() / 2
			for i in range(divisions):
				var pair = data.substr(i * 2, 2)
				if pair != "00":
					lane5_notes.append({
						"measure": measure_num,
						"slot": i + 1,
						"total_slots": divisions
					})

		if channel == "18":
			var divisions = data.length() / 2
			for i in range(divisions):
				var pair = data.substr(i * 2, 2)
				if pair != "00":
					lane6_notes.append({
						"measure": measure_num,
						"slot": i + 1,
						"total_slots": divisions
					})

func show_measure(measure_index: int) -> void:
	# Clear current notes
	for child in get_children():
		child.queue_free()

	var viewport_height = get_viewport_rect().size.y

	# --- Lane 7 ---
	var lane7_x = 512
	var notes_to_show7 = lane7_notes.filter(func(n): return n.measure == measure_index)
	for note_data in notes_to_show7:
		var note_instance = NoteScene.instantiate()
		if note_instance.has_method("set_note_data"):
			note_instance.set_note_data(note_data.measure, note_data.slot, note_data.total_slots)

		var y = viewport_height - ((note_data.slot - 0.5) / note_data.total_slots) * viewport_height
		note_instance.position = Vector2(lane7_x, y)
		add_child(note_instance)

	# --- Lane 1 ---
	var lane1_x = 128
	var notes_to_show1 = lane1_notes.filter(func(n): return n.measure == measure_index)
	for note_data in notes_to_show1:
		var note_instance = NoteScene.instantiate()
		if note_instance.has_method("set_note_data"):
			note_instance.set_note_data(note_data.measure, note_data.slot, note_data.total_slots)

		var y = viewport_height - ((note_data.slot - 0.5) / note_data.total_slots) * viewport_height
		note_instance.position = Vector2(lane1_x, y)
		add_child(note_instance)

	var lane2_x = 192
	var notes_to_show2 = lane2_notes.filter(func(n): return n.measure == measure_index)
	for note_data in notes_to_show2:
		print("Lane 2 - Measure %d, Slot %d/%d" % [note_data.measure, note_data.slot, note_data.total_slots])
		var note_instance = NoteScene.instantiate()
		if note_instance.has_method("set_note_data"):
			note_instance.set_note_data(note_data.measure, note_data.slot, note_data.total_slots)

		var y = viewport_height - ((note_data.slot - 0.5) / note_data.total_slots) * viewport_height
		note_instance.position = Vector2(lane2_x, y)
		add_child(note_instance)

	var lane3_x = 256
	var notes_to_show3 = lane3_notes.filter(func(n): return n.measure == measure_index)
	for note_data in notes_to_show3:
		var note_instance = NoteScene.instantiate()
		if note_instance.has_method("set_note_data"):
			note_instance.set_note_data(note_data.measure, note_data.slot, note_data.total_slots)

		var y = viewport_height - ((note_data.slot - 0.5) / note_data.total_slots) * viewport_height
		note_instance.position = Vector2(lane3_x, y)
		add_child(note_instance)

	var lane4_x = 320
	var notes_to_show4 = lane4_notes.filter(func(n): return n.measure == measure_index)
	for note_data in notes_to_show4:
		var note_instance = NoteScene.instantiate()
		if note_instance.has_method("set_note_data"):
			note_instance.set_note_data(note_data.measure, note_data.slot, note_data.total_slots)

		var y = viewport_height - ((note_data.slot - 0.5) / note_data.total_slots) * viewport_height
		note_instance.position = Vector2(lane4_x, y)
		add_child(note_instance)

	var lane5_x = 384
	var notes_to_show5 = lane5_notes.filter(func(n): return n.measure == measure_index)
	for note_data in notes_to_show5:
		var note_instance = NoteScene.instantiate()
		if note_instance.has_method("set_note_data"):
			note_instance.set_note_data(note_data.measure, note_data.slot, note_data.total_slots)

		var y = viewport_height - ((note_data.slot - 0.5) / note_data.total_slots) * viewport_height
		note_instance.position = Vector2(lane5_x, y)
		add_child(note_instance)

	var lane6_x = 448
	var notes_to_show6 = lane6_notes.filter(func(n): return n.measure == measure_index)
	for note_data in notes_to_show6:
		var note_instance = NoteScene.instantiate()
		if note_instance.has_method("set_note_data"):
			note_instance.set_note_data(note_data.measure, note_data.slot, note_data.total_slots)

		var y = viewport_height - ((note_data.slot - 0.5) / note_data.total_slots) * viewport_height
		note_instance.position = Vector2(lane6_x, y)
		add_child(note_instance)
