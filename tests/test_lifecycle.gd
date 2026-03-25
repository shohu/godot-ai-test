extends GTestCase
## ブートストラップテスト: ライフサイクル順序の検証

var _lifecycle_log: Array[String] = []


func before_all() -> void:
	_lifecycle_log.append("before_all")


func after_all() -> void:
	_lifecycle_log.append("after_all")
	# Verify lifecycle at the very end
	# Note: after_all runs AFTER all tests, so we check the accumulated log
	# The expected order is: before_all, then for each test: before_each, test_*, after_each
	# We can't assert here because results are already collected, but we print for verification
	print("[GTest:lifecycle] %s" % str(_lifecycle_log))


func before_each() -> void:
	_lifecycle_log.append("before_each")


func after_each() -> void:
	_lifecycle_log.append("after_each")


func test_first() -> void:
	_lifecycle_log.append("test_first")
	# At this point: before_all, before_each, test_first
	assert_has(_lifecycle_log, "before_all", "before_all should have run")
	assert_has(_lifecycle_log, "before_each", "before_each should have run")


func test_second() -> void:
	_lifecycle_log.append("test_second")
	# At this point: before_all, before_each, test_first, after_each, before_each, test_second
	# Verify before_each ran again
	var before_each_count: int = _lifecycle_log.count("before_each")
	assert_gt(before_each_count, 1, "before_each should run before each test")
	# Verify after_each ran between tests
	assert_has(_lifecycle_log, "after_each", "after_each should have run after first test")
