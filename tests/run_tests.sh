#!/usr/bin/env bash
## Godot AI Test — フレームワーク自身のブートストラップテスト（シェルベース外部検証）
## runner.gd の循環依存を避けるため、外部からプロセス起動 + exit code で検証
set -euo pipefail

GODOT_CMD="${GODOT_CMD:-godot}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

failed=0
total=0
passed=0
failed_tests=()

echo "========================================="
echo "[GTest] Bootstrap Test Suite"
echo "========================================="
echo ""

# --- Test 1: runner.gd with no args should fail ---
total=$((total + 1))
echo "--- Test: runner with no args exits 1 ---"
if "$GODOT_CMD" --headless --path "$PROJECT_DIR" -s addons/godot-ai-test/cli/runner.gd 2>&1; then
	echo "--- FAIL: should have exited with error ---"
	failed=$((failed + 1))
	failed_tests+=("runner_no_args")
else
	echo "--- PASS: correctly exits with error ---"
	passed=$((passed + 1))
fi
echo ""

# --- Test 2: runner.gd with nonexistent file should fail ---
total=$((total + 1))
echo "--- Test: runner with nonexistent file exits 1 ---"
if "$GODOT_CMD" --headless --path "$PROJECT_DIR" -s addons/godot-ai-test/cli/runner.gd -- tests/nonexistent.gd 2>&1; then
	echo "--- FAIL: should have exited with error ---"
	failed=$((failed + 1))
	failed_tests+=("runner_nonexistent")
else
	echo "--- PASS: correctly exits with error ---"
	passed=$((passed + 1))
fi
echo ""

# --- Test 3: assert tests pass ---
total=$((total + 1))
echo "--- Test: test_asserts.gd ---"
if "$GODOT_CMD" --headless --path "$PROJECT_DIR" -s addons/godot-ai-test/cli/runner.gd -- tests/test_asserts.gd 2>&1; then
	echo "--- PASS: test_asserts.gd ---"
	passed=$((passed + 1))
else
	echo "--- FAIL: test_asserts.gd ---"
	failed=$((failed + 1))
	failed_tests+=("test_asserts")
fi
echo ""

# --- Test 4: lifecycle tests pass ---
total=$((total + 1))
echo "--- Test: test_lifecycle.gd ---"
if "$GODOT_CMD" --headless --path "$PROJECT_DIR" -s addons/godot-ai-test/cli/runner.gd -- tests/test_lifecycle.gd 2>&1; then
	echo "--- PASS: test_lifecycle.gd ---"
	passed=$((passed + 1))
else
	echo "--- FAIL: test_lifecycle.gd ---"
	failed=$((failed + 1))
	failed_tests+=("test_lifecycle")
fi
echo ""

# --- Test 5: runner discovery tests pass ---
total=$((total + 1))
echo "--- Test: test_runner_discovery.gd ---"
if "$GODOT_CMD" --headless --path "$PROJECT_DIR" -s addons/godot-ai-test/cli/runner.gd -- tests/test_runner_discovery.gd 2>&1; then
	echo "--- PASS: test_runner_discovery.gd ---"
	passed=$((passed + 1))
else
	echo "--- FAIL: test_runner_discovery.gd ---"
	failed=$((failed + 1))
	failed_tests+=("test_runner_discovery")
fi
echo ""

# --- Test 6: screenshot compare tests pass ---
total=$((total + 1))
echo "--- Test: test_screenshot_compare.gd ---"
if "$GODOT_CMD" --headless --path "$PROJECT_DIR" -s addons/godot-ai-test/cli/runner.gd -- tests/test_screenshot_compare.gd 2>&1; then
	echo "--- PASS: test_screenshot_compare.gd ---"
	passed=$((passed + 1))
else
	echo "--- FAIL: test_screenshot_compare.gd ---"
	failed=$((failed + 1))
	failed_tests+=("test_screenshot_compare")
fi
echo ""

# --- Test 7: JSON output contains expected structure ---
total=$((total + 1))
echo "--- Test: JSON report output ---"
OUTPUT=$("$GODOT_CMD" --headless --path "$PROJECT_DIR" -s addons/godot-ai-test/cli/runner.gd -- tests/test_asserts.gd 2>&1)
if echo "$OUTPUT" | grep -q '"suite"' && echo "$OUTPUT" | grep -q '"passed"' && echo "$OUTPUT" | grep -q '"failed"'; then
	echo "--- PASS: JSON output has expected fields ---"
	passed=$((passed + 1))
else
	echo "--- FAIL: JSON output missing expected fields ---"
	failed=$((failed + 1))
	failed_tests+=("json_output")
fi
echo ""

echo ""
echo "========================================="
echo "[GTest] Bootstrap Summary"
echo "========================================="
echo "Total: $total  Passed: $passed  Failed: $failed"

if [[ $failed -gt 0 ]]; then
	echo ""
	echo "Failed tests:"
	for t in "${failed_tests[@]}"; do
		echo "  - $t"
	done
	exit 1
fi

echo "All bootstrap tests passed!"
exit 0
