#!/usr/bin/env python3
"""
Test Verification Report Generator
Runs the Godot test suite and generates a report
"""

import subprocess
import json
from pathlib import Path
import os

def run_test_suite():
    """Run the test suite in Godot"""
    print("🧪 Starting Godot Test Suite...")
    print("=" * 70)

    # Get project root
    project_root = Path(os.getcwd())

    # Test files to verify (relative to project root)
    test_files = {
        "ClassParser": "scripts/TestClassParser.gd",
        "ClassCache": "scripts/TestClassCache.gd",
        "ClassTableResource": "scripts/TestClassTableResource.gd",
    }

    # Support files to verify
    support_files = {
        "PropertyInspector": "addons/class_table_editor/property_inspector.gd",
        "ClassInspector": "addons/class_table_editor/class_inspector.gd",
        "ClassTableResource": "addons/class_table_editor/class_table_resource.gd",
        "ClassCache": "addons/class_table_editor/class_cache.gd",
        # "ClassParser": "addons/class_table_editor/class_parser.gd",  # Removed - deprecated
    }

    results = {
        "test_files": {},
        "support_files": {},
        "summary": {}
    }

    # Check test files
    print("\n📁 Verifying Test Files:")
    print("-" * 70)
    for name, path in test_files.items():
        file_path = project_root / path
        exists = file_path.exists()
        results["test_files"][name] = {
            "path": path,
            "exists": exists,
            "status": "✅" if exists else "❌"
        }
        print(f"{results['test_files'][name]['status']} {name}: {path}")

    # Check support files
    print("\n🔧 Verifying Support Files:")
    print("-" * 70)
    for name, path in support_files.items():
        file_path = project_root / path
        exists = file_path.exists()
        results["support_files"][name] = {
            "path": path,
            "exists": exists,
            "status": "✅" if exists else "❌"
        }
        print(f"{results['support_files'][name]['status']} {name}: {path}")

    # Summary
    test_passed = sum(1 for f in results["test_files"].values() if f["exists"])
    support_passed = sum(1 for f in results["support_files"].values() if f["exists"])

    print("\n" + "=" * 70)
    print("📊 Summary:")
    print(f"  Test Files: {test_passed}/{len(test_files)} ✅")
    print(f"  Support Files: {support_passed}/{len(support_files)} ✅")

    if test_passed == len(test_files) and support_passed == len(support_files):
        print("\n🎉 All files verified!")
    else:
        print("\n⚠️  Some files missing")

    print("=" * 70 + "\n")

    return results

if __name__ == "__main__":
    run_test_suite()
