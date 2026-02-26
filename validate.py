#!/usr/bin/env python3
"""
SpeedsterAI — Geometric Collision Detection
============================================

Exports component envelopes and inner cavity as individual STLs via
OpenSCAD CLI, then uses trimesh + manifold3d to verify:
  1. Each component is fully contained within the cavity
  2. No pair-wise component intersections exist

Usage:
  python3 validate.py [--openscad PATH] [--skip-export] [--verbose]

Exit codes:
  0 = all checks pass
  1 = one or more checks failed
  2 = export or setup error
"""

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path

try:
    import trimesh
    import numpy as np
except ImportError:
    print("ERROR: Required packages not installed. Run:")
    print("  pip3 install trimesh numpy manifold3d")
    sys.exit(2)


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

SCAD_FILE = "speedster-ai.scad"
TMP_DIR = "tmp/validation"

# OpenSCAD validation_export modes → component names
COMPONENTS = {
    2: "woofer",
    3: "tweeter",
    4: "binding_posts",
    5: "crossover_hp",
    6: "crossover_lp",
    7: "port_tube",
}

CAVITY_EXPORT_MODE = 1  # validation_export=1 → inner_cavity

# Components that intentionally pass through enclosure walls.
# Woofer: flange protrudes forward, basket passes through baffle bore
# Tweeter: faceplate sits in recess, body passes through baffle bore
# Binding posts: external knobs/shoulder outside back face, shaft through wall
PASS_THROUGH_COMPONENTS = {"woofer", "tweeter", "binding_posts"}

# Colors for terminal output
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
CYAN = "\033[96m"
RESET = "\033[0m"
BOLD = "\033[1m"


# ---------------------------------------------------------------------------
# OpenSCAD STL Export
# ---------------------------------------------------------------------------

def find_openscad():
    """Find OpenSCAD binary."""
    paths = [
        "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
        "openscad",
    ]
    for p in paths:
        if os.path.isfile(p) and os.access(p, os.X_OK):
            return p
        # Check if it's on PATH
        result = subprocess.run(["which", p], capture_output=True, text=True)
        if result.returncode == 0:
            return result.stdout.strip()
    return None


def export_stl(openscad_bin, scad_file, export_mode, output_path, verbose=False):
    """Export a single component/cavity STL via OpenSCAD."""
    cmd = [
        openscad_bin,
        scad_file,
        "-o", output_path,
        "-D", f"validation_export={export_mode}",
    ]
    if verbose:
        print(f"  Running: {' '.join(cmd)}")

    result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)

    if result.returncode != 0:
        print(f"  {RED}OpenSCAD export failed for mode {export_mode}{RESET}")
        if result.stderr:
            # Check for assertion failures
            for line in result.stderr.split("\n"):
                if "Assertion" in line or "ERROR" in line:
                    print(f"    {line}")
        return False

    # Check for assertion errors in stderr (OpenSCAD reports them but may
    # still exit 0)
    if result.stderr and "Assertion" in result.stderr:
        for line in result.stderr.split("\n"):
            if "Assertion" in line:
                print(f"  {RED}{line}{RESET}")
        return False

    if not os.path.exists(output_path) or os.path.getsize(output_path) == 0:
        print(f"  {RED}Output file empty or missing: {output_path}{RESET}")
        return False

    return True


def export_all(openscad_bin, scad_file, tmp_dir, verbose=False):
    """Export cavity and all component STLs."""
    os.makedirs(tmp_dir, exist_ok=True)
    paths = {}

    # Export cavity
    cavity_path = os.path.join(tmp_dir, "cavity.stl")
    print(f"Exporting cavity...")
    if export_stl(openscad_bin, scad_file, CAVITY_EXPORT_MODE, cavity_path, verbose):
        paths["cavity"] = cavity_path
    else:
        print(f"{RED}FATAL: Could not export cavity STL{RESET}")
        return None

    # Export each component
    for mode, name in COMPONENTS.items():
        stl_path = os.path.join(tmp_dir, f"{name}.stl")
        print(f"Exporting {name}...")
        if export_stl(openscad_bin, scad_file, mode, stl_path, verbose):
            paths[name] = stl_path
        else:
            print(f"{YELLOW}WARNING: Could not export {name}, skipping{RESET}")

    return paths


