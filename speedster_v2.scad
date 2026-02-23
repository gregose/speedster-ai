// ============================================================
// Paul Carmody's Speedster - 3D Printed Enclosure v2
// "Curved-Back Wedge" Design
// 
// Parametric OpenSCAD Design
// Printer: Bambu Lab H2D
// Material: PETG (single material, 10mm walls)
// Seal: Tongue-and-groove joint with foam tape or TPU strip
// 
// Drivers:
//   Woofer:  Tang Band W4-1720 (surface mounted)
//   Tweeter: Fountek NeoCD1.0 (flush mounted, round faceplate)
//
// Target specs:
//   Internal volume: 5.5 liters
//   Port: 1.375" dia x 4.5" long, tuned to ~55 Hz
//   
// Shape: Wide flat baffle tapering to narrow rounded back
// Assembly: Front/back split with tongue-and-groove seal + M4 bolts
//           8 pillar pairs with concentric interlocks at split plane
// ============================================================

// ========================
// PARAMETRIC VARIABLES
// ========================

// --- Target ---
target_volume_liters = 5.5;

// --- Wall thickness ---
wall = 10;                // PETG wall thickness (mm)

// --- Baffle (front face) dimensions ---
baffle_width = 165;       // External width at front (mm) - close to original 152mm
baffle_height = 300;      // External height (mm) - taller for volume
baffle_corner_r = 15;     // Corner rounding on front face

// --- Front edge roundover ---
// Smooths baffle-to-side transition to reduce diffraction
// Larger = better diffraction behavior, blends into taper
baffle_roundover = 28;    // Front edge roundover radius (mm)

// --- Back dimensions ---
// NOTE: back_width must be >= terminal_outer + 15mm for binding plate to fit
back_width = 118;         // External width at rear (mm) - sized for binding plate
back_height = 240;        // External height at rear (mm)
back_corner_r = 42;       // Generous rounding on back

// --- Depth ---
enclosure_depth = 185;    // Total external depth (mm) - TUNED for 5.5L

// --- Taper curve ---
// Controls the shape of the wedge taper
// Higher = more volume up front, sharper taper at back
// 1.0 = linear taper, 2.0 = quadratic, 1.5 = gentle curve
taper_power = 2.0;        // TUNED - quadratic taper for 5.5L target

// --- Port parameters ---
port_diameter = 34.925;   // 1.375 inches in mm
port_length = 114.3;      // 4.5 inches in mm
port_wall_thick = 2.5;    // Port tube wall thickness
port_x_offset = 0;        // Centered horizontally
port_y_offset = 45;       // Behind tweeter area (positive = upper)
port_flare_r = 15;        // Radius of smooth flare at port exit (back face, mm)
port_entry_flare_r = 15;  // Radius of smooth flare at port entry (cavity side, mm)

// Port reinforcement ribs at back wall junction
port_rib_count = 6;        // Number of gusset ribs around port circumference
port_rib_height = 15;      // Rib extent along port tube from back wall (mm)
port_rib_extent = 10;      // Radial extent beyond port tube outer surface (mm)
port_rib_thick = 2;        // Rib thickness in circumferential direction (mm)

// --- Split plane ---
// Split aligned with front end of port tube so port stays 
// entirely in the back half (no split through the port)
// Port front = enclosure_depth - wall - port_length
split_z = enclosure_depth - wall - port_length;  // ~60.7mm from front

// --- Driver parameters ---

// Tang Band W4-1720 (surface mounted)
// Dimensions from mechanical drawing
woofer_cutout_dia = 95.5;        // Baffle cutout diameter (mm)
woofer_flange_dia = 125.5;       // Overall flange OD (mm)
woofer_screw_circle_dia = 115.0; // Screw hole circle diameter (mm)
woofer_screw_dia = 5.2;          // Driver flange hole diameter (mm) - passes M4
woofer_screw_cbore_dia = 8.5;    // Screw counterbore diameter (mm)
woofer_screw_count = 4;          // Number of mounting screws
woofer_flange_thick = 4.5;       // Flange thickness (mm)
woofer_total_depth = 89;         // Total depth behind baffle (mm)
woofer_magnet_dia = 90;          // Magnet diameter for clearance (mm)
woofer_y_offset = -45;           // Below center
// M4 heat-set inserts for woofer mounting
woofer_insert_dia = 5.6;         // M4 heat-set insert hole diameter
woofer_insert_depth = 6;         // Insert pocket depth (mm)

// Fountek NeoCD1.0 (flush mounted, ROUND faceplate)
// Dimensions from mechanical drawing
tweeter_faceplate_dia = 100;      // Round faceplate OD (mm)
tweeter_cutout_dia = 76;          // Baffle cutout for body (mm)
tweeter_recess_depth = 4.0;       // Faceplate thickness / flush recess (mm)
tweeter_ribbon_w = 24;            // Ribbon opening width (mm)  
tweeter_ribbon_h = 46;            // Ribbon opening height (mm)
tweeter_screw_spacing = 60.8;     // Square screw pattern spacing (mm)
tweeter_screw_dia = 3.5;          // Driver faceplate hole diameter (mm) - passes M3
tweeter_screw_count = 4;          // 4 screws in square pattern
tweeter_body_dia = 80;            // Body barrel diameter behind baffle (mm)
tweeter_rear_width = 55;          // Rear body width (mm)
tweeter_mount_depth = 70;         // Total depth behind baffle (66 + 4mm faceplate)
tweeter_y_offset = 55;            // Above center
// M3 heat-set inserts for tweeter mounting
tweeter_insert_dia = 4.5;         // M3 heat-set insert hole diameter
tweeter_insert_depth = 5;         // Insert pocket depth (mm)

// --- Assembly hardware ---
bolt_dia = 4.2;           // M4 through-hole diameter
insert_dia = 5.6;         // M4 heat-set insert hole
insert_depth = 8;          // Insert pocket depth
bolt_landing_dia = 8;      // Counterbore/landing diameter for bolt head
bolt_inset = 12;           // Distance from edge to bolt center

// --- Tongue-and-groove seal joint ---
// Tongue on front half, groove in back half
// Self-aligning + sealing with foam tape or TPU in groove
tongue_width = 3;          // Width of tongue ridge (mm)
tongue_height = 4;         // Tongue protrusion past split face (mm)
tongue_clearance = 0.3;    // Gap per side for print tolerance (mm)
seal_depth = 1;            // Extra groove depth below tongue for foam/TPU (mm)
tongue_inset = 5;          // From outer wall to tongue center (mm)

// --- Binding post plate (Dayton Audio SBPP-SI) ---
// From mechanical drawing: square plate with countersunk corner screws
terminal_outer = 100.6;          // Overall plate size (mm, square)
terminal_cutout = 76.5;          // Inner cutout that passes through wall (mm, square)
terminal_cutout_r = 4;           // Inner cutout corner radius (R4)
terminal_screw_spacing = 84.5;   // Screw hole spacing (mm, square pattern)
terminal_screw_dia = 4.5;        // M4 clearance hole in plate (mm)
terminal_insert_dia = 5.6;       // M4 heat-set insert hole diameter (mm)
terminal_insert_depth = 6;       // Heat-set insert pocket depth (mm)
terminal_recess_depth = 3;       // Depth the plate lip inserts into wall (mm)
terminal_y_offset = -45;         // Below center on rear face (limited by back_height)

