# Godot AI Test

AI-First Game Testing Framework for Godot 4.x

Write tests in GDScript that AI can generate, understand, and execute autonomously. Designed for developers using Claude Code, Cursor, and other AI coding tools with Godot.

## Features

- **GDScript-native** — No C# required, works with stock Godot 4.6+
- **AI-Friendly API** — Structured JSON output, self-documenting asserts, test skeleton generation
- **Screenshot comparison** — Pixel-diff with configurable tolerance for visual regression testing
- **Process isolation** — Each test file runs in its own Godot process (no autoload state leaks)
- **Headless + Visual** — `@visual` tag auto-switches between headless CI and GUI tests

## Quick Start

### 1. Install

Copy the `addons/godot-ai-test/` directory into your project's `addons/` folder.

Or with [GodotEnv](https://github.com/chickensoft-games/GodotEnv):

```jsonc
// addons.jsonc
{
  "addons": {
    "godot-ai-test": {
      "url": "https://github.com/shohu/godot-ai-test",
      "subfolder": "addons/godot-ai-test"
    }
  }
}
```

### 2. Write a test

```gdscript
# tests/test_economy.gd
extends GTestCase

func test_earn_gold() -> void:
    var scene: Node = GTest.load_scene("res://scenes/main.tscn")
    GameState.earn_gold(100)
    assert_eq(GameState.gold, 100, "gold after earning")
    scene.queue_free()

func test_spend_gold() -> void:
    var scene: Node = GTest.load_scene("res://scenes/main.tscn")
    GameState.earn_gold(100)
    GameState.spend_gold(30)
    assert_eq(GameState.gold, 70, "gold after spending")
    scene.queue_free()
```

### 3. Run

```bash
# Single test file
godot --headless --path . -s addons/godot-ai-test/cli/runner.gd -- tests/test_economy.gd

# All tests
bash addons/godot-ai-test/cli/run_all.sh
```

### 4. Read JSON output

```json
[
    {
        "suite": "test_economy",
        "passed": 2,
        "failed": 0,
        "total": 2,
        "errors": []
    }
]
```

## API Reference

### GTestCase (base class)

```gdscript
extends GTestCase

# Lifecycle
func before_all() -> void     # Once before all tests
func after_all() -> void      # Once after all tests
func before_each() -> void    # Before each test_* method
func after_each() -> void     # After each test_* method

# Asserts
func assert_eq(actual, expected, label)       # Equal
func assert_true(condition, label)            # True
func assert_false(condition, label)           # False
func assert_gt(actual, threshold, label)      # Greater than
func assert_lt(actual, threshold, label)      # Less than
func assert_near(actual, expected, eps, label)# Approximate
func assert_not_null(value, label)            # Not null
func assert_has(collection, item, label)      # Contains
```

### GTest (autoload)

```gdscript
# Scene loading
var scene: Node = GTest.load_scene("res://scenes/main.tscn")

# Time helpers
await GTest.wait(2.0)
await GTest.wait_frames(10)

# Screenshots (visual tests only)
var img: Image = await GTest.capture_screenshot()
GTest.save_screenshot("test_name")

# Screenshot comparison
var result: Dictionary = await GTest.assert_screenshot_matches("baselines/ui.png", 0.05)
var result: Dictionary = await GTest.assert_screenshot_differs("baselines/fog.png", 0.1)

# Baseline management
GTest.update_baseline("baselines/ui.png")

# Test skeleton generation
GTest.generate_skeleton("res://scenes/main.tscn")
```

### Visual Tests

Add `## @visual` as the first line to run with a window:

```gdscript
## @visual
extends GTestCase

func test_fog_dissolve() -> void:
    var scene: Node = GTest.load_scene("res://scenes/main.tscn")
    # ... trigger fog dissolve ...
    await GTest.wait(2.0)
    var result: Dictionary = await GTest.assert_screenshot_matches(
        "baselines/fog_dissolved.png", 0.05
    )
    assert_true(result["pass"], result.get("reason", ""))
    scene.queue_free()
```

Run visual tests:
```bash
GTEST_VISUAL=1 bash addons/godot-ai-test/cli/run_all.sh
```

## Using with Claude Code

Add to your `CLAUDE.md`:

```markdown
## Testing
# Run all tests
bash addons/godot-ai-test/cli/run_all.sh

# Generate test skeleton for a scene
godot --headless --path . -s addons/godot-ai-test/cli/runner.gd -- generate_skeleton res://scenes/main.tscn
```

## Complementary to GUT/gdUnit4

This framework complements existing test tools:

| Feature | GUT | gdUnit4 | Godot AI Test |
|---------|-----|---------|---------------|
| Unit tests | Yes | Yes | Yes |
| Mocking | Yes | Yes | No |
| Screenshot comparison | No | No | **Yes** |
| JSON output (LLM-friendly) | No | No | **Yes** |
| Test skeleton generation | No | No | **Yes** |
| Process isolation | No | No | **Yes** |
| Visual regression testing | No | No | **Yes** |

Use GUT or gdUnit4 for unit tests with mocking. Use Godot AI Test for visual regression, AI-assisted testing, and screenshot comparison.

## Important Notes

- **Test execution order is non-deterministic.** Do not rely on test methods running in source order. Each test should be independent.
- **Screenshot baselines are platform-dependent.** Generate baselines in the same environment where tests will run (e.g., generate baselines in CI, not on your local machine).
- **Process isolation** means each test file spawns a new Godot process (~2-4 seconds startup). For large test suites, this may be slow. We're exploring in-process execution for future versions.

## License

MIT