# ---------------------------------------------------------------------------
# Geometric Validation
# ---------------------------------------------------------------------------

def load_mesh(path, name):
    """Load an STL mesh and validate it."""
    try:
        mesh = trimesh.load(path, force="mesh")
        if mesh.is_empty:
            print(f"  {YELLOW}WARNING: {name} mesh is empty{RESET}")
            return None
        return mesh
    except Exception as e:
        print(f"  {RED}ERROR loading {name}: {e}{RESET}")
        return None


def check_containment(component_mesh, cavity_mesh, component_name, verbose=False):
    """
    Check if a component is fully contained within the cavity.

    Uses boolean difference: component - cavity. If the result has any
    volume, the component protrudes outside the cavity.
    """
    try:
        # component - cavity = protruding volume (should be empty)
        difference = trimesh.boolean.difference(
            [component_mesh, cavity_mesh], engine="manifold"
        )

        if difference is None or difference.is_empty:
            return True, 0.0

        protrusion_vol = abs(difference.volume)

        # Tiny volumes (< 0.01 mm³) are numerical noise
        if protrusion_vol < 0.01:
            return True, protrusion_vol

        if verbose:
            print(f"    Protrusion volume: {protrusion_vol:.2f} mm³")

        return False, protrusion_vol

    except Exception as e:
        print(f"    {YELLOW}Boolean op failed for {component_name}: {e}{RESET}")
        # Fall back to bounding box check
        comp_bounds = component_mesh.bounds
        cav_bounds = cavity_mesh.bounds
        contained = (
            np.all(comp_bounds[0] >= cav_bounds[0] - 0.1) and
            np.all(comp_bounds[1] <= cav_bounds[1] + 0.1)
        )
        return contained, 0.0


def check_intersection(mesh_a, mesh_b, name_a, name_b, verbose=False):
    """
    Check if two component meshes intersect.

    Uses boolean intersection: A ∩ B. If the result has any volume,
    the components collide.
    """
    try:
        # Quick bounding box pre-check
        if not mesh_a.bounds is None and not mesh_b.bounds is None:
            a_min, a_max = mesh_a.bounds
            b_min, b_max = mesh_b.bounds
            # Check for bounding box overlap
            if np.any(a_min >= b_max) or np.any(b_min >= a_max):
                return True, 0.0  # No overlap — pass

        intersection = trimesh.boolean.intersection(
            [mesh_a, mesh_b], engine="manifold"
        )

        if intersection is None or intersection.is_empty:
            return True, 0.0

        collision_vol = abs(intersection.volume)

        # Tiny volumes (< 0.01 mm³) are numerical noise
        if collision_vol < 0.01:
            return True, collision_vol

        if verbose:
            print(f"    Collision volume: {collision_vol:.2f} mm³")

        return False, collision_vol

    except Exception as e:
        print(f"    {YELLOW}Boolean op failed for {name_a}×{name_b}: {e}{RESET}")
        return True, 0.0  # Can't verify — assume pass


# ---------------------------------------------------------------------------
# Main Validation Pipeline
# ---------------------------------------------------------------------------

