# iterative-refine: a Claude Code skill for audit-until-clean review loops

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that hardens a change by
repeating an independent consistency audit until a fresh auditor finds nothing left to fix. It is
language- and project-agnostic.

Each round, a new read-only subagent reads the change cold, with a brief that states the intent and
where to look but not your conclusions. You verify every finding against the code, fix the confirmed
ones with tests, commit the round, and audit the whole change again. The loop ends only when an auditor
answers with the exact sentinel `NOTHING TO FIX`.

## What it does

| You ask for | The skill |
|---|---|
| "Review this PR until it's clean" | Audits the branch diff, fixes, re-audits with a fresh auditor until the sentinel |
| "Did I update docs/config/tests everywhere?" | Gives the auditor a list of places that must agree with the change, plus a drift checklist |
| "Raise the integrity of the codebase" | Audits area by area, fixes per area, then re-audits the whole tree until the sentinel |

It reports each round (found, fixed, dropped with reason, asked), keeps one commit per round, and never
merges or pushes to protected branches without your approval.

## Install

Requirements: Claude Code with subagents (the Agent tool), and git.

```bash
git clone <this repository> iterative-refine-skill
cd iterative-refine-skill
./install.sh                 # user level: available in every project
# or
./install.sh /path/to/repo   # project level: only inside that repository
```

`install.sh` symlinks the clone into `~/.claude/skills/iterative-refine` (or
`<repo>/.claude/skills/iterative-refine`), so `git pull` updates the skill in place. Restart Claude
Code and type `/iterative-refine`. Claude Code also picks the skill automatically when you ask it to
review until clean or to check that a change was propagated everywhere.

## Customize

- **Per-project rules:** copy `templates/PROJECT_RULES.md` to the repository root and fill in the test
  command, invariants (config defaults that must match, guard tests, prompt language, artifact
  compatibility), places that must agree, and what to ignore. The skill passes them to every auditor.
- **Sentinel and language:** say which sentinel you want (for example "수정할 것 없음") and in which
  language the auditor should answer.
- **Round budget:** the default stop is 5 rounds without the sentinel. Change it in `SKILL.md`.

## Layout

```
SKILL.md                     entry point: ground rules, the loop, change audit, codebase sweep
references/audit-brief.md    auditor prompt template and drift checklist
references/triage.md         verify, classify, fix, record, stop
templates/PROJECT_RULES.md   per-project invariants template
install.sh                   symlink installer
```

## Principles

- The auditor gets the code, not your conclusion; a fresh auditor every round.
- Every finding is verified before it is fixed; unconfirmed findings are dropped and reported.
- Fixes never weaken guard tests; new tests must fail on the old code.
- Every check that was not run is reported as not run.

## License

MIT. See [LICENSE](LICENSE).
