// Angled Vacuum Nozzle Adapter
// Wide flat suction inlet → round hose connector at a customizable angle.
//
// Orientation:
//   • Default print orientation puts the hose connector at -Z (on the bed)
//   • Inlet opening points upward by default

/* [Hose Connector] */
// Measured diameter of your vacuum hose (mm).
// For male:   measure the hose's INNER diameter — the adapter tube slides INTO the hose.
// For female: measure the hose's OUTER diameter — the hose slides INTO the adapter tube.
hose_diameter = 35;
// 0 = Male   (adapter inserts into hose, hose_diameter is the hose inner diameter)
// 1 = Female (hose inserts into adapter, hose_diameter is the hose outer diameter)
connector_style = 0; // [0:Male, 1:Female]
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
// Which end sits on the print bed.
// 0 = Hose connector on bed (recommended — usually no supports needed)
// 1 = Inlet on bed
print_orientation = 0; // [0:Hose on bed, 1:Inlet on bed]

/* [Quality] */
$fn = 64;

// ── Derived ──────────────────────────────────────────────────────────────────
// The mating surface differs by connector style:
//   male:   adapter tube OD = hose_diameter  → adapter slides INTO the hose
//           bore = hose_diameter - 2*wall (walls go inward)
//   female: adapter tube ID = hose_diameter  → hose slides INTO the adapter
//           outer = hose_diameter + 2*wall (walls go outward)
hose_od = connector_style == 1
    ? hose_diameter + 2 * wall_thickness
    : hose_diameter;
hose_inner_diameter = hose_od - 2 * wall_thickness;

// ── Derived orientation ───────────────────────────────────────────────────────
// Hose tube axis direction (before rotation): [0, cos(a), sin(a)]
//   Hose on bed  → rotate X by (270 − a) to align tube axis with −Z
//   Inlet on bed → rotate X by 90
_orientation_angle =
    print_orientation == 0 ? 270 - angle_of_attack : 90;

// Hose tube tip position (before orientation rotation)
_hose_tip_y = transition_length + hose_length * cos(angle_of_attack);
_hose_tip_z = transition_length * tan(angle_of_attack)
            + hose_length * sin(angle_of_attack);

// Translate model up so the lowest point sits on the bed (Z = 0)
_tip_z_rotated = _hose_tip_y * sin(_orientation_angle)
               + _hose_tip_z * cos(_orientation_angle);
_z_offset = -min(0, _tip_z_rotated);

// ── Main ─────────────────────────────────────────────────────────────────────
translate([0, 0, _z_offset])
rotate([_orientation_angle, 0, 0])
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
