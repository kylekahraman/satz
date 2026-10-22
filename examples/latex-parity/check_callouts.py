"""Guard body/code paragraph rhythm and callout pagination at two body sizes."""
from pathlib import Path
import subprocess
import tempfile
import pymupdf as fitz

ROOT = Path(__file__).resolve().parents[2]


def main():
    with tempfile.TemporaryDirectory(prefix="satz-callouts-") as folder:
        for size in (11, 13):
            source = Path(folder) / f"callout-{size}.typ"
            source.write_text(
                f'#import "{ROOT}/callouts.typ": callout\n'
                '#set page(width: 120mm, height: 140mm, margin: 12mm, numbering: "1")\n'
                f'#set text(font: "STIX Two Text", size: {size}pt)\n'
                '#set par(leading: 0.75em)\n'
                '#show raw: set text(font: "Fira Code", size: 9pt)\n'
                '#callout[\n'
                + '\n\n'.join(f'BODY{i:03d}\n\n`CODE{i:03d}`' for i in range(30))
                + '\n]\n'
            )
            output = source.with_suffix(".pdf")
            subprocess.run(["typst", "compile", "--root", "/", str(source), str(output)], check=True)
            with fitz.open(output) as document:
                text = "\n".join(p.get_text() for p in document)
                assert len(document) > 1
                for i in range(30):
                    assert text.count(f"BODY{i:03d}") == text.count(f"CODE{i:03d}") == 1
                for page in document:
                    lines = [l for b in page.get_text("dict")["blocks"] for l in b.get("lines", []) if any("BODY" in s["text"] or "CODE" in s["text"] for s in l["spans"])]
                    baselines = [l["spans"][0]["origin"][1] for l in lines]
                    assert all(y - x >= size * 1.4 for x, y in zip(baselines, baselines[1:])), baselines
                    boxes = [d["rect"] for d in page.get_drawings() if d.get("fill") is not None]
                    assert boxes and all(r.y1 <= page.rect.height - 33 for r in boxes)
    print("Passed: body/code rhythm at 11pt and 13pt, all paragraphs preserved, split boxes clear footers.")


if __name__ == "__main__":
    main()
