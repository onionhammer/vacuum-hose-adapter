// Angled Vacuum Nozzle Adapter
// Wide flat suction inlet → round hose connector at a customizable angle.
//
// Orientation:
//   • Inlet opening faces -Z (downward, toward the floor)
//   • Hose connector extends upward and back at angle_of_attack from vertical

/* [Hose Connector] */
// Inner diameter to accept your vacuum hose (mm)
hose_inner_diameter = 35;
// Shell wall thickness (mm)
wall_thickness = 2;
// Length of the round hose tube (mm)
hose_length = 50;

/* [Suction Inlet] */
// Width of the flat suction slot (mm)
inlet_width = 100;
// Slot height / thickness (mm)
inlet_height = 8;
// Corner rounding on the inlet slot (mm)
inlet_corner_radius = 3;

/* [Transition] */
// Length of the rect-to-round transition body (mm)
transition_length = 60;

/* [Angle] */
// Upward tilt of the hose connector from the inlet plane (degrees).
// 0 = flat/horizontal, 45 = steep.
angle_of_attack = 30; // [0:5:60]
// Rotation of the whole model around X axis (degrees).
// 90 = inlet faces down; 0 = inlet faces toward viewer.
model_rotation = 90; // [0:5:180]

/* [Quality] */
$fn = 64;

// ── Derived ──────────────────────────────────────────────────────────────────
hose_od = hose_inner_diameter + 2 * wall_thickness;

// ── Main ─────────────────────────────────────────────────────────────────────
// model_rotation rotates the sweep axis so the inlet faces the desired direction.
rotate([model_rotation, 0, 0])
difference() {
    union() {
        transition_body(true);
        hose_tube(true);
    }
    union() {
        transition_body(false);
        hose_tube(false);
    }
}

// ── Transition body ──────────────────────────────────────────────────────────
// Sweeps from the flat rectangular inlet to the round hose cross-section.
// is_outer=true  → solid outer envelope
// is_outer=false → solid inner bore (subtracted to hollow the part)
module transition_body(is_outer) {
    steps = 24;

    // Extend the inner bore slightly past the inlet face so the slot is open
    if (!is_outer) {
        hull() {
            cross_sect(false, -0.08);
            cross_sect(false,  0.00);
        }
    }

    for (i = [0 : steps - 1]) {
        hull() {
            cross_sect(is_outer, i / steps);
            cross_sect(is_outer, (i + 1) / steps);
        }
    }
}

// One thin slab representing a cross-section at parameter t (0=inlet, 1=hose).
// The slab lives in the XZ plane (perpendicular to the sweep Y-axis) at each
// step and gradually tilts to match the hose angle.
module cross_sect(is_outer, t) {
    tc = clamp(t, 0, 1);
    s  = smoothstep(tc);

    // Position on the straight sweep path
    y_pos = t * transition_length;
    z_pos = y_pos * tan(angle_of_attack);

    // Interpolate outer dimensions: rect → circle
    w  = lerp(inlet_width,                     hose_od,             s);
    h  = lerp(inlet_height,                    hose_od,             s);
    // Interpolate inner bore dimensions
    iw = lerp(inlet_width  - 2*wall_thickness, hose_inner_diameter, s);
    ih = lerp(inlet_height - 2*wall_thickness, hose_inner_diameter, s);

    // Corner radius: slot rounding → fully circular
    cr  = min(lerp(inlet_corner_radius, hose_od            / 2, s), min(w,  h)  / 2);
    icr = min(lerp(inlet_corner_radius, hose_inner_diameter / 2, s), min(iw, ih) / 2);

    dim = is_outer ? [w,  h,  cr]  : [iw, ih, icr];

    translate([0, y_pos, z_pos])
        rotate([angle_of_attack * t, 0, 0])  // tilt slab to follow hose angle
            rotate([-90, 0, 0])              // orient slab in XZ plane (⊥ to Y sweep axis)
                linear_extrude(height = 0.01)
                    rounded_rect(dim[0], dim[1], dim[2]);
}

// ── Hose tube ────────────────────────────────────────────────────────────────
// Straight round tube extending from the transition end at angle_of_attack.
module hose_tube(is_outer) {
    end_y = transition_length;
    end_z = transition_length * tan(angle_of_attack);

    d    = is_outer ? hose_od             : hose_inner_diameter;
    // Inner bore: extend 0.1 mm into transition body + 0.2 mm past hose end
    //             to guarantee clean subtraction at both junctions
    offs  = is_outer ? 0   : 0.1;
    extra = is_outer ? 0   : 0.3;

    translate([0, end_y, end_z])
        rotate([angle_of_attack, 0, 0])
            rotate([-90, 0, 0])
                translate([0, 0, -offs])
                    cylinder(d = d, h = hose_length + offs + extra);
}

// ── Helpers ───────────────────────────────────────────────────────────────────
module rounded_rect(w, h, r) {
    rc = max(0, min(r, min(w, h) / 2 - 0.001));
    if (rc < 0.01)
        square([w, h], center = true);
    else
        offset(r = rc) square([w - 2*rc, h - 2*rc], center = true);
}

function lerp(a, b, t)      = a + (b - a) * t;
function smoothstep(t)      = t * t * (3 - 2 * t);
function clamp(v, lo, hi)   = max(lo, min(hi, v));