// --- Crossover PCB mounting ---
// Two PCBs (high-pass and low-pass) separated from V-cut stack,
// mounted on opposing side walls with components facing inward.
// PCB dimensions from gregose/speedster-crossover KiCad layout.
xover_pcb_width = 92;            // PCB width (mm) - maps to Z axis
xover_pcb_height = 126;          // PCB height (mm) - maps to Y axis
xover_pcb_thick = 1.6;           // PCB board thickness (mm)
xover_comp_height = 40;          // Max component height, most parts (mm)
xover_comp_height_tall = 50;     // Tallest inductor height (mm)
xover_tall_pcb_y = 80;           // Tall inductor Y position on PCB (from top=0)

// Mounting hole positions on PCB (from top-left corner as 0,0):
//   (43,5), (87,5), (87,121), (5,121)
// Hole diameter: 3.3mm (accepts M3 screws)
xover_holes = [[43,5], [87,5], [87,121], [5,121]];
xover_hole_dia = 3.3;

// Mounting boss parameters
xover_boss_dia = 10;             // Boss pad diameter (mm)
xover_insert_dia = 4.5;          // M3 heat-set insert hole diameter
xover_insert_depth = 5;          // Insert pocket depth (mm)
xover_boss_min_depth = 6;        // Minimum boss depth for insert engagement

// PCB placement in enclosure coordinates
// PCB long axis (126mm) runs vertically (Y), short axis (92mm) along Z
// Board top at y=19, bottom at y=-107
// Z from 62 to 154 (just past split plane to ~20mm before binding posts)
xover_y_top = 19;                // Enclosure Y of PCB top edge
xover_z_start = 62;              // Enclosure Z of PCB front edge (past split)

// Binding post dimensions (Dayton BPP-SN)
// Side-by-side posts at x=±9.5mm from terminal center (y=-45)
// Intrusion past inner wall: ~24mm (15mm thread + 9mm solder lug)
// Conservative clearance envelope: 30mm depth from inner back wall
bp_spacing = 19.05;              // Post center-to-center spacing (mm)
bp_intrusion = 30;               // Conservative depth past inner wall (mm)

// --- Rendering ---
$fn = 100;

// ========================
// CORE SHAPE: TAPERED WEDGE
// ========================

// 2D cross-section at depth z (0=front, enclosure_depth=back)
// Smoothly tapers from baffle dims to back dims
// Incorporates front edge roundover in the first baffle_roundover mm
module cross_section_at(z) {
    t = z / enclosure_depth;
    t_curved = pow(t, taper_power);
    
    // Base interpolated dimensions (baffle → back taper)
    w_base = baffle_width * (1 - t_curved) + back_width * t_curved;
    h_base = baffle_height * (1 - t_curved) + back_height * t_curved;
    r_base = baffle_corner_r * (1 - t_curved) + back_corner_r * t_curved;
    
    // Front edge roundover: in the first baffle_roundover mm of depth,
    // reduce width and height to create a smooth curved lip
    // Uses a circular profile: at z=0 the section is inset by roundover,
    // at z=baffle_roundover it reaches full size
    if (z < baffle_roundover && baffle_roundover > 0) {
        // Circular roundover profile
        // At z=0: inset = baffle_roundover (maximum reduction)
        // At z=baffle_roundover: inset = 0 (full size)
        frac = z / baffle_roundover;
        // Circular profile: inset = R - sqrt(R² - (R-z)²) = R(1 - sqrt(1-(1-frac)²))
        roundover_inset = baffle_roundover * (1 - sqrt(1 - pow(1 - frac, 2)));
        
        w = max(0.1, w_base - 2 * roundover_inset);
        h = max(0.1, h_base - 2 * roundover_inset);
        r = min(r_base, w/2 - 0.1, h/2 - 0.1);
        
        offset(r = r)
            square([max(0.1, w - 2*r), max(0.1, h - 2*r)], center = true);
    } else {
        w = w_base;
        h = h_base;
        r_safe = min(r_base, w/2 - 0.1, h/2 - 0.1);
        
        offset(r = r_safe)
            square([max(0.1, w - 2*r_safe), max(0.1, h - 2*r_safe)], center = true);
    }
}

// Build outer shell by hulling adjacent slices
// Uses finer slicing in the roundover zone for smooth curvature
module outer_shape() {
    // Fine slices in roundover zone
    roundover_slices = 20;
    if (baffle_roundover > 0) {
        for (i = [0 : roundover_slices - 1]) {
            z0 = baffle_roundover * i / roundover_slices;
            z1 = baffle_roundover * (i + 1) / roundover_slices;
            hull() {
                translate([0, 0, z0])
                    linear_extrude(height = 0.01)
                        cross_section_at(z0);
                translate([0, 0, z1])
                    linear_extrude(height = 0.01)
                        cross_section_at(z1);
            }
        }
    }
    
    // Regular slices for the rest of the body
    body_slices = 40;
    z_start = max(0.01, baffle_roundover);
    for (i = [0 : body_slices - 1]) {
        z0 = z_start + (enclosure_depth - z_start) * i / body_slices;
        z1 = z_start + (enclosure_depth - z_start) * (i + 1) / body_slices;
        hull() {
            translate([0, 0, z0])
                linear_extrude(height = 0.01)
                    cross_section_at(z0);
            translate([0, 0, z1])
                linear_extrude(height = 0.01)
                    cross_section_at(z1);
        }
    }
}

// Inner cavity cross-section (inset by wall thickness)
module inner_cross_section_at(z) {
    t = z / enclosure_depth;
    t_curved = pow(t, taper_power);
    
    w_outer = baffle_width * (1 - t_curved) + back_width * t_curved;
    h_outer = baffle_height * (1 - t_curved) + back_height * t_curved;
    r_outer = baffle_corner_r * (1 - t_curved) + back_corner_r * t_curved;
    
    w = w_outer - 2 * wall;
    h = h_outer - 2 * wall;
    r = max(1, r_outer - wall);
    r_safe = min(r, max(0.1, w/2 - 0.1), max(0.1, h/2 - 0.1));
    
    if (w > 0.2 && h > 0.2) {
        offset(r = r_safe)
            square([max(0.1, w - 2*r_safe), max(0.1, h - 2*r_safe)], center = true);
    }
}

// Full inner cavity
// IMPORTANT: Uses the same hull slice z-positions as outer_shape() but
// offset by a tiny epsilon (0.001mm). This ensures:
//   1. Hull boundaries nearly align (no visible shelves from mismatched steps)
//   2. No exactly coplanar faces with outer_shape (prevents non-manifold edges)
// Without this alignment, each mismatched hull boundary creates a visible
// horizontal plane artifact in the STL.
module inner_cavity() {
    // Tiny offset to prevent exact coplanarity with outer_shape hull faces
    _eps = 0.001;
    
