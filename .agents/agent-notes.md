# Agent notes

A running log of the maintainer's corrections and standing always/never directives for this repo.

- **Read this file at the start of every session, before doing any work.**
- **Append proactively, without being asked:** whenever the maintainer corrects you or gives an always/never instruction, add one line here.
- One line per entry. Newest lines at the bottom.
- When a directive supersedes an earlier one, update or remove the stale line rather than leaving both.

Project facts that aren't directives (decisions, constraints, gotchas) go in `.agents/memory/` instead; see `.agents/memory/MEMORY.md`.

---

- 2026-11-24: Always use typed throws (`throws(SomeError)`) for every throwing function; the only exception is a protocol witness whose body must call untyped-throwing APIs (e.g. `Codable`'s `init(from:)`/`encode(to:)`).
- 2026-11-24: Never add an Xcode project, XcodeGen `project.yml` or `make xcode` target; the package is opened via `Package.swift`.
