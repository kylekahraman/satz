#import "../../lib.typ": document-class
#show: document-class.with(kind: "proposal", config: (
 typography: (font: "Arial"), toc: (depth: 0),
 colors: (bg-paper: white, brand-primary: black),
))
// Isolate heading rhythm from the engines' different page-top baselines.
#v(30pt)
BODYBEGIN

= LEVELONE
BODYONE

== LEVELTWO
BODYTWO

=== LEVELTHREE
BODYTHREE

= STACKONE
== STACKTWO
STACKBODY
