#!/bin/bash
# Claudsters — STL Export Pipeline
# Exports front and back half STLs from speedster_v2.scad using OpenSCAD CLI
#
# Usage: ./export.sh [output_dir]
#   output_dir defaults to ./models/
#
# Requires OpenSCAD installed at the standard macOS location.
# Full renders take ~2-3 minutes per half.

set -e

OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
SCAD="speedster_v2.scad"
OUTDIR="${1:-models}"

if [ ! -f "$SCAD" ]; then
    echo "Error: $SCAD not found. Run from project root." >&2
    exit 1
fi

if [ ! -x "$OPENSCAD" ]; then
    echo "Error: OpenSCAD not found at $OPENSCAD" >&2
    exit 1
fi

mkdir -p "$OUTDIR"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

SCAD_ABS="$(cd "$(dirname "$SCAD")" && pwd)/$(basename "$SCAD")"

# Export front half
echo "Exporting front half..."
cat > "$TMPDIR/front.scad" << EOF
include <$SCAD_ABS>
front_half();
EOF
$OPENSCAD "$TMPDIR/front.scad" -D 'render_mode=99' -o "$OUTDIR/speedster_v2-front.stl" 2>&1 | grep -E 'Status|Genus|Vertices|Facets|Error'

# Export back half
echo "Exporting back half..."
cat > "$TMPDIR/back.scad" << EOF
include <$SCAD_ABS>
back_half();
EOF
$OPENSCAD "$TMPDIR/back.scad" -D 'render_mode=99' -o "$OUTDIR/speedster_v2-back.stl" 2>&1 | grep -E 'Status|Genus|Vertices|Facets|Error'

echo ""
echo "Done. STLs saved to $OUTDIR/"
ls -lh "$OUTDIR"/*.stl
