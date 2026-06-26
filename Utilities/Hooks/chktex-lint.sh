#!/usr/bin/env bash
# Advisory LaTeX lint via chktex for staged .tex files.
# Never blocks the commit; prints findings so the author can fix new prose.
# Ignore-code policy mirrors Utilities/latex_linter.sh, plus 27 (cannot resolve
# \input across files) which is unavoidable noise when linting one staged file.

command -v chktex >/dev/null 2>&1 || {
  echo "chktex not found on PATH (install TeX Live / MacTeX); skipping LaTeX lint." >&2
  exit 0
}

IGNORE_WARNING_CODES="-n 1 -n 3 -n 8 -n 12 -n 13 -n 27 -n 36 -n 37"

# Filter the "Unable to open the TeX file" banner: per-file linting cannot see
# \input targets that live in the build tree, and that banner is not a finding.
chktex ${IGNORE_WARNING_CODES} --quiet "$@" 2>&1 |
  grep -v 'Unable to open the TeX file' || true
exit 0
