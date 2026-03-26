#!/bin/bash
# Render all individual keycap STL files using OpenSCAD.
# Usage: ./scripts/render_all_keys.sh [output_dir]
#
# Each key is rendered by passing keycap_id to gen_single_keycap.scad.
# Results are placed in stl/single_keys/ by default.
#
# Uses Manifold backend (fast) for most keys, CGAL backend for convex
# keys (cs_r*x_*) where the dish geometry requires it.

set -euo pipefail
cd "$(dirname "$0")/.."

OUTPUT_DIR="${1:-stl/single_keys}"
mkdir -p "$OUTPUT_DIR"

# All keys now use Manifold backend
CGAL_KEYS=""

KEYS=(
  cs_r1_1
  cs_r1_lateral_l
  cs_r1_lateral_r
  cs_r2_1
  cs_r2_125
  cs_r2_15
  cs_r2_175
  cs_r2_2
  cs_r2_225
  cs_r2_lateral_l
  cs_r2_lateral_r
  cs_r2x_1
  cs_r3_1
  cs_r3_125
  cs_r3_125_bar
  cs_r3_125_dot
  cs_r3_15
  cs_r3_175
  cs_r3_1_bar
  cs_r3_1_dot
  cs_r3_2
  cs_r3_225
  cs_r3_lateral_l
  cs_r3_lateral_l_bar
  cs_r3_lateral_l_dot
  cs_r3_lateral_r
  cs_r3_lateral_r_bar
  cs_r3_lateral_r_dot
  cs_r3x_1
  cs_r4_1
  cs_r4_lateral_l
  cs_r4_lateral_r
  cs_r4x_1
  cs_t_15_l
  cs_t_15_r
  cs_t_1_l
  cs_t_1_r
  cs_t_2_l
  cs_t_2_r
  cs_t_stem_rot_15_l
  cs_t_stem_rot_15_r
  cs_t_stem_rot_2_l
  cs_t_stem_rot_2_r
)

TOTAL=${#KEYS[@]}
DONE=0
FAILED=0
FAILED_KEYS=()

for key in "${KEYS[@]}"; do
  DONE=$((DONE + 1))
  # Use CGAL for convex keys, Manifold for everything else
  BACKEND="Manifold"
  if echo "$CGAL_KEYS" | grep -qw "$key"; then
    BACKEND="CGAL"
  fi
  echo "[$DONE/$TOTAL] Rendering $key ($BACKEND)..."
  if openscad --backend="$BACKEND" -o "${OUTPUT_DIR}/${key}.stl" -D "keycap_id=\"${key}\"" gen_single_keycap.scad 2>&1; then
    SIZE=$(stat -f%z "${OUTPUT_DIR}/${key}.stl" 2>/dev/null || stat -c%s "${OUTPUT_DIR}/${key}.stl" 2>/dev/null || echo 0)
    echo "  OK: ${key}.stl (${SIZE} bytes)"
  else
    echo "  FAILED: $key"
    FAILED=$((FAILED + 1))
    FAILED_KEYS+=("$key")
  fi
done

echo ""
echo "=== COMPLETE: $DONE rendered, $FAILED failed ==="
if [ ${#FAILED_KEYS[@]} -gt 0 ]; then
  echo "Failed keys:"
  printf "  - %s\n" "${FAILED_KEYS[@]}"
  exit 1
fi
