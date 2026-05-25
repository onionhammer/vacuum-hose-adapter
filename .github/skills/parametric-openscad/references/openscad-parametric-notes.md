# OpenSCAD Parametric Notes

Use this note when drafting or reviewing a reusable OpenSCAD model and you need language-level guidance rather than part-specific advice.

## Core Language Model

OpenSCAD is declarative and functional in style. Treat variables as bound values, not mutable state. Structure the model so dimensions are derived once and then consumed by modules and functions.

## Good Parametric Habits

- Put user-facing parameters first and comment how each fit-critical dimension should be measured.
- Keep derived values separate from public inputs.
- Use modules for geometry and functions for compact reusable math.
- Prefer a small number of meaningful parameters over many redundant knobs.

## Important Language Behaviors

### Variables are effectively single-assignment within a scope

Avoid imperative thinking such as incrementing values or depending on execution order. If a value changes conceptually, make a new derived variable in the appropriate scope.

### Scope matters

Assignments inside braces create inner-scope values. Use that to localize temporary geometry values inside modules and conditionals.

### Operators apply right to left

Nested transforms are easier to reason about when you remember the operator closest to the object is applied first.

### `undef` is a real value

Use `is_undef()` when optional values are allowed. Do not rely on comparing directly to `undef` if you want to avoid warnings.

### Floating-point steps can bite

Range steps like `0.2` may accumulate binary floating-point error. Prefer integer counters or steps that are exactly representable when precise sampling matters.

## Geometry Organization Pattern

1. Public parameters
2. Derived dimensions and guards
3. Main assembly call
4. Outer and inner geometry modules
5. Small helper modules and math functions

This keeps the model easy to customize and makes fit logic visible without digging through geometry.

## Preview And Resolution Guidance

- Use `$fn`, `$fa`, and `$fs` intentionally for circles and sweeps.
- Keep preview-friendly defaults when possible, then raise fidelity for final render and export.
- Avoid over-resolving every feature by default if the part is meant to stay interactive in Customizer.

## Comments And Customizer Usage

- Use short line comments for measurement instructions and fit semantics.
- Use Customizer section headers such as `/* [Interface] */` and `/* [Quality] */` to group inputs.
- Keep comments focused on non-obvious behavior, not literal restatements of code.

## Input Sources

OpenSCAD does not prompt for runtime input. Parameters come from the script, the Customizer, command-line `-D` overrides, or limited external file-based inputs.

## Data Structures Worth Using

- Vectors for points, dimensions, and grouped values
- Functions for interpolation, clamping, or fit calculations
- Objects only if you are intentionally targeting newer OpenSCAD object support and the environment is known to support it

## Practical Guardrails

- Clamp radii, wall thickness, and offsets before they create invalid geometry.
- Ensure subtractive solids overlap enough to fully cut openings.
- Separate measured interface dimensions from design intent dimensions like draft, lead-in, or wall thickness.
- Prefer explicit derived names over repeating arithmetic inline.

## OpenSCAD Manual Entry Point

- General language manual: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/General

## Practical Rule

Write the file so another person can answer three questions quickly: what to measure, what is derived from that measurement, and which module owns each piece of geometry.