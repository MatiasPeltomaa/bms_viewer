extends Node2D

var note_scene := preload("res://note.tscn")

var scratch_notes: Array = []
var lane1_notes: Array = []
var lane2_notes: Array = []
var lane3_notes: Array = []
var lane4_notes: Array = []
var lane5_notes: Array = []
var lane6_notes: Array = []
var lane7_notes: Array = []

var lane_colors := [
	Color(1, 0, 0),
	Color(1, 1, 1),
	Color(0, 0, 1),
	Color(1, 1, 1),
	Color(0, 0, 1),
	Color(1, 1, 1),
	Color(0, 0, 1),
	Color(1, 1, 1)
]

var lane_positions := [64, 128, 192, 256, 320, 384, 448, 512]

var current_measure: int = 1
var total_measures: int = 1

func _ready():
	var file_path = "res://_DoomeyTunes_MARYTHER.bms"
	parse_bms(file_path)

	for lane in [scratch_notes, lane1_notes, lane2_notes, lane3_notes, lane4_notes, lane5_notes, lane6_notes, lane7_notes]:
		for note in lane:
			total_measures = max(total_measures, note.measure)

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

		var lane_map = {
			"16": scratch_notes,
			"11": lane1_notes,
			"12": lane2_notes,
			"13": lane3_notes,
			"14": lane4_notes,
			"15": lane5_notes,
			"18": lane6_notes,
			"19": lane7_notes
		}

		if channel in lane_map:
			var lane_array = lane_map[channel]
			var divisions = data.length() / 2
			for i in range(divisions):
				var pair = data.substr(i * 2, 2)
				if pair != "00":
					var frac: float = float(i) / float(divisions)
					print("Lane %s - Measure %d, Slot %d/%d, fraction: %.3f" % [channel, measure_num, i + 1, divisions, frac])
					lane_array.append({
						"measure": measure_num,
						"slot": i + 1,
						"total_slots": divisions,
						"frac": frac
					})

func show_measure(measure_index: int) -> void:
	for child in get_children():
		child.queue_free()

	var viewport_height = get_viewport_rect().size.y

	var lanes = [scratch_notes, lane1_notes, lane2_notes, lane3_notes, lane4_notes, lane5_notes, lane6_notes, lane7_notes]

	for lane_index in range(lanes.size()):
		var lane_array = lanes[lane_index]
		var x_pos = lane_positions[lane_index]
		var notes_to_show = lane_array.filter(func(n): return n.measure == measure_index)

		for note_data in notes_to_show:
			var frac = note_data.frac
			var y = viewport_height - (frac * viewport_height)
			var note_instance = note_scene.instantiate()
			if note_instance.has_method("set_note_data"):
				note_instance.set_note_data(note_data.measure, note_data.slot, note_data.total_slots)
			note_instance.position = Vector2(x_pos, y)
			if note_instance is CanvasItem:
				note_instance.modulate = lane_colors[lane_index]
			add_child(note_instance)