    // Roundover zone: same 20 slices as outer_shape, clamped to [wall, roundover]
    roundover_slices = 20;
    if (baffle_roundover > wall) {
        for (i = [0 : roundover_slices - 1]) {
            z0_raw = baffle_roundover * i / roundover_slices + _eps;
            z1_raw = baffle_roundover * (i + 1) / roundover_slices + _eps;
            z0 = max(wall, z0_raw);
            z1 = z1_raw;
            if (z0 < z1) {
                hull() {
                    translate([0, 0, z0])
                        linear_extrude(height = 0.01)
                            inner_cross_section_at(z0);
                    translate([0, 0, z1])
                        linear_extrude(height = 0.01)
                            inner_cross_section_at(z1);
                }
            }
        }
    }

    // Body zone: same 40 slices as outer_shape, clamped to [roundover, depth-wall]
    body_slices = 40;
    z_start = max(0.01, baffle_roundover);
    for (i = [0 : body_slices - 1]) {
        z0_raw = z_start + (enclosure_depth - z_start) * i / body_slices + _eps;
        z1_raw = z_start + (enclosure_depth - z_start) * (i + 1) / body_slices + _eps;
        z1 = min(enclosure_depth - wall, z1_raw);
        if (z0_raw < z1) {
            hull() {
                translate([0, 0, z0_raw])
                    linear_extrude(height = 0.01)
                        inner_cross_section_at(z0_raw);
                translate([0, 0, z1])
                    linear_extrude(height = 0.01)
                        inner_cross_section_at(z1);
            }
        }
    }
}

// ========================
// DRIVER CUTOUTS
// ========================

// Woofer rear chamfer parameters
woofer_chamfer_start = 3;     // Depth of straight bore before chamfer begins (mm)
                               // Leaves material for screw thread engagement
woofer_chamfer_angle = 45;     // Chamfer angle (degrees from bore wall)
woofer_bore_r = woofer_cutout_dia / 2;
woofer_chamfer_depth = wall - woofer_chamfer_start;
woofer_chamfer_expand = woofer_chamfer_depth * tan(woofer_chamfer_angle);

module woofer_cutout() {
    translate([0, woofer_y_offset, 0]) {
        // Unified bore + rear chamfer as a single solid of revolution
        // Profile: straight bore for woofer_chamfer_start depth,
        // then 45° chamfer widening toward the inside
        rotate_extrude($fn = $fn) {
            // Straight bore section (front face to chamfer start)
            translate([0, -1])
                square([woofer_bore_r, woofer_chamfer_start + 1]);
            
            // 45° chamfer section (widens toward interior)
            translate([0, woofer_chamfer_start])
                polygon([
                    [0, 0],
                    [woofer_bore_r, 0],
                    [woofer_bore_r + woofer_chamfer_expand, woofer_chamfer_depth + 1],
                    [0, woofer_chamfer_depth + 1]
                ]);
        }
        
        // Heat-set insert pockets - 4x M4 on 115mm circle, diamond pattern (45° offset)
        // Blind holes from front face for heat-set inserts
        // M4 screws pass through driver flange into these inserts
        for (i = [0 : woofer_screw_count - 1]) {
            angle = i * (360 / woofer_screw_count) + 45;
            translate([cos(angle) * woofer_screw_circle_dia/2,
                       sin(angle) * woofer_screw_circle_dia/2, -0.1]) {
                cylinder(d = woofer_insert_dia, h = woofer_insert_depth + 0.1);
            }
        }
    }
}

module tweeter_cutout() {
    translate([0, tweeter_y_offset, 0]) {
        // Flush recess for round faceplate (100mm dia, 4mm deep)
        translate([0, 0, -0.1])
            cylinder(d = tweeter_faceplate_dia, h = tweeter_recess_depth + 0.1);
        
        // Through-hole for driver body (76mm cutout)
        translate([0, 0, -1])
            cylinder(d = tweeter_cutout_dia, h = wall + 2);
        
        // Heat-set insert pockets - 4x M3 in SQUARE pattern (60.8mm x 60.8mm)
        // Pockets start at the recess floor (z = tweeter_recess_depth)
        // and go deeper into the baffle
        // M3 screws pass through faceplate into these inserts
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx * tweeter_screw_spacing/2,
                           sy * tweeter_screw_spacing/2,
                           tweeter_recess_depth - 0.1])
                    cylinder(d = tweeter_insert_dia, h = tweeter_insert_depth + 0.1);
    }
}

// ========================
// PORT
// ========================

// The port tube solid adds material inside the cavity for the port walls.
// Extends 1mm past the inner back wall (z = depth - wall + 1) to avoid
// coplanar faces with the inner cavity boundary at z = depth - wall.
// A bell-shaped cone at the entry end provides material for the entry flare.
module port_tube_solid() {
    port_start_z = enclosure_depth - wall - port_length;
    
    // Main straight tube — extended 1mm past inner back wall
    translate([port_x_offset, port_y_offset, port_start_z])
        cylinder(d = port_diameter + 2*port_wall_thick, 
                 h = port_length + 1);
    
    // Entry flare bell: cone from flare mouth diameter to tube diameter
    if (port_entry_flare_r > 0) {
        translate([port_x_offset, port_y_offset, port_start_z])
            cylinder(d1 = port_diameter + 2*port_entry_flare_r + 2*port_wall_thick,
                     d2 = port_diameter + 2*port_wall_thick,
                     h = port_entry_flare_r);
    }
}

// Triangular gusset ribs reinforcing the port tube at the back wall.
// Each rib is a hull of two thin strips: one along the tube outer
// surface (axial) and one along the inner back wall (radial).
// This spreads the tube-to-wall load across more layer lines.
module port_ribs() {
    port_end_z = enclosure_depth - wall;  // inner back wall surface
    tube_outer_r = (port_diameter + 2*port_wall_thick) / 2;
    
    translate([port_x_offset, port_y_offset, 0])
    for (i = [0:port_rib_count-1]) {
        rotate([0, 0, i * 360/port_rib_count])
        hull() {
            // Vertical strip on port tube outer surface
            translate([tube_outer_r - 0.5, -port_rib_thick/2,
                       port_end_z - port_rib_height])
                cube([1, port_rib_thick, port_rib_height]);
            // Horizontal strip on inner back wall
            translate([tube_outer_r, -port_rib_thick/2,
                       port_end_z - 1])
                cube([port_rib_extent, port_rib_thick, 1]);
        }
    }
}

// Unified port bore + flares as a single solid of revolution.
// 2D profile in the r-z plane (r = radial distance from port axis):
//   - Entry flare: quarter-circle from bore wall outward at the cavity face
//   - Straight bore wall (r = port_diameter/2) between flares
//   - Exit flare: quarter-circle from bore wall outward at the back face
// This is subtracted from the enclosure in one operation.
module port_bore() {
    // Z coordinates (absolute, along enclosure depth axis)
    port_start_z = enclosure_depth - wall - port_length;
    flare_start_z = enclosure_depth - port_flare_r;  // exit flare begins
    back_face_z = enclosure_depth;
    
    bore_r = port_diameter / 2;
    
