#!/usr/bin/env python3
"""Compute how many jobs a workflow expands to.

The README carries a badge stating the CI job count. That number is a
product of every matrix axis in the file, which nobody recomputes by hand
after adding a compiler or a standard, so it goes stale silently.

Prints the total to stdout. Exits 1 if the workflow cannot be read.
"""
import sys
import pathlib
import yaml

ROOT = pathlib.Path(__file__).resolve().parent.parent
path = ROOT / (sys.argv[1] if len(sys.argv) > 1 else ".github/workflows/ci.yml")

try:
    spec = yaml.safe_load(path.read_text())
except Exception as exc:                      # noqa: BLE001
    print(f"cannot read {path}: {exc}", file=sys.stderr)
    sys.exit(1)

total = 0
for name, job in (spec.get("jobs") or {}).items():
    matrix = (job.get("strategy") or {}).get("matrix")

    if not matrix:
        total += 1
        continue

    include = matrix.get("include") or []
    axes = {k: v for k, v in matrix.items() if k not in ("include", "exclude")}

    if not axes:
        # An include-only matrix expands to exactly its entries.
        total += len(include) or 1
        continue

    count = 1
    for values in axes.values():
        count *= len(values)

    # Each exclude entry removes every combination it matches. With a
    # partial exclude (fewer keys than axes) that is more than one.
    for excl in (matrix.get("exclude") or []):
        removed = 1
        for key, values in axes.items():
            if key not in excl:
                removed *= len(values)
        count -= removed

    total += count + len(include)

print(total)
