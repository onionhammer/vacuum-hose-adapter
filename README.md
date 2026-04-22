# Angled Vacuum Nozzle Adapter

A parametric OpenSCAD model for a vacuum nozzle adapter that transitions from a wide flat suction inlet to a round hose connector at a customizable angle.

## Overview

- **Inlet**: Wide, flat rectangular slot (faces downward toward the floor)
- **Outlet**: Round tube sized to accept your vacuum hose
- **Transition**: Smooth rect-to-round hull sweep with configurable tilt angle

## Parameters

### Hose Connector
| Parameter | Default | Description |
|---|---|---|
| `hose_inner_diameter` | 35 mm | Inner diameter to accept your vacuum hose |
| `wall_thickness` | 2 mm | Shell wall thickness |
| `hose_length` | 50 mm | Length of the round hose tube |

### Suction Inlet
| Parameter | Default | Description |
|---|---|---|
| `inlet_width` | 100 mm | Width of the flat suction slot |
| `inlet_height` | 8 mm | Slot height / thickness |
| `inlet_corner_radius` | 3 mm | Corner rounding on the inlet slot |

### Transition
| Parameter | Default | Description |
|---|---|---|
| `transition_length` | 60 mm | Length of the rect-to-round transition body |

### Angle
| Parameter | Default | Description |
|---|---|---|
| `angle_of_attack` | 30° | Upward tilt of the hose connector from the inlet plane (0 = flat, 45 = steep) |
| `model_rotation` | 90° | Rotation around X axis (90 = inlet faces down) |

### Quality
| Parameter | Default | Description |
|---|---|---|
| `$fn` | 64 | Circle/cylinder resolution |

## Usage

1. Open `angled-vacuum-nozzle.scad` in [OpenSCAD](https://openscad.org/).
2. Adjust parameters in the Customizer panel to match your vacuum hose diameter and desired geometry.
3. Render (`F6`) and export as STL for 3D printing.

A preset parameter set is included in `angled-vacuum-nozzle.json` (`std`) tuned for a ~22 mm hose at 40°.

## Printing Tips

- Print with the inlet face flat on the bed (use `model_rotation = 90`).
- Wall thickness of 2 mm or more is recommended for rigidity.
- No supports should be needed for angles up to ~45°.
