"""Check scientific rules, native cells and repeated headings in actual PDFs."""
from pathlib import Path
import subprocess
import tempfile
import fitz

ROOT = Path(__file__).resolve().parents[2]


def main():
    with tempfile.TemporaryDirectory(prefix="satz-scientific-tables-") as folder:
        source = Path(folder) / "tables.typ"
        source.write_text(
            f'#import "{ROOT}/tables.typ": scientific-table\n'
            '#set page(width: 120mm, height: 140mm, margin: 12mm, numbering: "1")\n'
            '#set text(font: "Libertinus Serif", size: 11pt)\n'
            '#show figure.where(kind: table): set block(breakable: true)\n'
            '#figure(scientific-table(columns: (1fr, auto), align: (left, right),\n'
            'header: ([CONDITION], [VALUE]),\n'
            'table.cell(colspan: 2)[GROUP], table.hline(stroke: 0.5pt),\n'
            + '\n'.join(f'[ROW{i:03d}], [{i}.25],' for i in range(60))
            + '\n), kind: table, caption: [Measured results.]) <results>\n'
            'See @results.\n'
        )
        output = source.with_suffix(".pdf")
        subprocess.run(["typst", "compile", "--root", "/", str(source), str(output)], check=True)
        with fitz.open(output) as document:
            text = "\n".join(p.get_text() for p in document)
            assert all(text.count(f"ROW{i:03d}") == 1 for i in range(60))
            assert text.count("GROUP") == 1
            assert text.count("Measured results.") == 1
            pages = [p for p in document if "ROW" in p.get_text()]
            assert len(pages) > 1
            for page in pages:
                assert "CONDITION" in page.get_text() and "VALUE" in page.get_text()
                rules = [d for d in page.get_drawings() if d["type"] == "s"]
                horizontal = [d for d in rules if d["rect"].height < 0.1]
                assert len(horizontal) >= 3, (page.number, horizontal)
                assert len(horizontal) == len(rules), "Unexpected vertical grid"
                assert sum(abs(d["width"] - 0.8) < 0.01 for d in horizontal) == 2
                spans = [s for b in page.get_text("dict")["blocks"] for l in b.get("lines", []) for s in l["spans"]]
                assert any("CONDITION" in s["text"] and "Bold" in s["font"] for s in spans)
                assert max(d["rect"].y1 for d in rules) < page.rect.height - 30
    print("Passed: rules on every table fragment, repeated bold headings, all 60 rows, spanning cell, caption and reference.")


if __name__ == "__main__":
    main()