    translate([port_x_offset, port_y_offset, 0]) {
        rotate_extrude($fn = $fn) {
            // Build the 2D bore+flare profile as a union of shapes
            // All in the positive-r half-plane (required by rotate_extrude)
            
            // 1. Straight bore: rectangle from port entrance to exit flare start
            //    Width = bore radius, positioned at r=0 to r=bore_r
            translate([0, port_start_z - 1])
                square([bore_r, flare_start_z - port_start_z + 1]);
            
            // 2. Entry flare (cavity-side bell):
            //    Quarter-circle concave curve from bore_r + entry_flare_r
            //    at the port mouth (z=port_start_z) down to bore_r at
            //    z = port_start_z + entry_flare_r (where straight bore begins)
            if (port_entry_flare_r > 0) {
                translate([0, port_start_z - 1])
                    difference() {
                        square([bore_r + port_entry_flare_r,
                                port_entry_flare_r + 1]);
                        translate([bore_r + port_entry_flare_r,
                                   port_entry_flare_r + 1])
                            circle(r = port_entry_flare_r, $fn = 60);
                    }
            }
            
            // 3. Exit flare (back-face bell):
            //    Quarter-circle from bore wall outward to the back face
            translate([0, flare_start_z])
                difference() {
                    square([bore_r + port_flare_r, port_flare_r + 1]);
                    // Quarter circle: center at (bore_r + flare_r, 0)
                    // This creates the concave curve from the bore wall
                    // tangent at z=flare_start_z, curving out to the 
                    // back face tangent at r=bore_r+flare_r
                    translate([bore_r + port_flare_r, 0])
                        circle(r = port_flare_r, $fn = 60);
                }
        }
    }
}

// ========================
// TERMINAL CUP
// ========================

module terminal_cutout() {
    // Position on back face, centered horizontally
    translate([0, terminal_y_offset, enclosure_depth - wall - 1]) {
        // Main through-hole (76.5 x 76.5mm with R4 corners)
        linear_extrude(height = wall + 2)
            offset(r = terminal_cutout_r)
                square([terminal_cutout - 2*terminal_cutout_r,
                        terminal_cutout - 2*terminal_cutout_r], center = true);
        
        // Recess for plate flange (100.6 x 100.6mm, 3mm deep from outside)
        translate([0, 0, wall + 1 - terminal_recess_depth])
            linear_extrude(height = terminal_recess_depth + 1)
                offset(r = 7)  // R7 outer corners per drawing
                    square([terminal_outer - 14, terminal_outer - 14], center = true);
        
        // 4x M4 heat-set insert pockets (84.5mm square pattern)
        // Bored from the recess floor inward (toward cavity)
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx * terminal_screw_spacing/2,
                           sy * terminal_screw_spacing/2,
                           wall + 1 - terminal_recess_depth - terminal_insert_depth])
                    cylinder(d = terminal_insert_dia, h = terminal_insert_depth + 0.1);
    }
}

// ========================
// BOLT PATTERN (SPLIT-PLANE PERIMETER)
// ========================

// 8 bolts around the perimeter of the split plane cross-section.
// Bolt from BACK through back half wall → into heat-set inserts in front pillars.
// Pillars in front half run from baffle to split face; back pillars match.
module bolt_positions() {
    t = split_z / enclosure_depth;
    t_curved = pow(t, taper_power);
    w_at_split = baffle_width * (1 - t_curved) + back_width * t_curved;
    h_at_split = baffle_height * (1 - t_curved) + back_height * t_curved;
    
    positions = [
        // Top and bottom center
        [0, h_at_split/2 - bolt_inset],
        [0, -(h_at_split/2 - bolt_inset)],
        // Left and right center  
        [w_at_split/2 - bolt_inset, 0],
        [-(w_at_split/2 - bolt_inset), 0],
        // Four corners (inset from edges)
        [w_at_split/2 - bolt_inset, h_at_split/2 - bolt_inset - 15],
        [-(w_at_split/2 - bolt_inset), h_at_split/2 - bolt_inset - 15],
        [w_at_split/2 - bolt_inset, -(h_at_split/2 - bolt_inset - 15)],
        [-(w_at_split/2 - bolt_inset), -(h_at_split/2 - bolt_inset - 15)],
    ];
    
    for (pos = positions) {
        translate([pos[0], pos[1], 0])
            children();
    }
}

// Through-holes for bolt shanks through the back half
module bolt_through_holes() {
    bolt_positions()
        translate([0, 0, split_z - 1])
            cylinder(d = bolt_dia, h = enclosure_depth - split_z + 2);
}

// Counterbores on the back exterior for bolt heads
// The enclosure tapers, so bolts exit through angled side walls.
// Strategy: find the z depth where the cross-section still provides
// at least 4mm of material around each bolt center (enough for an 8mm
// landing), then cut an 8mm cylinder from that z all the way to the back.
// This creates a flat perpendicular face at the right depth in the wall.
// The bolt head sits on this flat; slight overhang past the curve is OK.

// Function to find the deepest z where the cross-section edge is at least
// 'clearance' mm from a point (px, py). Uses the taper formula.
// Returns the z where the bolt center has exactly 'clearance' to the edge.
function landing_z(px, py, clearance) = 
    let(
        // For the x-direction: find z where half-width = abs(px) + clearance
        target_w = 2 * (abs(px) + clearance),
        // w(z) = baffle_width*(1-tc) + back_width*tc = target_w
        // tc = (baffle_width - target_w) / (baffle_width - back_width)
        tc_x = (abs(px) < 0.1) ? 1 :
               (baffle_width - target_w) / (baffle_width - back_width),
        
        // For the y-direction: find z where half-height = abs(py) + clearance  
        target_h = 2 * (abs(py) + clearance),
        tc_y = (abs(py) < 0.1) ? 1 :
               (baffle_height - target_h) / (baffle_height - back_height),
        
        // Use whichever constraint is tighter (smaller tc = shallower z)
        tc = max(0.001, min(tc_x, tc_y)),
        z = enclosure_depth * pow(tc, 1/taper_power)
    ) z;

// Uniform landing z: use the shallowest (most restrictive) bolt position
// so all bolts are the same length. Computed by finding the minimum
// landing_z across all 8 bolt positions.
function min_landing_z() = 
    let(
        t = split_z / enclosure_depth,
        t_curved = pow(t, taper_power),
        w = baffle_width * (1 - t_curved) + back_width * t_curved,
        h = baffle_height * (1 - t_curved) + back_height * t_curved,
        positions = [
            [0, h/2 - bolt_inset],
            [0, -(h/2 - bolt_inset)],
            [w/2 - bolt_inset, 0],
            [-(w/2 - bolt_inset), 0],
            [w/2 - bolt_inset, h/2 - bolt_inset - 15],
            [-(w/2 - bolt_inset), h/2 - bolt_inset - 15],
            [w/2 - bolt_inset, -(h/2 - bolt_inset - 15)],
            [-(w/2 - bolt_inset), -(h/2 - bolt_inset - 15)],
        ],
        zs = [for (p = positions) landing_z(p[0], p[1], bolt_landing_dia/2)]
    ) min(zs);

module bolt_counterbores() {
    cut_z = min_landing_z();
    
    bolt_positions()
        translate([0, 0, cut_z])
            cylinder(d = bolt_landing_dia, h = enclosure_depth - cut_z + 1);
}

// Heat-set insert pockets in the FRONT half at the split face
module insert_pockets() {
    bolt_positions()
        translate([0, 0, split_z - insert_depth])
            cylinder(d = insert_dia, h = insert_depth + 0.1);
}

