"""Check placeholder dimensions and composition with normal satz figures."""

from pathlib import Path
import subprocess

import fitz


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = Path(__file__).resolve().parent / "output"


def main():
    OUTPUT.mkdir(exist_ok=True)
    path = OUTPUT / "placeholders.pdf"
    subprocess.run([
        "typst", "compile", "--root", str(ROOT),
        str(ROOT / "examples/placeholders.typ"), str(path),
    ], check=True)
    with fitz.open(path) as document:
        assert len(document) == 3, "Expected contents, figure list, and report body"
        body = document[2]
        text = " ".join(body.get_text().split())
        assert "Placeholder" in text and "Planned result plot" in text
        assert "See Figure 1 and Figure 2" in text
        assert "A longer caption describing the result plot" in text
        outline = document[1].get_text()
        assert "Planned results" in outline and "longer caption" not in outline
        assert "List of Tables" not in " ".join(page.get_text() for page in document)
        rectangles = [drawing["rect"] for drawing in body.get_drawings()
                      if drawing.get("dashes") and drawing["dashes"] != "[] 0"]
        assert len(rectangles) == 2, "Expected two dashed placeholder outlines"
        available = body.rect.width - 2 * 25 / 25.4 * 72
        for rect, width, height in zip(rectangles, [available, available * 0.8], [40, 28]):
            assert abs(rect.width - width) < 0.1, "Placeholder width changed"
            assert abs(rect.height - height / 25.4 * 72) < 0.1, "Placeholder height changed"
        for rect, label in zip(rectangles, ["Placeholder", "Planned result plot"]):
            bounds = body.search_for(label)[0]
            assert abs((bounds.x0 + bounds.x1 - rect.x0 - rect.x1) / 2) < 0.1
            assert abs((bounds.y0 + bounds.y1 - rect.y0 - rect.y1) / 2) < 5
        links = body.get_links()
        assert len(links) >= 2 and all(link.get("page") == 2 for link in links)
        body.get_pixmap().save(OUTPUT / "placeholders-preview.png")
    print("Passed: placeholder labels, physical dimensions, centering, captions, references, and figure list.")


if __name__ == "__main__":
    main()
