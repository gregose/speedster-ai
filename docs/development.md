# Development Guide

Instructions for working with the SpeedsterAI OpenSCAD model — rendering, exporting, validating, and the development container. For a project overview, see the [README](../README.md).

## Prerequisites

- [OpenSCAD](https://openscad.org/) (tested with 2024.x nightly builds with Manifold backend)
- For printing: slicer software (Bambu Studio, PrusaSlicer, etc.)
- For geometric validation: Python 3 with `pip install trimesh manifold3d numpy`

## Using the SCAD File

Open `speedster-ai.scad` in OpenSCAD. The default view shows the full assembled enclosure. Check the console for volume estimation and driver fit diagnostics.

### Rendering

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

**Phase 1 — Analytical assertions (22 checks):** Runs inside OpenSCAD at every render. Checks driver fit, cavity clearances, tweeter-port separation, crossover positioning, PCB corner containment, binding post fit, split plane validity, volume tolerance, and print envelope compliance.

**Phase 2 — Geometric collision detection (21 checks):** Python script (`validate.py`) exports each component envelope as STL, then uses trimesh + manifold3d to verify 6 cavity containment checks and 15 pair-wise collision checks across all internal components. Requires `pip install trimesh manifold3d numpy`.

The component fit can also be inspected visually with `render_mode=5` (transparent enclosure + color-coded component envelopes).

### Coordinate System

- **Z axis:** 0 at front baffle face, increasing toward back
- **Y axis:** Vertical, positive up. Woofer at y=−45, tweeter at y=+55
- **X axis:** Horizontal, positive right (facing speaker)

## Development Container

The project includes a devcontainer that serves two purposes: a reproducible development environment with all tools pre-installed, and a security boundary for AI-assisted work. It runs an x86_64 Linux container with OpenSCAD nightly (Manifold backend — 10-100× faster CSG than CGAL), Python validation tools, and GitHub Copilot CLI.

The container is isolated from the host OS — the AI agent can run OpenSCAD, export STLs, execute validation scripts, and iterate on the design, but it has no access to the host filesystem, network services, or system resources outside the project directory. The GitHub token used is a fine-grained PAT scoped to only the "Copilot Requests" permission — it cannot read repositories, push code, or access any other GitHub API. This lets the agent work at full speed (render, validate, export in seconds) while limiting the blast radius of any mistake to the project workspace.

### Prerequisites

- [Docker](https://www.docker.com/) or [Colima](https://github.com/abiosoft/colima) (macOS)
- [devcontainer CLI](https://github.com/devcontainers/cli): `npm install -g @devcontainers/cli`
- [Docker Buildx](https://github.com/docker/buildx): `brew install docker-buildx` (link with `mkdir -p ~/.docker/cli-plugins && ln -sfn $(which docker-buildx) ~/.docker/cli-plugins/docker-buildx`)

**Colima users (Apple Silicon):** Start with Rosetta support for x86_64 emulation:
```bash
colima start --vm-type vz --vz-rosetta --mount-type virtiofs --cpu 4 --memory 8 --disk 100
```

### Quick Start

1. **Store a GitHub token** (fine-grained PAT with only "Copilot Requests" permission):
   ```bash
   # Create token at: https://github.com/settings/personal-access-tokens/new
   security add-generic-password -a copilot -s speedster-ai-copilot -w "github_pat_..."
   ```

2. **Launch Copilot CLI in the container:**
   ```bash
   ./copilot.sh
   ```
   This builds the container on first run, forwards your git identity, and starts an interactive Copilot session with full tool access.

3. **Run tools directly:**
   ```bash
   devcontainer exec --workspace-folder . ./validate.sh          # Full validation
   devcontainer exec --workspace-folder . ./export.sh            # Export STLs
   devcontainer exec --workspace-folder . ./render.sh            # Generate renders
   ```

### What's in the Container

| Tool | Purpose |
|------|---------|
| OpenSCAD nightly (Manifold) | Fast CSG rendering — STL exports in ~4s |
| Python 3 + trimesh + manifold3d | Geometric collision detection |
| xvfb | Headless OpenGL for `--preview` renders |
| GitHub Copilot CLI | AI-assisted development |
| GitHub CLI + Node.js | GitHub integration |

Copilot session state persists across container rebuilds via a named Docker volume.
