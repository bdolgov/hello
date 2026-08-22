# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Note that the program's observable behaviour has not changed since 1972.
Every entry below 1.1.0 records a change forced by the language evolving
underneath it; every entry from 1.1.0 onward records documentation and
infrastructure. There has never been a bug fix, because there has never been
a bug in the six lines.

---

## [Unreleased]

Nothing.

## [1.1.0] — 2026-08-22

### Added

- A three-volume treatment in the source commentary, 2,712 lines: the descent
  of the sentence from Proto-Indo-European, the descent of the machine from
  ALGOL 60, and the philosophical status of the utterance
- Documentation: `README.md`, `INSTRUCTIONS.md`, `INSTALL.md`, `UNINSTALL.md`,
  and a manual page
- A test suite, a `Makefile`, and continuous integration across three
  operating systems and five architectures

### Changed

- No functional change. The program is byte-identical to 1.0.2, which is to
  say to 1999.

## [1.0.2] — 1999

### Changed

- Added an explicit `int` return type to `main`. C99 removed implicit `int`.
- Added an explicit `return 0;`. Optional under C99, written out because
  relying on the implicit return requires the reader to know a rule most
  readers do not know.

## [1.0.1] — 1989

### Fixed

- Added `#include <stdio.h>`. C89 requires a visible prototype for a variadic
  function; calling `printf` without one had been undefined behaviour since
  the standard said so.

## [1.0.0] — 1972

### Added

- Initial release, in Brian Kernighan's *A Tutorial Introduction to the
  Language B*, Bell Laboratories.
- Prints `hello, world`. Lowercase, no exclamation point.

---

[Unreleased]: https://github.com/Daemon125/hello/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/Daemon125/hello/releases/tag/v1.1.0

Entries before 1.1.0 predate this repository and have no corresponding tag.
1.0.0 through 1.0.2 record changes the C standard forced on the program
between 1972 and 1999.
