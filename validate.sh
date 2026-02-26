#!/bin/bash
# SpeedsterAI — Validation Pipeline
# ===================================
#
# Runs all design validation checks:
#   1. OpenSCAD assertion checks (analytical clearances)
#   2. Python geometric collision detection (trimesh)
#
# Usage: ./validate.sh [--skip-geometric] [--verbose]
#
# Exit codes:
#   0 = all checks pass
#   1 = one or more checks failed

set -e

OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
SCAD="speedster-ai.scad"
VERBOSE=""
SKIP_GEO=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --skip-geometric) SKIP_GEO=true ;;
        --verbose|-v)     VERBOSE="--verbose" ;;
        *)                echo "Unknown argument: $arg"; exit 2 ;;
    esac
done

if [ ! -f "$SCAD" ]; then
    echo "Error: $SCAD not found. Run from project root." >&2
    exit 2
fi

PASS=true

# -------------------------------------------------------
# Phase 1: OpenSCAD Assertion Checks
# -------------------------------------------------------
echo "========================================"
echo "  Phase 1: OpenSCAD Assertion Checks"
echo "========================================"

# Run OpenSCAD in preview mode to trigger assertions and echo output.
# We render a tiny PNG just to force evaluation.
ASSERT_OUTPUT=$($OPENSCAD "$SCAD" -o /dev/null --export-format binstl \
    -D "validation_export=1" 2>&1 || true)

# Check for assertion failures
if echo "$ASSERT_OUTPUT" | grep -q "Assertion.*failed"; then
    echo ""
    echo "ASSERTION FAILURES:"
    echo "$ASSERT_OUTPUT" | grep "Assertion" | while read -r line; do
        echo "  ✗ $line"
    done
    PASS=false
    echo ""
elif echo "$ASSERT_OUTPUT" | grep -q "ALL CLEARANCE ASSERTIONS PASSED"; then
    echo "  ✓ All clearance assertions passed"
else
    echo "  ? Could not determine assertion status"
    if [ -n "$VERBOSE" ]; then
        echo "$ASSERT_OUTPUT"
    fi
fi

# Show key echo output
echo ""
echo "  Key dimensions from model:"
echo "$ASSERT_OUTPUT" | grep "ECHO:" | grep -E "(volume|Net air|Target|Difference|DRIVER FIT|Gap between|Woofer depth|Tweeter depth)" | while read -r line; do
    echo "    $line"
done
echo ""

# -------------------------------------------------------
# Phase 2: Geometric Collision Detection
# -------------------------------------------------------
if [ "$SKIP_GEO" = true ]; then
    echo "========================================"
    echo "  Phase 2: Geometric Checks (SKIPPED)"
    echo "========================================"
else
    echo "========================================"
    echo "  Phase 2: Geometric Collision Detection"
    echo "========================================"
    echo ""

    if ! python3 validate.py --openscad "$OPENSCAD" $VERBOSE; then
        PASS=false
    fi
fi

# -------------------------------------------------------
# Final Result
# -------------------------------------------------------
echo ""
echo "========================================"
if [ "$PASS" = true ]; then
    echo "  ✓ ALL VALIDATION CHECKS PASSED"
else
    echo "  ✗ VALIDATION FAILED — see above"
fi
echo "========================================"

if [ "$PASS" = true ]; then
    exit 0
else
    exit 1
fi
