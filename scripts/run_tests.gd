@tool
## Test runner script - can be executed directly by Godot
extends SceneTree

func _ready() -> void:
	print("\n" + "═".repeat(60))
	print("                  GODOT SHEET EDITOR - TEST SUITE")
	print("═".repeat(60))

	# Create test runner
	var test_all = TestAll.new()
	test_all.run_all_tests()

	# Give time for output to flush
	await self.process_frame

	# Exit
	quit()
