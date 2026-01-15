#!/usr/bin/evn bash

# https://www.nongnu.org/chktex/ChkTeX.pdf

utils_dir=$(cd $(dirname $0) || exit 1; pwd)
cd ${utils_dir}

SRC_DIR=${SRC_DIR:=$(dirname $utils_dir)}
BLD_DIR=${BLD_DIR:=${SRC_DIR}/cmake-build-release}

latex_warn_edit() {
    local error_code="$1"
    local error_file="$2"

    if [[ -z "$error_code" || -z "$error_file" ]]; then
        echo "Usage: latex_warn_edit <error_code> <output_file>" >&2
        return 2
    fi

    if [[ ! -f /tmp/ALL_LATEX_WARNINGS ]]; then
        echo "ERROR: /tmp/ALL_LATEX_WARNINGS does not exist" >&2
        return 1
    fi

    grep "CODE=${error_code} " /tmp/ALL_LATEX_WARNINGS > "$error_file"

    if [[ ! -s "$error_file" ]]; then
        echo "No warnings found for CODE=${error_code}"
        return 0
    fi
    vim -q "$error_file"
}

cat ${BLD_DIR}/ITKSoftwareGuide-build/SoftwareGuide/LaTeXWrapper.sh |fgrep -v TEXINPUTS
cd ${BLD_DIR}/ITKSoftwareGuide-build

export TEXINPUTS=.:${SRC_DIR}/SoftwareGuide/../Latex:${SRC_DIR}/SoftwareGuide:${SRC_DIR}/SoftwareGuide/Latex:${SRC_DIR}/SoftwareGuide/Art:${BLD_DIR}/ITKSoftwareGuide-build/SoftwareGuide:${BLD_DIR}/ITKSoftwareGuide-build/SoftwareGuide/Examples:${BLD_DIR}/ITKSoftwareGuide-build/SoftwareGuide/Art:${BLD_DIR}/ITKSoftwareGuide-build/SoftwareGuide/Latex:

cat > ${utils_dir}/.chktexrc << EOF
# Add directories to TeX input search path
TeXInputs = {
${SRC_DIR}/SoftwareGuide/../Latex
${SRC_DIR}/SoftwareGuide
${SRC_DIR}/SoftwareGuide/Latex
${SRC_DIR}/SoftwareGuide/Art
${BLD_DIR}/ITKSoftwareGuide-build/SoftwareGuide
${BLD_DIR}/ITKSoftwareGuide-build/SoftwareGuide/Examples
${BLD_DIR}/ITKSoftwareGuide-build/SoftwareGuide/Art
${BLD_DIR}/ITKSoftwareGuide-build/SoftwareGuide/Latex
}
EOF

IGNORE_WARNING_CODES=" -n 1 -n 3 -n 8 -n 12 -n 13 -n 36 -n 37"

chktex \
  --localrc  ${utils_dir}/.chktexrc \
 ${IGNORE_WARNING_CODES} \
  --format '%f:%l:%c: CODE=%n MESSAGE=%m!n'  \
  ${SRC_DIR}/SoftwareGuide/Latex/ITKSoftwareGuide-Book*.tex \
  |sed 's/!n/\n/g' \
  > /tmp/ALL_LATEX_WARNINGS

  echo vim -q /tmp/ALL_LATEX_WARNINGS

  cat /tmp/ALL_LATEX_WARNINGS |grep "ITKSoftwareGuide-build/SoftwareGuide/Examples" > /tmp/CXX_LATEX_WARNINGS
  cat /tmp/ALL_LATEX_WARNINGS |grep -v "ITKSoftwareGuide-build/SoftwareGuide/Examples" > /tmp/GUIDE_LATEX_WARNINGS


cat /dev/null << EOF_FILE
#latex_warn_edit 27 could_not_execute_command
latex_warn_edit 3 enclose_parenthesis
latex_warn_edit 0000 delete_space_pagereferences
latex_warn_edit 9 mismatch_blocks  # Not all are relavant for fixing
latex_warn_edit 10 solo_block_delimiter
latex_warn_edit 11 use_ldots
latex_warn_edit 12 error.interword_spacing #Not recommended to be fixed
latex_warn_edit 13 error.intersentence_spacing #Not recommended to be fixed
latex_warn_edit 15 no_match_paren
latex_warn_edit 17 match_paren
latex_warn_edit 18 avoid_doublequotes
latex_warn_edit 26 remove_spaces_in_front_of_punctuation
latex_warn_edit 29 make_times_prettier
latex_warn_edit 31 text_maybe_ignored
latex_warn_edit 32 single_quote_begin
latex_warn_edit 35 use_cos_instead
latex_warn_edit 36 space_in_front_parenthesis # too many false positives in correct code
latex_warn_edit 37 space_after_parenthesis # too many false positives in correct code
latex_warn_edit 39 double_space_found
latex_warn_edit 44 misc_regex_concerns

# These are pedantic codes that like make the code worse for trying to fix:
# CODE=1 MESSAGE=Command terminated with space.
# CODE=3 MESSAGE=You should enclose the previous parenthesis with '{}'. FALSE ALARMS SEE You should enclose the previous parenthesis with '{}'.
# CODE=8 MESSAGE=Wrong length of dash may have been used.
# CODE=12 MESSAGE=Interword spacing ('\ ') should perhaps be used.
# CODE=13 MESSAGE=Intersentence spacing ('\@') should perhaps be used.
# CODE=36 MESSAGE=You should put a space in front of parenthesis.
# CODE=37 MESSAGE=You should avoid spaces after parenthesis.
# CODE=37 MESSAGE=You should avoid spaces in front of parenthesis.

#
# Error codes found by chktex
# CODE=9 MESSAGE=')' expected, found '}'.
# CODE=9 MESSAGE=']' expected, found '}'.
# CODE=9 MESSAGE='}' expected, found ')'.
# CODE=9 MESSAGE='}' expected, found ']'.
# CODE=10 MESSAGE=Solo ')' found.
# CODE=10 MESSAGE=Solo '}' found.
# CODE=11 MESSAGE=You should use \ldots to achieve an ellipsis.
# CODE=15 MESSAGE=No match found for '('.
# CODE=17 MESSAGE=Number of '(' doesn't match the number of ')'!
# CODE=17 MESSAGE=Number of '{' doesn't match the number of '}'!
# CODE=18 MESSAGE=Use either '' or '' as an alternative to '"'.
# CODE=26 MESSAGE=You ought to remove spaces in front of punctuation.
# CODE=27 MESSAGE=Could not execute LaTeX command.
# CODE=29 MESSAGE=$\times$ may look prettier here.
# CODE=31 MESSAGE=This text may be ignored.
# CODE=32 MESSAGE=Use ' to begin quotation, not '.
# CODE=35 MESSAGE=You should perhaps use '\cos' instead.
# CODE=39 MESSAGE=Double space found.
# CODE=44 MESSAGE=User Regex: -2:Use \toprule, \midrule, or \bottomrule from booktabs.
# CODE=44 MESSAGE=User Regex: -2:Vertical rules in tables are ugly.
# CODE=44 MESSAGE=User Regex: 1:Capitalize before references.
EOF_FILE
