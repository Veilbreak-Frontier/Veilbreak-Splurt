#!/usr/bin/env python3
"""
After checking out upstream/master on a branch, replay fork-only .dm procs and
restore fork-only tgstation.dme #includes, then print instructions for
checkouting modular trees (or use --checkout-modular).

  python3 tools/apply_upstream_fork_restore.py --fork-ref testing [--repo .] [--dry-run]

Requires tools/restore_fork_procs.py (merge_upstream_with_fork_procs).
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

# Import sibling module when run as script
_TOOLS = Path(__file__).resolve().parent
if str(_TOOLS) not in sys.path:
    sys.path.insert(0, str(_TOOLS))

from restore_fork_procs import merge_upstream_with_fork_procs  # noqa: E402


def git_show(repo: Path, ref: str, rel: str) -> str | None:
    r = subprocess.run(
        ["git", "show", f"{ref}:{rel}"],
        cwd=repo,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if r.returncode != 0:
        return None
    return r.stdout


def git_ls_dm_upstream(repo: Path, upstream_ref: str) -> list[str]:
    r = subprocess.run(
        ["git", "ls-tree", "-r", "--name-only", upstream_ref],
        cwd=repo,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    r.check_returncode()
    return [ln for ln in r.stdout.splitlines() if ln.endswith(".dm")]


def merge_dme_includes(upstream_text: str, fork_text: str) -> tuple[str, int]:
    """Insert fork #include lines (not already in upstream) immediately before // END_INCLUDE."""
    up_lines = upstream_text.splitlines(keepends=True)
    up_inc = {
        ln.strip()
        for ln in up_lines
        if ln.strip().startswith("#include")
    }
    extras: list[str] = []
    for ln in fork_text.splitlines():
        s = ln.strip()
        if s.startswith("#include") and s not in up_inc:
            extras.append(ln)
            up_inc.add(s)
    if not extras:
        return upstream_text, 0
    try:
        end_i = next(
            i for i, ln in enumerate(up_lines) if ln.strip() == "// END_INCLUDE"
        )
    except StopIteration:
        banner = "\n// --- Fork-only #includes restored by apply_upstream_fork_restore.py ---\n"
        return (
            upstream_text.rstrip("\n")
            + banner
            + "\n".join(extras)
            + "\n",
            len(extras),
        )
    banner = "// --- Fork-only #includes restored by apply_upstream_fork_restore.py ---\n"
    fork_block = [banner] + [
        ln if ln.endswith("\n") else ln + "\n" for ln in extras
    ]
    merged = "".join(up_lines[:end_i] + fork_block + up_lines[end_i:])
    return merged, len(extras)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--repo", type=Path, default=Path("."), help="Git repo root")
    ap.add_argument("--fork-ref", default="testing", help="Branch/ref with fork state (default: testing)")
    ap.add_argument(
        "--upstream-ref",
        default="HEAD",
        help="Ref for upstream file list (default: HEAD = current upstream checkout)",
    )
    ap.add_argument(
        "--dry-run",
        action="store_true",
        help="Report counts only; do not write files",
    )
    ap.add_argument(
        "--checkout-modular",
        action="store_true",
        help="Run git checkout fork-ref for modular_* and fork define dirs",
    )
    ap.add_argument(
        "--checkout-added",
        action="store_true",
        help="git checkout fork-ref for paths added on fork vs upstream-ref (diff-filter=A)",
    )
    args = ap.parse_args()
    repo = args.repo.resolve()

    dm_paths = git_ls_dm_upstream(repo, args.upstream_ref)
    restored_procs = 0
    dm_files_with_procs = 0
    skipped_no_fork = 0

    for rel in dm_paths:
        if rel == "tgstation.dme":
            continue
        fork_src = git_show(repo, args.fork_ref, rel)
        if fork_src is None:
            skipped_no_fork += 1
            continue
        path = repo / rel
        if not path.is_file():
            continue
        upstream_src = path.read_text(encoding="utf-8", errors="replace")
        merged, keys = merge_upstream_with_fork_procs(upstream_src, fork_src)
        if not keys:
            continue
        dm_files_with_procs += 1
        restored_procs += len(keys)
        if not args.dry_run:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(merged, encoding="utf-8")

    # tgstation.dme
    dme = repo / "tgstation.dme"
    dme_extras = 0
    if dme.is_file():
        up_dme = dme.read_text(encoding="utf-8", errors="replace")
        fk_dme = git_show(repo, args.fork_ref, "tgstation.dme")
        if fk_dme is not None:
            merged_dme, dme_extras = merge_dme_includes(up_dme, fk_dme)
            if dme_extras and not args.dry_run:
                dme.write_text(merged_dme, encoding="utf-8")

    print(
        f"dm files scanned: {len(dm_paths)}\n"
        f"dm files with restored proc stanzas: {dm_files_with_procs}\n"
        f"proc stanzas appended: {restored_procs}\n"
        f"tgstation.dme extra includes: {dme_extras}\n"
        f"upstream .dm with no fork blob: {skipped_no_fork}",
        file=sys.stderr,
    )

    if args.checkout_modular and not args.dry_run:
        r = subprocess.run(
            ["git", "ls-tree", "--name-only", args.fork_ref],
            cwd=repo,
            capture_output=True,
            text=True,
            check=True,
        )
        to_checkout = sorted(
            name for name in r.stdout.splitlines() if name.startswith("modular_")
        )
        if to_checkout:
            subprocess.run(
                ["git", "checkout", args.fork_ref, "--", *to_checkout],
                cwd=repo,
                check=True,
            )
            print(f"Checked out modular trees: {', '.join(to_checkout)}", file=sys.stderr)

        defines = [
            "code/__DEFINES/~~~splurt_defines",
            "code/__DEFINES/~~~veilbreak_defines",
        ]
        existing = [d for d in defines if git_show(repo, args.fork_ref, d) is not None]
        if existing:
            subprocess.run(
                ["git", "checkout", args.fork_ref, "--", *existing],
                cwd=repo,
                check=True,
            )
            print(f"Checked out defines: {', '.join(existing)}", file=sys.stderr)

    if args.checkout_added and not args.dry_run:
        r = subprocess.run(
            [
                "git",
                "diff",
                "--name-only",
                "--diff-filter=A",
                args.upstream_ref,
                args.fork_ref,
            ],
            cwd=repo,
            capture_output=True,
            text=True,
        )
        r.check_returncode()
        added = [ln for ln in r.stdout.splitlines() if ln.strip()]
        if added:
            # Batch to avoid arg max
            batch = 100
            for i in range(0, len(added), batch):
                chunk = added[i : i + batch]
                subprocess.run(
                    ["git", "checkout", args.fork_ref, "--", *chunk],
                    cwd=repo,
                    check=True,
                )
            print(f"Checked out {len(added)} fork-only paths", file=sys.stderr)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
