extends Node2D

var count: int = 0


func _ready() -> void:
	update_counter()


func increment() -> void:
	count += 1
	update_counter()


func update_counter() -> void:
	var counter_label: Label = $Counter
	counter_label.text = "Count: %d" % count