// ========================
// PILLAR SYSTEM
// ========================

// Front pillars: baffle inner wall to split face
// Back pillars: split face into back half with taper
// Each pair meets at split plane with interlock boss/recess
pillar_dia = 16;          // Outer diameter of support pillar (mm)
pillar_length = split_z - wall;  // Front pillar length

// Pillar interlock: boss on BACK half, recess on FRONT half (insert side)
// This prevents heat-set insert expansion from interfering with the fit —
// expansion around the recess is absorbed by clearance, while the boss
// on the non-insert side stays at nominal dimensions.
pillar_interlock_dia = 10;    // Boss/recess outer diameter (mm)
pillar_interlock_h = 2;       // Boss height / recess depth (mm)
pillar_interlock_clearance = 0.3;  // Gap per side for print tolerance

// Back pillar extends from split face into back half
back_pillar_depth = 30;       // Functional depth from split face (increased for coverage)

// Taper on back pillars for overhang-free printing — gradual blend into wall
back_pillar_taper_angle = 15;  // Degrees from vertical (gentler = longer taper)
back_pillar_taper_h = (pillar_dia/2) / tan(back_pillar_taper_angle);

// Front pillars: solid cylinders from inner baffle to split face
module insert_pillars() {
    bolt_positions()
        translate([0, 0, wall])
            cylinder(d = pillar_dia, h = pillar_length);
}

// Back pillars: from split face into back cavity with 15° taper
module back_pillars() {
    bolt_positions()
        translate([0, 0, split_z]) {
            cylinder(d = pillar_dia, h = back_pillar_depth);
            translate([0, 0, back_pillar_depth])
                cylinder(d1 = pillar_dia, d2 = 0, h = back_pillar_taper_h);
        }
}

// Interlock RECESS on front pillars at split face (insert side)
// The recess absorbs any heat-set insert expansion
module pillar_interlock_recesses() {
    bolt_positions()
        translate([0, 0, split_z - pillar_interlock_h - 0.1])
            cylinder(d = pillar_interlock_dia + 2*pillar_interlock_clearance, 
                     h = pillar_interlock_h + 0.2);
}

// Interlock BOSS on back pillars at split face (no insert, stays nominal)
// Protrudes past split_z into front half territory
module pillar_interlock_bosses() {
    bolt_positions()
        translate([0, 0, split_z - pillar_interlock_h - 0.01])
            difference() {
                cylinder(d = pillar_interlock_dia, h = pillar_interlock_h + 0.01);
                // Clear the bolt through-hole
                translate([0, 0, -0.1])
                    cylinder(d = bolt_dia + 1, h = pillar_interlock_h + 0.3);
            }
}

// ========================
// TONGUE-AND-GROOVE SEAL JOINT
// ========================

// 2D ring at the split plane, centered within the wall thickness.
// Uses the outer and inner cross-sections at split_z, then creates
// a ring at a specified width centered between them.
// tongue_inset = distance from outer wall surface to ring center.
module seal_ring_2d(ring_width) {
    // Get outer cross-section dimensions at the split plane
    t = split_z / enclosure_depth;
    t_curved = pow(t, taper_power);
    w_out = baffle_width * (1 - t_curved) + back_width * t_curved;
    h_out = baffle_height * (1 - t_curved) + back_height * t_curved;
    r_out = baffle_corner_r * (1 - t_curved) + back_corner_r * t_curved;
    r_out_safe = min(r_out, w_out/2 - 0.1, h_out/2 - 0.1);
    
    // The ring center sits tongue_inset mm inside the outer surface
    // Outer edge of ring: inset by (tongue_inset - ring_width/2) from outer
    // Inner edge of ring: inset by (tongue_inset + ring_width/2) from outer
    inset_outer = tongue_inset - ring_width/2;
    inset_inner = tongue_inset + ring_width/2;
    
    w_ring_out = w_out - 2 * inset_outer;
    h_ring_out = h_out - 2 * inset_outer;
    r_ring_out = max(1, r_out_safe - inset_outer);
    
    w_ring_in = w_out - 2 * inset_inner;
    h_ring_in = h_out - 2 * inset_inner;
    r_ring_in = max(1, r_out_safe - inset_inner);
    
    difference() {
        // Outer edge of ring
        offset(r = min(r_ring_out, w_ring_out/2 - 0.1, h_ring_out/2 - 0.1))
            square([max(0.1, w_ring_out - 2*min(r_ring_out, w_ring_out/2 - 0.1, h_ring_out/2 - 0.1)),
                    max(0.1, h_ring_out - 2*min(r_ring_out, w_ring_out/2 - 0.1, h_ring_out/2 - 0.1))], center = true);
        // Inner edge of ring
        offset(r = min(r_ring_in, w_ring_in/2 - 0.1, h_ring_in/2 - 0.1))
            square([max(0.1, w_ring_in - 2*min(r_ring_in, w_ring_in/2 - 0.1, h_ring_in/2 - 0.1)),
                    max(0.1, h_ring_in - 2*min(r_ring_in, w_ring_in/2 - 0.1, h_ring_in/2 - 0.1))], center = true);
    }
}

// Tongue: raised ridge on the front half's split face
// Protrudes toward the back half
module tongue() {
    translate([0, 0, split_z - 0.01])
        linear_extrude(height = tongue_height + 0.01)
            seal_ring_2d(tongue_width);
}

// Groove: channel cut into the back half's split face
// Wider than tongue by 2x clearance, deeper by seal_depth
// Foam tape or TPU bead sits in the bottom of the groove
module groove() {
    groove_width = tongue_width + 2 * tongue_clearance;
    groove_depth = tongue_height + seal_depth;
    translate([0, 0, split_z - 0.1])
        linear_extrude(height = groove_depth + 0.1)
            seal_ring_2d(groove_width);
}

// ========================
// CROSSOVER PCB MOUNTING BOSSES
// ========================

// Helper: compute inner half-width at a given z depth
function inner_half_w_at(z) = 
    let(
        t = z / enclosure_depth,
        tc = pow(t, taper_power),
        w_outer = baffle_width * (1 - tc) + back_width * tc
    ) (w_outer - 2 * wall) / 2;

// Helper: compute inner half-height at a given z depth
function inner_half_h_at(z) =
    let(
        t = z / enclosure_depth,
        tc = pow(t, taper_power),
        h_outer = baffle_height * (1 - tc) + back_height * tc
    ) (h_outer - 2 * wall) / 2;

// Convert PCB hole coordinates to enclosure coordinates.
// sign: -1 for left wall (normal orientation), +1 for right wall (flipped)
//
// Left wall:  components face +x (inward). PCB mounted as-is.
//   PCB top-left (0,0) is at enclosure (z_start, y_top).
//
// Right wall: components face -x (inward). PCB rotated 180° around its
//   vertical axis so the component side faces the opposite direction.
//   This flips the x-coordinate: pcb_x → (pcb_width - pcb_x).
//   The y-coordinate is unchanged.
//
// Returns [enc_z, enc_y]
function xover_hole_enc(hole, sign) = 
    let(
        // Left wall (sign<0): PCB flipped so components face +x (inward)
        // Right wall (sign>0): PCB normal so components face -x (inward)
        pcb_x = (sign < 0) ? (xover_pcb_width - hole[0]) : hole[0],
        pcb_y = hole[1]
    )
    [xover_z_start + pcb_x, xover_y_top - pcb_y];

