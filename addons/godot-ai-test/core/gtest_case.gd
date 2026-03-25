class_name GTestCase
extends Node
## AI-First テストケース基底クラス
##
## 使い方:
##   extends GTestCase
##   func test_something() -> void:
##       assert_eq(1 + 1, 2, "basic math")

var _pass_count: int = 0
var _fail_count: int = 0
var _errors: Array[Dictionary] = []
var _current_test: String = ""


# ------------------------------------------------------------------
# Lifecycle — override in subclasses
# ------------------------------------------------------------------

func before_all() -> void:
	pass


func after_all() -> void:
	pass


func before_each() -> void:
	pass


func after_each() -> void:
	pass


# ------------------------------------------------------------------
# Assert methods (8 total)
# ------------------------------------------------------------------

func assert_eq(actual: Variant, expected: Variant, label: String = "") -> void:
	if actual == expected:
		_pass_count += 1
	else:
		_record_failure(label, "expected %s, got %s" % [str(expected), str(actual)])


func assert_true(condition: bool, label: String = "") -> void:
	if condition:
		_pass_count += 1
	else:
		_record_failure(label, "expected true, got false")


func assert_false(condition: bool, label: String = "") -> void:
	if not condition:
		_pass_count += 1
	else:
		_record_failure(label, "expected false, got true")


func assert_gt(actual: Variant, threshold: Variant, label: String = "") -> void:
	if actual > threshold:
		_pass_count += 1
	else:
		_record_failure(label, "expected > %s, got %s" % [str(threshold), str(actual)])


func assert_lt(actual: Variant, threshold: Variant, label: String = "") -> void:
	if actual < threshold:
		_pass_count += 1
	else:
		_record_failure(label, "expected < %s, got %s" % [str(threshold), str(actual)])


func assert_near(actual: float, expected: float, epsilon: float, label: String = "") -> void:
	if absf(actual - expected) <= epsilon:
		_pass_count += 1
	else:
		_record_failure(label, "expected ~%s (±%s), got %s" % [str(expected), str(epsilon), str(actual)])


func assert_not_null(value: Variant, label: String = "") -> void:
	if value != null:
		_pass_count += 1
	else:
		_record_failure(label, "expected non-null, got null")


func assert_has(collection: Variant, item: Variant, label: String = "") -> void:
	if collection is Array and (collection as Array).has(item):
		_pass_count += 1
	elif collection is Dictionary and (collection as Dictionary).has(item):
		_pass_count += 1
	else:
		_record_failure(label, "collection does not contain %s" % str(item))


# ------------------------------------------------------------------
# Internal
# ------------------------------------------------------------------

func _record_failure(label: String, detail: String) -> void:
	_fail_count += 1
	var msg: String = "FAIL: %s — %s" % [label if label != "" else _current_test, detail]
	print(msg)
	_errors.append({
		"test": _current_test,
		"label": label,
		"detail": detail,
	})


func get_results() -> Dictionary:
	return {
		"passed": _pass_count,
		"failed": _fail_count,
		"errors": _errors,
	}
