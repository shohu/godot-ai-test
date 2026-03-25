#!/usr/bin/env bash
## Godot AI Test — 全テスト一括実行
## Usage: bash addons/godot-ai-test/cli/run_all.sh [test_dir]
set -euo pipefail

GODOT_CMD="${GODOT_CMD:-godot}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="${1:-$(pwd)}"
TEST_DIR="${2:-tests}"

# Resolve test directory
if [[ ! -d "$PROJECT_DIR/$TEST_DIR" ]]; then
	echo "[GTest] Test directory not found: $PROJECT_DIR/$TEST_DIR"
	exit 1
fi

failed=0
total=0
passed=0
failed_tests=()

for test_file in "$PROJECT_DIR/$TEST_DIR"/test_*.gd; do
	[[ ! -f "$test_file" ]] && continue
	test_name="$(basename "$test_file")"

	# Check for @visual tag — skip in headless mode
	if head -1 "$test_file" | grep -q "## @visual"; then
		if [[ "${GTEST_VISUAL:-0}" != "1" ]]; then
			echo "--- SKIP (visual): $test_name ---"
			continue
		fi
	fi

	total=$((total + 1))
	echo "--- Running: $test_name ---"

	# Determine headless flag
	headless_flag="--headless"
	if head -1 "$test_file" | grep -q "## @visual"; then
		headless_flag=""
	fi

	if "$GODOT_CMD" $headless_flag --path "$PROJECT_DIR" \
		-s addons/godot-ai-test/cli/runner.gd -- "$TEST_DIR/$test_name" 2>&1; then
		echo "--- PASS: $test_name ---"
		passed=$((passed + 1))
	else
		echo "--- FAIL: $test_name ---"
		failed=$((failed + 1))
		failed_tests+=("$test_name")
	fi
	echo ""
done

echo ""
echo "========================================="
echo "[GTest] Test Summary"
echo "========================================="
echo "Total: $total  Passed: $passed  Failed: $failed"

if [[ $total -eq 0 ]]; then
	echo "No test files found in $TEST_DIR/"
	exit 0
fi

if [[ $failed -gt 0 ]]; then
	echo ""
	echo "Failed tests:"
	for t in "${failed_tests[@]}"; do
		echo "  - $t"
	done
	exit 1
fi

echo "All tests passed!"
exit 0
