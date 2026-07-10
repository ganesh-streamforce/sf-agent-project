# Project knowledge base

This file is read by the agent at the start of every run (via the
`@AGENTS.md` import in CLAUDE.md) and updated by the agent at the end of
every successful run. Keep entries short and factual — this is a
reference, not a changelog of everything that ever happened.

## Org structure

- Auth: Client Credentials flow (Consumer Key/Secret + instance URL)
- Target org: Developer Edition (used directly as target-org for now)
- Integration user: (fill in once created — e.g. agent-sf-user)
- Namespace: (fill in if applicable)
- Key custom objects: (fill in as they're touched)

## Conventions

- (to be filled in as the agent establishes/discovers patterns — e.g.
  Apex naming prefixes, test class conventions, flow naming)

## Known gotchas

- Developer Edition orgs are treated as "production" by Salesforce's
  deploy tooling — the standard 75% Apex code coverage requirement is
  enforced on deploy here, unlike a true sandbox or scratch org.

## Recent changes (agent log)

- (dated entries added automatically after each successful ticket, e.g.
  "2026-07-10 (PROJ-101): Added AC_ExampleController, extended layout")
