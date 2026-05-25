# BOSL2 Mechanical Patterns

Use this note when a parametric OpenSCAD part would benefit from BOSL2 instead of hand-built transforms and raw CSG.

## What BOSL2 Is Good At

- Shorter, clearer transforms such as directional movement and richer rotation helpers
- Anchored composition so parts can be placed relative to semantic faces and edges instead of tracked coordinates
- Rounded 2D and 3D primitives that avoid repetitive hull and offset scaffolding
- Edge and face treatment helpers using masks and profile tools
- Sweeps, skins, and path-driven solids that are awkward in stock OpenSCAD
- Functional part libraries such as threads, screws, clips, hinges, and standardized connectors

## First BOSL2 Modules To Reach For

- `std.scad` for common helpers when you want broad BOSL2 access
- `transforms.scad` for movement and rotation shorthands
- `attachments.scad` for anchors, attach points, and semantic placement
- `shapes2d.scad` and `shapes3d.scad` for rounded and parameter-rich primitives
- `masks.scad` and `rounding.scad` for chamfers, rounds, and edge treatments
- `skin.scad` for `path_sweep()` and `skin()` workflows
- `regions.scad` and `paths.scad` when you need path or profile preprocessing before extrusion or sweep

## When BOSL2 Is Worth It

- The part has multiple subcomponents that should align by face, edge, or anchor instead of literal coordinates.
- You need repeated rounds, chamfers, tubes, or profile transitions that would otherwise create a lot of custom support code.
- The model has sweep-like or path-following geometry.
- The part resembles a standard mechanical feature already covered by BOSL2.

## When Native OpenSCAD Is Better

- The part is a simple one-module boolean composition.
- BOSL2 would replace three obvious native lines with five less-familiar library concepts.
- The repo or recipient is unlikely to have BOSL2 installed and portability matters more than abstraction.

## Recommended BOSL2 Style

1. Use BOSL2 to remove coordinate bookkeeping, not to obscure the part.
2. Prefer anchored composition for assemblies and interfaces.
3. Keep top-level user parameters library-agnostic when possible.
4. Hide BOSL2-specific helper details inside geometry modules, not in the parameter block.
5. Still derive fit-critical dimensions explicitly; BOSL2 should simplify implementation, not replace dimensional reasoning.

## Common Mechanical Patterns

### Anchored assembly

Use anchors when one feature is naturally attached to another feature's face or edge. This is a better fit than hand-maintained `translate()` chains when parts must stay aligned as dimensions change.

### Rounded bodies

Use BOSL2 rounded primitives when the rounding is part of the design intent. This is usually clearer than repeated `offset()`, `hull()`, or subtractive masks.

### Tubes and hollow connectors

Prefer BOSL2 tube-like or shape helpers when they match the geometry directly. If the fit logic is unusual, keep the dimensional math explicit and only use BOSL2 for the shell geometry.

### Edge treatment

Use masks, profile tools, or rounding helpers when the part needs selective chamfers or rounds. This is especially useful for printable lead-ins, finger-safe edges, and mount faces.

### Sweeps and transitions

Use `path_sweep()` or `skin()` when the part follows a path or when sections need to interpolate through space. For a simple straight transition, native `hull()` slices may still be easier to read.

## Installation Notes

- Install BOSL2 into your OpenSCAD library path as a folder named `BOSL2`.
- On macOS, the default user library path is typically `$HOME/Documents/OpenSCAD/libraries/`.
- In OpenSCAD, Help -> Library Info shows the active user library path.
- `OPENSCADPATH` can be used to point OpenSCAD at a shared library location.

## Useful BOSL2 Wiki Entry Points

- Home and overview: https://github.com/BelfrySCAD/BOSL2/wiki
- Table of contents: https://github.com/BelfrySCAD/BOSL2/wiki/TOC
- Topics index: https://github.com/BelfrySCAD/BOSL2/wiki/Topics
- Cheat sheet: https://github.com/BelfrySCAD/BOSL2/wiki/CheatSheet
- Tutorials: https://github.com/BelfrySCAD/BOSL2/wiki/Tutorials

## Practical Rule

Start with native OpenSCAD if the geometry is small and obvious. Switch to BOSL2 when anchors, rounded primitives, masks, or sweeps materially reduce custom scaffolding and make the model easier to maintain.