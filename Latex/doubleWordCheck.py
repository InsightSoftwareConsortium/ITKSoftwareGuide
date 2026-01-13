#!/usr/bin/env python3
"""
Search for doubled words in text

Behavior:
- Reads one or more files (or stdin if none).
- Processes input in "records" delimited by ".\n" (Perl: $/ = ".\n").
- In each record, highlights a repeated word (case-insensitive) where the two
  occurrences are separated by whitespace and/or simple HTML tags.
- Removes any leading lines that contain no escape characters.
- Prefixes each remaining line with "<filename>: ".
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ESC = "\x1b"

# Perl: s/\b([a-z]+)((\s|<[^>]+>)+)(\1\b)/\e[7m$1\e[m$2\e[7m$4\e[m/ig
DOUBLE_WORD_RE = re.compile(
    r"\b([a-z]+)((?:\s|<[^>]+>)+)(\1\b)",
    re.IGNORECASE,
)

# Perl: s/^([^\e]*\n)+//mg
# Interpreted as: drop initial consecutive lines that contain no ESC.
LEADING_NO_ESC_LINES_RE = re.compile(r"^(?:[^\x1b]*\n)+", re.MULTILINE)


def highlight_double_words(record: str) -> str | None:
    """
    Return transformed record if a double-word pattern is found; otherwise None.
    """

    def repl(m: re.Match[str]) -> str:
        w1 = m.group(1)
        sep = m.group(2)
        w2 = m.group(3)  # same text as group(1) as matched
        return f"{ESC}[7m{w1}{ESC}[m{sep}{ESC}[7m{w2}{ESC}[m"

    new_record, n = DOUBLE_WORD_RE.subn(repl, record, count=1)
    if n == 0:
        return None

    new_record = LEADING_NO_ESC_LINES_RE.sub("", new_record, count=1)
    return new_record


def iter_records(text: str, sep: str = ".\n"):
    """
    Yield records split by the exact separator, including the separator (like Perl $/).
    """
    start = 0
    while True:
        idx = text.find(sep, start)
        if idx == -1:
            if start < len(text):
                yield text[start:]
            break
        end = idx + len(sep)
        yield text[start:end]
        start = end


def process_stream(name: str, data: str, out) -> None:
    for record in iter_records(data, sep=".\n"):
        transformed = highlight_double_words(record)
        if transformed is None:
            continue

        # Perl: s/^/$ARGV: /mg  => prefix each line
        prefixed = re.sub(r"^", f"{name}: ", transformed, flags=re.MULTILINE)
        out.write(prefixed)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="*", help="Files to scan; if empty, read stdin.")
    args = ap.parse_args()

    if not args.files:
        data = sys.stdin.read()
        process_stream("<stdin>", data, sys.stdout)
        return 0

    for f in args.files:
        p = Path(f)
        data = p.read_text(encoding="utf-8", errors="replace")
        process_stream(f, data, sys.stdout)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
