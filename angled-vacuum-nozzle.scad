// Angled Vacuum Nozzle Adapter
// A wide, flat suction inlet that transitions to a round hose connector,
// with a customizable angle of attack for ergonomic use.

/* [Hose Connector] */
// Inner diameter of the hose connector (mm)
hose_inner_diameter = 35;
// Wall thickness (mm)
wall_thickness = 2;
// Length of the hose connector tube (mm)
hose_length = 50;

/* [Suction Inlet] */
// Width of the flat inlet (mm)
inlet_width = 100;
// Height of the flat inlet opening (mm)
inlet_height = 8;
// Corner radius on the inlet (mm)
inlet_corner_radius = 3;

/* [Transition] */
// Length of the transition zone from inlet to hose (mm)
transition_length = 60;

/* [Angle] */
// Angle of attack - tilts the hose upward from the inlet (degrees)
angle_of_attack = 30; // [0:5:60]

/* [Quality] */
// Facets for round shapes
$fn = 64;

// Derived values
hose_outer_diameter = hose_inner_diameter + 2 * wall_thickness;
hose_outer_radius = hose_outer_diameter / 2;
hose_inner_radius = hose_inner_diameter / 2;

// Build the nozzle
angled_vacuum_nozzle();

module angled_vacuum_nozzle() {
    union() {
        // The main body: transition from flat inlet to round outlet
        transition_body();

        // The hose connector tube, angled upward
        hose_tube();
    }
}

// Flat inlet to round transition, using hull between cross-sections
module transition_body() {
    wall = wall_thickness;

    // We'll build the transition as a series of hulled slices.
    // The inlet is at y=0, the hose connection is at y=transition_length.
    // The angle tilts the path upward as we go from inlet toward the hose.

    steps = 30;
    for (i = [0 : steps - 1]) {
        t1 = i / steps;
        t2 = (i + 1) / steps;
        hull() {
            cross_section(t1);
            cross_section(t2);
        }
    }
}

// A single cross-section along the transition path.
// t=0 is the flat inlet, t=1 is the round hose opening.
module cross_section(t) {
    // Smooth interpolation (ease in-out)
    s = smoothstep(t);

    // Position along the path: y advances linearly, z rises with the angle
    y_pos = t * transition_length;
    z_pos = t * transition_length * tan(angle_of_attack);

    // Interpolate dimensions
    w = lerp(inlet_width, hose_outer_diameter, s);
    h = lerp(inlet_height, hose_outer_diameter, s);
    iw = lerp(inlet_width - 2 * wall_thickness, hose_inner_diameter, s);
    ih = lerp(inlet_height - 2 * wall_thickness, hose_inner_diameter, s);

    // Corner radius interpolation: from inlet corners to fully round
    max_radius = min(w, h) / 2;
    cr = lerp(min(inlet_corner_radius, max_radius), max_radius, s);
    icr = lerp(min(inlet_corner_radius, min(iw, ih) / 2), min(iw, ih) / 2, s);

    // Rotation to follow the angled path
    translate([0, y_pos, z_pos])
        rotate([angle_of_attack * t, 0, 0])
            translate([0, 0, 0])
                linear_extrude(height = 0.01)
                    difference() {
                        rounded_rect(w, h, cr);
                        rounded_rect(iw, ih, icr);
                    }
}

// The hose tube extending from the end of the transition
module hose_tube() {
    // Position and angle at the end of the transition
    end_y = transition_length;
    end_z = transition_length * tan(angle_of_attack);

    translate([0, end_y, end_z])
        rotate([angle_of_attack, 0, 0])
            // Extend along the local Y axis (which is now angled)
            translate([0, 0, 0])
                rotate([-90, 0, 0])
                    difference() {
                        cylinder(d = hose_outer_diameter, h = hose_length);
                        translate([0, 0, -0.1])
                            cylinder(d = hose_inner_diameter, h = hose_length + 0.2);
                    }
}

// Rounded rectangle centered at origin
module rounded_rect(w, h, r) {
    r_clamped = min(r, min(w, h) / 2);
    if (r_clamped < 0.01) {
        square([w, h], center = true);
    } else {
        offset(r = r_clamped)
            square([w - 2 * r_clamped, h - 2 * r_clamped], center = true);
    }
}

// Linear interpolation
function lerp(a, b, t) = a + (b - a) * t;

// Smooth step (ease in-out)
function smoothstep(t) = t * t * (3 - 2 * t);
