#!/usr/bin/env python3
"""Render a single CSV record vertically, one field per section.

Built for wide CSVs with huge, multi-line quoted cells (chatbot response
dumps) where column-grid viewers are useless. Parsing is byte-level so it
stays correct with multi-line quoted fields, escaped quotes ("") and
multi-byte UTF-8 (curly quotes etc.) — byte offsets match Neovim's
line2byte().

Usage:
  csv_record.py FILE --offset N   # record containing 0-based byte offset N
  csv_record.py FILE --index N    # Nth data record, 0-based (header excluded)

First stdout line is metadata: "IDX\\t<data_index>\\t<total_data_records>".
Everything after is the rendered record.
"""
import argparse
import csv
import io

QUOTE = 0x22  # "
NL = 0x0A     # \n
WIDTH = 78


def scan_records(data: bytes) -> list[tuple[int, bytes]]:
    """Split into records on unquoted newlines. Returns (start_offset, raw)."""
    records: list[tuple[int, bytes]] = []
    start = i = 0
    n = len(data)
    in_quotes = False
    while i < n:
        c = data[i]
        if c == QUOTE:
            if in_quotes and i + 1 < n and data[i + 1] == QUOTE:
                i += 2  # escaped quote inside a quoted field
                continue
            in_quotes = not in_quotes
        elif c == NL and not in_quotes:
            records.append((start, data[start:i]))
            i += 1
            start = i
            continue
        i += 1
    if start < n:
        records.append((start, data[start:]))
    return records


def parse_fields(raw: bytes) -> list[str]:
    text = raw.decode("utf-8", "replace").rstrip("\r")
    return next(csv.reader(io.StringIO(text)), [])


def rule(label: str, fill: str) -> str:
    prefix = f"{fill}{fill} {label} "
    return prefix + fill * max(0, WIDTH - len(prefix))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("--offset", type=int)
    ap.add_argument("--index", type=int)
    args = ap.parse_args()

    with open(args.file, "rb") as f:
        data = f.read()

    records = scan_records(data)
    if not records:
        print("IDX\t0\t0")
        print("(empty file)")
        return

    header = parse_fields(records[0][1])
    body = records[1:]
    total = len(body)
    if total == 0:
        print("IDX\t0\t0")
        print("(header only — no data records)")
        return

    if args.index is not None:
        idx = max(0, min(args.index, total - 1))
    else:
        off = args.offset or 0
        idx = total - 1  # default to last if past end
        for di, (bstart, raw) in enumerate(body):
            if bstart > off:
                idx = max(0, di - 1)
                break
            if bstart <= off <= bstart + len(raw):
                idx = di
                break

    fields = parse_fields(body[idx][1])
    ncols = max(len(header), len(fields))

    out = [f"IDX\t{idx}\t{total}", rule(f"record {idx + 1} / {total}", "═")]
    for c in range(ncols):
        name = header[c] if c < len(header) else f"col{c}"
        val = fields[c] if c < len(fields) else ""
        out.append("")
        out.append(rule(name, "─"))
        out.extend(val.split("\n") if val != "" else ["·"])
    print("\n".join(out))


if __name__ == "__main__":
    main()
