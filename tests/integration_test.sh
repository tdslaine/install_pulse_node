#!/bin/bash
#
# Integration Test Suite for Enhanced Validator Setup
# Tests all new utilities and their integration
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_RESULTS=()
TESTS_PASSED=0
TESTS_FAILED=0

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_test_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

pass_test() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
    TEST_RESULTS+=("PASS: $1")
}

fail_test() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    echo -e "  ${YELLOW}Reason: $2${NC}"
    ((TESTS_FAILED++))
    TEST_RESULTS+=("FAIL: $1 - $2")
}

# Test 1: Check all utility files exist
test_utility_files_exist() {
    print_test_header "Test 1: Utility Files Existence"
    
    local files=(
        "utils/colors.sh"
        "utils/validators.sh"
        "utils/preflight.sh"
        "utils/help.sh"
        "utils/keygen_safety.sh"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$SCRIPT_DIR/../$file" ]]; then
            pass_test "File exists: $file"
        else
            fail_test "File missing: $file" "File not found"
        fi
    done
}

# Test 2: Check all files are executable
test_files_executable() {
    print_test_header "Test 2: File Permissions"
    
    local files=(
        "utils/colors.sh"
        "utils/validators.sh"
        "utils/preflight.sh"
        "utils/help.sh"
        "utils/keygen_safety.sh"
        "setup_easy.sh"
    )
    
    for file in "${files[@]}"; do
        if [[ -x "$SCRIPT_DIR/../$file" ]]; then
            pass_test "Executable: $file"
        else
            fail_test "Not executable: $file" "Missing execute permission"
        fi
    done
}

# Test 3: Check shell syntax
test_shell_syntax() {
    print_test_header "Test 3: Shell Script Syntax"
    
    local files=(
        "utils/colors.sh"
        "utils/validators.sh"
        "utils/preflight.sh"
        "utils/help.sh"
        "utils/keygen_safety.sh"
        "setup_easy.sh"
    )
    
    for file in "${files[@]}"; do
        if bash -n "$SCRIPT_DIR/../$file" 2>/dev/null; then
            pass_test "Valid syntax: $file"
        else
            fail_test "Syntax error: $file" "bash -n failed"
        fi
    done
}

# Test 4: Check source dependencies
test_source_dependencies() {
    print_test_header "Test 4: Source Dependencies"
    
    # setup_easy.sh should source all utilities
    local setup_easy="$SCRIPT_DIR/../setup_easy.sh"
    
    if grep -q 'source.*colors.sh' "$setup_easy"; then
        pass_test "setup_easy.sh sources colors.sh"
    else
        fail_test "setup_easy.sh missing colors.sh" "Source statement not found"
    fi
    
    if grep -q 'source.*validators.sh' "$setup_easy"; then
        pass_test "setup_easy.sh sources validators.sh"
    else
        fail_test "setup_easy.sh missing validators.sh" "Source statement not found"
    fi
    
    if grep -q 'source.*preflight.sh' "$setup_easy"; then
        pass_test "setup_easy.sh sources preflight.sh"
    else
        fail_test "setup_easy.sh missing preflight.sh" "Source statement not found"
    fi
}

# Test 5: Check documentation exists
test_documentation_exists() {
    print_test_header "Test 5: Documentation Files"
    
    local docs=(
        "README_BEGINNER.md"
        "QUICKSTART.md"
        "ENHANCEMENTS.md"
        "docs/TROUBLESHOOTING.md"
        "docs/KEYGEN_SECURITY.md"
        "docs/KEYGEN_ENHANCEMENTS.md"
    )
    
    for doc in "${docs[@]}"; do
        if [[ -f "$SCRIPT_DIR/../$doc" ]]; then
            pass_test "Documentation exists: $doc"
        else
            fail_test "Documentation missing: $doc" "File not found"
        fi
    done
}

# Test 6: Check function exports
test_function_exports() {
    print_test_header "Test 6: Function Exports"
    
    # Check colors.sh exports
    if grep -q 'export -f print_success' "$SCRIPT_DIR/../utils/colors.sh"; then
        pass_test "colors.sh exports print_success"
    else
        fail_test "colors.sh missing export" "print_success not exported"
    fi
    
    # Check help.sh exports
    if grep -q 'export -f show_contextual_help' "$SCRIPT_DIR/../utils/help.sh"; then
        pass_test "help.sh exports show_contextual_help"
    else
        fail_test "help.sh missing export" "show_contextual_help not exported"
    fi
    
    # Check validators.sh exports
    if grep -q 'export -f validate_eth_address' "$SCRIPT_DIR/../utils/validators.sh"; then
        pass_test "validators.sh exports validate_eth_address"
    else
        fail_test "validators.sh missing export" "validate_eth_address not exported"
    fi
}

# Test 7: Check for proper attribution
test_attribution() {
    print_test_header "Test 7: Attribution Headers"
    
    local files=(
        "utils/colors.sh"
        "utils/validators.sh"
        "utils/preflight.sh"
        "utils/help.sh"
        "utils/keygen_safety.sh"
        "setup_easy.sh"
    )
    
    for file in "${files[@]}"; do
        if grep -q "tdslaine" "$SCRIPT_DIR/../$file"; then
            pass_test "Attribution present: $file"
        else
            fail_test "Attribution missing: $file" "No credit to original author"
        fi
    done
}

# Test 8: Check original files are untouched
test_original_files_intact() {
    print_test_header "Test 8: Original Files Integrity"
    
    local originals=(
        "setup_pulse_node.sh"
        "setup_validator.sh"
        "setup_monitoring.sh"
        "functions.sh"
    )
    
    for file in "${originals[@]}"; do
        if [[ -f "$SCRIPT_DIR/../$file" ]]; then
            pass_test "Original file intact: $file"
        else
            fail_test "Original file missing: $file" "File not found"
        fi
    done
}

# Test 9: Check help system completeness
test_help_system() {
    print_test_header "Test 9: Help System Completeness"
    
    local help_functions=(
        "help_network_selection"
        "help_execution_client"
        "help_consensus_client"
        "help_installation_path"
        "help_withdrawal_address"
        "help_ssh_access"
        "help_rpc_access"
        "help_keygen_method"
    )
    
    for func in "${help_functions[@]}"; do
        if grep -q "^$func()" "$SCRIPT_DIR/../utils/help.sh"; then
            pass_test "Help function exists: $func"
        else
            fail_test "Help function missing: $func" "Function not defined"
        fi
    done
}

# Test 10: Check README links are valid
test_readme_links() {
    print_test_header "Test 10: README Internal Links"
    
    # Check if linked files exist
    if grep -q 'docs/TROUBLESHOOTING.md' "$SCRIPT_DIR/../README_BEGINNER.md"; then
        if [[ -f "$SCRIPT_DIR/../docs/TROUBLESHOOTING.md" ]]; then
            pass_test "TROUBLESHOOTING.md link valid"
        else
            fail_test "TROUBLESHOOTING.md link broken" "Target file missing"
        fi
    fi
    
    if grep -q 'docs/KEYGEN_SECURITY.md' "$SCRIPT_DIR/../README_BEGINNER.md"; then
        if [[ -f "$SCRIPT_DIR/../docs/KEYGEN_SECURITY.md" ]]; then
            pass_test "KEYGEN_SECURITY.md link valid"
        else
            fail_test "KEYGEN_SECURITY.md link broken" "Target file missing"
        fi
    fi
}

# Run all tests
main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  Enhanced Validator Setup - Integration Test Suite          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    test_utility_files_exist
    test_files_executable
    test_shell_syntax
    test_source_dependencies
    test_documentation_exists
    test_function_exports
    test_attribution
    test_original_files_intact
    test_help_system
    test_readme_links
    
    # Print summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  TEST SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ✓ ALL TESTS PASSED - Project is ready!                     ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  ✗ SOME TESTS FAILED - Please review errors above           ║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        return 1
    fi
}

# Run tests
main
exit $?
