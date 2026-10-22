"""Check outline hierarchy, wrapping, spacing, links, independent lists and themes."""
from pathlib import Path
import subprocess
import tempfile

import fitz

ROOT = Path(__file__).resolve().parents[2]


def compile_pdf(folder, name, source):
    path = folder / f"{name}.typ"
    path.write_text(source)
    subprocess.run(["typst", "compile", "--root", "/", str(path), str(path.with_suffix('.pdf'))], check=True)
    return fitz.open(path.with_suffix('.pdf'))


def baseline(page, text):
    return next(s["origin"][1] for b in page.get_text("dict")["blocks"]
                for line in b.get("lines", []) for s in line["spans"] if text in s["text"])


def prelude(config="", theme=None):
    theme_arg = f"theme: {theme}, " if theme is not None else ""
    return (f'#import "{ROOT}/lib.typ": report\n'
            f'#show: report.with({theme_arg}config: ({config}))\n')


def main():
    with tempfile.TemporaryDirectory(prefix="satz-outline-check-") as directory:
        folder = Path(directory)
        sample = (ROOT / "examples/outline.typ").read_text().replace('"../lib.typ"', f'"{ROOT}/lib.typ"')
        with compile_pdf(folder, "ordinary", sample) as doc:
            toc = doc[0]
            assert "1.1 Research question" in toc.get_text()
            assert "1.2.1 Scope" in toc.get_text()
            row_gap = baseline(toc, "Summary table") - baseline(toc, "Recording")
            assert row_gap >= 13
            assert baseline(toc, "Methods") - baseline(toc, "Scope") > row_gap + 5
            assert baseline(toc, "Introduction") - baseline(toc, "Table of Contents") >= 22
            wrapped = toc.search_for("A deliberately long subsection title illustrating the hanging indentation of a wrapped contents entry in a report with multiple levels")
            assert len(wrapped) >= 2
            assert abs(wrapped[0].x0 - wrapped[1].x0) < 0.1
            assert all(s["color"] == 0 for b in toc.get_text("dict")["blocks"]
                       for line in b.get("lines", []) for s in line["spans"] if "Methods" in s["text"])
            assert len(toc.get_links()) >= 10
            assert "List of Figures" in doc[1].get_text()
            assert "Example diagram" in doc[1].get_text()
            assert "List of Tables" in doc[2].get_text()
            assert "Summary of the example measurements" in doc[2].get_text()
            for page in list(doc)[:3]:
                assert not page.get_text(clip=fitz.Rect(0, page.rect.height - 60, page.rect.width, page.rect.height)).strip()
            for page in list(doc)[3:]:
                assert page.get_text(clip=fitz.Rect(0, page.rect.height - 60, page.rect.width, page.rect.height)).strip()
            assert doc[0].get_pixmap().pixel(0, 0) == (255, 255, 255)
            for page in list(doc)[:3]:
                for block in page.get_text("dict")["blocks"]:
                    for line in block.get("lines", []):
                        for span in line["spans"]:
                            color = span["color"]
                            assert color >> 16 == (color >> 8 & 255) == (color & 255)

        custom = '''
#set page(numbering: "i")
= Alpha
== Beta
#figure(rect(width: 10mm, height: 10mm), kind: image, numbering: "a", supplement: [Graphic], caption: [FIGCAPTION])
#counter(figure.where(kind: table)).update(3)
#figure(table(columns: 1, [Data]), kind: table, numbering: "I", caption: [TABLECAPTION])
'''
        for compact in ("false", "true"):
            source = prelude(f'headings: (numbering: "I.a"), lof: (compact: {compact}), lot: (compact: {compact}),') + custom
            with compile_pdf(folder, f"custom-{compact}", source) as doc:
                assert "I.a Beta" in doc[0].get_text()
                assert "Graphic a" in doc[1].get_text().replace('\xa0', ' ')
                assert "Table IV" in doc[2].get_text().replace('\xa0', ' ')
                assert "ii" in doc[1].get_text() and "ii" in doc[2].get_text()
                assert ("FIGCAPTION" in doc[1].get_text()) == (compact == "false")
                assert ("TABLECAPTION" in doc[2].get_text()) == (compact == "false")
                assert doc[1].get_links() and doc[2].get_links()
                assert all(s["color"] == 0 for b in doc[1].get_text("dict")["blocks"]
                           for line in b.get("lines", []) for s in line["spans"] if "Graphic" in s["text"])

        with compile_pdf(folder, "table-only", prelude('toc: (depth: 0),') + custom) as doc:
            assert "List of Figures" in doc[0].get_text()
            assert "List of Tables" in doc[1].get_text()
            assert "Table of Contents" not in ''.join(p.get_text() for p in doc)
        with compile_pdf(folder, "empty-lists", prelude() + '= Only heading\n#table(columns: 1, [Uncaptioned])\n#figure(rect(), outlined: false)') as doc:
            assert len(doc) == 2
            assert "List of" not in ''.join(p.get_text() for p in doc)

        lists = '''FIRSTLINE\\
SECONDLINE

- BULLETONE
- BULLETTWO

+ ENUMONE
+ ENUMTWO
'''
        with compile_pdf(folder, "list-spacing", prelude('toc: (depth: 0),') + lists) as doc:
            page = doc[0]
            line_gap = baseline(page, "SECONDLINE") - baseline(page, "FIRSTLINE")
            bullet_gap = baseline(page, "BULLETTWO") - baseline(page, "BULLETONE")
            enum_gap = baseline(page, "ENUMTWO") - baseline(page, "ENUMONE")
            assert bullet_gap > line_gap + 2
            assert abs(bullet_gap - enum_gap) < 0.1
        for theme in ('"neutral"', '"soft-jade"', '"soft-slate"', '"warm-editorial"', '"plum"', '"soft-rose"', 'none'):
            with compile_pdf(folder, f"theme-{theme.strip(chr(34))}", prelude('toc: (depth: 0), colors: (brand-primary: red),', theme) + '= Override') as doc:
                assert any(s["color"] == 0xFF4136 for b in doc[0].get_text("dict")["blocks"]
                           for line in b.get("lines", []) for s in line["spans"] if "Override" in s["text"])
    print("Passed: native numbering, wrapping, row/section/title gaps, neutral links, captions, compact/custom numbers, Roman pages, independent lists, empty lists, item spacing, themes and overrides.")


if __name__ == "__main__":
    main()
