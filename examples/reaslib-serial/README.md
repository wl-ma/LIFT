# ReasLib: serial construction from three sources

This Lean project grows one thematic library through **Beck → Bauschke–Combettes → Nesterov → Beck → Nesterov → Bauschke–Combettes**. Each source batch runs statement preparation, library integration, and proof against the preceding project. The resulting interfaces connect extended-real strong convexity, quadratic shifts, derivative monotonicity, and quadratic Jensen inequalities.

[Construction results](../../experiments/serial-library-growth/README.md) · [Interactive report](../../demo/serial.html)

## Build and verify

Install Elan and Git. From this directory:

```bash
lake update
lake exe cache get
lake build
```

From the repository root, verify all 180 library declarations, 69 fixed source/representation clients, 25 extension boundary examples, and the original 21 independent checks:

```bash
python3 scripts/check_serial_demo.py --output _runs/reaslib-serial
```

The project pins Lean **4.30.0** and Mathlib commit `c5ea00351c28e24afc9f0f84379aa41082b1188f`. The checker verifies source hashes, the compiler and dependency pins, a complete library axiom inventory, 17 three-source clients, four initial extended-real boundary clients, all 69 frozen exact-type clients and 25 extension boundary examples. Accepted axioms are `propext`, `Classical.choice`, and `Quot.sound`.

## Library organization

```text
ReasLib/Analysis/Convex/
  EffectiveDomain.lean         Extended-real domains and finite values
  Strong.lean                  Strong-convexity representation and bridges
  QuadraticShift.lean          Shift convexity and shared quadratic algebra
  StrongC1.lean                Derivative and Jensen characterizations
  Indicator.lean               Extended-real constraints
  StrongC1Nonneg.lean          Nonnegative weighted curvature
  StrongC1EReal.lean         Real/extended-real interface
  Subdifferential.lean         Quadratic support and monotonicity
  BauschkeCompatibility.lean   Original Bauschke source interface
  NesterovCompatibility.lean   Original Nesterov source interface
ReasLib/Analysis/InnerProductSpace/
  NormSq.lean                 Squared-norm algebra
  StronglyMonotone.lean        Graph monotonicity
  Cocoercive.lean              Cocoercivity and norm bounds
  Resolvent.lean               Range-defined resolvents
ReasLibDemo/Sources/           Source-facing applications
ReasLibDemo/Clients/           Independent consumer and boundary checks
```

The library is organized by mathematical concepts. Source files import the library and expose the textbook statements. Compatibility interfaces retain the original complete types; the client directory exercises the same interfaces on concrete functions and boundary cases.

## A shared quadratic example

[ThreeSourceQuadratic.lean](ReasLibDemo/Clients/ThreeSourceQuadratic.lean) studies the same function `x ↦ ‖x‖² / 2` through the extended-real and real-valued representations:

- Beck's view gives convexity after subtracting the quadratic term.
- Bauschke–Combettes' view gives the strong Jensen inequality and global shift convexity.
- Nesterov's view gives the first-order lower bound, derivative monotonicity, and quadratic Jensen inequality.

The client also checks empty and singleton domains, a line in a maximum-norm plane, and changes to a function away from that line. [ExtendedRealBoundaries.lean](ReasLibDemo/Clients/ExtendedRealBoundaries.lean) checks infinite values, positive modulus, and the exact quadratic-shift definition. These independent clients were written for validation and are accounted separately from generated library declarations.
