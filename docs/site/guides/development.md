---
title: "Development versions and updates"
---

The published package and the development checkout serve different needs. Beginner examples on this site use the published `@preview/satz:0.1.1` package. A page marked **development** requires the source version containing that feature.

## Use a published version

```typst
#import "@preview/satz:0.1.1": report
#show: report.with()
```

The version is explicit. Changing it is a deliberate update; your document does not automatically adopt future releases. There is no `latest` import that follows repository changes.

## Try development features from source

Download or clone the Satz repository into a folder called `satz` inside your project. Then create your own `main.typ` next to that folder:

```typst
#import "satz/lib.typ": journal-entry
#show: journal-entry.with(
  title: "Trying a palette",
  date: "2026-10-21",
  theme: "soft-jade",
)

== Notes

This uses the source checkout, including its development features.
```

Compile from the project folder with `typst compile --root . main.typ`, or preview `main.typ` in your editor. Record the repository commit you use if you need to reproduce the same layout later. Source changes can change your output.

## Live local package or copied runtime?

A local package import such as `@local/satz:0.1.1` only works after you set up a local package directory. If that directory links to your checkout, edits are live. It is a local convention, not a package your colleagues can download from Universe.

The journal starter's `_satz` directory is a copied runtime. It makes a project portable, but stays at that snapshot until you update it. The development launcher provides an explicit `update-satz` command. Updating templates should be deliberate, especially for a long journal: retain a backup and review the resulting PDF.

## Where is the source for a feature?

Use [the repository](https://github.com/kylekahraman/satz) for development code and detailed technical guides. The public site keeps beginner paths separate from API design and parity audits.
