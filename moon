import re
from datetime import datetime

def pad2(n: str) -> str:
    return ("0" + n)[-2:]

def normalize_date(d: str) -> str:
    d = (d or "").strip()
    # MM/DD/YYYY or M/D/YY
    m = re.match(r"^\s*(\d{1,2})/(\d{1,2})/(\d{2,4})\s*$", d)
    if m:
        mm, dd, yy = m.groups()
        if len(yy) == 2:
            # interpret 2‑digit year as 20xx for small numbers, 19xx for older
            yy_num = int(yy)
            yy = ("19" if yy_num >= 70 else "20") + yy
        return f"{pad2(mm)}/{pad2(dd)}/{yy}"

    # M/D (no year) -> current year
    m = re.match(r"^\s*(\d{1,2})/(\d{1,2})\s*$", d)
    if m:
        mm, dd = m.groups()
        return f"{pad2(mm)}/{pad2(dd)}/{datetime.now().year}"

    return ""




@@@@@@@@@ 



def extract_next_appt_date_from_block(special_block: str) -> str:
    """
    Tries hard to find 'Date: 01/13/26' style lines in the Special Instructions block.
    Returns a normalized MM/DD/YYYY string or "".
    """
    if not special_block:
        return ""

    lines = [ln.strip() for ln in special_block.replace("\u00A0", " ").splitlines()]

    # Pass 1: look for 'Date:' (case‑insensitive) with date on same line
    for ln in lines:
        m = re.search(r"(?i)\bdate\b\s*[:\-]\s*(\d{1,2}/\d{1,2}(?:/\d{2,4})?)", ln)
        if m:
            return normalize_date(m.group(1))

    # Pass 2: handle 'Date:' on one line and date on the next line
    for i, ln in enumerate(lines):
        if re.search(r"(?i)\bdate\b\s*[:\-]\s*$", ln):
            if i + 1 < len(lines):
                m = re.search(r"(\d{1,2}/\d{1,2}(?:/\d{2,4})?)", lines[i + 1])
                if m:
                    return normalize_date(m.group(1))

    # Pass 3 (fallback): any date in the block that looks like MM/DD(/YY)
    m = re.search(r"\b(\d{1,2}/\d{1,2}(?:/\d{2,4})?)\b", special_block)
    if m:
        return normalize_date(m.group(1))

    return ""


@@@@@@@@@@@@@@@@@@



def extract_special_instructions(full_text: str):
    # ... your existing logic that builds `special` (the Special Instructions block) ...

    special = special.strip()

    # (other extractions...)

    next_date = extract_next_appt_date_from_block(special)

    # if you still want a global fallback:
    if not next_date:
        m = re.search(r"\b(\d{1,2}/\d{1,2}(?:/\d{2,4})?)\b", full_text)
        if m:
            next_date = normalize_date(m.group(1))

    return {
        "specialInstructions": special,
        # ...
        "nextApptDate": next_date,
        # ...
    }
