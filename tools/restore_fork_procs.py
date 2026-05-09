#!/usr/bin/env python3
"""
Re-append proc definitions that exist in a fork .dm file but are absent from an
upstream .dm file (same relative path). Intended after you replace a file with
upstream's version and need whole missing procs back.

DM allows absolute-path definitions anywhere, so restored stanzas are appended
to the end of the upstream file.

Limits (read before relying on this):
- Only stanzas whose first line contains '(' are considered (proc/verb-style).
  Type headers like `/datum/foo` with only vars underneath are NOT merged.
- If upstream already defines the same proc (same normalized header), the fork
  body is NOT merged — you changed an existing proc; resolve that manually or
  use markers/diff tools.
- Does not understand #if / strings with embedded newlines; rare edge cases
  may split stanzas wrong.

Usage:
  python tools/restore_fork_procs.py --upstream code/foo.dm --fork code/foo.dm.fork \\
      --output code/foo.dm

  python tools/restore_fork_procs.py --batch \\
      --upstream-root /tmp/upstream-checkout \\
      --fork-root /path/to/veilbreak \\
      --file-list files.txt \\
      --output-root /tmp/merged

  # files.txt: one relative path per line, e.g. code/modules/mob/living/living.dm
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path


def _strip_dm_comment(code: str) -> str:
    """Remove a trailing // comment (best-effort; ignores strings)."""
    if "//" not in code:
        return code
    in_string = False
    escape = False
    quote = ""
    for i, ch in enumerate(code):
        if in_string:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == quote:
                in_string = False
            continue
        if ch in ('"', "'"):
            in_string = True
            quote = ch
            continue
        if ch == "/" and i + 1 < len(code) and code[i + 1] == "/":
            return code[:i].rstrip()
    return code


def normalize_proc_header(header_line: str) -> str | None:
    """
    Return a canonical key for proc-like stanzas, or None if not proc-like.
    Proc-like = first line starts with /, has '(', and is not a bare type path.
    """
    raw = header_line.strip()
    if not raw.startswith("/") or raw.startswith("//"):
        return None
    code = _strip_dm_comment(raw)
    if "(" not in code:
        return None
    # Collapse whitespace for stable comparison
    return re.sub(r"\s+", " ", code.strip())


def split_stanzas(text: str) -> tuple[list[str], list[str]]:
    """
    Split a .dm file into preamble (everything before first top-level / def)
    and list of stanza strings (each starts with a line beginning with /).
    Top-level = line starts with '/' and not '//' (after lstrip of... we don't lstrip file).
    """
    lines = text.splitlines(keepends=True)
    preamble: list[str] = []
    stanzas: list[str] = []
    current: list[str] = []
    seen_first_def = False

    for line in lines:
        is_def = (
            line.startswith("/")
            and not line.startswith("//")
        )
        if is_def:
            seen_first_def = True
            if current:
                stanzas.append("".join(current))
                current = []
            current.append(line)
        else:
            if not seen_first_def:
                preamble.append(line)
            else:
                if not current:
                    # Orphan line after preamble but not under a def — attach to preamble
                    preamble.append(line)
                else:
                    current.append(line)

    if current:
        stanzas.append("".join(current))

    return preamble, stanzas


def proc_stanza_map(stanzas: list[str]) -> dict[str, str]:
    """Map normalized proc header -> full stanza text (last wins on duplicate)."""
    out: dict[str, str] = {}
    for stanza in stanzas:
        first_line = stanza.splitlines()[0] if stanza else ""
        key = normalize_proc_header(first_line)
        if key is not None:
            out[key] = stanza
    return out


def merge_upstream_with_fork_procs(upstream_text: str, fork_text: str) -> tuple[str, list[str]]:
    """
    Return merged text and list of normalized keys that were appended from fork.
    """
    _up_pre, up_stanzas = split_stanzas(upstream_text)
    _fk_pre, fk_stanzas = split_stanzas(fork_text)

    up_procs = proc_stanza_map(up_stanzas)
    fk_procs = proc_stanza_map(fk_stanzas)

    missing_keys = [k for k in fk_procs if k not in up_procs]
    if not missing_keys:
        return upstream_text, []

    restored_blocks = [fk_procs[k] for k in missing_keys]
    # Ensure single trailing newline on base, then banner + blocks
    base = upstream_text.rstrip("\n") + "\n"
    banner = "\n// VEILBREAK/SPLURT fork sync: procs present in fork but missing from upstream (auto-restored)\n"
    appended = banner + "\n".join(b.rstrip("\n") + "\n" for b in restored_blocks)
    return base + appended, missing_keys


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--upstream",
        help="Path to upstream version of one .dm file (single-file mode)",
    )
    parser.add_argument(
        "--fork",
        help="Path to fork (old) version of the same file (single-file mode)",
    )
    parser.add_argument(
        "--output",
        "-o",
        help="Write merged file here (default: stdout for single-file mode)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print restored proc keys only; do not write merged output",
    )

    batch = parser.add_argument_group("batch")
    batch.add_argument(
        "--batch",
        action="store_true",
        help="Process many files; requires --upstream-root, --fork-root, --file-list, --output-root",
    )
    batch.add_argument("--upstream-root", type=Path, help="Checkout of upstream")
    batch.add_argument("--fork-root", type=Path, help="Root of fork repo")
    batch.add_argument(
        "--file-list",
        type=Path,
        help="Newline-separated relative paths to .dm files",
    )
    batch.add_argument("--output-root", type=Path, help="Merged files written here")

    args = parser.parse_args()

    if args.batch:
        if not all([args.upstream_root, args.fork_root, args.file_list, args.output_root]):
            parser.error("--batch requires --upstream-root --fork-root --file-list --output-root")
        rel_paths = [
            line.strip()
            for line in args.file_list.read_text().splitlines()
            if line.strip() and not line.strip().startswith("#")
        ]
        total_restored = 0
        for rel in rel_paths:
            up_path = args.upstream_root / rel
            fk_path = args.fork_root / rel
            out_path = args.output_root / rel
            if not up_path.is_file():
                print(f"skip (no upstream file): {rel}", file=sys.stderr)
                continue
            if not fk_path.is_file():
                print(f"skip (no fork file): {rel}", file=sys.stderr)
                continue
            merged, keys = merge_upstream_with_fork_procs(
                up_path.read_text(encoding="utf-8", errors="replace"),
                fk_path.read_text(encoding="utf-8", errors="replace"),
            )
            if args.dry_run:
                for k in keys:
                    print(f"{rel}: {k}")
                total_restored += len(keys)
            else:
                out_path.parent.mkdir(parents=True, exist_ok=True)
                out_path.write_text(merged, encoding="utf-8")
                if keys:
                    print(f"{rel}: restored {len(keys)} proc(s)", file=sys.stderr)
                total_restored += len(keys)
        if args.dry_run:
            print(f"Total proc stanzas to restore: {total_restored}", file=sys.stderr)
        return 0

    if not args.upstream or not args.fork:
        parser.error("single-file mode requires --upstream and --fork (or use --batch)")

    upstream_text = Path(args.upstream).read_text(encoding="utf-8", errors="replace")
    fork_text = Path(args.fork).read_text(encoding="utf-8", errors="replace")
    merged, keys = merge_upstream_with_fork_procs(upstream_text, fork_text)

    if args.dry_run:
        for k in keys:
            print(k)
        print(f"count: {len(keys)}", file=sys.stderr)
        return 0

    if args.output:
        Path(args.output).write_text(merged, encoding="utf-8")
    else:
        sys.stdout.write(merged)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