// Find the PCB face x-position magnitude.
// Uses the narrowest inner half-width across all hole z-positions
// for BOTH orientations, minus minimum boss depth.
// Returns a POSITIVE value; actual face_x is ±this value per side.
function xover_pcb_face_x_abs() =
    let(
        // Left wall uses flipped pcb_x, right wall uses normal pcb_x
        left_hws = [for (h = xover_holes) inner_half_w_at(xover_z_start + (xover_pcb_width - h[0]))],
        right_hws = [for (h = xover_holes) inner_half_w_at(xover_z_start + h[0])],
        min_hw = min([each left_hws, each right_hws])
    ) min_hw - xover_boss_min_depth;

// Crossover mounting bosses for ONE side wall.
// Each boss is a cylinder extending from the curved inner wall surface
// inward to a common flat PCB mounting face, plus a 45° triangular brace
// above each boss (in +Z direction, toward split plane) for print support.
//
// Back half prints with back wall DOWN on build plate, so Z DECREASES
// going upward during printing. Bosses near the back wall print first;
// bosses near the split plane print last. Each boss needs support from
// the +Z side (material already printed below it = closer to back wall).
//
// sign: -1 for left wall, +1 for right wall
module xover_bosses(sign) {
    face_abs = xover_pcb_face_x_abs();
    
    for (h = xover_holes) {
        enc = xover_hole_enc(h, sign);
        ez = enc[0];  // enclosure z
        ey = enc[1];  // enclosure y
        hw = inner_half_w_at(ez);  // inner half-width at this z
        
        // Boss spans from wall inner surface to PCB face
        boss_len = hw - face_abs;
        
        // Brace extends in +Z direction from the bottom of the boss
        // (ez + boss_dia/2) so the full cylinder is supported at 45°
        boss_r = xover_boss_dia / 2;
        brace_h = min(boss_len, (enclosure_depth - wall) - (ez + boss_r) - 0.5);
        
        if (sign < 0) {
            // Left wall: wall at x=-hw, face at x=-face_abs
            // Boss: cylinder hulled with flat slab at bottom so edges
            // meet the brace surface flush (no crescent gaps)
            hull() {
                translate([-hw, ey, ez])
                    rotate([0, 90, 0])
                        cylinder(d = xover_boss_dia, h = boss_len);
                translate([-hw, ey - boss_r, ez + boss_r])
                    cube([boss_len, xover_boss_dia, 0.01]);
            }
            // 45° brace from bottom of boss (+Z direction, toward back wall)
            hull() {
                translate([-hw, ey - boss_r, ez + boss_r])
                    cube([0.01, xover_boss_dia, brace_h]);
                translate([-face_abs - 0.01, ey - boss_r, ez + boss_r])
                    cube([0.01, xover_boss_dia, 0.01]);
            }
        } else {
            // Right wall: wall at x=+hw, face at x=+face_abs
            // Boss: cylinder hulled with flat slab at bottom
            hull() {
                translate([face_abs, ey, ez])
                    rotate([0, 90, 0])
                        cylinder(d = xover_boss_dia, h = boss_len);
                translate([face_abs, ey - boss_r, ez + boss_r])
                    cube([boss_len, xover_boss_dia, 0.01]);
            }
            // 45° brace from bottom of boss (+Z direction, toward back wall)
            hull() {
                translate([hw - 0.01, ey - boss_r, ez + boss_r])
                    cube([0.01, xover_boss_dia, brace_h]);
                translate([face_abs, ey - boss_r, ez + boss_r])
                    cube([0.01, xover_boss_dia, 0.01]);
            }
        }
    }
}

// Heat-set insert pockets in crossover bosses.
// Pocket is bored into the PCB-facing end of each boss.
// The pocket goes INTO the boss from the flat face toward the wall.
module xover_insert_pockets(sign) {
    face_abs = xover_pcb_face_x_abs();
    
    for (h = xover_holes) {
        enc = xover_hole_enc(h, sign);
        ez = enc[0];
        ey = enc[1];
        
        if (sign < 0) {
            // Left wall: PCB face at x=-face_abs
            // Bore in -x direction (toward wall at -hw)
            translate([-face_abs, ey, ez])
                rotate([0, -90, 0])
                    cylinder(d = xover_insert_dia, h = xover_insert_depth + 0.1);
        } else {
            // Right wall: PCB face at x=+face_abs
            // Bore in +x direction (toward wall at +hw)
            translate([face_abs, ey, ez])
                rotate([0, 90, 0])
                    cylinder(d = xover_insert_dia, h = xover_insert_depth + 0.1);
        }
    }
}

// Both sets of crossover bosses (left and right walls)
module xover_bosses_all() {
    xover_bosses(-1);  // Left wall (PCB flipped so components face +x inward)
    xover_bosses(+1);  // Right wall (PCB normal, components face -x inward)
}

module xover_insert_pockets_all() {
    xover_insert_pockets(-1);
    xover_insert_pockets(+1);
}

// ========================
// FULL ENCLOSURE (ASSEMBLED)
// ========================

module full_enclosure() {
    difference() {
        union() {
            // Main shell
            difference() {
                outer_shape();
                inner_cavity();
            }
            
            // Port tube (added to shell)
            intersection() {
                outer_shape();
                port_tube_solid();
            }
            
            // Port reinforcement ribs at back wall junction
            intersection() {
                inner_cavity();
                port_ribs();
            }
            
            // Front pillar bosses (inside front half)
            intersection() {
                inner_cavity();
                insert_pillars();
            }
            
            // Back pillar bosses (inside back half)
            intersection() {
                inner_cavity();
                back_pillars();
            }
            
            // Crossover PCB mounting bosses (both side walls)
            // Added directly without inner_cavity intersection to avoid
            // coplanar faces between boss cylinder facets and cavity hull
            // boundaries, which create horizontal plane artifacts in STL.
            // Bosses are already positioned within the cavity (from inner
            // wall surface to PCB face), so clipping is unnecessary.
            xover_bosses_all();
        }
        
        // Subtract all cutouts
        woofer_cutout();
        tweeter_cutout();
        port_bore();
        terminal_cutout();
        bolt_through_holes();
        insert_pockets();
        
        // Crossover mount insert pockets
        xover_insert_pockets_all();
    }
}

// ========================
// SPLIT INTO HALVES
// ========================

// Cutting block: everything in front of split plane
module front_block() {
    translate([-500, -500, -1])
        cube([1000, 1000, split_z + 1]);
}

// Cutting block: everything behind split plane
module back_block() {
    translate([-500, -500, split_z])
        cube([1000, 1000, 1000]);
}

// --- Front half (baffle side) ---
// Contains: baffle, driver cutouts, front pillars with heat-set pockets
// Tongue protrudes from split face for alignment and sealing
// Interlock recesses in each pillar face accept bosses from back half
// No visible hardware on front face
module front_half() {
    difference() {
        union() {
            intersection() {
                full_enclosure();
                front_block();
            }
            // Add tongue ridge on split face
            intersection() {
                outer_shape();  // Keep tongue within enclosure outline
                tongue();
            }
        }
        // Cut interlock recesses into front pillar faces
        pillar_interlock_recesses();
    }
}

