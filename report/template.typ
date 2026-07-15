// Report template — thin wrapper around the unified personal class.
#import "../personal.typ": personal

#let report(body, config: (:)) = {
  personal(kind: "report", config: config, body)
}
