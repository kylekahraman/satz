"""Stage the manifest-selected package tree and compile representative starters."""
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import tempfile
import tomllib


ROOT = Path(__file__).resolve().parents[2]
CANDIDATE_VERSION = "0.2.0"


def included(path, patterns):
    value = PurePosixPath(path).as_posix()
    for pattern in patterns:
        prefix = pattern.removesuffix("/**").rstrip("/")
        if value == pattern or value == prefix or value.startswith(prefix + "/"):
            return False
        if "/" not in pattern and PurePosixPath(value).name == pattern:
            return False
        if PurePosixPath(value).match(pattern):
            return False
    return True


def main():
    manifest = tomllib.loads((ROOT / "typst.toml").read_text())["package"]
    source_version = manifest["version"]
    version = CANDIDATE_VERSION
    patterns = manifest.get("exclude", [])
    files = subprocess.run(
        ["git", "ls-files", "-co", "--exclude-standard", "-z"],
        cwd=ROOT,
        check=True,
        capture_output=True,
    ).stdout.decode().split("\0")
    files = [path for path in files if path and included(path, patterns)]
    assert manifest["entrypoint"] in files
    assert "LICENSE" in files
    assert not any(path == "tools" or path.startswith("tools/") for path in files), "tools/** leaked into package"
    assert not any(path == "workbook-conversion" or path.startswith("workbook-conversion/") for path in files), "workbook conversion leaked into package"

    with tempfile.TemporaryDirectory(prefix="satz-staged-package-") as directory:
        stage = Path(directory)
        packages = stage / "packages"
        package_dir = packages / "local" / manifest["name"] / version
        for relative in files:
            source = ROOT / relative
            if source.is_file():
                destination = package_dir / relative
                destination.parent.mkdir(parents=True, exist_ok=True)
                if relative == "typst.toml":
                    package_manifest = source.read_text().replace(
                        f'version = "{source_version}"',
                        f'version = "{version}"',
                        1,
                    )
                    destination.write_text(package_manifest)
                else:
                    shutil.copy2(source, destination)

        project = stage / "project"
        project.mkdir()
        starters = {
            "report": f'''#import "@local/{manifest['name']}:{version}": report
#show: report.with()
= Release candidate
Report body.
''',
            "article": f'''#import "@local/{manifest['name']}:{version}": article
#show: article.with(title: [Candidate article])
= Methods
Article body.
''',
            "journal": f'''#import "@local/{manifest['name']}:{version}": journal-entry, journal-index
#journal-index()
#journal-entry(title: "Candidate entry", date: "2026-10-22")[Journal body]
''',
            "letter": f'''#import "@local/{manifest['name']}:{version}": letter
#show: letter.with(sender: (name: "Sender", street: "One Street", postal-code-city: "City"), recipient: (name: "Recipient", street: "Two Street", postal-code-city: "City"))
Letter body.
''',
            "invoice": f'''#import "@local/{manifest['name']}:{version}": invoice
#show: invoice.with(items: ((description: "Work", quantity: 1, unit-price: 10),), qr: false)
Invoice body.
''',
            "cover": f'''#import "@local/{manifest['name']}:{version}": cover-page
#cover-page(layout: "minimal", title: "Candidate cover")
''',
            "proposal": f'''#import "@local/{manifest['name']}:{version}": research-proposal
#show: research-proposal.with(title: "Candidate proposal", applicants: ("Researcher",), institution: ("Institute",))
= Aims
Proposal body.
''',
        }
        for name, source in starters.items():
            path = project / f"{name}.typ"
            path.write_text(source)
            output = stage / f"{name}.pdf"
            result = subprocess.run(
                ["typst", "compile", "--package-path", str(packages), "--root", str(project), str(path), str(output)],
                text=True,
                capture_output=True,
            )
            assert result.returncode == 0, f"{name} starter failed from staged package:\n{result.stderr}"

    print(f"Passed: staged {len(files)} files from source manifest {source_version} as isolated Satz {version}; report, article, journal, letter, invoice, cover, and proposal starters compile.")


if __name__ == "__main__":
    main()