// --- Back half ---
// Contains: port tube (intact), terminal plate, back pillars,
// bolt holes + counterbores
// Groove in split face accepts tongue from front half
// Interlock bosses protrude from each back pillar toward front half
module back_half() {
    union() {
        difference() {
            intersection() {
                full_enclosure();
                back_block();
            }
            // Counterbores for bolt heads on back exterior
            bolt_counterbores();
            // Cut groove into split face for tongue + seal strip
            groove();
        }
        // Add interlock bosses on back pillar faces
        // These protrude past split_z into front half territory
        pillar_interlock_bosses();
    }
}

// ========================
// SEAL VISUALIZATION
// ========================

// 3D tongue-and-groove joint for visualization
module seal_joint_3d() {
    color("Gold", 0.9) tongue();
    color("DarkOrange", 0.5) groove();
}

// ========================
// WHAT TO RENDER / EXPORT
// ========================

// render_mode controls what is displayed:
//   0 = Full assembled (default)
//   1 = Exploded view (front/back separated)
//   2 = Front half only
//   3 = Back half only
//   4 = Inner cavity (for volume check)
// Override from CLI: openscad -D render_mode=1 ...
render_mode = 0;

// Display rotation: model uses Y=vertical, but OpenSCAD screen uses Z=up.
// rotate([90,0,0]) stands the speaker upright for PNG renders (tweeter on top).
// After rotation: X=horizontal, Y=depth(0=baffle,-185=back), Z=height.
// Model center: (0, -92.5, 0). See render.sh for standard camera angles.
// For STL export, set render_mode and don't apply this rotation.
rotate([90, 0, 0])
if (render_mode == 0) {
    // Full assembled visualization
    color("SlateBlue", 0.7) full_enclosure();
} else if (render_mode == 1) {
    // Exploded view (shows pillar interlocks + tongue-and-groove)
    translate([0, 0, -40]) color("SteelBlue", 0.8) front_half();
    translate([0, 0, 40]) color("CornflowerBlue", 0.8) back_half();
} else if (render_mode == 2) {
    // Front half (baffle side)
    color("SteelBlue", 0.8) front_half();
} else if (render_mode == 3) {
    // Back half
    color("CornflowerBlue", 0.8) back_half();
} else if (render_mode == 4) {
    // Inner cavity only (for volume check in slicer)
    inner_cavity();
}


// ========================
// VOLUME ESTIMATION
// ========================
// Approximate volume using Simpson's rule on cross-sections

// Front cavity cross-section area
_z_front = wall;
_t_f = _z_front / enclosure_depth;
_tc_f = pow(_t_f, taper_power);
_w_f = (baffle_width - 2*wall) * (1 - _tc_f) + max(0, back_width - 2*wall) * _tc_f;
_h_f = (baffle_height - 2*wall) * (1 - _tc_f) + max(0, back_height - 2*wall) * _tc_f;
_A_front = _w_f * _h_f;

// Mid cavity cross-section area
_z_mid = enclosure_depth / 2;
_t_m = _z_mid / enclosure_depth;
_tc_m = pow(_t_m, taper_power);
_w_m = (baffle_width - 2*wall) * (1 - _tc_m) + max(0, back_width - 2*wall) * _tc_m;
_h_m = (baffle_height - 2*wall) * (1 - _tc_m) + max(0, back_height - 2*wall) * _tc_m;
_A_mid = _w_m * _h_m;

// Back cavity cross-section area
_z_back = enclosure_depth - wall;
_t_b = _z_back / enclosure_depth;
_tc_b = pow(_t_b, taper_power);
_w_b = (baffle_width - 2*wall) * (1 - _tc_b) + max(0, back_width - 2*wall) * _tc_b;
_h_b = (baffle_height - 2*wall) * (1 - _tc_b) + max(0, back_height - 2*wall) * _tc_b;
_A_back = _w_b * _h_b;

// Simpson's rule: V = (h/6)(A1 + 4*A_mid + A2)
_cavity_length = enclosure_depth - 2*wall;
_vol_mm3 = (_cavity_length / 6) * (_A_front + 4*_A_mid + _A_back);
_vol_liters = _vol_mm3 / 1e6;

// Port tube displacement (straight tube + entry flare bell cone)
_port_outer_dia = port_diameter + 2*port_wall_thick;
_port_vol_mm3 = PI/4 * pow(_port_outer_dia, 2) * port_length;
// Entry flare bell: truncated cone from flare mouth to tube diameter
_bell_mouth_dia = port_diameter + 2*port_entry_flare_r + 2*port_wall_thick;
_bell_r1 = _bell_mouth_dia / 2;
_bell_r2 = _port_outer_dia / 2;
_bell_vol_mm3 = PI/3 * port_entry_flare_r * (_bell_r1*_bell_r1 + _bell_r2*_bell_r2 + _bell_r1*_bell_r2)
              - PI/4 * pow(_port_outer_dia, 2) * port_entry_flare_r;  // subtract overlap with main tube
_port_total_vol_mm3 = _port_vol_mm3 + _bell_vol_mm3;
_port_vol_liters = _port_total_vol_mm3 / 1e6;

// Pillar displacement (approximate - 8 front + 8 back pillars)
_pillar_vol_liters = 0.02;  // Rough estimate for pillar pairs

// Net volume
_net_vol = _vol_liters - _port_vol_liters - _pillar_vol_liters;

