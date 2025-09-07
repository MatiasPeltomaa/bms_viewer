extends Node2D

var measure: int
var slot: int
var total_slots: int

func set_note_data(m: int, s: int, t: int) -> void:
	measure = m
	slot = s
	total_slots = t
