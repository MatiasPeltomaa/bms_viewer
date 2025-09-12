extends Node2D

var note_scene := preload("res://note.tscn")

var scroll_offset: float = 0.0
var scroll_speed: float = 100.0

var scratch_notes: Array = []
var lane1_notes: Array = []
var lane2_notes: Array = []
var lane3_notes: Array = []
var lane4_notes: Array = []
var lane5_notes: Array = []
var lane6_notes: Array = []
var lane7_notes: Array = []

var lane_colors := [
	Color(0.991, 0.479, 0.397),
	Color(1, 1, 1),
	Color(0.451, 0.552, 0.956),
	Color(1, 1, 1),
	Color(0.451, 0.552, 0.956),
	Color(1, 1, 1),
	Color(0.451, 0.552, 0.956),
	Color(1, 1, 1)
]

var total_measures: int = 1
var lane_positions: Array = []

func _ready():
	get_viewport().files_dropped.connect(_on_files_dropped)

	var window_width := get_viewport_rect().size.x
	var lane_spacing := 64
	var main_lane_count := 7
	var playfield_width := (main_lane_count - 1) * lane_spacing
	var start_x := (window_width - playfield_width) / 2

	lane_positions.append(start_x - lane_spacing)
	for i in range(main_lane_count):
		lane_positions.append(start_x + i * lane_spacing)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var viewport_height = get_viewport_rect().size.y
		var measure_height = viewport_height
		var max_scroll = max(0, total_measures * measure_height - viewport_height)

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_offset = max(scroll_offset - scroll_speed, 0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_offset = min(scroll_offset + scroll_speed, max_scroll)

func _process(_delta):
	position.y = -scroll_offset
	if $ui:
		$ui/lane_divider_left.position.x = lane_positions[0] - 64
		$ui/lane_divider_7.position.x = lane_positions[1] - 32
		$ui/lane_divider_1.position.x = lane_positions[1] + 32
		$ui/lane_divider_2.position.x = lane_positions[2] + 32
		$ui/lane_divider_3.position.x = lane_positions[3] + 32
		$ui/lane_divider_4.position.x = lane_positions[4] + 32
		$ui/lane_divider_5.position.x = lane_positions[5] + 32
		$ui/lane_divider_6.position.x = lane_positions[6] + 32
		$ui/lane_divider_right.position.x = lane_positions[7] + 32

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
					lane_array.append({
						"measure": measure_num,
						"slot": i + 1,
						"total_slots": divisions,
						"frac": frac
					})
					
		total_measures = max(total_measures, measure_num + 1)

func spawn_all_notes() -> void:
	var viewport_height = get_viewport_rect().size.y
	var measure_height = viewport_height

	var lanes = [scratch_notes, lane1_notes, lane2_notes, lane3_notes, lane4_notes, lane5_notes, lane6_notes, lane7_notes]

	for lane_index in range(lanes.size()):
		var lane_array = lanes[lane_index]
		var x_pos = lane_positions[lane_index]

		for note_data in lane_array:
			var frac = note_data.frac
			var y = (total_measures - note_data.measure) * measure_height + (1.0 - frac) * measure_height

			var note_instance = note_scene.instantiate()
			if note_instance.has_method("set_note_data"):
				note_instance.set_note_data(note_data.measure, note_data.slot, note_data.total_slots)

			note_instance.position = Vector2(x_pos, y)

			if note_instance is CanvasItem:
				note_instance.modulate = lane_colors[lane_index]

			if lane_index == 0:
				var x_pos_2 = lane_positions[0] - 16
				note_instance.scale.x = 1.5
				note_instance.position = Vector2(x_pos_2, y)

			add_child(note_instance)

func draw_measure_lines():
	var viewport_height = get_viewport_rect().size.y
	var measure_height = viewport_height

	var playfield_left = lane_positions[0] - 64
	var playfield_right = lane_positions[7] + 32
	var playfield_width = playfield_right - playfield_left

	for m in range(total_measures + 1):
		var y = (total_measures - m) * measure_height

		var line = ColorRect.new()
		line.color = Color(0.5, 0.5, 0.5)
		line.position = Vector2(playfield_left, y)
		line.size = Vector2(playfield_width, 4)
		add_child(line)

func _on_files_dropped(files: PackedStringArray) -> void:
	if files.is_empty():
		return

	var file_path := files[0]
	if file_path.to_lower().ends_with(".bms"):
		print("Dropped BMS file: ", file_path)

		for child in get_children():
			if child != $ui:
				child.queue_free()

		scratch_notes.clear()
		lane1_notes.clear()
		lane2_notes.clear()
		lane3_notes.clear()
		lane4_notes.clear()
		lane5_notes.clear()
		lane6_notes.clear()
		lane7_notes.clear()
		total_measures = 1

		parse_bms(file_path)
		spawn_all_notes()
		draw_measure_lines()

		var viewport_height = get_viewport_rect().size.y
		scroll_offset = (total_measures - 1) * viewport_height
	else:
		push_warning("Unsupported file type: " + file_path)
