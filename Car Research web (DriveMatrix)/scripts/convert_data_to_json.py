#!/usr/bin/env python3
import json
import re
from pathlib import Path

infile = Path(r"c:\xampp\htdocs\Autopredator\Car Research web (DriveMatrix)\mocks\data.json")
if not infile.exists():
    raise SystemExit(f"Input file not found: {infile}")

text = infile.read_text(encoding='utf-8')
# Remove Markdown-style code fences if present
text = re.sub(r"^```[a-zA-Z0-9+-]*\n", "", text)
text = re.sub(r"\n```$", "", text)

lines = [ln.rstrip('\r') for ln in text.splitlines()]
# Find header line (starts with S.No.)
header_idx = None
for i, ln in enumerate(lines):
    if ln.strip().startswith('S.No.'):
        header_idx = i
        break

if header_idx is None:
    raise SystemExit('Header line starting with "S.No." not found')

data_lines = lines[header_idx+1:]
records = []

for ln in data_lines:
    if not ln.strip():
        continue
    # Skip manufacturer group lines like "Hyundai" alone
    if '\t' not in ln:
        # if single word or short, assume group header and skip
        if len(ln.strip().split()) <= 3:
            continue
    # Split by tabs first
    parts = re.split(r"\t+", ln)
    if len(parts) < 8:
        # fallback: split by 2+ spaces
        parts = re.split(r" {2,}", ln)
    # If still short, try splitting by single tabs/spaces
    if len(parts) < 8:
        parts = re.split(r"\s+", ln, maxsplit=7)
    # Normalize to 8 fields
    while len(parts) < 8:
        parts.append("")
    s_no, make, model, price, power, rng, fuel, notes = [p.strip() for p in parts[:8]]
    # Some lines may have misplaced make (e.g., blank make because group header existed). Attempt to fill from model column if make missing and model seems like make+model
    records.append({
        "s_no": s_no,
        "make": make,
        "model": model,
        "price": price,
        "power_bhp": power,
        "range_mileage": rng,
        "fuel_type": fuel,
        "notes": notes,
    })

# Write pretty JSON back to the same file (backup original first)
backup = infile.with_suffix('.original.txt')
if not backup.exists():
    backup.write_text(text, encoding='utf-8')

out_text = json.dumps(records, ensure_ascii=False, indent=2)
infile.write_text(out_text, encoding='utf-8')
print(f"Converted {len(records)} records and wrote JSON to {infile}")
print(f"Backup of original written to {backup}")
