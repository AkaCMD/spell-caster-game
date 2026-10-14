# Domain Docs

This repository uses a single-context layout.

## Before exploring

- Read CONTEXT.md at the repository root.
- Read relevant decisions under docs/adr/.

If these files do not exist, proceed silently. Do not flag their
absence or suggest creating them upfront. The domain-modeling skill
creates them lazily when terms or decisions are resolved.

## File structure

- CONTEXT.md: shared domain terminology.
- docs/adr/: architectural decisions.

## Vocabulary

Use the glossary's terms in issue titles, proposals, hypotheses,
and tests. Avoid synonyms the glossary explicitly excludes.

If a concept is missing, reconsider whether it fits the project's
language; note real gaps for domain-modeling.

## ADR conflicts

Explicitly identify any proposal that contradicts an existing ADR,
and explain why the decision should be reconsidered.