echo("============================================");
echo(str("  SPEEDSTER v2 - VOLUME ESTIMATE"));
echo(str("  Gross cavity:   ", _vol_liters, " L"));
echo(str("  Port tube:      -", _port_vol_liters, " L"));
echo(str("  Pillars (approx): -", _pillar_vol_liters, " L"));
echo(str("  ----------------------------------------"));
echo(str("  Net air volume:  ", _net_vol, " L"));
echo(str("  Target:          ", target_volume_liters, " L"));
echo(str("  Difference:      ", _net_vol - target_volume_liters, " L"));
echo("============================================");
echo(str("  Enclosure: ", baffle_width, "W x ", baffle_height, "H x ", enclosure_depth, "D mm"));
echo(str("  Back:      ", back_width, "W x ", back_height, "H mm"));
echo(str("  Wall:      ", wall, " mm PETG"));
echo(str("  Taper:     power=", taper_power));
echo("============================================");
echo(str("  Tune depth (enclosure_depth) to adjust volume."));
echo(str("  ~1mm depth change ≈ ", round(_A_mid/1000)/1000, " L"));
echo("============================================");
echo("");
echo("  DRIVER FIT CHECK:");
_woofer_top = woofer_y_offset + woofer_flange_dia/2;
_tweeter_bottom = tweeter_y_offset - tweeter_faceplate_dia/2;
_driver_gap = _tweeter_bottom - _woofer_top;
echo(str("  Woofer flange top edge:   y=", _woofer_top, " mm"));
echo(str("  Tweeter faceplate bottom: y=", _tweeter_bottom, " mm"));
echo(str("  Gap between drivers:      ", _driver_gap, " mm"));
echo(str("    (negative = overlap, Carmody's original overlaps slightly)"));
_woofer_screw_edge = woofer_screw_circle_dia/2 + woofer_screw_dia/2;
_baffle_inner_half = (baffle_width - 2*wall) / 2;
echo(str("  Woofer screw outermost:   ", _woofer_screw_edge, "mm from center"));
echo(str("  Baffle inner half-width:  ", _baffle_inner_half, "mm"));
echo(str("  Screw-to-wall clearance:  ", _baffle_inner_half - _woofer_screw_edge, "mm"));
echo(str("  Woofer depth behind baffle: ", woofer_total_depth, "mm"));
echo(str("  Tweeter depth behind baffle: ", tweeter_mount_depth, "mm"));
echo("");
echo("  DIFFRACTION / BAFFLE STEP:");
echo(str("  Baffle width:     ", baffle_width, "mm"));
echo(str("  Edge roundover:   ", baffle_roundover, "mm radius"));
_baffle_step_hz = round(344000 / (PI * baffle_width));
echo(str("  Est. baffle step: ~", _baffle_step_hz, " Hz"));
echo(str("  Roundover effective above: ~", round(344000 / (2 * PI * baffle_roundover)), " Hz"));
echo("");
echo("  For precise volume: export inner_cavity() as STL,");
echo("  import into Bambu Studio → check volume in cm³");
echo("");
echo("  CROSSOVER PCB MOUNTING:");
_xover_face_x = xover_pcb_face_x_abs();
echo(str("  PCB face x-position:  ±", _xover_face_x, "mm from center"));
echo(str("  PCB y range:          ", xover_y_top - xover_pcb_height, " to ", xover_y_top, "mm"));
echo(str("  PCB z range:          ", xover_z_start, " to ", xover_z_start + xover_pcb_width, "mm"));
_xover_port_clear = 25 - xover_y_top;
echo(str("  Port clearance below: ", _xover_port_clear, "mm (port bottom at y=25)"));
_bp_pcb_y = xover_y_top - (-45);
echo(str("  BP at y=-45 maps to:  PCB y=", _bp_pcb_y, " (normal comp height zone)"));
_xover_inductor_y = xover_y_top - xover_tall_pcb_y;
echo(str("  Tall inductor at:     enc y=", _xover_inductor_y, " (BP zone: y=-60 to -30)"));
echo(str("  Boss lengths:         ", xover_boss_min_depth, "mm min (at narrowest) to ~20mm"));
echo("");


// ========================
// PRINT NOTES
// ========================
// 
// PETG Settings (10mm walls):
//   Layer height: 0.2mm
//   Perimeters: 5-6 (to fill most of the 10mm wall)
//   Infill: 50-80% gyroid (for remaining wall fill)
//   Top/bottom layers: 8+
//   Supports: Yes, for driver cutouts and counterbores
//
// Print orientation:
//   Front half: baffle face DOWN on bed (split face up)
//   Back half:  split face DOWN on build plate
//
// Assembly:
//   1. Print both halves (pillars + interlocks integral to each)
//   2. Clean up supports from driver cutouts
//   3. Install M4 heat-set inserts into front half pillars (8x enclosure bolts)
//   4. Install M4 heat-set inserts into woofer screw holes (4x, from front face)
//   5. Install M3 heat-set inserts into tweeter recess floor (4x, from recess)
//   6. Install M3 heat-set inserts into crossover bosses (8x, 4 per side wall)
//   7. Mount high-pass PCB on one side wall, low-pass on opposite (M3 screws)
//   8. Run speaker wire from back to front through split plane
//   9. Press foam tape or TPU strip into groove on back half split face
//   10. Add polyfill loosely to cavity
//   11. Align tongue into groove and interlock bosses into recesses,
//       mate halves, bolt from BACK with M4 caps
//       (bolt heads on rear tapered walls, no hardware on front)
//   12. Mount tweeter (flush into recess) with M3 screws
//   13. Mount woofer (surface mount) with M4 screws
//   14. Connect drivers to crossover
//   15. Install binding post plate on rear
//
// Hardware BOM (per speaker):
//   Enclosure assembly:
//     8x M4 heat-set inserts (Ø5.6mm × 8mm deep) - front half pillars
//     8x M4 × 16mm socket head cap screws - from back
//   Woofer mounting:
//     4x M4 heat-set inserts (Ø5.6mm × 6mm deep) - baffle front face
//     4x M4 × 10mm socket head cap screws - through driver flange
//   Tweeter mounting:
//     4x M3 heat-set inserts (Ø4.5mm × 5mm deep) - recess floor
//     4x M3 × 8mm socket head cap screws - through faceplate
//   Seal strip (one of):
//     Closed-cell foam tape ~3mm wide, pressed into groove
//     OR TPU filament bead laid into groove before mating
//   Crossover mounting:
//     8x M3 heat-set inserts (Ø4.5mm × 5mm deep) - side wall bosses (4 per side)
//     8x M3 × 8mm socket head cap screws - through PCB holes (4 per board)
//   Binding post plate:
//     4x M4 heat-set inserts (Ø5.6mm × 6mm deep) - back wall recess floor
//     4x M4 flat head (countersunk) cap screws - through plate countersunk holes
//
// Pillar interlock system:
//   8x 16mm dia pillar pairs (front + back) at split-plane perimeter
//   Front pillars: baffle inner wall to split face
//   Back pillars: split face + 30mm into back half, with 15° taper (~30mm cone)
//   Interlock BOSS on back pillar face (protrudes into front half)
//   Interlock RECESS on front pillar face (absorbs heat-set insert expansion)
//   Boss/recess: 10mm dia × 2mm, 0.3mm clearance per side
//   Boss on non-insert side stays at nominal dims; recess on insert side
//   absorbs thermal expansion from heat-set installation
//
// Tongue-and-groove joint:
//   Tongue: 3mm wide × 4mm tall ridge on front half split face
//   Groove: 3.6mm wide × 5mm deep channel in back half split face
//   Self-aligning in X and Y, seal strip compressed in groove bottom
//
// Crossover PCB mounting (split boards, one per side wall):
//   Two V-cut PCBs separated and mounted on opposing side walls
//   Left wall: PCB flipped (rotated 180° around vertical), components face +x (inward)
//   Right wall: PCB in normal orientation, components face -x (inward)
//   Hole pattern differs per side due to asymmetric flip
//   4x M3 heat-set inserts (Ø4.5mm × 5mm) per side wall (8 total)
//   4x M3 × 8mm socket head cap screws per board (8 total)
//   Boss pads integral to back half print, variable length 6-18mm
//   Each boss has a 45° triangular brace below for print support
//   PCB position: y=-107 to +19, z=62 to 154
//   Port tube clearance: 6mm above PCB top edge
//   Binding post clearance: components don't reach center at post y-level
//   Tall inductor (PCB y=80) positioned below binding post zone
//
// Airtightness:
//   PETG at 5+ perimeters is inherently airtight
//   Tongue-and-groove + foam/TPU seals the split joint
//   8 pillar pairs with interlocks provide structural rigidity
//   Test: cover port, push woofer cone gently
//   Should resist and return slowly
