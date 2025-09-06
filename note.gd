extends Node2D

# Optional: store measure/slot info
var measure: int
var slot: int
var total_slots: int

# Called from Main.gd when instantiating
func set_note_data(m: int, s: int, t: int) -> void:
	measure = m
	slot = s
	total_slots = t
