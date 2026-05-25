---
name: parametric-openscad
description: 'Build reusable parametric OpenSCAD models for 3D-printable parts. Use for Customizer-driven OpenSCAD projects, BOSL2-based modeling, adapters, enclosures, fixtures, transitions, fit-critical geometry, and print-oriented parameter design.'
argument-hint: 'Describe the part, mating dimensions, manufacturing constraints, and whether to use BOSL2.'
---

# Parametric OpenSCAD

Create OpenSCAD parts as reusable, measurement-driven models instead of one-off geometry. This skill is for parts that should be easy to customize, safe to re-measure, and practical to print.

## When to Use

- You are starting a new OpenSCAD part from real-world measurements.
- You want a Customizer-friendly parameter block with grouped inputs and comments.
- The part has mating geometry such as holes, sockets, tubes, tabs, slots, bosses, or adapters.
- The model should support multiple configurations without rewriting geometry.
- You want to use BOSL2 helpers instead of hand-rolling every primitive when BOSL2 makes the model simpler or more robust.

## Inputs to Collect First

- What the part mates with, and whether each interface is an insert, socket, pass-through, snap fit, or clearance feature.
- Which measurements come from the real object and which are design choices.
- Print process assumptions: nozzle size, expected material, support tolerance, preferred bed face, and minimum wall thickness.
- What should stay fixed versus what should scale when parameters change.
- Whether BOSL2 is allowed or required.

If key dimensions are missing, ask for the mating measurements before generating geometry.

## Workflow

1. Define the interfaces before the shape.
State the real-world mating surfaces first. Separate measured dimensions from chosen dimensions such as wall thickness, draft, fillets, offsets, and transition length.

2. Expose only meaningful top-level parameters.
Group public parameters with Customizer sections such as `Interface`, `Body`, `Orientation`, and `Quality`. Add unit-aware comments and explain how to measure each critical dimension.

3. Derive geometry from the public parameters.
Compute internal dimensions from a small number of inputs instead of exposing redundant knobs. Examples: outer diameter from fit plus wall thickness, bore size from mating style, body length from reach plus overlap, or print offset from orientation.

4. Separate public inputs, derived values, and geometry modules.
Keep the file structured in this order:
- User-facing parameters
- Derived dimensions and guards
- Main assembly
- Reusable modules
- Small helper functions

5. Model the outer shell and inner void independently.
For hollow parts, build the outer envelope and subtract the inner volume. Make boolean overlaps intentional so openings are fully cut and mating transitions do not leave thin artifacts.

6. Prefer modular geometry over inline transforms.
Break the part into named modules for each logical region: interface, transition, body, mounting feature, chamfer mask, and helper profile. Keep each module responsible for one idea.

7. Choose the simplest geometry strategy that matches the part.
- Use built-in primitives and `difference`, `union`, `intersection`, `hull`, and `minkowski` when the part is simple.
- Use 2D profiles plus `linear_extrude`, `rotate_extrude`, or sweep-style construction when the cross-section matters.
- Use BOSL2 when it reduces custom math or improves maintainability, especially for rounded shapes, attachment systems, masks, paths, tubes, or reusable anchor-based composition.

8. Encode fit logic explicitly.
If the part supports alternative fit modes, reflect that in derived dimensions instead of duplicating geometry. Typical examples are male versus female connectors, clearance versus interference, or nominal versus loose fit.

9. Design for printability as part of the model.
Add orientation controls only when they materially affect print success. If the part has a preferred bed face, derive the rotation and bed offset so the model lands flat in a sane default configuration.

10. Guard against invalid parameter combinations.
Clamp or validate dimensions that can go negative or collapse. Keep corner radii, wall thickness, and offsets within geometric limits.

11. Document the intended measurement and usage path.
Leave short comments near parameters describing what to measure, whether the value is inner or outer, and how the part fits. Do not bury critical fit semantics in a README only.

12. Finish with a verification pass.
Check that the part renders cleanly, stays manifold, and still makes sense when the main parameters are varied through likely ranges.

## BOSL2 Guidance

Use BOSL2 when it makes the model clearer than a custom implementation. Good candidates include:

- Rounded and offsettable 2D profiles
- Reusable attachment points and anchored transforms
- Sweep or path-driven solids
- Mask-driven chamfers, rounds, and edge treatments
- Standardized tube, cuboid, and shape composition helpers

Avoid pulling in BOSL2 for one small convenience if the native OpenSCAD version is already short and obvious.

Load these local references when BOSL2 or language details matter:

- [BOSL2 Mechanical Patterns](./references/bosl2-mechanical-patterns.md)
- [OpenSCAD Parametric Notes](./references/openscad-parametric-notes.md)

External sources:

- BOSL2 wiki: https://github.com/BelfrySCAD/BOSL2/wiki
- OpenSCAD language tutorial: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/General

## Quality Bar

The result should meet these checks:

- Public parameters are few, measurable, and non-redundant.
- Derived values fully explain fit-critical geometry.
- The file is organized so someone else can safely adjust it later.
- The model renders without obvious self-intersections or missing cuts.
- Default settings produce a printable orientation or clearly expose orientation control.
- Fit logic is commented where the parameters are declared.

## Output Expectations

When using this skill, produce:

- A structured OpenSCAD file with Customizer-friendly parameters
- Derived dimensions instead of duplicated manual inputs
- Clear module boundaries
- Brief fit and measurement comments
- BOSL2 usage only when it simplifies the design

## Suggested Pattern

Use a structure like this when drafting:

```scad
/* [Interface] */
feature_size = 20;

/* [Body] */
wall_thickness = 2;

/* [Orientation] */
print_orientation = 0;

/* [Quality] */
$fn = 64;

derived_outer = feature_size + 2 * wall_thickness;

main();

module main() {
    difference() {
        outer_body();
        inner_void();
    }
}
```

## When Not to Use

- One-off throwaway geometry with no intent to reuse or customize
- Mesh editing or STL repair work better handled outside OpenSCAD
- Highly organic sculpting where parametric CSG is the wrong tool