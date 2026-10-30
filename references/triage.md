# Triage: verify, classify, fix, record, stop

## 1. Verify

For each finding:
1. Open the cited file:line. Read enough around it to understand the logic, not just the line.
2. Reproduce the claim: trace the call, run the snippet, or write the failing test.
3. Decide: **confirmed**, **partly right** (the symptom is real but the cause or fix differs), or
   **not reproducible** (drop it, with one line why).

Don't fix what you could not confirm. Don't argue with what you could confirm.

## 2. Classify

| Class | Meaning | Action |
|---|---|---|
| Bug | Behavior is wrong or a path fails | Fix with a test that fails before the fix |
| False statement | Docs, comment, prompt or log says something the code does not do | Fix the text (or the code, if the text is the intent) |
| Drift | Two places that must agree don't (defaults, names, terms) | Make them agree; prefer one source of truth |
| Test gap | A changed branch is not pinned, or a test passes vacuously | Add or strengthen the test; check it fails on the old code |
| Decision | Fixing it changes behavior the user may care about | Ask the user with options; don't decide silently |
| Cosmetic | Wording or style with no effect on correctness | Fix if cheap, else record as skipped |

## 3. Fix

- Smallest change that removes the finding. No refactors inside an integrity round.
- When a finding offers options, pick the one that keeps a single source of truth and the smaller
  surface. If both change behavior, ask the user.
- Fix the root, then search for siblings. One stale term usually has three more copies. Search for it
  everywhere, including tests and docs.
- Edit scripted replacements safely: assert the old text occurs exactly once before replacing.
- After fixing, run the targeted tests, then the full suite.

## 4. Record

Keep a round log (in the scratchpad, the PR body, or the reply):

```
Round N (<auditor scope>): <k> findings
  fixed    <file:line> <one line>            [bug|false|drift|test|cosmetic]
  dropped  <file:line> <one line> — <why>
  asked    <decision> — <options given to the user>
  commit   <sha> "<message>"
```

## 5. Stop

- **Done:** a fresh auditor returns the sentinel and the full suite passes. Say so plainly.
- **Not converging:** 5 rounds without the sentinel, or the same kind of finding returns twice after a
  fix. Stop and report the pattern. It usually points at an unclear design, a missing single source of
  truth, or a test fake that encodes an old contract.
- **Blocked:** a guard test or an invariant prevents the fix. Report it; don't weaken the guard.
