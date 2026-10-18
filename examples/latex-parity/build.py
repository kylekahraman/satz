"""Build the first paired satz/KOMA-Script examples and inspect their PDFs.

Requires Typst and PyMuPDF, plus curl for --fetch.
Never compiles or executes downloaded TeX source.
"""

from pathlib import Path
from collections import Counter
import argparse
import hashlib
import io
import json
import subprocess
import unicodedata
import zipfile

import fitz


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
UPSTREAM = HERE / "upstream"
OUTPUT = HERE / "output"
URL = "https://mirrors.ctan.org/info/examples/KOMA-Script-6.zip"
SHA256 = "e982bac0108654cbeea5f87ce5cc39b799a90098941190103fd499aeb368b026"
PAIRS = {
    "koma-letter": {
        "reference": "Kapitel-4/result/letter-1.pdf",
        "source": "Kapitel-4/source/letter-1.tex",
        "phrases": ["Petra Mustermann", "Liebe Vereinsvorsitzende,", "In Erwartung einer Einladung"],
    },
    "koma-commentary": {
        "reference": "Kapitel-19/result/scrlayer-notecolumn-example.pdf",
        "source": "Kapitel-19/source/scrlayer-notecolumn-example.tex",
        "phrases": ["Kommentar zum GüdaVaS", "Inhaltsverzeichnis", "Vormerkung", "Analyse", "Komik der Kultur"],
    },
}


def fetch():
    data = subprocess.run(
        ["curl", "--fail", "--location", "--silent", "--show-error", "--max-time", "45", URL],
        check=True, capture_output=True, timeout=60,
    ).stdout
    if hashlib.sha256(data).hexdigest() != SHA256:
        raise ValueError("CTAN archive changed; review it before updating the checksum")
    # Preserve the complete upstream work, including its license and sources.
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        for entry in archive.infolist():
            target = (UPSTREAM / entry.filename).resolve()
            if not target.is_relative_to(UPSTREAM.resolve()):
                raise ValueError(f"Unsafe archive path: {entry.filename}")
            if not entry.is_dir():
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(archive.read(entry))


def inspect(path, phrases):
    with fitz.open(path) as document:
        if len(document) != 1:
            raise AssertionError(f"{path.name}: expected one page, got {len(document)}")
        page = document[0]
        text = " ".join(page.get_text().split())
        for phrase in phrases:
            if phrase not in text:
                raise AssertionError(f"{path.name}: missing {phrase!r}")
        for word in page.get_text("words"):
            x0, y0, x1, y1 = word[:4]
            if x0 < 0 or y0 < 0 or x1 > page.rect.width or y1 > page.rect.height:
                raise AssertionError(f"{path.name}: text outside page: {word[4]!r}")
        # Render for human inspection; text checks cannot detect all collisions.
        page.get_pixmap(matrix=fitz.Matrix(1.5, 1.5)).save(
            OUTPUT / (path.stem + "-preview.png")
        )
        return {
            "pages": len(document),
            "size_pt": list(page.rect)[2:],
            "links": len(page.get_links()),
            "header": page.get_text(clip=fitz.Rect(0, 0, page.rect.width, 60)).strip(),
            "footer": page.get_text(clip=fitz.Rect(0, page.rect.height - 60, page.rect.width, page.rect.height)).strip(),
        }


def text_inventory(path):
    # Ignore layout whitespace, discretionary hyphens, and ligature encoding.
    # Reading order differs between the two column implementations.
    with fitz.open(path) as document:
        text = unicodedata.normalize("NFKC", document[0].get_text())
    return Counter(character for character in text if character.isalnum())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fetch", action="store_true", help="download the pinned original examples")
    args = parser.parse_args()
    if args.fetch:
        fetch()
    OUTPUT.mkdir(exist_ok=True)
    results = {}
    for name, pair in PAIRS.items():
        reference = UPSTREAM / "KOMA-Script-6" / pair["reference"]
        source = UPSTREAM / "KOMA-Script-6" / pair["source"]
        if not reference.exists() or not source.exists():
            raise FileNotFoundError("Original source/PDF missing. Run build.py --fetch first.")
        output = OUTPUT / (name + ".pdf")
        subprocess.run(
            ["typst", "compile", "--root", str(ROOT), str(HERE / (name + ".typ")), str(output)],
            check=True,
        )
        results[name] = {
            "reference": inspect(reference, pair["phrases"]),
            "satz": inspect(output, pair["phrases"]),
        }
        if text_inventory(reference) != text_inventory(output):
            raise AssertionError(f"{name}: reference and recreation text inventories differ")
        results[name]["text_inventory_matches"] = True
    (OUTPUT / "checks.json").write_text(json.dumps(results, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(results, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
