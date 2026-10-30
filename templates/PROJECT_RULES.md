# Project rules for integrity audits

Copy this file to the repository root and fill it in. The iterative-refine skill reads it before each
audit and passes the invariants to the auditor. Keep only rules that are true for this project.

## Read first
- <CLAUDE.md, README.md, docs/design.md, ...>

## Test command
- `<command that runs the full suite>`
- Known flaky tests to exclude, with the reason: <test id — reason>

## Invariants the auditor must check
- Config defaults: <config file> must equal the defaults in <code location>.
- Guard tests that must never weaken: <list>.
- Language rules: <e.g. LLM prompts English only; user-facing reports in Korean>.
- Layering / import rules: <e.g. enforced by tests/test_architecture.py>.
- Artifact compatibility: <files and field names that existing outputs depend on>.
- Docs: <e.g. no run-specific measurements in docs or comments; evidence goes in PR bodies>.

## Places that must agree
- <behavior> ↔ <doc section> ↔ <prompt text> ↔ <test file>

## Ignore during audits
- <build output, data directories, vendored code, other teams' directories>

## Commit and PR conventions
- <branch naming; one commit per round; who approves merges; PR body sections>
