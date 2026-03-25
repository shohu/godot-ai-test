class_name GTestSingleton
extends Node
## GTest — AI-First テストフレームワーク メインAPI
##
## autoload として登録。テストケースからアクセス:
##   var scene := GTest.load_scene("res://scenes/main.tscn")
##   await GTest.wait(1.0)
##   GTest.save_screenshot("after_action")

const BASELINES_DIR: String = "res://tests/baselines/"
const OUTPUT_DIR: String = "res://tests/output/"

var _screenshot_compare: RefCounted = null


func _ready() -> void:
	_screenshot_compare = preload("res://addons/godot-ai-test/core/screenshot_compare.gd").new()


# ------------------------------------------------------------------
# Scene loading
# ------------------------------------------------------------------

func load_scene(path: String) -> Node:
	if not ResourceLoader.exists(path):
		push_error("[GTest] Scene not found: %s" % path)
		return null
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		push_error("[GTest] Failed to load scene: %s" % path)
		return null
	var instance: Node = packed.instantiate()
	get_tree().root.add_child(instance)
	return instance


# ------------------------------------------------------------------
# Time helpers
# ------------------------------------------------------------------

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func wait_frames(count: int) -> void:
	for i: int in range(count):
		await get_tree().process_frame


# ------------------------------------------------------------------
# Screenshot capture
# ------------------------------------------------------------------

func capture_screenshot() -> Image:
	if DisplayServer.get_name() == "headless":
		push_warning("[GTest] capture_screenshot() is not available in headless mode")
		return null
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()


func save_screenshot(test_name: String) -> String:
	var img: Image = await capture_screenshot()
	if img == null:
		return ""
	var dir_path: String = ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(dir_path)
	var file_path: String = OUTPUT_DIR + test_name + ".png"
	img.save_png(ProjectSettings.globalize_path(file_path))
	return file_path


# ------------------------------------------------------------------
# Screenshot comparison
# ------------------------------------------------------------------

func assert_screenshot_matches(baseline_path: String, tolerance: float = 0.05) -> Dictionary:
	var img: Image = await capture_screenshot()
	if img == null:
		return {"pass": false, "reason": "screenshot capture failed (headless?)"}
	var global_baseline: String = ProjectSettings.globalize_path(baseline_path)
	if not FileAccess.file_exists(global_baseline):
		return {"pass": false, "reason": "baseline not found: %s" % baseline_path}
	var baseline: Image = Image.load_from_file(global_baseline)
	var result: Dictionary = _screenshot_compare.compare(img, baseline, tolerance)
	return result


func assert_screenshot_differs(baseline_path: String, min_diff: float = 0.1) -> Dictionary:
	var img: Image = await capture_screenshot()
	if img == null:
		return {"pass": false, "reason": "screenshot capture failed (headless?)"}
	var global_baseline: String = ProjectSettings.globalize_path(baseline_path)
	if not FileAccess.file_exists(global_baseline):
		return {"pass": false, "reason": "baseline not found: %s" % baseline_path}
	var baseline: Image = Image.load_from_file(global_baseline)
	var result: Dictionary = _screenshot_compare.compare(img, baseline, min_diff)
	# Invert: we WANT the images to differ
	return {
		"pass": not result["pass"],
		"diff_ratio": result.get("diff_ratio", 0.0),
		"reason": "images are too similar" if result["pass"] else "images differ as expected",
	}


func update_baseline(baseline_name: String) -> String:
	var img: Image = await capture_screenshot()
	if img == null:
		return ""
	var dir_path: String = ProjectSettings.globalize_path(BASELINES_DIR)
	DirAccess.make_dir_recursive_absolute(dir_path)
	var file_path: String = BASELINES_DIR + baseline_name
	if not file_path.ends_with(".png"):
		file_path += ".png"
	img.save_png(ProjectSettings.globalize_path(file_path))
	return file_path


# ------------------------------------------------------------------
# Skeleton generation
# ------------------------------------------------------------------

func generate_skeleton(scene_path: String, output_path: String = "") -> String:
	if not ResourceLoader.exists(scene_path):
		push_error("[GTest] Scene not found for skeleton: %s" % scene_path)
		return ""

	var packed: PackedScene = load(scene_path) as PackedScene
	var instance: Node = packed.instantiate()

	var scene_name: String = scene_path.get_file().get_basename()
	if output_path == "":
		output_path = "res://tests/test_%s_skeleton.gd" % scene_name

	var lines: PackedStringArray = PackedStringArray()
	lines.append("extends GTestCase")
	lines.append("## Auto-generated test skeleton for %s" % scene_path)
	lines.append("")
	lines.append("")
	lines.append("func before_each() -> void:")
	lines.append('\tvar _scene: Node = GTest.load_scene("%s")' % scene_path)
	lines.append("")

	# Generate test stubs for each child node
	var children: Array[Node] = _get_all_children(instance)
	for child: Node in children:
		var node_name: String = child.name.to_snake_case()
		lines.append("")
		lines.append("func test_%s_exists() -> void:" % node_name)
		lines.append('\tvar node: Node = get_tree().root.find_child("%s", true, false)' % child.name)
		lines.append('\tassert_not_null(node, "%s should exist")' % child.name)

	instance.queue_free()

	var global_path: String = ProjectSettings.globalize_path(output_path)
	var dir: String = output_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var file: FileAccess = FileAccess.open(global_path, FileAccess.WRITE)
	if file == null:
		push_error("[GTest] Cannot write skeleton: %s" % global_path)
		return ""
	file.store_string("\n".join(lines) + "\n")
	file.close()
	print("[GTest] Skeleton generated: %s" % output_path)
	return output_path


func _get_all_children(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child: Node in node.get_children():
		result.append(child)
		result.append_array(_get_all_children(child))
	return result
