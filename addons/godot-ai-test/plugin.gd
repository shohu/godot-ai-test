@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("GTest", "res://addons/godot-ai-test/core/gtest.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("GTest")
