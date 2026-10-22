"""Compare report spacing with native headings and a KOMA-Script specimen."""

from pathlib import Path
import json
import subprocess

import pymupdf as fitz


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUTPUT = HERE / "output"


def run(command):
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)


def compile_source(name, source):
    path = OUTPUT / f"{name}.typ"
    path.write_text(source)
    pdf = path.with_suffix(".pdf")
    run(["typst", "compile", "--root", str(ROOT), str(path), str(pdf)])
    return pdf


def locate(document, phrase):
    for index, page in enumerate(document):
        rectangles = page.search_for(phrase)
        if rectangles:
            return index, rectangles
    raise AssertionError(f"Missing text: {phrase}")


def main():
    OUTPUT.mkdir(exist_ok=True)
    # Keep the original native-flow comparison as the explicit opt-out check.
    source = (HERE / "typography.typ").read_text().replace('"../../lib.typ"', '"/lib.typ"').replace('"typography-content.typ"', '"/examples/latex-parity/typography-content.typ"')
    source = source.replace('typography: (font:', 'headings: (spacing: "native", h1-below: 1em, h2-below: 1em, h3-below: 0.9em, h4-below: 0.75em), typography: (font:')
    compile_source("typography-report", source)
    for mode in ("native",):
        run(["typst", "compile", "--root", str(ROOT), "--input", f"mode={mode}",
             str(HERE / "typography.typ"), str(OUTPUT / f"typography-{mode}.pdf")])
    run(["pdflatex", "-no-shell-escape", "-interaction=nonstopmode", "-halt-on-error",
         f"-output-directory={OUTPUT}", str(HERE / "typography.tex")])
    failures, measurements = [], {}
    anchors = [
        "A report with a consistent rhythm", "A section followed by ordinary text",
        "A smaller heading", "A fourth-level heading", "Consecutive headings",
        "A subsection immediately follows", "A heading followed by a list",
        "A heading followed by an equation",
    ]
    with fitz.open(OUTPUT / "typography-report.pdf") as report, fitz.open(OUTPUT / "typography-native.pdf") as native:
        for phrase in anchors:
            page, rects = locate(report, phrase)
            expected_page, expected_rects = locate(native, phrase)
            measurements[phrase] = {"report_page": page + 1, "report_y": rects[0].y0, "native_y": expected_rects[0].y0}
            if page != expected_page or abs(rects[0].y0 - expected_rects[0].y0) > 0.05:
                failures.append(f"{phrase}: report differs from native heading flow")
        # Native headings stay attached through consecutive headings and into prose.
        assert locate(report, "Consecutive headings")[0] == locate(report, "There is no intervening prose here.")[0]
        assert len(locate(report, "A deliberately long section heading that wraps onto a second line and still stays attached to the text that explains it")[1]) >= 2
        for index, page in enumerate(report):
            page.get_pixmap().save(OUTPUT / f"typography-report-{index + 1}.png")

    # Fixed small pages exercise attachment near a page boundary at all levels.
    for level in range(1, 5):
        for height in (104, 112):
            source = '#import "/lib.typ": report\n#show: report.with(config: (toc: (depth: 0), page: (paper: "a6", margin: 12mm)))\n'
            source += f'#v({height}mm)\n' + '=' * level + ' EDGEHEADING\nFOLLOWINGBODY must stay attached.\n'
            with fitz.open(compile_source(f"edge-{level}-{height}", source)) as document:
                assert locate(document, "EDGEHEADING")[0] == locate(document, "FOLLOWINGBODY")[0]

    # Paragraph controls must affect geometry, and headings must suppress the indent.
    baselines = []
    for spacing in (8, 16):
        source = '#import "/lib.typ": report\n#show: report.with(config: (toc: (depth: 0), typography: ('
        source += f'paragraph-spacing: {spacing}pt, first-line-indent: 1em)))\n'
        source += 'FIRSTPAR\n\nSECONDPAR\n\n== ANOTHERHEADING\nAFTERHEADING\n'
        with fitz.open(compile_source(f"paragraphs-{spacing}", source)) as document:
            first = locate(document, "FIRSTPAR")[1][0]
            second = locate(document, "SECONDPAR")[1][0]
            after = locate(document, "AFTERHEADING")[1][0]
            if abs(second.x0 - first.x0 - 11) > 0.05:
                failures.append("Configured first-line indentation did not reach the paragraph")
            assert abs(after.x0 - first.x0) < 0.05, "Paragraph after heading is indented"
            baselines.append(second.y0 - first.y0)
    if abs(baselines[1] - baselines[0] - 8) > 0.05:
        failures.append("Configured paragraph spacing did not change the gap by 8pt")
    measurements["paragraph_gap_change_pt"] = baselines[1] - baselines[0]

    # Before-spacing must actually reach the heading block. Otherwise a large
    # below-spacing can visually attach the heading to the preceding paragraph.
    heading_gaps = {}
    for level in range(1, 5):
        gaps = []
        for above in (12, 32):
            source = '#import "/lib.typ": report\n#show: report.with(config: ('
            source += 'toc: (depth: 0), typography: (paragraph-spacing: 4pt), '
            source += f'headings: (h{level}-above: {above}pt, h{level}-below: 6pt)))\n'
            source += '#v(30pt)\nPRECEDINGBODY\n\n'
            source += '=' * level + ' TUNABLEHEADING\nFOLLOWINGBODY\n'
            with fitz.open(compile_source(f"heading-gaps-{level}-{above}", source)) as document:
                preceding_page, preceding = locate(document, "PRECEDINGBODY")
                heading_page, heading = locate(document, "TUNABLEHEADING")
                following_page, following = locate(document, "FOLLOWINGBODY")
                assert preceding_page == heading_page == following_page
                gaps.append((heading[0].y0 - preceding[0].y1,
                             following[0].y0 - heading[0].y1))
        if abs(gaps[1][0] - gaps[0][0] - 20) > 0.05:
            failures.append(f"Level {level}: above-spacing did not increase the gap by 20pt")
        if abs(gaps[1][1] - gaps[0][1]) > 0.05 or gaps[1][0] <= gaps[1][1]:
            failures.append(f"Level {level}: heading does not group with its following paragraph")
        heading_gaps[str(level)] = gaps
    measurements["heading_gaps_pt"] = heading_gaps
    (OUTPUT / "typography-checks.json").write_text(json.dumps(measurements, indent=2) + "\n")
    if failures:
        raise AssertionError("\n".join(failures))
    print("Passed: native heading flow, multiline/consecutive headings, 8 page-edge cases, paragraph spacing/indentation, above/below heading grouping at all 4 levels.")


if __name__ == "__main__":
    main()
    from check_shared_headings import main as check_shared
    check_shared()
