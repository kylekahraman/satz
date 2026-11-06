#import "cover.typ": cover-page
#import "setup.typ": journal-entry, journal-index

#cover-page()
#pagebreak()
#journal-index()
#pagebreak()
#set page(numbering: "1")
#counter(page).update(1)

// Keep this line to include your journal entries.
#include "journal-entries.typ"