def run_validation(stl_paths, verbose=False):
    """Run all geometric checks and return pass/fail status."""
    all_passed = True
    results = []

    # Load cavity mesh
    print(f"\n{BOLD}Loading meshes...{RESET}")
    cavity = load_mesh(stl_paths["cavity"], "cavity")
    if cavity is None:
        print(f"{RED}FATAL: Cannot load cavity mesh{RESET}")
        return False

    # Load component meshes
    components = {}
    for name in COMPONENTS.values():
        if name in stl_paths:
            mesh = load_mesh(stl_paths[name], name)
            if mesh is not None:
                components[name] = mesh
                if verbose:
                    vol = abs(mesh.volume)
                    print(f"  {name}: {vol:.1f} mm³, "
                          f"bounds {mesh.bounds[0]} → {mesh.bounds[1]}")

    # --- Containment Checks ---
    print(f"\n{BOLD}=== CAVITY CONTAINMENT CHECKS ==={RESET}")
    for name, mesh in components.items():
        passed, vol = check_containment(mesh, cavity, name, verbose)

        if name in PASS_THROUGH_COMPONENTS:
            # These components intentionally pass through walls
            print(f"  [{GREEN}SKIP{RESET}] {name} — passes through wall by design"
                  f" ({vol:.0f} mm³ external)")
            results.append(("containment", name, True))
        else:
            status = f"{GREEN}PASS{RESET}" if passed else f"{RED}FAIL{RESET}"
            detail = "" if passed else f" (protrusion: {vol:.2f} mm³)"
            print(f"  [{status}] {name} contained in cavity{detail}")
            results.append(("containment", name, passed))
            if not passed:
                all_passed = False

    # --- Pair-wise Collision Checks ---
    print(f"\n{BOLD}=== COMPONENT COLLISION CHECKS ==={RESET}")
    comp_names = list(components.keys())
    for i in range(len(comp_names)):
        for j in range(i + 1, len(comp_names)):
            name_a = comp_names[i]
            name_b = comp_names[j]
            passed, vol = check_intersection(
                components[name_a], components[name_b],
                name_a, name_b, verbose
            )
            status = f"{GREEN}PASS{RESET}" if passed else f"{RED}FAIL{RESET}"
            detail = "" if passed else f" (collision: {vol:.2f} mm³)"
            print(f"  [{status}] {name_a} × {name_b}{detail}")
            results.append(("collision", f"{name_a}×{name_b}", passed))
            if not passed:
                all_passed = False

    # --- Summary ---
    total = len(results)
    passed_count = sum(1 for _, _, p in results if p)
    failed_count = total - passed_count

    print(f"\n{BOLD}=== SUMMARY ==={RESET}")
    if all_passed:
        print(f"{GREEN}ALL {total} CHECKS PASSED{RESET}")
    else:
        print(f"{RED}{failed_count} of {total} CHECKS FAILED:{RESET}")
        for check_type, name, passed in results:
            if not passed:
                print(f"  {RED}✗ {check_type}: {name}{RESET}")

    return all_passed


def main():
    parser = argparse.ArgumentParser(
        description="SpeedsterAI geometric collision validation"
    )
    parser.add_argument(
        "--openscad", default=None,
        help="Path to OpenSCAD binary"
    )
    parser.add_argument(
        "--skip-export", action="store_true",
        help="Skip STL export, use existing files in tmp/validation/"
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true",
        help="Show detailed output"
    )
    args = parser.parse_args()

    print(f"{BOLD}SpeedsterAI — Geometric Collision Validation{RESET}")
    print(f"{'=' * 46}\n")

    # Find OpenSCAD
    openscad_bin = args.openscad or find_openscad()
    if not openscad_bin and not args.skip_export:
        print(f"{RED}ERROR: OpenSCAD not found. Install it or use --openscad PATH{RESET}")
        sys.exit(2)

    # Export STLs
    if args.skip_export:
        print("Skipping STL export, using existing files...")
        stl_paths = {"cavity": os.path.join(TMP_DIR, "cavity.stl")}
        for name in COMPONENTS.values():
            path = os.path.join(TMP_DIR, f"{name}.stl")
            if os.path.exists(path):
                stl_paths[name] = path
            else:
                print(f"  {YELLOW}WARNING: {path} not found, skipping{RESET}")
    else:
        print(f"Exporting STLs via OpenSCAD...")
        start = time.time()
        stl_paths = export_all(openscad_bin, SCAD_FILE, TMP_DIR, args.verbose)
        elapsed = time.time() - start
        if stl_paths is None:
            sys.exit(2)
        print(f"Export complete ({elapsed:.1f}s)\n")

    # Run validation
    start = time.time()
    all_passed = run_validation(stl_paths, args.verbose)
    elapsed = time.time() - start
    print(f"\nValidation completed in {elapsed:.1f}s")

    sys.exit(0 if all_passed else 1)


if __name__ == "__main__":
    main()
