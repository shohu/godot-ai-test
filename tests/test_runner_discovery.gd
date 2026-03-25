extends GTestCase
## ブートストラップテスト: テスト発見ロジックの検証


func test_discover_finds_test_methods() -> void:
	var runner := GTestRunner.new()
	var methods: Array[String] = runner._discover_test_methods(self)
	# This test itself should be discovered
	assert_has(methods, "test_discover_finds_test_methods", "should find this test")
	assert_has(methods, "test_discover_excludes_non_tests", "should find sibling test")
	assert_has(methods, "test_discover_sorts_alphabetically", "should find sibling test")


func test_discover_excludes_non_tests() -> void:
	var runner := GTestRunner.new()
	var methods: Array[String] = runner._discover_test_methods(self)
	# Lifecycle methods should NOT be discovered
	assert_false(methods.has("before_all"), "should not find before_all")
	assert_false(methods.has("before_each"), "should not find before_each")
	assert_false(methods.has("after_all"), "should not find after_all")
	assert_false(methods.has("after_each"), "should not find after_each")
	# Helper methods should NOT be discovered
	assert_false(methods.has("_helper_method"), "should not find private helper")


func test_discover_sorts_alphabetically() -> void:
	var runner := GTestRunner.new()
	var methods: Array[String] = runner._discover_test_methods(self)
	# Verify sorted order
	for i: int in range(methods.size() - 1):
		assert_true(methods[i] <= methods[i + 1],
			"methods should be sorted: %s <= %s" % [methods[i], methods[i + 1]])


func _helper_method() -> void:
	# This should NOT be discovered as a test
	pass
