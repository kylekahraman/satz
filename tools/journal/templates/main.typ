#import "cover.typ": cover-page
#import "setup.typ": journal-entry, journal-index

#cover-page()
#pagebreak()
#journal-index()
#pagebreak()
#set page(numbering: "1")
#counter(page).update(1)

// --- entries ---
#include "{{FIRST_ENTRY_PATH}}"
// --- end entries ---
