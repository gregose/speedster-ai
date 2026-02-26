# SpeedsterAI — 3D Printed Speedster Speaker Enclosure

A parametric OpenSCAD enclosure for Paul Carmody's [Speedster](https://sites.google.com/site/undefinition/bookshelf-speakers/speedster) bookshelf speakers, replacing the original 1/2" MDF cabinet with a 3D-printed PETG curved-back wedge.

## Specifications

| Spec | Original (Carmody) | SpeedsterAI |
|------|-------------------|---------------|
| Internal volume | 5.5 L | 5.68 L net (~5.35 L effective) |
| Port tuning | ~55 Hz | ~55 Hz (same port) |
| Port | 1.375" dia × 4.5" long | 34.925mm × 114.3mm + 15mm entry bell / 45° exit chamfer |
| Woofer | Tang Band W4-1720 (surface) | Same (surface mount, M4 heat-set inserts) |
| Tweeter | Fountek NeoCD1.0 (flush) | Same (flush recess, M3 heat-set inserts) |
| Wall material | 1/2" MDF | 10mm PETG (5-6 perimeters) |
| Baffle dimensions | 152 × ~254mm (6" × 10") | 180 × 264mm |
| Back dimensions | N/A (rectangular) | 118 × 211mm, R17 corners |
| Enclosure depth | ~152mm | 205mm |
| Bracing | None | 8× pillar pairs with interlocks |
| Shape | Rectangular box | Curved-back wedge with 20mm front roundover |
| Printer | N/A | Bambu Lab H2D (350×320×325mm build volume) |

## Drivers

- **Woofer:** Tang Band W4-1720 — 4" underhung midbass with massive motor
- **Tweeter:** Fountek NeoCD1.0 — true ribbon tweeter (aluminum diaphragm, transformer coupled)
- **Crossover:** Carmody's 3rd-order electrical filters (see [Speedster page](https://sites.google.com/site/undefinition/bookshelf-speakers/speedster) for schematic)

## Design Features

**Curved-back wedge shape** with quadratic taper (power 2.0) from 180×264mm baffle to 118×211mm back over 205mm depth. Concentrates volume near the baffle where driver clearance matters most, then tapers aggressively toward the back.

**20mm front edge roundover** with a cubic Hermite spline profile, plus a 2mm 45° baffle edge chamfer. Designed for FDM printability (max overhang exactly 45° when printed baffle-down). Reduces diffraction effects above ~2737 Hz. The original MDF box had sharp baffle edges — any roundover is an improvement.

**Port flares** reduce turbulence noise and chuffing at the port openings. The cavity-side entry uses a 15mm concave quarter-circle bell for smooth airflow expansion. The back-face exit uses a 45° linear chamfer confined to the 10mm wall for FDM printability. Six triangular gusset ribs reinforce the port tube-to-back-wall junction for reliable FDM layer adhesion.

**Woofer rear chamfer** at 45° opens the baffle bore behind the driver, reducing back-wave reflections off the cutout edge.

**Front/back split** at z=80.7mm with tongue-and-groove seal joint. The split plane is aligned with the port tube front end so the port stays entirely in the back half.

**8 pillar pairs** at the split-plane perimeter provide wall reinforcement, bolt anchorage, and shear-resistant alignment via interlock boss/recess at the split face.

**Bolt counterbore landing** computed analytically from the taper cross-section — finds the z-depth where the wall provides sufficient material for a flat bolt head seat, then cuts a uniform-depth pocket for all 8 bolts.

**Crossover mounting bosses** on both side walls with heat-set inserts for M3 standoff screws. Each boss has a 45° triangular brace and D-shaped cross-section for overhang-free FDM printing. The HP and LP crossover boards mount on opposite walls.

**Component envelope validation** — a comprehensive test suite verifies all internal components (woofer, tweeter, binding posts, crossover PCBs with per-component 3D models, port tube) fit within the cavity without collisions. 20 analytical assertions run at every render; a Python geometric pipeline checks cavity containment and pair-wise collisions across 21 checks.

## Renders

### Assembled Views

| Front | Back | Side |
|-------|------|------|
| ![Front](renders/front.png) | ![Back](renders/back.png) | ![Side](renders/side.png) |

| 3/4 Front | 3/4 Back |
|-----------|----------|
| ![3/4 Front](renders/three_quarter_front.png) | ![3/4 Back](renders/three_quarter_back.png) |

### Exploded Views

