"""Check actionable validation for public legal and contract inputs."""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]


def main():
    cases = [
        ("legal-exhibit-shape", '#import "/lib.typ": klageschrift\n#show: klageschrift.with(anlagen: (1,))\nBody', "anlagen` must be an array"),
        ("legal-page-limit", '#import "/lib.typ": klageschrift\n#show: klageschrift.with(anlagen_pdf_path: "appendix.pdf", anlagen_max_pages: 0)\nBody', "positive integer"),
        ("contract-mode", '#import "/lib.typ": gastspielvertrag\n#show: gastspielvertrag.with(dokument: "draft")', "dokument must be vertrag, angebot or rechnung"),
        ("contract-fee-mode", '#import "/lib.typ": gastspielvertrag\n#show: gastspielvertrag.with(gage_typ: "hourly")', "gage_typ must be fest or prozent"),
        ("contract-percent", '#import "/lib.typ": gastspielvertrag\n#show: gastspielvertrag.with(prozentsatz: 101)', "must not exceed 100"),
        ("contract-cost", '#import "/lib.typ": gastspielvertrag\n#show: gastspielvertrag.with(transport_km: -1)', "nonnegative integer"),
        ("contract-flag", '#import "/lib.typ": gastspielvertrag\n#show: gastspielvertrag.with(techniker: "yes")', "must be booleans"),
        ("cover-layout-type", '#import "/lib.typ": cover-page\n#cover-page(layout: 1, title: "Title")', "layout must be a string"),
        ("cover-theme", '#import "/lib.typ": cover-page\n#cover-page(layout: "minimal", theme: "unknown", title: "Title")', "Unknown cover theme"),
        ("book-toc-depth", '#import "/lib.typ": book-contents\n#book-contents(depth: -1)', "depth must be a nonnegative integer"),
        ("nwo-output-reference", '#import "/lib.typ": nwo-key-output\n#nwo-key-output(reference: 1)', "reference` must be a string or content"),
    ]
    with tempfile.TemporaryDirectory(prefix="satz-input-validation-", dir=ROOT / "examples/latex-parity") as directory:
        for name, source, expected in cases:
            typ = Path(directory) / f"{name}.typ"
            typ.write_text(source)
            result = subprocess.run(
                ["typst", "compile", "--root", str(ROOT), str(typ), str(typ.with_suffix(".pdf"))],
                text=True,
                capture_output=True,
            )
            assert result.returncode != 0 and expected in result.stderr, (name, result.stderr)
    print("Passed: config-safe cover/book choices, NWO key-output shapes, legal exhibit/PDF limits, contract modes, percentage/cost ranges, and boolean flags fail with field-specific diagnostics.")


if __name__ == "__main__":
    main()
