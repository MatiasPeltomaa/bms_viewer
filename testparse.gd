extends Node2D

# ----------------------------------------------------
# 1. Parse the raw chart into a dictionary:
#    measures[measure] = { channel : data_string }
# ----------------------------------------------------
var bpm_definitions := {}
var measures: Dictionary = {}

func parse_chart(text: String) -> void:
	for line in text.split("\n"):
		line = line.strip_edges()
		if line == "" or not line.begins_with("#"):
			continue

		# BPM definitions – “#BPMxx value”
		if line.begins_with("#BPM") and line.length() > 6 and not line[4].is_valid_int():
			var parts = line.split(" ", false, 2)
			if parts.size() >= 2:
				var bpm_id   = line.substr(4, 2)     # e.g. “01”
				var bpm_val  = float(parts[1])      # e.g. 150.0
				bpm_definitions[bpm_id] = bpm_val
			continue

		if line.length() < 7:          # too short to contain a measure
			continue

		var measure : int = int(line.substr(1, 3))   # “001”
		var channel : int = int(line.substr(4, 2))   # “02” etc.
		var data    : String = line.substr(7).strip_edges()

		if data == "":
			continue

		if not measures.has(measure):
			measures[measure] = {}
		measures[measure][channel] = data
