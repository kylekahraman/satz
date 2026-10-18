"""Build the original KOMA-Script/satz header comparison and verify its policy.

Requires pdflatex, Typst, and PyMuPDF. This compiles only our own TeX source.
"""

from pathlib import Path
import json
import subprocess

import fitz


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUTPUT = HERE / "output"
HEADERS = [
    "", "", "Measurements", "Instrument checks", "", "Section-free chapter",
    "Section-free chapter", "Section-free chapter", "Follow-up", "", "Closing remarks",
    "Closing remarks",
]
CASES = [
    None, "opening-a", "section-change", "continuation-a", "opening-b",
    "continuation-b-even", "continuation-b-odd", "follow-up-even", "follow-up-odd",
    "opening-unnumbered", "unnumbered-odd", "counter-reset",
]


def run(command):
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)


def compile_typst(name, inputs=()):
    path = OUTPUT / f"{name}.pdf"
    command = ["typst", "compile", "--root", str(ROOT)]
    for value in inputs:
        command += ["--input", value]
    run(command + [str(HERE / "header-report.typ"), str(path)])
    return path


def inspect(path, custom_header=False, custom_footer=False, headers=True, numbered=True):
    rows, failures = [], []
    with fitz.open(path) as document:
        if len(document) != len(HEADERS):
            raise AssertionError(f"{path.name}: expected {len(HEADERS)} pages, got {len(document)}")
        for index, page in enumerate(document):
            width, height = page.rect.width, page.rect.height
            header_rect = fitz.Rect(0, 0, width, 65)
            footer_rect = fitz.Rect(0, height - 65, width, height)
            header = " ".join(page.get_text(clip=header_rect).split())
            footer = " ".join(page.get_text(clip=footer_rect).split())
            expected_header = ("Custom header" if custom_header else HEADERS[index]) if index else ""
            if not headers and not custom_header:
                expected_header = ""
            raw_counter = 4 if index == 11 else index + 1
            expected_footer = "Custom footer" if custom_footer else str(raw_counter - 1)
            if not numbered and not custom_footer:
                expected_footer = ""
            if index == 0:
                expected_footer = ""
            for kind, actual, expected in [
                ("header", header, expected_header), ("footer", footer, expected_footer),
            ]:
                if actual != expected:
                    failures.append(f"page {index + 1} {kind}: {actual!r}, expected {expected!r}")
            if CASES[index] and f"CASE {CASES[index]}" not in page.get_text():
                failures.append(f"page {index + 1}: missing case marker")
            if index and not custom_footer and numbered:
                words = page.get_text("words", clip=footer_rect)
                center = (words[0][0] + words[0][2]) / 2 if words else width / 2
                if (center < width / 2) != (raw_counter % 2 == 0):
                    failures.append(f"page {index + 1}: footer alignment disagrees with counter parity")
            if header and not custom_header:
                words = page.get_text("words", clip=header_rect)
                center = (min(w[0] for w in words) + max(w[2] for w in words)) / 2
                if (center < width / 2) != (raw_counter % 2 == 0):
                    failures.append(f"page {index + 1}: header alignment disagrees with counter parity")
            rows.append({"physical_page": index + 1, "raw_counter": raw_counter, "header": header, "footer": footer})
            page.get_pixmap().save(OUTPUT / f"{path.stem}-page-{index + 1:02}.png")
        links = [link for page in document for link in page.get_links()]
        if len(links) < 5 or any(link.get("page", 0) >= len(document) for link in links):
            failures.append("missing or invalid internal cross-reference links")
    return {"pages": rows, "failures": failures}


def main():
    OUTPUT.mkdir(exist_ok=True)
    latex = ["pdflatex", "-no-shell-escape", "-interaction=nonstopmode", "-halt-on-error",
             f"-output-directory={OUTPUT}", str(HERE / "header-report.tex")]
    for _ in range(2):
        run(latex)
    log = (OUTPUT / "header-report.log").read_text(errors="replace")
    if "undefined references" in log or "multiply defined" in log:
        raise AssertionError("Unresolved LaTeX reference warnings")
    results = {
        "latex": inspect(OUTPUT / "header-report.pdf"),
        "satz": inspect(compile_typst("header-report-satz")),
        "headers-disabled": inspect(compile_typst("header-report-no-headers", ["headers=false"]), headers=False),
        "single-sided": inspect(compile_typst("header-report-single-sided", ["single-sided=true"]), headers=False, numbered=False),
        "custom": inspect(compile_typst("header-report-custom", ["custom-header=true", "custom-footer=true"]), custom_header=True, custom_footer=True),
    }
    (OUTPUT / "report-checks.json").write_text(json.dumps(results, indent=2) + "\n")
    failures = [f"{name}: {failure}" for name, result in results.items() for failure in result["failures"]]
    if failures:
        raise AssertionError("\n".join(failures))
    print("Passed: KOMA-Script reference, satz headers/parity/reset, disabled headers, single-sided, custom header/footer.")


if __name__ == "__main__":
    main()
