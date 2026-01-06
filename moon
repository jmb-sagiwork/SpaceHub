import re

def normalize_time(t: str) -> str:
    """
    Normalizes:
      - 2:00 p.m. / 2:00 pm / 2 pm -> 2:00 PM
      - 530pm / 05:30pm           -> 5:30 PM
      - 13:30                     -> 1:30 PM
    """
    t = (t or "").strip()
    if not t:
        return ""

    # Normalize all a.m./p.m. variants to "am"/"pm"
    # p.m., p. m., PM, P.M. -> pm
    # a.m., a. m., AM, A.M. -> am
    t = re.sub(r'(?i)\b([ap])\s*\.?\s*m\.?\b', r'\1m', t)

    # Clean up spaces and stray "@"
    t = re.sub(r"\s*@\s*", " ", t)
    t = re.sub(r"\s+", " ", t)

    # 1) h or h:mm with explicit am/pm: "2pm", "2 pm", "2:00pm", "2:00 pm"
    m = re.match(r'(?i)^\s*(\d{1,2})(?::(\d{2}))?\s*([ap])m\s*$', t)
    if m:
        h = int(m.group(1))
        mm = m.group(2) or "00"
        ap = m.group(3).upper()
        return f"{h}:{mm} {ap}M"

    # 2) Compact time with am/pm: "530pm", "0530pm"
    m = re.match(r'(?i)^\s*([01]?\d|2[0-3])([0-5]\d)\s*([ap])m\s*$', t)
    if m:
        h = int(m.group(1))
        mm = m.group(2)
        ap = m.group(3).upper()
        return f"{h}:{mm} {ap}M"

    # 3) 24h / no-am-pm clock: "13:30", "8:05", "2:00"
    m = re.match(r'^\s*([01]?\d|2[0-3]):([0-5]\d)\s*$', t)
    if m:
        h = int(m.group(1))
        mm = m.group(2)
        ap = "PM" if h >= 12 else "AM"
        h12 = 12 if h == 0 else (h - 12 if h > 12 else h)
        return f"{h12}:{mm} {ap}"

    return ""
