"""Check palette propagation and explicit overrides through public journal APIs."""
from pathlib import Path
import subprocess
import tempfile
import pdfplumber

ROOT = Path(__file__).resolve().parents[2]


def main():
    with tempfile.TemporaryDirectory(prefix='satz-journal-themes-', dir=ROOT) as directory:
        output = Path(directory)
        def compile_doc(name, source, error=None):
            path = output / (name + '.typ')
            path.write_text(source)
            p = subprocess.run(['typst', 'compile', '--root', str(ROOT), str(path), str(path.with_suffix('.pdf'))], capture_output=True, text=True)
            if error:
                assert p.returncode and error in p.stderr, p.stderr
                return
            assert p.returncode == 0 and not p.stderr.strip(), p.stderr
            return path.with_suffix('.pdf')
        themes = ['neutral', 'soft-jade', 'soft-slate', 'warm-editorial', 'plum', 'soft-rose']
        colors = []
        for name in themes:
            source = f'''#import "/lib.typ": journal-entry, journal-index, theme-config, document-themes
#assert(theme-config(none, config: (typography: (size: 13pt),)) == (typography: (size: 13pt),))
#assert(theme-config("{name}", config: (colors: (brand-primary: red),)).colors.brand-primary == red)
#assert(theme-config("{name}").colors.brand-primary == document-themes.at("{name}").brand-primary)
#journal-index(theme: "{name}")
#pagebreak()
#journal-entry(title: "ENTRYTITLE", date: "DATE", theme: "{name}")[
  == SECTION
  BODYTEXT
]
'''
            with pdfplumber.open(compile_doc(name, source)) as pdf:
                text = '\n'.join(p.extract_text() for p in pdf.pages)
                assert 'ENTRYTITLE' in text and 'BODYTEXT' in text and 'Index' in text
                section = next(m for p in pdf.pages for m in p.search('SECTION', regex=False))
                color = tuple(section['chars'][0]['non_stroking_color'])
                colors.append(color)
        assert len(set(colors)) == len(themes), colors
        source = '#import "/lib.typ": journal-entry\n#show: journal-entry.with(theme: "soft-jade", config: (colors: (brand-primary: rgb("ff0000")),))\n== OVERRIDE\nBody'
        with pdfplumber.open(compile_doc('override', source)) as pdf:
            char = pdf.pages[0].search('OVERRIDE', regex=False)[0]['chars'][0]
            assert tuple(char['non_stroking_color']) == (1, 0, 0)
        compile_doc('unknown', source.replace('soft-jade', 'unknown'), error='Unknown document theme')
    print('Passed: six journal/index palettes, public reusable theme config, none compatibility, explicit nested overrides and unknown-theme errors.')


if __name__ == '__main__':
    main()
