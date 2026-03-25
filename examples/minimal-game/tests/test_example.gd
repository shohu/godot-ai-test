extends GTestCase
## Minimal game のテスト例 — GTest フレームワーク使用例


func test_scene_loads() -> void:
	var scene: Node = GTest.load_scene("res://examples/minimal-game/scenes/main.tscn")
	assert_not_null(scene, "main scene should load")
	if scene:
		scene.queue_free()


func test_initial_count() -> void:
	var scene: Node = GTest.load_scene("res://examples/minimal-game/scenes/main.tscn")
	assert_not_null(scene, "scene loaded")
	if scene:
		assert_eq(scene.count, 0, "initial count should be 0")
		scene.queue_free()


func test_increment() -> void:
	var scene: Node = GTest.load_scene("res://examples/minimal-game/scenes/main.tscn")
	assert_not_null(scene, "scene loaded")
	if scene:
		scene.increment()
		assert_eq(scene.count, 1, "count should be 1 after increment")
		scene.increment()
		scene.increment()
		assert_eq(scene.count, 3, "count should be 3 after 3 increments")
		scene.queue_free()


func test_counter_label_updates() -> void:
	var scene: Node = GTest.load_scene("res://examples/minimal-game/scenes/main.tscn")
	assert_not_null(scene, "scene loaded")
	if scene:
		var label: Label = scene.find_child("Counter", true, false)
		assert_not_null(label, "Counter label should exist")
		if label:
			assert_eq(label.text, "Count: 0", "initial label text")
			scene.increment()
			assert_eq(label.text, "Count: 1", "label after increment")
		scene.queue_free()
