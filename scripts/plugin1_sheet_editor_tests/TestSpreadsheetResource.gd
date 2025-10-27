@tool
extends Node
class_name TestSpreadsheetResource

## Tests for SpreadsheetResource - the core data storage class for Plugin 1 (Sheet Editor)
## P1-001 to P1-005: Sheet resource creation, columns, rows, save/load

func run_all_tests() -> void:
	print("\n" + "─".repeat(50))
	print("🧪 SpreadsheetResource Tests")
	print("─".repeat(50))

	test_create_spreadsheet()
	test_cell_management()
	test_column_row_names()


## Test 1: Create a new spreadsheet resource
func test_create_spreadsheet() -> void:
	print("\n  Test: Create new spreadsheet")

	var sheet = SpreadsheetResource.new()
	sheet.sheet_name = "Test Sheet"
	sheet.row_count = 5
	sheet.column_count = 3

	assert(sheet is SpreadsheetResource, "❌ Sheet is not SpreadsheetResource instance")
	assert(sheet.sheet_name == "Test Sheet", "❌ Sheet name not set correctly")
	assert(sheet.row_count == 5, "❌ Row count should be 5")
	assert(sheet.column_count == 3, "❌ Column count should be 3")

	print("    ✅ Spreadsheet created successfully (5x3)")


## Test 2: Cell management (get/set)
func test_cell_management() -> void:
	print("\n  Test: Cell management")

	var sheet = SpreadsheetResource.new()
	sheet.row_count = 3
	sheet.column_count = 3

	# Set cells
	sheet.set_cell(0, 0, "Apple")
	sheet.set_cell(0, 1, "100")
	sheet.set_cell(1, 0, "Banana")
	sheet.set_cell(2, 2, "Done")

	# Get cells
	assert(sheet.get_cell(0, 0) == "Apple", "❌ Cell [0,0] should be 'Apple'")
	assert(sheet.get_cell(0, 1) == "100", "❌ Cell [0,1] should be '100'")
	assert(sheet.get_cell(1, 0) == "Banana", "❌ Cell [1,0] should be 'Banana'")
	assert(sheet.get_cell(2, 2) == "Done", "❌ Cell [2,2] should be 'Done'")
	assert(sheet.get_cell(0, 2) == "", "❌ Empty cell should return empty string")

	print("    ✅ Cell management working (set/get)")


## Test 3: Column and row names
func test_column_row_names() -> void:
	print("\n  Test: Column and row names")

	var sheet = SpreadsheetResource.new()
	sheet.row_count = 3
	sheet.column_count = 4

	# Set column names
	sheet.column_names = ["ID", "Name", "Type", "Value"]

	# Set row names
	sheet.row_names = ["Header", "Data1", "Data2"]

	# Populate cells
	sheet.set_cell(0, 0, "1")
	sheet.set_cell(0, 1, "Item A")
	sheet.set_cell(1, 0, "2")
	sheet.set_cell(1, 1, "Item B")

	assert(sheet.column_names.size() == 4, "❌ Should have 4 column names")
	assert(sheet.column_names[0] == "ID", "❌ Column 0 should be named 'ID'")
	assert(sheet.column_names[2] == "Type", "❌ Column 2 should be named 'Type'")

	assert(sheet.row_names.size() == 3, "❌ Should have 3 row names")
	assert(sheet.row_names[1] == "Data1", "❌ Row 1 should be named 'Data1'")

	print("    ✅ Column and row names set successfully")
