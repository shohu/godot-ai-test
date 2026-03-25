extends GTestCase
## ブートストラップテスト: assert メソッド全8種の PASS/FAIL パス


func test_assert_eq_pass() -> void:
	assert_eq(42, 42, "integers should be equal")
	assert_eq("hello", "hello", "strings should be equal")
	assert_eq([], [], "empty arrays should be equal")


func test_assert_eq_fail() -> void:
	# Intentionally test failure recording
	var before_fail: int = _fail_count
	assert_eq(1, 2, "intentional fail")
	assert_eq(_fail_count, before_fail + 1, "fail count should increment")
	# Restore: remove the intentional failure from errors
	_errors.pop_back()
	_fail_count -= 1


func test_assert_true() -> void:
	assert_true(true, "true is true")
	assert_true(1 == 1, "equality check")
	assert_true(10 > 5, "comparison")


func test_assert_false() -> void:
	assert_false(false, "false is false")
	assert_false(1 == 2, "inequality")


func test_assert_gt() -> void:
	assert_gt(10, 5, "10 > 5")
	assert_gt(0.5, 0.1, "float comparison")


func test_assert_lt() -> void:
	assert_lt(5, 10, "5 < 10")
	assert_lt(-1, 0, "negative < zero")


func test_assert_near() -> void:
	assert_near(3.14159, 3.14, 0.01, "pi approximation")
	assert_near(1.0, 1.0, 0.0, "exact match")


func test_assert_not_null() -> void:
	assert_not_null("string", "string is not null")
	assert_not_null(0, "zero is not null")
	assert_not_null([], "empty array is not null")


func test_assert_has_array() -> void:
	assert_has([1, 2, 3], 2, "array contains 2")
	assert_has(["a", "b"], "a", "array contains 'a'")


func test_assert_has_dictionary() -> void:
	assert_has({"key": "value"}, "key", "dict has key")
