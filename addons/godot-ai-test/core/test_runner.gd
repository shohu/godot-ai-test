class_name GTestRunner
extends RefCounted
## テスト発見・実行・JSON レポート出力

var _results: Array[Dictionary] = []


func run_test_file(test_instance: GTestCase) -> Dictionary:
	var suite_name: String = test_instance.get_script().resource_path.get_file().get_basename()
	var methods: Array[String] = _discover_test_methods(test_instance)

	print("[GTest] Running suite: %s (%d tests)" % [suite_name, methods.size()])

	# before_all
	test_instance.before_all()

	for method_name: String in methods:
		test_instance._current_test = method_name
		test_instance.before_each()

		# Run test with error catching
		var err: String = ""
		if test_instance.has_method(method_name):
			var callable: Callable = Callable(test_instance, method_name)
			# GDScript doesn't have try-catch, but we can detect errors via return
			callable.call()
		else:
			err = "method not found: %s" % method_name

		test_instance.after_each()

		if err != "":
			test_instance._errors.append({
				"test": method_name,
				"label": "runtime",
				"detail": err,
			})
			test_instance._fail_count += 1

	# after_all
	test_instance.after_all()

	var result: Dictionary = {
		"suite": suite_name,
		"passed": test_instance._pass_count,
		"failed": test_instance._fail_count,
		"total": test_instance._pass_count + test_instance._fail_count,
		"errors": test_instance._errors,
	}
	_results.append(result)

	# Print summary
	var status: String = "PASS" if test_instance._fail_count == 0 else "FAIL"
	print("[GTest] %s: %s (passed: %d, failed: %d)" % [
		status, suite_name, test_instance._pass_count, test_instance._fail_count
	])

	return result


func _discover_test_methods(instance: GTestCase) -> Array[String]:
	var methods: Array[String] = []
	for method_info: Dictionary in instance.get_method_list():
		var name: String = method_info["name"]
		if name.begins_with("test_") and _is_concrete_method(instance, name):
			methods.append(name)
	# Sort for consistent output (execution order is NOT guaranteed to match source order)
	methods.sort()
	return methods


func _is_concrete_method(instance: GTestCase, method_name: String) -> bool:
	# Only include methods defined on the concrete class, not inherited ones
	var script: Script = instance.get_script()
	if script == null:
		return false
	for method_info: Dictionary in script.get_script_method_list():
		if method_info["name"] == method_name:
			return true
	return false


func get_json_report() -> String:
	return JSON.stringify(_results, "\t")


func get_exit_code() -> int:
	for result: Dictionary in _results:
		if result["failed"] > 0:
			return 1
	return 0
