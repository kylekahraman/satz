---
title: "Development versions and updates"
---

The tutorials on this site target Satz 0.2.0 so you can test the release candidate. They import `@local/satz:0.2.0` and compile against a local checkout. Follow [Set up the local 0.2.0 package](/satz/getting-started/setup/) before copying an example.

## After the 0.2.0 release

```typst
#import "@preview/satz:0.2.0": report
#show: report.with()
```

Once the package is available from Typst Universe, replace `@local` with `@preview` in the tutorial imports. Keeping the version explicit means future releases will not silently change your document.

## Import directly from the repository

If you do not want to set up a local Typst package directory, clone the Satz repository into a folder called `satz` inside your document project. Import the checked-out implementation directly:

```typst
#import "satz/lib.typ": letter
#show: letter.with(sender: (name: "Alex Example", street: "One Street", postal-code-city: "12345 City"))
Hello,

This uses the Satz source checkout in the neighboring folder.

== Notes

This uses the 0.2.0 source checkout.
```

Compile from the project folder with `typst compile --root . main.typ`, or preview `main.typ` in your editor. Record the repository commit you use if you need to reproduce the same layout later. Source changes can change your output.

## Live local package or copied runtime?

The `@local` namespace is a Typst convention for packages available on your computer. It is not a package your colleagues can download from Universe. Use the `@preview` namespace after the release is published.

The journal starter's `_satz` directory is a copied runtime. It makes a project portable, but stays at that snapshot until you update it. The development launcher provides an explicit `update-satz` command. Updating templates should be deliberate, especially for a long journal: retain a backup and review the resulting PDF.

## Where is the source for a feature?

Use [the repository](https://github.com/kylekahraman/satz) for development code and detailed technical guides. The public site keeps beginner paths separate from API design and parity audits.