| Exploded Front | Exploded Back |
|----------------|---------------|
| ![Exploded Front](renders/exploded_front.png) | ![Exploded Back](renders/exploded_back.png) |

### Component Fit Views

| Component Fit Front | Component Fit Back |
|---------------------|-------------------|
| ![Component Fit Front](renders/component_fit_front.png) | ![Component Fit Back](renders/component_fit_back.png) |

Transparent enclosure with color-coded component envelopes: Red=woofer, Blue=tweeter, Green=binding posts, Orange/Gold=crossover HP/LP, Cyan=port tube.

## STL Downloads

- [Front half](models/speedster-ai-front.stl) — print baffle-face down
- [Back half](models/speedster-ai-back.stl) — print flat back-face down

## Using the SCAD File

### Prerequisites

- [OpenSCAD](https://openscad.org/) (tested with 2024.x)
- For printing: slicer software (Bambu Studio, PrusaSlicer, etc.)

### Rendering

Open `speedster-ai.scad` in OpenSCAD. The default view shows the full assembled enclosure. Check the console for volume estimation and driver fit diagnostics.

#### Standard Render Set

Run `./render.sh` to generate 9 standard PNG renders (1920×1080) in the `renders/` directory:

| View | Description |
|------|-------------|
| `front.png` | Front baffle face — driver cutouts, roundover, heat-set insert holes |
| `back.png` | Back panel — terminal recess, port exit flare, bolt counterbores |
| `side.png` | Side profile — taper from wide baffle to narrow back |
| `three_quarter_front.png` | 3/4 front isometric — hero shot |
| `three_quarter_back.png` | 3/4 back isometric — terminal + port + taper |
| `exploded_front.png` | Exploded from front — split halves, pillar interlocks, tongue-and-groove |
| `exploded_back.png` | Exploded from back — port tube, crossover bosses, internal features |
| `component_fit_front.png` | Component envelopes from front — transparent shell with color-coded internals |
| `component_fit_back.png` | Component envelopes from back — port tube, crossover boards, binding posts |

The `render_mode` variable can also be set from CLI: `openscad -D render_mode=1` for exploded, `=2` for front half only, `=3` for back half only, `=4` for inner cavity, `=5` for component fit.

### Exporting for Print

Run `./export.sh` to generate print-ready STL files in the `models/` directory:

```bash
./export.sh           # exports to models/ (default)
./export.sh mydir/    # exports to custom directory
```

This exports both halves with full CGAL rendering and reports geometry status. STLs are ready to import directly into your slicer.

Alternatively, in the OpenSCAD GUI, uncomment ONE export option at the bottom of the file, then Render (F6) and Export as STL (F7).

### Adjusting Volume

Change `enclosure_depth` (currently 205mm). The echo block reports estimated volume. Each 1mm of depth change ≈ 0.033L. Current verified gross volume is 5.86L (via STL export); net is 5.68L after port/pillar displacement; effective air volume is ~5.35L after subtracting crossover component displacement (~0.33L). Note: the SCAD Simpson's rule overestimates by ~0.08L because it uses only 3 sample points and doesn't fully capture the roundover zone.

### Validating the Design

Run `./validate.sh` to execute the full validation pipeline:

```bash
./validate.sh               # Full validation (assertions + geometric collision checks)
./validate.sh --skip-geometric  # Fast mode — assertions only (~2s)
```

**Phase 1 — Analytical assertions (20 checks):** Runs inside OpenSCAD at every render. Checks driver fit, cavity clearances, tweeter-port separation, crossover positioning, PCB corner containment, binding post fit, split plane validity, volume tolerance, and H2D print envelope compliance.

**Phase 2 — Geometric collision detection (21 checks):** Python script (`validate.py`) exports each component envelope as STL, then uses trimesh + manifold3d to verify cavity containment and check all pair-wise component combinations for intersections. Requires `pip install trimesh manifold3d numpy`.

The component fit can also be inspected visually with `render_mode=5` (transparent enclosure + color-coded component envelopes).

### Coordinate System

- **Z axis:** 0 at front baffle face, increasing toward back
- **Y axis:** Vertical, positive up. Woofer at y=-45, tweeter at y=+55
- **X axis:** Horizontal, positive right (facing speaker)

## Print Settings

**Material:** PETG (mandatory for airtightness and stiffness)

**Printer:** Bambu Lab H2D (350×320×325mm build volume). Both halves verified to fit within the build envelope.

| Setting | Value | Rationale |
|---------|-------|-----------|
| Layer height | 0.2mm | Good detail/speed balance |
| Perimeters | 5–6 | Fills most of 10mm wall, airtight |
| Infill | 50–80% gyroid | Fills remaining wall, adds damping |
| Top/bottom layers | 8+ | Solid baffle and back face |
| Supports | Minimal | Driver cutouts, counterbores; roundover profile is ≤45° overhang |

**Print orientation:**
- Front half: baffle face DOWN (split face up) — roundover profile designed for ≤45° overhang; best surface finish on visible face
- Back half: flat back face DOWN (split face up) — large flat surface on build plate for best adhesion

## Assembly Instructions

1. Print both halves
2. Clean up supports from driver cutouts and counterbores
3. Install M4 heat-set inserts into front half pillars (8× for enclosure bolts)
4. Install M4 heat-set inserts into woofer screw holes (4× from front face)
5. Install M3 heat-set inserts into tweeter recess floor (4× from recess)
6. Install M3 heat-set inserts into crossover boss holes (6× per side wall, from cavity)
7. Mount HP crossover board on left wall, LP board on right wall, with M3 standoff screws
8. Run speaker wire from back to front through split plane
8. Press foam tape or TPU strip into groove on back half split face
9. Add polyfill loosely to cavity
10. Align tongue into groove and interlock bosses into recesses, mate halves
11. Insert 8× M4 bolts from back into front pillar inserts
12. Mount tweeter (flush into recess) with M3 screws
13. Mount woofer (surface mount) with M4 screws
14. Connect drivers to crossover
15. Install binding post plate on rear

## Bill of Materials (per speaker)

### Enclosure Assembly
| Qty | Item | Spec |
|-----|------|------|
| 8 | M4 heat-set inserts | Ø5.6mm × 8mm deep |
| 8 | M4 socket head cap screws | ~65mm length |

### Woofer Mounting
| Qty | Item | Spec |
|-----|------|------|
| 4 | M4 heat-set inserts | Ø5.6mm × 6mm deep |
| 4 | M4 socket head cap screws | 10mm length |

### Tweeter Mounting
| Qty | Item | Spec |
|-----|------|------|
| 4 | M3 heat-set inserts | Ø4.5mm × 5mm deep |
| 4 | M3 socket head cap screws | 8mm length |

### Crossover Mounting
| Qty | Item | Spec |
|-----|------|------|
| 6 | M3 heat-set inserts | Ø4.5mm × 6mm deep |
| 6 | M3 standoff screws | 8mm length |

### Seal
| Qty | Item | Spec |
|-----|------|------|
| 1 | Closed-cell foam tape | ~3mm wide, enough for perimeter |
| — | *OR* TPU filament bead | Laid into groove before mating |

### Binding Post Plate
| Qty | Item | Spec |
|-----|------|------|
| 1 | Binding post plate | Dayton Audio SBPP-SI, 100.6mm square |
| 4 | M4 heat-set inserts | Ø5.6mm × 6mm deep |
| 4 | M4 flat head (countersunk) cap screws | 8mm length, 90° head |

### Drivers & Crossover
| Qty | Item |
|-----|------|
| 1 | Tang Band W4-1720 |
| 1 | Fountek NeoCD1.0 |
| 1 | Speedster crossover (see Carmody's BOM) |
| 1 | Polyfill (loose handfuls) |

## Airtightness Test

After assembly, cover the port opening with your palm and gently push the woofer cone inward. It should resist and return slowly. If it springs back quickly, there is a leak at the split joint — check foam tape compression.

## File Structure

```
speedster-ai/
├── speedster-ai.scad         # Complete parametric OpenSCAD enclosure model
├── component-envelopes.scad  # Component clearance envelopes + validation assertions
├── export.sh                 # STL export pipeline (front + back halves)
├── render.sh                 # Standard render pipeline (9 PNG views)
├── validate.sh               # Validation pipeline (assertions + geometric checks)
├── validate.py               # Python geometric collision detection (trimesh + manifold3d)
├── models/                   # Exported STL files for printing
├── renders/                  # Generated PNG renders
├── references/               # Component reference drawings and datasheets
├── analysis.md               # Design verification and analysis
└── claude.md                 # AI agent design context
```

## License

Enclosure design files are provided for personal/hobby use. The Speedster speaker design is by Paul Carmody. Crossover schematic and driver selection are his work.
