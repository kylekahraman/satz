// Your identity and cover style live here. The rest of the journal follows
// Satz defaults and the currently bundled Satz runtime.
#let identity = (
  title: "Research Journal",
  subtitle: "Research notes and project log",
  author: "Your Name",
  date: "",
  keywords: "",
  supervisors: (),
)

#let journal-style = (
  theme: "neutral", // black and white; choose a named color palette if desired
  cover-layout: "research", // research or minimal
  paper: "a4",
)

// Optional Satz overrides. Keep this small so new Satz defaults continue to
// flow into the journal. For example: (typography: (leading: 0.75em,))
#let journal-overrides = (:)
