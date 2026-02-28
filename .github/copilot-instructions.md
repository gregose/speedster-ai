# Copilot Instructions — SpeedsterAI

This is a parametric OpenSCAD project for a 3D-printed speaker enclosure. AI agents working in this repo should follow these instructions.

## After Every Design Change

When any change is made to the OpenSCAD model (`speedster-ai.scad` or `component-envelopes.scad`), complete **all** of the following steps before considering the work done:

1. **Validate** — Run `./validate.sh` and confirm all checks pass. If validation fails, fix the issue before proceeding.
2. **Export STLs** — Run `./export.sh` to regenerate the print-ready STL files in `models/`. This is how the user reviews changes in their slicer.
3. **Render** — Run `./render.sh` to update all PNG renders in `renders/`.
4. **Update documentation:**
   - **`docs/copilot.md`** — Add a new session summary describing what changed, why, and any dead ends or reverted approaches. Follow the existing session format.
   - **`docs/design.md`** — Update any affected design details (dimensions, clearances, feature descriptions) to match the new model state.
   - **`docs/analysis.md`** — Re-run any applicable analysis and update verification data (volume, clearances, collision margins) with current values.
   - **`README.md`** — Update if the change affects anything public-facing: specs table, design highlights, renders, STL links, or minimum print envelope.
5. **User review** — After exporting STLs, ask the user to review the generated models in their slicer before proceeding. Do not commit until the user confirms the STLs look correct.
6. **Commit** — Explain the changes to the user and get approval before staging and committing. Ensure the exported STLs in `models/` are included in the commit. Include a clear summary in the commit message.

## Key Files

| File | Purpose |
|------|---------|
| `speedster-ai.scad` | Complete parametric enclosure model — all dimensions are parameters at the top |
| `component-envelopes.scad` | Component clearance envelopes + 22 analytical assertions |
| `tolerance-test.scad` | Printer tolerance calibration print |
| `validate.py` | Geometric collision detection (trimesh + manifold3d) |
| `docs/copilot.md` | Full AI design history — every session, decision, and rationale |
| `docs/design.md` | Engineering design details for each feature |
| `docs/analysis.md` | Design verification data and analysis |
| `docs/printing.md` | Print settings, tolerance test, assembly, BOM |
| `docs/development.md` | Dev guide, pipelines, devcontainer |

## Conventions

- **Temporary files** go in the `tmp/` directory (gitignored), not `/tmp`.
- **Commit messages** should include: `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`
- **Coordinate system:** Z=0 at front baffle, increasing toward back. Y vertical (positive up). X horizontal (positive right facing speaker).

## Design Constraints

These constraints have been violated in past sessions and required rework. Check them explicitly when making geometry changes.

### FDM Printability (≤45° overhang)

Every surface must print with at most 45° overhang in its print orientation. Front half prints baffle-down (z=0 on bed); back half prints back-face-down (z=enclosure_depth on bed). Features that have been redesigned for this constraint:
- Front roundover: circular arc → cubic Hermite spline (Session 13)
- Port exit flare: concave quarter-circle → 45° linear chamfer (Session 15)
- Crossover bosses: added 45° triangular braces + D-shaped cross-section (Session 8)

When adding new geometry, verify the overhang in the print orientation before proceeding.

### Volume Target (~5.5L)

After any dimension change (`enclosure_depth`, `baffle_width`, `baffle_height`, `back_width`, `back_height`), check the echo output to verify net volume stays near the 5.5L target. Each 1mm of depth ≈ 0.033L. The SCAD Simpson's rule overestimates by ~0.08L — for precise measurement, export `inner_cavity()` as STL and measure in a slicer.

### Parameter Interdependencies

Changing `enclosure_depth` cascades to many derived values. After any depth change, verify:
- `split_z` (auto-computed: `enclosure_depth - wall - port_length`) still clears the roundover zone (must be > `roundover_depth`)
- Port entry z-position (`split_z`) still clears the tweeter body depth (currently 10.7mm gap)
- Crossover z-range (`xover_z_start` to `xover_z_start + xover_pcb_width`) still fits within the cavity
- All 8 bolt counterbore landings still have sufficient wall material

Changing `baffle_width` or `baffle_height` affects woofer/tweeter flange fit margins. Verify driver cutouts remain within the flat baffle face.

### Hull Boundary Alignment

`inner_cavity()` must use the same slice count and z-formula as `outer_shape()` (20 roundover + 40 body slices) with a 0.001mm epsilon offset. Misaligned slice boundaries create visible horizontal plane artifacts in the STL. Exactly coplanar boundaries create non-manifold edges. The epsilon offset avoids both. Do not change slice counts in one without updating the other.

### Tolerance Test Sync

All fit-critical dimensions are controlled by `print_*` variables at the top of `speedster-ai.scad`. When adding a new fit-critical feature:
1. Add a `print_*` variable with the design nominal as default
2. Add a corresponding test panel to `tolerance-test.scad` with matching print orientation and engraved labels
3. `tolerance-test.scad` uses `include <speedster-ai.scad>` to derive center values — they stay in sync automatically
