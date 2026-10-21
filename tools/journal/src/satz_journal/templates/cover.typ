#import "_satz/lib.typ": cover-page as base-cover-page
#import "config.typ": identity, journal-style

#let cover-page() = base-cover-page(
  config: (page: (paper: journal-style.paper,)),
  layout: journal-style.cover-layout,
  theme: journal-style.theme,
  title: identity.title,
  subtitle: identity.subtitle,
  author: identity.author,
  date: if identity.date == "" { none } else { identity.date },
  keywords: if identity.keywords == "" { none } else { identity.keywords },
  supervisors: if identity.supervisors.len() == 0 { none } else { identity.supervisors },
)
