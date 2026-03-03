#!/usr/bin/env bash
set -euo pipefail

readme_path="${1:-README.md}"
output_path="${2:-index.md}"

if [ ! -f "${readme_path}" ]; then
  echo "README file not found: ${readme_path}" >&2
  exit 1
fi

site_title="$(sed -n 's/^# //p' "${readme_path}" | head -n 1)"
if [ -z "${site_title}" ]; then
  site_title="Matrix Helm Charts"
fi

{
  echo "---"
  echo "layout: page"
  echo "title: ${site_title}"
  echo "---"
  echo

  awk '
    BEGIN {
      skipped_h1 = 0
      dropped_overview = 0
    }
    {
      if (!skipped_h1 && $0 ~ /^# /) {
        skipped_h1 = 1
        next
      }

      if (!dropped_overview) {
        if ($0 ~ /^[[:space:]]*$/) {
          next
        }
        if ($0 ~ /^## Overview[[:space:]]*$/) {
          dropped_overview = 1
          next
        }
        dropped_overview = 1
      }

      print
    }
  ' "${readme_path}"
} > "${output_path}"
