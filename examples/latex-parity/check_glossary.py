"""Verify the public satz/Glossarium example, references, and caption coexistence."""

from pathlib import Path
import subprocess

import fitz


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = Path(__file__).resolve().parent / "output"


def main():
    OUTPUT.mkdir(exist_ok=True)
    path = OUTPUT / "glossary.pdf"
    subprocess.run([
        "typst", "compile", "--root", str(ROOT),
        str(ROOT / "examples/glossary.typ"), str(path),
    ], check=True)
    with fitz.open(path) as document:
        assert len(document) == 5, "Expected TOC, LoF, LoT, body, and abbreviation list"
        texts = [" ".join(page.get_text().split()) for page in document]
        body, abbreviations = texts[3:]
        assert body.count("application programming interface (API)") == 1
        assert "The API is referenced again" in body
        assert "Portable Document Format (PDF)" in body
        assert "API – application programming interface" in abbreviations
        assert "PDF – Portable Document Format" in abbreviations
        assert "SQL" not in " ".join(texts), "Unused entry leaked into output"
        assert "Document workflow" in texts[1] and "full caption" not in texts[1]
        assert "A full caption describing the example document workflow." in body
        assert "Example workflow stages." in texts[2]
        assert "API" not in texts[1] + texts[2], "Glossary entries leaked into LoF/LoT"
        glossary_links = [link for link in document[3].get_links() if link.get("page") == 4]
        assert len(glossary_links) >= 3, "Term references do not link to the abbreviation list"
        for page in document:
            assert all(0 <= link.get("page", 0) < len(document) for link in page.get_links())
        for index in (3, 4):
            document[index].get_pixmap().save(OUTPUT / f"glossary-page-{index + 1}.png")
    print("Passed: first/repeated use, unused terms, term links, LoF/LoT, and short/long captions.")


if __name__ == "__main__":
    main()
