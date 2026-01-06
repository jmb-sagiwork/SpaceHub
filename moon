def first_time(s: str) -> str:
    s = (s or "").replace("\u00A0", " ")

    # "at 2 pm" / "at 2 p.m."
    m = re.search(r"(?i)\b(?:at|@)\s*([1-9]|1[0-2])\s*([ap])\.?\s*m\.?\b", s)
    if m:
        h = int(m.group(1))
        ap = m.group(2).upper()
        return f"{h}:00 {ap}M"

    # bare hour-only "2 pm" / "2 p.m."
    m = re.search(r"(?i)\b([1-9]|1[0-2])\s*([ap])\.?\s*m\.?\b", s)
    if m:
        h = int(m.group(1))
        ap = m.group(2).upper()
        return f"{h}:00 {ap}M"

    # explicit clock with am/pm: "2:00 p.m.", "2:00pm"
    m = re.search(r"(?i)\b([0-2]?\d:[0-5]\d\s*[ap]\s*\.?\s*m\.?)\b", s)
    if m:
        return normalize_time(m.group(1))

    # plain clock (no am/pm) – fallback, treated as 24h
    m = re.search(r"\b([0-2]?\d:[0-5]\d)\b", s)
    if m:
        return normalize_time(m.group(1))

    return ""
