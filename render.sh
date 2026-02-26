#!/bin/bash
# SpeedsterAI — Standard Render Pipeline
# Generates 9 PNG renders from speedster-ai.scad using OpenSCAD CLI
#
# Usage: ./render.sh [output_dir]
#   output_dir defaults to ./renders/
#
# Requires OpenSCAD installed at the standard macOS location.
# Camera format: --camera=eye_x,eye_y,eye_z,center_x,center_y,center_z
#
# Coordinate system after display rotation (rotate([90,0,0])):
#   X = horizontal (left-right)
#   Y = depth (0=baffle, -197=back)
#   Z = height (vertical, positive up, center ~0)
#   Model center: (0, -98.5, 0)

set -e

SCAD="speedster-ai.scad"
OUTDIR="${1:-renders}"
SIZE="1920,1080"
CENTER="0,-98.5,0"

# Auto-detect OpenSCAD
if [ -z "$OPENSCAD" ]; then
    if command -v openscad &>/dev/null; then
        OPENSCAD="openscad"
    elif [ -x "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD" ]; then
        OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
    else
        echo "Error: OpenSCAD not found. Install it or set OPENSCAD env var." >&2
        exit 1
    fi
fi

# Headless rendering support (containers without a display)
if [ -z "$DISPLAY" ] && command -v xvfb-run &>/dev/null; then
    XVFB="xvfb-run -a"
else
    XVFB=""
fi

if [ ! -f "$SCAD" ]; then
    echo "Error: $SCAD not found. Run from project root." >&2
    exit 1
fi

mkdir -p "$OUTDIR"

echo "Rendering 9 standard views..."

# Assembled views (render_mode=0, default)
$XVFB $OPENSCAD "$SCAD" --preview --camera=100,800,50,$CENTER    --imgsize=$SIZE -o "$OUTDIR/front.png"               2>/dev/null &
$XVFB $OPENSCAD "$SCAD" --preview --camera=-100,-800,50,$CENTER  --imgsize=$SIZE -o "$OUTDIR/back.png"                2>/dev/null &
$XVFB $OPENSCAD "$SCAD" --preview --camera=900,-50,80,$CENTER    --imgsize=$SIZE -o "$OUTDIR/side.png"                2>/dev/null &
$XVFB $OPENSCAD "$SCAD" --preview --camera=450,550,300,$CENTER   --imgsize=$SIZE -o "$OUTDIR/three_quarter_front.png" 2>/dev/null &
$XVFB $OPENSCAD "$SCAD" --preview --camera=-450,-700,300,$CENTER --imgsize=$SIZE -o "$OUTDIR/three_quarter_back.png"  2>/dev/null &

# Exploded views (render_mode=1)
$XVFB $OPENSCAD "$SCAD" --preview -D render_mode=1 --camera=500,600,300,$CENTER   --imgsize=$SIZE -o "$OUTDIR/exploded_front.png" 2>/dev/null &
$XVFB $OPENSCAD "$SCAD" --preview -D render_mode=1 --camera=-500,-700,300,$CENTER --imgsize=$SIZE -o "$OUTDIR/exploded_back.png"  2>/dev/null &

# Component fit view (render_mode=5)
$XVFB $OPENSCAD "$SCAD" --preview -D render_mode=5 --camera=500,600,300,$CENTER   --imgsize=$SIZE -o "$OUTDIR/component_fit_front.png" 2>/dev/null &
$XVFB $OPENSCAD "$SCAD" --preview -D render_mode=5 --camera=-450,-700,300,$CENTER --imgsize=$SIZE -o "$OUTDIR/component_fit_back.png"  2>/dev/null &

wait
echo "Done. Renders saved to $OUTDIR/"
ls -lh "$OUTDIR"/*.png
