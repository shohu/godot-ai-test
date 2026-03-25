extends GTestCase
## ブートストラップテスト: スクリーンショット比較エンジンの検証


func test_identical_images() -> void:
	var img := Image.create(100, 100, false, Image.FORMAT_RGBA8)
	img.fill(Color.RED)
	var compare := ScreenshotCompare.new()
	var result: Dictionary = compare.compare(img, img, 0.0)
	assert_true(result["pass"], "identical images should pass with 0 tolerance")
	assert_eq(result["diff_ratio"], 0.0, "diff ratio should be 0")


func test_completely_different_images() -> void:
	var img_a := Image.create(100, 100, false, Image.FORMAT_RGBA8)
	img_a.fill(Color.RED)
	var img_b := Image.create(100, 100, false, Image.FORMAT_RGBA8)
	img_b.fill(Color.BLUE)
	var compare := ScreenshotCompare.new()
	var result: Dictionary = compare.compare(img_a, img_b, 0.05)
	assert_false(result["pass"], "completely different images should fail")
	assert_gt(result["diff_ratio"], 0.05, "diff ratio should exceed tolerance")


func test_within_tolerance() -> void:
	var img_a := Image.create(100, 100, false, Image.FORMAT_RGBA8)
	img_a.fill(Color.RED)
	var img_b := img_a.duplicate()
	# Modify 1 pixel out of 10000 = 0.01%
	img_b.set_pixel(0, 0, Color.BLUE)
	var compare := ScreenshotCompare.new()
	var result: Dictionary = compare.compare(img_a, img_b, 0.05)
	assert_true(result["pass"], "1 pixel diff out of 10000 should pass with 5% tolerance")


func test_size_mismatch() -> void:
	var img_a := Image.create(100, 100, false, Image.FORMAT_RGBA8)
	var img_b := Image.create(200, 200, false, Image.FORMAT_RGBA8)
	var compare := ScreenshotCompare.new()
	var result: Dictionary = compare.compare(img_a, img_b, 0.05)
	assert_false(result["pass"], "size mismatch should fail")
	assert_true(result["reason"].contains("size mismatch"), "reason should mention size mismatch")


func test_early_return_performance() -> void:
	# Create two very different large images
	var img_a := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	img_a.fill(Color.RED)
	var img_b := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	img_b.fill(Color.BLUE)
	var compare := ScreenshotCompare.new()
	# With 0% tolerance, should early-return almost immediately
	var start: int = Time.get_ticks_msec()
	var result: Dictionary = compare.compare(img_a, img_b, 0.0)
	var elapsed: int = Time.get_ticks_msec() - start
	assert_false(result["pass"], "should fail")
	# Early return should make this very fast even for large images
	assert_lt(elapsed, 1000, "early return should complete in < 1 second")
