#!/bin/bash
# Claudsters — Standard Render Pipeline
# Generates 7 PNG renders from speedster_v2.scad using OpenSCAD CLI
#
# Usage: ./render.sh [output_dir]
#   output_dir defaults to ./renders/
#
# Requires OpenSCAD installed at the standard macOS location.
# Camera format: --camera=eye_x,eye_y,eye_z,center_x,center_y,center_z
#
# Coordinate system after display rotation (rotate([90,0,0])):
#   X = horizontal (left-right)
#   Y = depth (0=baffle, -185=back)
#   Z = height (vertical, positive up, center ~0)
#   Model center: (0, -92.5, 0)

set -e

OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
SCAD="speedster_v2.scad"
OUTDIR="${1:-renders}"
SIZE="1920,1080"
CENTER="0,-92.5,0"

if [ ! -f "$SCAD" ]; then
    echo "Error: $SCAD not found. Run from project root." >&2
    exit 1
fi

if [ ! -x "$OPENSCAD" ]; then
    echo "Error: OpenSCAD not found at $OPENSCAD" >&2
    exit 1
fi

mkdir -p "$OUTDIR"

echo "Rendering 7 standard views..."

# Assembled views (render_mode=0, default)
$OPENSCAD "$SCAD" --preview --camera=100,800,50,$CENTER    --imgsize=$SIZE -o "$OUTDIR/front.png"               2>/dev/null &
$OPENSCAD "$SCAD" --preview --camera=-100,-800,50,$CENTER  --imgsize=$SIZE -o "$OUTDIR/back.png"                2>/dev/null &
$OPENSCAD "$SCAD" --preview --camera=900,-50,80,$CENTER    --imgsize=$SIZE -o "$OUTDIR/side.png"                2>/dev/null &
$OPENSCAD "$SCAD" --preview --camera=450,550,300,$CENTER   --imgsize=$SIZE -o "$OUTDIR/three_quarter_front.png" 2>/dev/null &
$OPENSCAD "$SCAD" --preview --camera=-450,-700,300,$CENTER --imgsize=$SIZE -o "$OUTDIR/three_quarter_back.png"  2>/dev/null &

# Exploded views (render_mode=1)
$OPENSCAD "$SCAD" --preview -D render_mode=1 --camera=500,600,300,$CENTER   --imgsize=$SIZE -o "$OUTDIR/exploded_front.png" 2>/dev/null &
$OPENSCAD "$SCAD" --preview -D render_mode=1 --camera=-500,-700,300,$CENTER --imgsize=$SIZE -o "$OUTDIR/exploded_back.png"  2>/dev/null &

wait
echo "Done. Renders saved to $OUTDIR/"
ls -lh "$OUTDIR"/*.png
