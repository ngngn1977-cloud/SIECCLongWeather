# Contributing

1. Open an issue describing the proposed scientific or software change.
2. Do not alter frozen publication references; add a new versioned authority.
3. Add or update testthat known-answer and regression tests.
4. Run `R CMD check`, `run_demo()`, `reproduce_statistics()`,
   `validate_against_publication()`, and repository scans.
5. Never commit provider credentials, participant data, or raw IMS observations.

Method selection is closed for the publication release. Proposed future
methods belong in a separate development branch and must not silently change
the archived authority.

