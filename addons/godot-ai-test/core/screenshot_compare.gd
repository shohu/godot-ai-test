class_name ScreenshotCompare
extends RefCounted
## スクリーンショット比較エンジン — PackedByteArray + 早期リターン最適化

const CHANNEL_THRESHOLD: int = 10  # 各チャンネル差がこの値を超えたら「異なるピクセル」


func compare(actual: Image, baseline: Image, tolerance: float) -> Dictionary:
	if actual.get_size() != baseline.get_size():
		return {
			"pass": false,
			"diff_ratio": 1.0,
			"reason": "size mismatch: actual %s vs baseline %s" % [
				str(actual.get_size()), str(baseline.get_size())
			],
		}

	# RGBA8 に統一
	if actual.get_format() != Image.FORMAT_RGBA8:
		actual.convert(Image.FORMAT_RGBA8)
	if baseline.get_format() != Image.FORMAT_RGBA8:
		baseline.convert(Image.FORMAT_RGBA8)

	var actual_data: PackedByteArray = actual.get_data()
	var baseline_data: PackedByteArray = baseline.get_data()
	var total_pixels: int = actual.get_width() * actual.get_height()
	var max_diff_pixels: int = int(float(total_pixels) * tolerance)
	var diff_count: int = 0

	# 4 bytes per pixel (RGBA)
	var byte_count: int = actual_data.size()
	var i: int = 0
	while i < byte_count:
		var dr: int = absi(actual_data[i] - baseline_data[i])
		var dg: int = absi(actual_data[i + 1] - baseline_data[i + 1])
		var db: int = absi(actual_data[i + 2] - baseline_data[i + 2])
		if dr > CHANNEL_THRESHOLD or dg > CHANNEL_THRESHOLD or db > CHANNEL_THRESHOLD:
			diff_count += 1
			# Early return: if diff exceeds tolerance, no need to continue
			if diff_count > max_diff_pixels:
				return {
					"pass": false,
					"diff_ratio": float(diff_count) / float(total_pixels),
					"reason": "diff exceeded tolerance (>%d/%d pixels)" % [max_diff_pixels, total_pixels],
				}
		i += 4  # skip alpha

	var diff_ratio: float = float(diff_count) / float(total_pixels)
	return {
		"pass": true,
		"diff_ratio": diff_ratio,
		"diff_pixels": diff_count,
		"total_pixels": total_pixels,
		"reason": "within tolerance (%.2f%% diff, %.2f%% allowed)" % [diff_ratio * 100.0, tolerance * 100.0],
	}
