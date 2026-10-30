---
name: iterative-refine
description: Repeat an independent consistency/integrity audit of a code change, a branch or a whole codebase, fix what it finds, and repeat until a fresh auditor reports "nothing to fix". Use it when the user asks to "review until clean", "audit until nothing is left", check that docs, comments, config, tests and scripts were updated together with the code, run an integrity sweep, harden a PR before merge, or "repeat the review loop", even when they don't say "audit". Also use it after finishing any non-trivial change that touches behavior described elsewhere (docs, prompts, config defaults, tests), before opening the PR.
---

# Iterative refine

One reviewer, reading once, misses what they assumed. This skill turns review into a loop with a hard
exit condition: an **independent auditor** reads the change cold, you **verify and fix** what it finds,
and a **new** auditor reads the result again. The loop ends only when an auditor that did not see the
earlier rounds answers with the exact sentinel `NOTHING TO FIX` (or the user's chosen sentinel, e.g.
"수정할 것 없음").

The three jobs share the same loop (§2); they differ in what the auditor reads:

| The user wants to… | Scope given to the auditor |
|---|---|
| harden one change or PR before merge | the branch diff against its base (§3) |
| check that one feature was propagated everywhere | the diff plus a list of "places that must agree" (§3) |
| raise the integrity of a whole codebase | one area per round, then the whole tree (§4) |

Supporting files, read when the step calls for them:
- `references/audit-brief.md`: the auditor prompt template and the checklist of drift categories. **Read it before the first round.**
- `references/triage.md`: how to verify, classify, fix and record findings; when to ask the user; how to stop.
- `PROJECT_RULES.md` at the repository root, when it exists: invariants the auditor must check in this project (defaults that must match, guard tests that must not weaken, prompt language, generated files, artifact compatibility). `templates/PROJECT_RULES.md` is a starting point; offer to create one when the session has established such rules. Read the project's own `CLAUDE.md`/`README`/design docs too, and pass their paths to the auditor.

## 1. Ground rules

- **The auditor gets the code, not your conclusion.** Brief it with the intent of the change and where to look, never with "I think X is fine". An auditor handed your hypothesis tends to confirm it.
- **A fresh auditor every round.** Do not continue the previous auditor's conversation. Its context is anchored on the earlier version.
- **Read-only auditors.** They must not edit, commit or push. You own every change.
- **Verify every finding before acting.** Open the cited file:line and reproduce the reasoning. Auditor findings arrive in the same confident tone whether right or wrong. Drop what you cannot confirm and say so.
- **Every round audits the whole change, not only the last fix.** Fixes create new drift (a renamed term in one place, a doc sentence that is now false).
- **Fixes keep the guards.** Never weaken a test, a validation or a safety check to make a finding go away. If a guard blocks the fix, the fix is wrong.
- **Tests before and after.** Run the full suite before the first audit and after each round of fixes. A new test must fail on the old code; check it, or say it was not checked.
- **Report honestly.** State how many rounds ran, what each found, what was fixed, what was dropped and why, and which checks were not run.
- **Don't merge, push to protected branches or publish without the user's approval.** The loop prepares a change; it does not ship it.

## 2. The loop

```
0. baseline   full test suite green; branch committed; scope written down
1. audit      spawn a fresh read-only auditor with the brief (references/audit-brief.md)
2. verify     check each finding against the code; classify (references/triage.md)
3. fix        apply confirmed fixes, smallest change first; add or strengthen tests
4. test       full suite; targeted tests for each fix
5. commit     one commit per round: "integrity round N: <what>"
6. repeat     back to 1 with a NEW auditor, same scope (whole change), until it returns the sentinel
7. finish     final full test run; summary of rounds; PR (evidence in the PR body); wait for approval
```

- **Exit:** the auditor's whole answer is the sentinel. A report that says "minor nits only" is not the sentinel. Decide on each nit (fix, or record why not) and audit again.
- **Budget:** stop after 5 rounds without the sentinel and report what keeps coming back. Recurring findings usually mean the design is unclear, not that the text is.
- **Parallel work:** while an auditor runs, don't edit the files it is reading. Do unrelated work, or wait.
- **Progress:** keep a visible checklist (task list) of rounds and their outcomes, and tell the user at each round boundary what was found and fixed.

## 3. Auditing a change or a PR

1. Write the **intent** in 3–8 bullets: what changed, why, and which behavior is now different. Include decisions already made with the user, so the auditor does not relitigate them.
2. List the **places that must agree** with the change. Typical ones are code paths and their callers, docstrings and comments, user docs and design docs, config files and their defaults in code, prompts or templates, tests (including fixtures and fakes), scripts and tools, generated files, changelogs. `references/audit-brief.md` has the full list.
3. Give the auditor the diff command (`git diff <base>...HEAD`), the rule files to read, the ignore list (build output, data, vendored code), and the checklist.
4. Ask for findings as `file:line — what is wrong — suggested fix`, verified by reading code, speculative ones dropped, and the sentinel when nothing remains.

## 4. Codebase-wide integrity sweep

A whole tree is too big for one cold read. Split it.

1. **Round A, by area.** One auditor per area (for example: config and defaults; prompts and their tests; docs vs. behavior; dead code and unused settings; error handling and fallbacks). Run them in parallel only if the user agreed to the cost. Otherwise run them one after another.
2. Fix the confirmed findings area by area, one commit per area.
3. **Round B, whole tree.** One fresh auditor over everything, with the drift checklist. Repeat until the sentinel.
4. Keep decisions that change behavior (removing a config key, changing a default) as separate, clearly named commits, and list them for the user. They are not "cleanup".

## 5. Deliverables

- The commits, one per round, with messages that say what drift was fixed.
- A short round log (see `references/triage.md`): round, findings, fixed, dropped (with reason).
- The PR description: intent, evidence that motivated the change, what the audit rounds fixed, tests run, and what was **not** checked.
- Anything that needs the user's decision, listed separately from what you fixed.
