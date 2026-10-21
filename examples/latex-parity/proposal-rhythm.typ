#import "../../lib.typ": dfg-proposal, proposal-citations, dfg-publications

#show: dfg-proposal.with(
  applicant: [Example Applicant, Example University],
  project: [Reliable Measurements Across Laboratories],
)

= Starting Point
*State of the art and preliminary work*

Measurement protocols often differ between laboratories. These differences can
change the observed signal even when the underlying process remains stable.
A shared reference protocol is therefore needed to distinguish biological
variation from variation introduced by acquisition and analysis. The proposed
project will establish this reference and test its reproducibility across sites.

The preliminary work has established a calibration procedure and an analysis
pipeline. Both have been applied to independent recordings. The remaining
question is whether the same quality criteria transfer to instruments with
different noise characteristics. This question motivates the validation work.

= Objectives and work programme
== Anticipated total duration of the project
The project will run for twelve months. Acquisition and calibration will take
place during the first four months, followed by validation and dissemination.

== Objectives
The central objective is to quantify how reliably a reference protocol recovers
known changes under realistic measurement conditions. Success requires both
stable baseline measurements and sufficient sensitivity to the target change.

== Work programme incl. proposed research methods
=== Reference protocol
BASELINEONE \ BASELINETWO \ BASELINETHREE

A controlled comparison will vary acquisition settings while retaining the same
reference samples. Analysis will use pre-specified quality criteria, and the
final evaluation will use recordings held out during protocol development.

- Calibrate the instruments against shared reference samples.
- Estimate repeatability within each laboratory.
- Evaluate transfer to independent instruments and recordings.

=== Validation and dissemination
Results will be reported with uncertainty estimates and explicit failure cases.
The protocol, analysis scripts and permitted data will be archived together.

#block(breakable: false)[
#table(
  columns: (auto, auto),
  table.header([*Period*], [*Milestone*]),
  [Months 1–4], [Calibration complete],
  [Months 5–9], [Independent validation],
  [Months 10–12], [Release and documentation],
)
]
