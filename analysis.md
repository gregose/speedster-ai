# Design Analysis — Claudsters v2

This document verifies that the Claudsters v2 enclosure design is mechanically sound, dimensionally correct, and acoustically faithful to Paul Carmody's original Speedster specification.

## 1. Acoustic Fidelity to Carmody's Design

### 1.1 Internal Volume

**Carmody spec:** 5.5 liters (0.19 ft³)

**Claudsters v2:** 5.49 liters (net, after subtracting port tube and pillar displacement)

The volume is computed via Simpson's rule on the inner cavity cross-sections at the front wall (z=10mm), midpoint (z=92.5mm), and back wall (z=175mm). The taper formula interpolates between inner baffle dimensions (145×280mm) and inner back dimensions (98×220mm) using a power-2.0 curve.

Breakdown:
- Gross cavity volume: ~5.63 L
- Port tube displacement: -0.12 L (39.925mm OD × 114.3mm)
- Pillar displacement: -0.02 L (estimated, 8 front + 8 back pillars)
- **Net air volume: 5.49 L** (within 0.2% of target)

For final verification, export `inner_cavity()` as STL and measure volume in slicing software.

### 1.2 Port Tuning

**Carmody spec:** 1.375" diameter × 4.5" long, tuned to ~55 Hz

**Claudsters v2:** 34.925mm diameter × 114.3mm long (exact conversion of Carmody's imperial specs)

The port dimensions are unchanged from the original design. The Helmholtz resonance frequency depends on port area, port length, and box volume — all three are matched. The 15mm concave exit flare adds effective port length of approximately 3-5mm (partial end correction), which would shift tuning down by ~1-2 Hz. This is well within Carmody's stated tolerance and the flare's turbulence reduction benefit outweighs this negligible shift.

### 1.3 Baffle Diffraction

**Original:** 152mm (6") wide flat MDF baffle with sharp edges. Estimated baffle step frequency: ~720 Hz.

**Claudsters v2:** 165mm wide baffle with 28mm circular roundover. Estimated baffle step: ~664 Hz. Roundover effective above ~1950 Hz.

The baffle is 13mm wider than the original (165mm vs 152mm) to accommodate 10mm walls while maintaining internal clearance for the woofer screw circle. This shifts the baffle step down by ~56 Hz — a minor change that would slightly benefit the crossover's low-pass rolloff region.

The 28mm roundover is a significant improvement over the original sharp-edged MDF box. Diffraction at the baffle edge causes a characteristic amplitude ripple in the frequency response. The roundover smooths this transition, reducing diffraction artifacts above ~1950 Hz (where the crossover transitions to the ribbon tweeter). The original Speedster had no roundover.

### 1.4 Driver Spacing and Crossover Compatibility

**Carmody's design note:** Woofer is surface-mounted, tweeter is flush-mounted. The original design had the woofer slightly overlapping the tweeter flange.

**Claudsters v2:**
- Woofer center: y = -45mm
- Tweeter center: y = +55mm
- Center-to-center: 100mm
- Woofer flange top edge: y = +17.75mm (125.5mm flange / 2 - 45mm offset)
- Tweeter faceplate bottom: y = +5mm (55mm - 100mm/2)
- Gap between driver edges: 7.75mm (slight positive gap, vs slight negative overlap in original)

This 7.75mm gap means the drivers do not overlap, which is a minor departure from the original. Carmody himself noted that builders have increased cabinet height to eliminate the overlap with "negligible effect" on acoustics. The crossover was designed with 3rd-order electrical filters that control the off-axis behavior regardless of this small spacing change.

### 1.5 Woofer Depth Clearance

The W4-1720 requires 89mm of depth behind the baffle. The internal cavity at the woofer position (y=-45mm, near the center) provides approximately 165mm of depth (from inner baffle at z=10mm to inner back wall at z=175mm). This is nearly 2× the required clearance.

### 1.6 Port Placement

Carmody specifies the port "directly behind the tweeter." In Claudsters v2, the port is at y=+45mm (10mm below the tweeter center at y=+55mm), centered horizontally (x=0). The port tube extends from z=60.7mm to z=175mm, entirely within the back half.

## 2. Mechanical Feasibility

### 2.1 Wall Stiffness

**Original:** 1/2" (12.7mm) MDF, density ~750 kg/m³, Young's modulus ~4 GPa

**Claudsters v2:** 10mm PETG at 5-6 perimeters + 50-80% gyroid infill

PETG has a Young's modulus of ~2.0 GPa (roughly half of MDF). However, the curved-back wedge shape provides structural advantage: curved surfaces resist pressure better than flat panels (shell stiffness). The 8 pillar pairs act as internal ties between the front and back halves, further resisting baffle flex.

Carmody's original design specifies "no bracing" with 1/2" MDF. The Claudsters design adds 8 structural pillars despite using slightly thinner walls, which should provide equivalent or better panel rigidity.

### 2.2 Split-Plane Joint Integrity

The split at z=60.7mm divides the enclosure into a shallow front half (baffle + 50.7mm of cavity) and a deep back half (port, terminal, 114.3mm of cavity).

Three mechanisms ensure joint integrity:
1. **Tongue-and-groove:** 3mm tongue / 3.6mm groove provides X-Y alignment and prevents lateral shift during assembly
2. **8× M4 bolts:** Provide z-axis clamping force at the split-plane perimeter (12mm inset from edge)
3. **8× pillar interlocks:** 10mm diameter × 2mm boss/recess at each bolt position resist shear loads

The seal strip (foam tape or TPU) in the groove bottom ensures airtightness under bolt compression.

### 2.3 Bolt Pattern and Counterbore Landing

The 8 bolts are positioned at the split-plane cross-section perimeter:
- 2× top/bottom center
- 2× left/right center
- 4× corners (offset 15mm from the cardinal positions to clear driver cutouts)

Each bolt passes from the back exterior through the back half wall into a heat-set insert in the front half pillar. The challenge is that bolts exit through tapered side walls, not flat surfaces.

**Solution:** The `landing_z()` function computes, for each bolt position (px, py), the z-depth where the taper cross-section still provides at least 4mm of material clearance to the nearest outer edge. An 8mm diameter cylinder is then cut from this z through to the back face, creating a flat perpendicular landing surface inside the wall.

All 8 bolts use the same landing z (~113mm), determined by the most restrictive positions (top/bottom center bolts, which are closest to the shrinking height edge). This gives uniform bolt length (~60mm from landing to split plane insert).

**Verification of the most restrictive bolt:**
- Top center bolt position: (0, 134.8) at the split plane
- At z=113mm: cross-section half-height = 134.8 + 4.0 = 138.8mm → actual half-height at z=113 ≈ 138.8mm ✓
- Landing depth from back face: 185 - 113 = 72mm of material for the counterbore cut
- Wall thickness at landing: ~10mm (the bolt sits in the wall zone)

### 2.4 Pillar Dimensions

**Front pillars:** 16mm diameter × 50.7mm long (from inner baffle at z=10mm to split plane at z=60.7mm). Solid cylinders providing material for the M4 heat-set insert (Ø5.6mm × 8mm deep pocket at split face).

**Back pillars:** 16mm diameter × 30mm cylinder + 30mm taper (15° from vertical, transitioning from 16mm to 0mm). Total: 60mm from split plane. The gentler 15° angle (vs the original 20°) creates a more gradual blend with the inner wall and provides better coverage of the bolt through-hole.

The back cavity depth is 114.3mm (from split plane to inner back wall). The back pillar occupies 60mm of this, leaving 54.3mm clear — plenty of room for the crossover board, wiring, and polyfill.

### 2.5 Crossover Mounting Bosses

Crossover PCBs mount vertically on the left and right inner side walls via cylindrical bosses with M3 heat-set inserts. Each boss extends horizontally from the wall to a common flat PCB face plane.

**Print support geometry:** The back half prints with the back wall down, so bosses are horizontal cantilevered cylinders that need support from below. Each boss has:

1. **D-shaped cross-section:** The cylinder is hulled with a thin slab at z = ez + boss_r, creating a flat bottom that mates flush with the triangular brace surface. This eliminates the crescent-shaped gaps that would otherwise exist between a round cylinder and a flat support.

2. **45° triangular brace:** A wedge extending from the bottom of the boss toward the back wall (+Z). Full height (= boss_len) at the wall end, tapering to zero at the PCB face end. The brace starts at the very bottom of the boss (z = ez + boss_r, not the center), so every layer of the boss prints on ≤45° supported material.

These features ensure the bosses print cleanly without slicer-generated support material.

### 2.6 Interlock Boss/Recess Configuration

The interlock boss is on the **back half** pillar (protrudes 2mm past split plane toward front). The recess is on the **front half** pillar (2mm deep pocket at split face).

This orientation was chosen specifically because the front half has heat-set inserts pressed into the pillar faces. Insert installation causes localized thermal expansion of the surrounding PETG. If the boss were on the front half, this expansion could make the boss oversized and prevent mating. With the recess on the front half instead:
- Expansion slightly shrinks the recess diameter, but 0.3mm clearance per side absorbs this
- The boss on the back half (no insert) stays at nominal dimensions
- The result is actually a slightly tighter (better) friction fit

### 2.7 Heat-Set Insert Engagement

All heat-set inserts have adequate wall material surrounding them:

| Insert | Diameter | Depth | Pillar/Wall Dia | Wall Ratio |
|--------|----------|-------|-----------------|------------|
| Enclosure M4 | 5.6mm | 8mm | 16mm pillar | 2.86× |
| Woofer M4 | 5.6mm | 6mm | 10mm wall | 1.79× |
| Tweeter M3 | 4.5mm | 5mm | 10mm wall | 2.22× |
| Terminal M4 | 5.6mm | 6mm | 10mm wall | 1.79× |

A minimum wall ratio of 1.5× insert diameter is recommended for PETG; all four exceed this.

**Terminal insert depth check:** The recess is 3mm deep from the back exterior. Inserts are 6mm deep from the recess floor, for a total of 9mm into the 10mm wall. This leaves 1mm of solid PETG on the cavity side — sufficient to prevent punch-through during insert installation. The insert pockets do not intersect the terminal through-cutout (76.5mm square) because the screw pattern (84.5mm spacing) places each insert center 4mm outside the cutout edge. ✓

## 3. Dimensional Verification

### 3.1 Terminal Plate Clearance

The binding post plate is 100.6mm square, mounted at y=-45mm on the back face. The back face dimensions are 118×240mm with R30 corners (internal: 98×220mm).

- Horizontal clearance: (118 - 100.6) / 2 = 8.7mm per side ✓
- Vertical clearance: plate center at y=-45, plate extends from y=-95.3 to y=+5.3. Back face extends from y=-120 to y=+120. Clearance to bottom edge: 120 - 95.3 = 24.7mm ✓

### 3.2 Driver Cutout vs Baffle Inner Width

- Woofer cutout: 95.5mm diameter at y=-45mm
- Woofer screw circle: 115mm diameter (outermost screw edge at 60.1mm from center)
- Baffle inner half-width: (165 - 20) / 2 = 72.5mm
- Screw-to-wall clearance: 72.5 - 60.1 = 12.4mm ✓

- Tweeter faceplate: 100mm diameter at y=+55mm
- Tweeter screw spacing: 60.8mm square (outermost screw at 30.4 + 1.75 = 32.15mm from center)
- Faceplate edge to inner wall: 72.5 - 50 = 22.5mm ✓

### 3.3 Port Tube vs Inner Cavity

- Port outer diameter: 34.925 + 2×2.5 = 39.925mm
- Port at (x=0, y=+45) from z=60.7 to z=175mm
- Inner cavity width at z=60.7: ~143mm → port center to side wall: 71.5mm >> 20mm radius ✓
- Inner cavity height at y=+45: port top edge at y=65mm, inner cavity top at ~138mm → 73mm clearance ✓

### 3.4 Bolt Position vs Driver Cutout Clearance

The bolt pattern is computed from the cross-section at the split plane (z=60.7mm). At this depth, the cross-section is approximately 161×293mm. Bolt centers are 12mm inset from the edge.

The most critical clearance is between corner bolts and the woofer/tweeter cutouts. The woofer cutout at the split plane is a 95.5mm diameter bore (or wider due to the 45° chamfer starting at z=3mm — at z=60.7mm the bore has expanded well past the baffle). Since the woofer bore passes through the baffle (z=0 to z=10mm) and the split plane is at z=60.7mm, the woofer cutout does not intersect the split plane at all. The bolt positions at z=60.7 are in the wall zone, well outboard of the cavity. ✓

## 4. Advantages Over Original Design

1. **Reduced diffraction:** 28mm roundover eliminates sharp baffle edges (the single biggest source of coloration in small speakers)
2. **Curved back:** Eliminates parallel internal surfaces that cause standing waves at specific frequencies. The MDF box had 6 parallel pairs; the wedge has zero.
3. **Port exit flare:** Reduces turbulence noise at moderate-to-high listening levels. The original had a plain tube end.
4. **Structural pillars:** 8 pillar pairs add internal reinforcement that the original "no bracing" MDF box lacked.
5. **Repeatability:** Parametric CAD model produces identical enclosures every time. MDF builds vary with woodworking skill.
6. **Woofer rear chamfer:** Opens the baffle bore behind the driver, reducing back-wave reflections that can color the midrange.
7. **Serviceability:** Heat-set inserts allow unlimited assembly/disassembly cycles. The original design used glue for the enclosure and wood screws for drivers.

## 5. Potential Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| PETG less stiff than MDF | Curved shape + 8 pillar pairs compensate; gyroid infill adds internal damping |
| Split-plane air leak | Tongue-and-groove + foam tape + 8 bolt compression |
| Bolt head overhang past curved wall | Analytically computed landing ensures ≥4mm of flat seat; slight overhang is cosmetic only |
| Heat-set insert expansion | Interlock recess on insert side absorbs expansion; boss on non-insert side stays nominal |
| Print warping (large PETG parts) | Bambu H2D enclosed chamber; split into two halves keeps each part manageable |
| Volume sensitivity to print dimensions | Simpson's rule estimation + STL volume verification in slicer before printing |

## 6. Summary

The Claudsters v2 enclosure faithfully reproduces Carmody's acoustic design (5.49L volume, identical port tuning, same drivers and crossover) while adding structural improvements (roundover, curved back, pillars, port flare) that should improve measured performance. All mechanical interfaces (driver mounting, bolt pattern, terminal plate, split joint) have been verified for dimensional clearance. The design is printable on a large-format FDM printer in PETG with standard slicer settings.
