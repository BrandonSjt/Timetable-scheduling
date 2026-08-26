#!/usr/bin/env python3
"""Extract the official February 2026 commuter timetable into deterministic JSON."""

from __future__ import annotations

import hashlib
import json
import re
import sys
from collections import Counter
from pathlib import Path

import pdfplumber


TIME = re.compile(r"^(\d{2}):(\d{2})$")
PAGE_META = {
    1: ("bogor", "JAKARTA_KOTA", True),
    2: ("bogor", "JAKARTA_KOTA", True),
    3: ("bogor", "NAMBO_BOGOR", True),
    4: ("bogor", "NAMBO_BOGOR", True),
    5: ("cikarang", "KAMPUNG_BANDAN_JAKARTA_KOTA", True),
    6: ("cikarang", "KAMPUNG_BANDAN_JAKARTA_KOTA", True),
    7: ("cikarang", "BEKASI_CIKARANG", True),
    8: ("cikarang", "BEKASI_CIKARANG", True),
    9: ("rangkasbitung", "TANAH_ABANG", True),
    10: ("rangkasbitung", "RANGKASBITUNG", True),
    11: ("tangerang", "DURI", False),
    12: ("tangerang", "TANGERANG", False),
}
EXPECTED_LINES = {
    "bogor": 392,
    "cikarang": 365,
    "rangkasbitung": 204,
    "tangerang": 120,
    "tanjung_priok": 64,
}
def minute_value(value: str, previous: int | None) -> int:
    match = TIME.fullmatch(value)
    if not match:
        raise ValueError(f"Invalid time {value!r}")
    raw_minute = int(match.group(1)) * 60 + int(match.group(2))
    minute = raw_minute + (previous // 1440 * 1440 if previous is not None else 0)
    if previous is not None and minute < previous:
        if previous % 1440 < 18 * 60 or raw_minute > 6 * 60:
            raise ValueError(f"Unexpected non-monotonic time {value} after minute {previous}")
        minute += 1440
    if minute >= 2880:
        raise ValueError("A service cannot cross midnight twice")
    return minute


def stops_from(values: list[str], codes: list[str]) -> list[dict]:
    stops, previous = [], None
    for code, value in zip(codes, values):
        value = (value or "").strip()
        if not value:
            continue
        sequence = len(stops) + 1
        if value == "Ls":
            stops.append(
                {
                    "stationCode": code,
                    "sequence": sequence,
                    "arrivalMinute": None,
                    "departureMinute": None,
                    "isPassThrough": True,
                }
            )
            continue
        previous = minute_value(value, previous)
        stops.append(
            {
                "stationCode": code,
                "sequence": sequence,
                "arrivalMinute": previous,
                "departureMinute": previous,
                "isPassThrough": False,
            }
        )
    return stops


def service(
    *,
    line_slug: str,
    direction: str,
    page: int,
    source_row: int,
    loop_number: int | None,
    train_number: str,
    continuation: str | None,
    relation: str,
    values: list[str],
    codes: list[str],
    notes: str,
) -> dict:
    note = notes.strip()
    return {
        "lineSlug": line_slug,
        "direction": direction,
        "sourcePage": page,
        "sourceRow": source_row,
        "loopNumber": loop_number,
        "trainNumber": train_number,
        "continuationTrainNumber": continuation,
        "relation": relation,
        "calendarCode": (
            "WEEKDAY" if "Sabtu/Minggu/Libur Nasional Batal" in note else "DAILY"
        ),
        "isFullRacket": "Full Racket" in note,
        "notes": note,
        "stops": stops_from(values, codes),
    }


def parse_standard_row(row: list[str | None], header: list[str], page: int) -> dict:
    line_slug, direction, has_loop = PAGE_META[page]
    source_row = int(row[0] or 0)
    loop_number = int(row[1] or 0) if has_loop else None
    train_index, relation_index, station_index = (2, 3, 4) if has_loop else (1, 2, 3)
    train_numbers = (row[train_index] or "").split(" - ")
    train_number = train_numbers[0]
    continuation = train_numbers[1] if len(train_numbers) == 2 else None
    relation = (row[relation_index] or "").split(" - ")[0]
    values = [(value or "") for value in row[station_index:-1]]
    if len(values) != len(header):
        raise ValueError(f"Header mismatch on page {page}, row {source_row}")
    return service(
        line_slug=line_slug,
        direction=direction,
        page=page,
        source_row=source_row,
        loop_number=loop_number,
        train_number=train_number,
        continuation=continuation,
        relation=relation,
        values=values,
        codes=header,
        notes=row[-1] or "",
    )


def parse_priok_row(row: list[str | None], page: int) -> list[dict]:
    result = []
    for number_index, header, direction in (
        (1, ["JAKK", "KPB", "AC", "TPK"], "TANJUNG_PRIOK"),
        (10, ["TPK", "AC", "KPB", "JAKK"], "JAKARTA_KOTA"),
    ):
        source_row, train_number, relation = row[number_index : number_index + 3]
        result.append(
            service(
                line_slug="tanjung_priok",
                direction=direction,
                page=page,
                source_row=int(source_row or 0),
                loop_number=None,
                train_number=train_number or "",
                continuation=None,
                relation=relation or "",
                values=[value or "" for value in row[number_index + 3 : number_index + 7]],
                codes=header,
                notes=row[number_index + 7] or "",
            )
        )
    return result


def validate(services: list[dict]) -> None:
    calls = [stop for item in services for stop in item["stops"]]
    primary = {item["trainNumber"] for item in services}
    continuations = [item["continuationTrainNumber"] for item in services if item["continuationTrainNumber"]]
    individual = primary | set(continuations)
    checks = {
        "services": (len(services), 1145),
        "individual train numbers": (len(individual), 1147),
        "timed calls": (sum(stop["arrivalMinute"] is not None for stop in calls), 18985),
        "pass-through calls": (sum(stop["isPassThrough"] for stop in calls), 343),
        "cross-midnight services": (
            sum(any((stop["arrivalMinute"] or 0) >= 1440 for stop in item["stops"]) for item in services),
            21,
        ),
        "weekday services": (sum(item["calendarCode"] == "WEEKDAY" for item in services), 33),
        "Full Racket services": (sum(item["isFullRacket"] for item in services), 160),
        "station codes": (len({stop["stationCode"] for stop in calls}), 85),
        "continuation rows": (len(continuations), 80),
    }
    checks.update(
        (f"{line} services", (count, EXPECTED_LINES[line]))
        for line, count in Counter(item["lineSlug"] for item in services).items()
    )
    failures = [f"{name}: got {actual}, expected {expected}" for name, (actual, expected) in checks.items() if actual != expected]
    continuation_only = sorted(set(continuations) - primary)
    if continuation_only != ["5746", "6052B"]:
        failures.append(f"continuation-only numbers: {continuation_only}")
    target = next((item for item in services if item["trainNumber"] == "5020A"), None)
    ckr = next((stop for stop in target["stops"] if stop["stationCode"] == "CKR"), None) if target else None
    if not target or ckr["arrivalMinute"] != 384 or "06:31" not in target["notes"]:
        failures.append("KA 5020A anomaly was not preserved as notes after CKR 06:24")
    if failures:
        raise ValueError("Snapshot validation failed:\n- " + "\n- ".join(failures))


def extract(source: Path) -> list[dict]:
    services = []
    with pdfplumber.open(source) as document:
        if len(document.pages) != 13:
            raise ValueError(f"Expected 13 pages, got {len(document.pages)}")
        for page_number, page in enumerate(document.pages, 1):
            table = page.extract_table()
            if not table:
                raise ValueError(f"No table found on page {page_number}")
            if page_number == 13:
                for row in table[3:]:
                    if row[1] and row[1].isdigit():
                        services.extend(parse_priok_row(row, page_number))
                continue
            station_index = 4 if PAGE_META[page_number][2] else 3
            header = [code or "" for code in table[2][station_index:-1]]
            services.extend(
                parse_standard_row(row, header, page_number)
                for row in table[3:]
                if row[0] and row[0].isdigit()
            )
    return services


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("Usage: extract_commuter_timetable.py SOURCE.pdf OUTPUT.json")
    source, output = map(Path, sys.argv[1:])
    services = extract(source)
    validate(services)
    payload = {
        "meta": {
            "version": "2026-02",
            "sourceName": source.name,
            "sourceSha256": hashlib.sha256(source.read_bytes()).hexdigest(),
            "timezone": "Asia/Jakarta",
        },
        "services": services,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
    print(f"Validated {len(services)} services, {sum(len(item['stops']) for item in services)} calls, 85 station codes.")


if __name__ == "__main__":
    main()
