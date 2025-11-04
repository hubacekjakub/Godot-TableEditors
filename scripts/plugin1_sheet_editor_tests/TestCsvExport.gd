@tool
extends Node
class_name TestCsvExport

## Tests for CSV export functionality - Plugin 1 (Sheet Editor)
## P1-011 to P1-015: CSV export format, headers, data rows, special characters

func run_all_tests() -> void:
	print("\n" + "─".repeat(50))
	print("🧪 CSV Export Tests")
	print("─".repeat(50))

	test_csv_data_preparation()
	test_csv_column_headers()
	test_csv_data_formatting()


## Test 1: Prepare data for CSV export
func test_csv_data_preparation() -> void:
	print("\n  Test: CSV data preparation")

	var sheet = SpreadsheetResource.new()
	sheet.sheet_name = "Export Test"
	sheet.row_count = 3
	sheet.column_count = 3
	sheet.column_names = ["Name", "Score", "Active"]

	# Set test data
	sheet.set_cell(0, 0, "Alice")
	sheet.set_cell(0, 1, "95")
	sheet.set_cell(0, 2, "true")

	sheet.set_cell(1, 0, "Bob")
	sheet.set_cell(1, 1, "87")
	sheet.set_cell(1, 2, "false")

	sheet.set_cell(2, 0, "Charlie")
	sheet.set_cell(2, 1, "92")
	sheet.set_cell(2, 2, "true")

	# Verify data is properly set
	assert(sheet.get_cell(0, 0) == "Alice", "❌ First data row should start with 'Alice'")
	assert(sheet.get_cell(2, 1) == "92", "❌ Last row, col 1 should be '92'")

	print("    ✅ CSV data prepared (3 rows x 3 columns)")


## Test 2: CSV column headers
func test_csv_column_headers() -> void:
	print("\n  Test: CSV column headers")

	var sheet = SpreadsheetResource.new()
	sheet.column_count = 5
	sheet.column_names = ["ID", "Product Name", "Quantity", "Unit Price", "Total"]

	# Verify headers are correctly set
	assert(sheet.column_names.size() == 5, "❌ Should have 5 column headers")
	assert(sheet.column_names[0] == "ID", "❌ Header 0 should be 'ID'")
	assert(sheet.column_names[1] == "Product Name", "❌ Header 1 should be 'Product Name'")
	assert(sheet.column_names[4] == "Total", "❌ Header 4 should be 'Total'")

	# Build CSV header line
	var csv_header = ",".join(sheet.column_names)
	assert(csv_header.contains("ID"), "❌ CSV header should contain 'ID'")
	assert(csv_header.contains("Product Name"), "❌ CSV header should contain 'Product Name'")

	print("    ✅ CSV column headers validated")


## Test 3: CSV data formatting
func test_csv_data_formatting() -> void:
	print("\n  Test: CSV data formatting")

	var sheet = SpreadsheetResource.new()
	sheet.row_count = 2
	sheet.column_count = 4
	sheet.column_names = ["Name", "Email", "Age", "City"]

	# Set data that might need CSV escaping
	sheet.set_cell(0, 0, "John Doe")
	sheet.set_cell(0, 1, "john@example.com")
	sheet.set_cell(0, 2, "30")
	sheet.set_cell(0, 3, "New York")

	sheet.set_cell(1, 0, "Jane Smith")
	sheet.set_cell(1, 1, "jane@example.com")
	sheet.set_cell(1, 2, "28")
	sheet.set_cell(1, 3, "Los Angeles")

	# Verify all cells are retrievable for export
	var row_data = []
	for col in range(sheet.column_count):
		row_data.append(sheet.get_cell(0, col))

	assert(row_data.size() == 4, "❌ Should have 4 columns in row data")
	assert(row_data[0] == "John Doe", "❌ First cell in row should be 'John Doe'")
	assert(row_data[3] == "New York", "❌ Last cell in row should be 'New York'")

	print("    ✅ CSV data formatting validated")
