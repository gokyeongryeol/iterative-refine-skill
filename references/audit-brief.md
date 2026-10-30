# Auditor brief and drift checklist

## 1. Brief template

Fill the angle brackets. Keep it self-contained: the auditor knows nothing except what you write.

```
You are auditing <a branch | a commit | the codebase> in <absolute path>
(<branch name>: commits <shas> on top of <base sha>).
Read-only: do NOT edit files, commit, push, or change any state.

Project rules: read <CLAUDE.md, README, design doc, PROJECT_RULES.md>.
Key invariants: <e.g. config file equals code defaults; prompts English only;
guard tests must not weaken; no run-specific numbers in docs>.

See the change with: git -C <path> diff <base>...HEAD

Intent of the change:
- <what changed and why, 3-8 bullets>
- <decisions already made with the user — do not relitigate>
<If this is round N>: earlier rounds fixed <one line each>.

Task: an independent consistency/integrity audit of the whole change.
Find places that should have changed correspondingly but did not, or that are
now false or inconsistent, in: <code paths, docs, comments, config, prompts,
tests, scripts>. Check in particular:
- <the 3-6 riskiest consequences of this change, as concrete questions>
- tests that pass vacuously or miss an important branch
Ignore: <build output, data, vendored code, other teams' directories>.

Report concrete findings, each as: file:line — what is wrong — suggested fix.
Verify each by reading the code; drop speculative or purely cosmetic ones.
If nothing needs fixing, answer exactly: NOTHING TO FIX
Answer in <language>.
```

Write the "check in particular" questions yourself. They are where the auditor spends its effort.
Good questions name a mechanism ("does resume restore the counters before the new stop rule is
checked?"), not a topic ("check resume").

## 2. Drift checklist

What a change usually forgets to update. Give the auditor the rows that apply.

| Category | Look for |
|---|---|
| Callers and siblings | Other call sites, parallel branches of the same logic (a fix in one branch that the twin branch lacks), replay/resume paths, fallbacks |
| Defaults | Config files vs. defaults in code; validation ranges; documented defaults |
| Removed things | Leftover keys, flags, enum values, branches, docs sentences, test fakes that still mention the removed thing |
| Renamed things | Old names in docs, logs, prompts, tests, scripts; mixed terms for the same idea ("measured" vs. "tried") |
| Docs vs. behavior | Statements that are now false (a stop condition, a resume step, a cost), examples that no longer run, anchors and links |
| Prompts and templates | Placeholders filled at every format call; rules that now contradict each other; wording that names options the user disabled |
| Tests | New behavior pinned; old behavior no longer asserted; tests that pass on the old code too (vacuous); fakes that encode the old contract |
| Records and artifacts | Field names and meanings in logs, histories and reports; compatibility with existing artifacts; readers in other tools |
| Error paths | What happens on empty input, failure, timeout, resume; whether a fallback still terminates |
| Cost and safety | New loops that can run forever; limits that still bound them; secrets, data leakage, permissions |
| Numbers in prose | Run-specific measurements that belong in the PR body, not in docs or comments |

## 3. Reading the answer

- A finding without file:line is a lead, not a finding. Locate it yourself or drop it.
- "Consider…" and "might" findings are usually cosmetic. Fix them only if they are cheap and make the
  change clearer, and say which ones you skipped.
- An auditor that disagrees with a decision the user made is not a finding. Note it for the user if
  the argument is new.
