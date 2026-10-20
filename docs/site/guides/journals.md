# Research journals

Use `journal-entry` for a dated entry with a title and optional keywords. A single Typst file can contain one entry or a collection of entries.

```typst
#import "@preview/satz:0.1.1": journal-entry

#show: journal-entry.with(
  title: "Experiment 42",
  date: "2026-10-20",
  keywords: "MEG, preprocessing, review",
)

## Question

What changed in this run?

## Notes

- [ ] Check the sensor layout.
- [x] Save the analysis contract.
```

Journal entries use shared settings for typography and page layout. Use `journal-index()` to generate an index from entries carrying Satz's journal metadata. See the [journal examples](https://github.com/kylekahraman/satz/tree/main/examples).

For a new journal, decide whether you want one file per entry or a single document with many entries. Keep private notes and research data out of public repositories unless you intend to publish them.
