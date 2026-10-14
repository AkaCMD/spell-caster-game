# Issue tracker: GitHub

Issues and specs live in GitHub Issues for AkaCMD/spell-caster-game.
Use the gh CLI from this repo; infer the repository from git remote -v.

## Conventions

- Create: gh issue create --title "..." --body-file <file>
- Read: gh issue view <number> --comments; fetch labels when relevant.
- List: gh issue list with appropriate state and label filters.
- Comment: gh issue comment <number> --body-file <file>
- Labels: gh issue edit <number> --add-label "..." or --remove-label "..."
- Close: gh issue close <number> --comment "..."

Use a temporary UTF-8 file for multiline issue bodies and comments.

When a skill says "publish to the issue tracker", create a GitHub issue.
When it says "fetch the relevant ticket", read the issue and its comments.

## Pull requests as a triage surface

PRs as a request surface: no.

## Wayfinding operations

- Map: one issue labelled wayfinder:map containing Notes,
  Decisions-so-far, and Fog.
- Children: link tickets as GitHub sub-issues. If unavailable, use a
  task list in the map and "Part of #<map>" in each child.
- Types: wayfinder:research, wayfinder:prototype,
  wayfinder:grilling, and wayfinder:task.
- Blocking: use native GitHub issue dependencies with the blocker's
  numeric database ID. If unavailable, record "Blocked by: #<number>"
  in the child. All blockers must be closed before work starts.
- Frontier: choose the first open, unassigned, unblocked child in map order.
- Claim: assign the ticket to @me.
- Resolve: comment with the answer, close the ticket, and append a
  summary and link to the map's Decisions-so-far.
