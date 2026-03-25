extends SceneTree
## CLI テストランナーエントリポイント
##
## Usage:
##   godot --headless --path . -s addons/godot-ai-test/cli/runner.gd -- tests/test_foo.gd
##   godot --path . -s addons/godot-ai-test/cli/runner.gd -- tests/test_foo.gd

var _gtest: Node = null
var _runner: GTestRunner = null


func _init() -> void:
	# Parse command line arguments
	var test_path: String = _get_test_path()
	if test_path == "":
		print("[GTest] Error: No test file specified")
		print("[GTest] Usage: godot -s addons/godot-ai-test/cli/runner.gd -- <test_file.gd>")
		quit(1)
		return

	# Manually load GTest autoload (not registered in project.godot)
	var gtest_script: Script = preload("res://addons/godot-ai-test/core/gtest.gd")
	_gtest = gtest_script.new()
	_gtest.name = "GTest"
	root.add_child(_gtest)

	# Load and instantiate the test file
	if not ResourceLoader.exists(test_path):
		print("[GTest] Error: Test file not found: %s" % test_path)
		quit(1)
		return

	var test_script: Script = load(test_path) as Script
	if test_script == null:
		print("[GTest] Error: Failed to load test script: %s" % test_path)
		quit(1)
		return

	var test_instance: Node = test_script.new()
	if not test_instance is GTestCase:
		print("[GTest] Error: Test must extend GTestCase: %s" % test_path)
		test_instance.queue_free()
		quit(1)
		return

	# Add test to tree so it can access scene tree features
	root.add_child(test_instance)

	# Run tests
	_runner = GTestRunner.new()
	var result: Dictionary = _runner.run_test_file(test_instance as GTestCase)

	# Output JSON report
	var json_report: String = _runner.get_json_report()
	print("\n[GTest:JSON]")
	print(json_report)
	print("[/GTest:JSON]")

	# Save JSON report to file
	var report_path: String = "res://tests/output/%s_report.json" % test_path.get_file().get_basename()
	var global_report: String = ProjectSettings.globalize_path(report_path)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tests/output/"))
	var file: FileAccess = FileAccess.open(global_report, FileAccess.WRITE)
	if file:
		file.store_string(json_report)
		file.close()

	# Cleanup and exit
	test_instance.queue_free()
	quit(_runner.get_exit_code())


func _get_test_path() -> String:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for arg: String in args:
		if arg.ends_with(".gd"):
			# Ensure res:// prefix
			if not arg.begins_with("res://"):
				if arg.begins_with("/") or arg.begins_with("./"):
					# Absolute or relative path — try to convert
					return "res://" + arg.lstrip("./")
				return "res://" + arg
			return arg
	return ""
