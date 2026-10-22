"""Exercise article columns, spanning front matter, figures, and numbering."""

from pathlib import Path
import subprocess

import pymupdf as fitz

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = Path(__file__).resolve().parent / "output"


def compile_source(name, source):
    path = OUTPUT / f"{name}.typ"
    path.write_text(source)
    subprocess.run(["typst", "compile", "--root", str(ROOT), str(path), str(path.with_suffix('.pdf'))], check=True)
    return path.with_suffix('.pdf')


def main():
    OUTPUT.mkdir(exist_ok=True)
    example = (ROOT / "examples/article.typ").read_text().replace('"../lib.typ"', '"/lib.typ"')
    with fitz.open(compile_source("article", example)) as document:
        assert len(document) == 2
        rectangles = [drawing['rect'] for page in document for drawing in page.get_drawings()
                      if drawing.get('dashes') and drawing['dashes'] != '[] 0']
        widths = sorted(rect.width for rect in rectangles)
        available = document[0].rect.width - 2 * 25 / 25.4 * 72
        assert len(widths) == 2
        assert abs(widths[0] - (available - 5 / 25.4 * 72) / 2) < .1
        assert abs(widths[1] - available) < .1
        text = ' '.join(' '.join(page.get_text().split()) for page in document)
        assert 'An example footnote in the article.' in text
        assert 'Figure 1 and Figure 2' in text
        assert 'Contents' not in text
        assert document[0].search_for('Abstract')[0].x0 < document[0].rect.width / 2
        for index, page in enumerate(document):
            footer = page.get_text(clip=fitz.Rect(0, page.rect.height - 60, page.rect.width, page.rect.height)).strip()
            assert footer == str(index + 1), footer
        assert document[0].search_for('Example Author')
        assert document[0].search_for('Example Research Institute')

    base = '#import "/lib.typ": article\n#show: article.with(title: [SHORTTITLE], config: (page: (columns: 1), toc: (depth: 2)))\n= FIRSTHEADING\nBODYMARKER\n'
    with fitz.open(compile_source('article-single', base)) as document:
        assert len(document) == 1
        assert 'Contents' in document[0].get_text()
        assert document[0].search_for('BODYMARKER')[0].x0 < 80
        assert document[0].search_for('SHORTTITLE')[0].y0 < document[0].search_for('Contents')[0].y0

    # A two-column report keeps its generated contents page full-width.
    source = '#import "/lib.typ": report\n#show: report.with(config: (page: (columns: 2)))\n'
    source += '= A deliberately long chapter heading to measure the width of the contents page\n#lorem(600)\n'
    with fitz.open(compile_source('report-columns', source)) as document:
        assert len(document) >= 2
        heading = document[0].search_for('A deliberately long chapter heading to measure the width of the contents page')
        assert heading and heading[0].width > 300
        assert 'Contents' in document[0].get_text()
        # The body actually flows into the right-hand column.
        words = document[1].get_text('words')
        assert any(word[0] > 300 for word in words)

    invalid = OUTPUT / 'article-invalid.typ'
    invalid.write_text('#import "/lib.typ": article\n#show: article.with(authors: ((name: "Example", affiliations: (2,)),), affiliations: ("Institute",))\nBody')
    result = subprocess.run(['typst', 'compile', '--root', str(ROOT), str(invalid), str(invalid.with_suffix('.pdf'))], text=True, capture_output=True)
    assert result.returncode != 0 and 'Author affiliation indices' in result.stderr
    invalid_records = [
        ('author-shape', 'authors: ("Example",)', 'must be a dictionary with a name field'),
        ('author-name', 'authors: ((affiliations: ()),)', 'must have a string or content `name`'),
        ('author-affiliations', 'authors: ((name: "Example", affiliations: "1"),)', 'must be an array of one-based affiliation indices'),
        ('affiliation-shape', 'affiliations: (1,)', 'must be a string or content'),
    ]
    for name, arguments, message in invalid_records:
        path = OUTPUT / f'article-{name}.typ'
        path.write_text(f'#import "/lib.typ": article\n#show: article.with({arguments})\nBody')
        result = subprocess.run(['typst', 'compile', '--root', str(ROOT), str(path), str(path.with_suffix('.pdf'))], text=True, capture_output=True)
        assert result.returncode != 0 and message in result.stderr, result.stderr
    print('Passed: article column widths, spanning title/figures, footnote, references, numbering, single-column/outline options, report contents, and author/affiliation validation.')


if __name__ == '__main__':
    main()
