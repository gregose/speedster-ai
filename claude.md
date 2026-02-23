# Claudsters — Design Context for AI Agents

This document captures the full design history and decision rationale for the Claudsters project (3D printed Paul Carmody Speedster speaker enclosures). It is intended to provide context for future Claude sessions, Claude Code, or other AI agents continuing the work.

## Project Overview

The goal is to replace the original Speedster's 1/2" MDF box with a 3D-printed PETG enclosure that maintains acoustic fidelity to Paul Carmody's design while taking advantage of curves and geometry impossible with traditional woodworking. The enclosure is designed for the Bambu Lab H2D large-format printer.

**Drivers (unchanged from Carmody's design):**
- Woofer: Tang Band W4-1720 (4" underhung midbass)
- Tweeter: Fountek NeoCD1.0 (true ribbon)

**Key acoustic targets (from Carmody's spec):**
- Internal volume: 5.5 liters
- Port: 1.375" dia × 4.5" long, tuned to ~55 Hz
- -3 dB point: mid-40 Hz range

## Design Sessions (Chronological)

### Session 1: Initial Enclosure Design
**File:** `2026-02-19-20-50-54-speedster-3d-printed-enclosure-design.txt`

Established the core parametric OpenSCAD model. Key decisions:
- **Curved-back wedge shape:** Wide flat baffle (165×300mm) tapering to narrow rounded back (118×240mm) over 185mm depth. Quadratic taper (power 2.0) concentrates volume near the baffle where driver clearance matters.
- **10mm PETG walls:** Chosen for stiffness/mass comparable to 1/2" MDF. At 5-6 perimeters, PETG walls are inherently airtight.
- **28mm front edge roundover:** Circular profile smoothing the baffle-to-side transition. Reduces diffraction effects above ~1950 Hz. The original MDF box had sharp edges.
- **Volume tuning:** Simpson's rule estimation built into the SCAD file. Iterated `enclosure_depth` to hit 5.49L net (after subtracting port tube and pillar displacement).
- **Driver placement:** Woofer at y=-45mm, tweeter at y=+55mm (center-to-center spacing of 100mm). Carmody's original had the woofer overlapping the tweeter flange slightly; our design maintains a small 7.75mm gap.

### Session 2: Bolt Reversal, Port Flare, Woofer Chamfer
**File:** `2026-02-20-02-43-55-speedster-3d-enclosure-refinements.txt`

Major refinements:
- **Bolt direction reversed:** Originally bolts entered from the front (visible). Reversed so bolts enter from back — no visible hardware on the front baffle.
- **Split plane repositioned:** Moved to z=60.7mm (aligned with port tube front end) so the port stays entirely in the back half. No split cuts through the port tube.
- **Port exit flare:** Added 15mm radius concave flare at the port exit on the back face. Reduces turbulence noise at the port opening. Implemented as a quarter-circle rotate_extrude profile.
- **Woofer rear chamfer:** 45° chamfer on the baffle cutout interior starting at z=3mm (leaving 3mm of straight bore for screw thread engagement). Opens the bore from 95.5mm to ~109.5mm at the inner wall surface, reducing back-wave reflection.

### Session 3: Heat-Set Inserts
**File:** `2026-02-20-02-45-11-speedster-3d-driver-heat-inserts.txt`

Converted all driver mounting from through-holes to heat-set inserts:
- **Woofer:** 4× M4 heat-set inserts (Ø5.6mm × 6mm deep) in baffle face, 45° rotated diamond pattern on 115mm bolt circle
- **Tweeter:** 4× M3 heat-set inserts (Ø4.5mm × 5mm deep) in recess floor, 60.8mm square pattern

This allows repeated assembly/disassembly without wearing out the plastic threads.

### Session 4: Tongue-and-Groove Seal
**File:** `2026-02-21-04-47-04-speedster-tongue-groove-seal.txt`

Replaced a CNC-cut foam gasket concept with an integral tongue-and-groove joint:
- **Tongue:** 3mm wide × 4mm tall ridge on front half split face, centered 5mm from outer wall
- **Groove:** 3.6mm wide × 5mm deep channel in back half (0.3mm clearance per side)
- **Seal strip:** Closed-cell foam tape or TPU filament bead in groove bottom (1mm extra depth below tongue)
- Provides X-Y self-alignment during assembly plus airtight seal when compressed

### Session 5: Internal Bracing Exploration → Pillar System
**File:** `2026-02-21-04-48-38-shelf-brace-iteration-pillar-approach.txt`

Explored three bracing strategies:
1. **Window brace** (separate printed piece clamped at split plane) — Rejected: extra part, tolerance-sensitive
2. **Shelf brace** (horizontal shelf between drivers) — Rejected: complicated clearances around port tube and drivers, additional bolt hardware
3. **Pillar-to-pillar mating** — Adopted: 8 pillar pairs at split-plane perimeter with interlock boss/recess. Pillars double as wall reinforcement and bolt anchorage.

### Session 6: Back-Face Bolt Exploration → Reverted
**File:** `2026-02-21-14-42-07-pillar-bolt-redesign-back-face.txt`

Attempted to move all 8 bolts to the flat back face for simpler counterbores. Reverted because:
1. Pillars lose side-wall attachment (less rigid)
2. Back panel becomes cluttered
3. Required specialty 180mm M4 bolts

### Session 7: Bolt Landing Solution + Pillar Refinements

Final resolution of the bolt-on-curved-wall problem:

- **Counterbore landing approach:** For each bolt position, compute the z-depth where the taper cross-section still provides 4mm of material around the bolt center. Cut an 8mm cylinder from that z through to the back exterior. This creates a flat perpendicular face inside the tapered wall for the bolt head to seat on.
- **Uniform bolt length:** All 8 counterbores use the shallowest (most restrictive) landing z (~113mm), so all bolts are the same standard length (~M4×60mm).
- **Back pillar extension:** Increased from 15mm to 30mm depth past split face, with taper angle reduced from 20° to 15° for a more gradual blend into the inner wall (~60mm total pillar+taper). Covers more of the bolt through-hole.
- **Interlock swap:** Boss moved to back half (no heat-set insert, stays at nominal size), recess moved to front half (absorbs any expansion from heat-set insert installation).

### Session 8: Crossover Boss Print Support Refinements

Improved the crossover PCB mounting bosses for overhang-free FDM printing:

- **45° brace start shifted:** The triangular support brace previously started at the boss center (`ez`), leaving the bottom half of the cylinder unsupported. Moved brace start to `ez + boss_r` (bottom of boss in print orientation) so the full cylinder sits on a 45° ramp with no overhang.
- **D-shaped boss cross-section:** Hulled each boss cylinder with a thin slab at `z = ez + boss_r` to create a flat-bottomed profile. This eliminates the crescent-shaped gaps between the round cylinder and the flat brace surface, giving a seamless transition from boss to support.
- **Result:** Every layer of the crossover boss prints with ≤45° overhang — no support material needed for these features.

### Session 9: Binding Plate Heat-Set Inserts

Converted binding post plate mounting from through-hole self-tappers to heat-set inserts:

- **4× M4 heat-set inserts** (Ø5.6mm × 6mm deep) pressed into the recess floor on the back face, same spec as the woofer mounting inserts.
- **Insert pockets bored from recess floor inward** (toward cavity). Total depth used: 3mm recess + 6mm insert = 9mm of the 10mm wall, leaving 1mm of material on the cavity side.
- **Rationale:** Self-tapping screws into PETG wear out quickly with repeated assembly. Heat-set inserts allow unlimited disassembly for crossover tuning and driver swaps, consistent with the rest of the enclosure's insert-based design.

## Current Locked Parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Baffle | 165 × 300 mm | Driver clearance + volume |
| Back | 118 × 240 mm, R42 corners | Terminal plate clearance |
| Depth | 185 mm | Tuned for 5.49L net volume |
| Wall | 10 mm PETG | Stiffness parity with 1/2" MDF |
| Taper | Power 2.0 (quadratic) | Volume concentration near baffle |
| Roundover | 28 mm radius | Diffraction control > ~1950 Hz |
| Split plane | z = 60.7 mm | Port tube stays in back half |
| Port | 34.925mm dia × 114.3mm long | Carmody spec: 55 Hz tuning |
| Port flare | 15 mm concave radius | Reduced turbulence noise |
| Pillar dia | 16 mm | 8 pairs at split-plane perimeter |
| Back pillar | 30mm + 15° taper (30mm cone) | Wall blend + bolt coverage |
| Bolt pattern | 8× M4, 12mm inset from edge | Split-plane perimeter |
| Counterbore | 8mm dia, uniform z ≈ 113mm | Cross-section landing analysis |
| Tongue | 3mm wide × 4mm tall | Self-aligning seal joint |
| Groove | 3.6mm wide × 5mm deep | 0.3mm clearance + 1mm seal depth |
| Interlock | 10mm dia × 2mm boss/recess | Boss on back, recess on front |

## File Structure

```
claudsters/
├── speedster_v2.scad    # Complete parametric OpenSCAD model
├── README.md            # Project overview, BOM, assembly
├── claude.md            # This file — AI agent context
└── analysis.md          # Design verification and analysis
```

## Key Implementation Notes for Agents

1. **OpenSCAD parametric model:** All dimensions are parameters at the top of the file. Changing `enclosure_depth` adjusts volume; the echo block reports the estimated volume.
2. **Volume estimation:** Simpson's rule approximation. For precise volume, export `inner_cavity()` as STL and measure in a slicer.
3. **Split halves:** Uncomment the appropriate export option at the bottom. Front half prints baffle-down; back half prints split-face-down.
4. **Bolt counterbore math:** `landing_z()` and `min_landing_z()` functions compute the uniform counterbore depth analytically from the taper formula. No iterative search needed.
5. **The model uses z=0 at the front baffle face,** increasing toward the back. Y is vertical (positive up), X is horizontal (positive right when facing the speaker).

## Open Items / Future Work

- Crossover mounting solution inside back cavity
- Validation render in OpenSCAD (render times may be long due to hull operations)
- STL export and slicer test for printability
- Prototype print and fit check
- Acoustic measurement comparison to original Speedster
