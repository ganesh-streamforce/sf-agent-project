# Project Knowledge Base — Salesforce AI Agent

This file is the **source of truth** for the Claude Code agent. Read it at the start of every run and update it at the end of every successful run. Keep entries short and factual.

---

## Project Overview

- **Purpose**: SFDX project that serves as the workspace for an AI agent that performs Salesforce admin/developer work (Apex, LWC, Flows, metadata, permissions, etc.)
- **Trigger**: Jira automation flow — when a ticket is assigned to a user or AI agent, this GitHub Actions workflow runs
- **Workflow**: `.github/workflows/agent.yml` — checks out code → creates branch → authenticates to Salesforce → runs Claude Code agent → deploys → tests → commits/PRs
- **Model**: `deepseek/deepseek-v4-flash` via OpenRouter (configured in `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN` secrets)
- **Max turns**: 75 (`--max-turns 75` in agent.yml)

## Org & Auth

| Item | Value |
|------|-------|
| Auth flow | Client Credentials (OAuth 2.0) |
| Secrets | `SF_CLIENT_ID`, `SF_CLIENT_SECRET`, `SF_INSTANCE_URL` |
| Org alias | `target-org` |
| Org type | Developer Edition (treated as "production" — 75% Apex coverage enforced) |
| API version | `64.0` |
| Namespace | None (empty string) |

## Project Structure

```
force-app/          → Salesforce metadata (main source of truth — may be empty, retrieve as needed)
scripts/
  apex/             → Anonymous Apex scripts for org utilities
  soql/             → SOQL query files for reference
config/
  project-scratch-def.json  → Scratch org definition
.agents/skills/     → Salesforce skills (installed via skills-lock.json)
.claude/skills/     → Additional Claude skills
.github/
  workflows/
    agent.yml       → Main CI/CD workflow (triggered by Jira automation)
    test-connections.yml → Connection test workflow
  agent/
    AGENTS.md       ← This file (project knowledge base)
    CLAUDE.md       → Agent guardrails and environment notes
    mcp-config.json → MCP server config (Jira integration via mcp-atlassian)
```

## Key Conventions

- **No `force-app/` exists yet** — the agent must retrieve metadata from the org before making changes. Use `sf project retrieve start` to pull existing metadata.
- **Always deploy to `target-org`** before committing. Never deploy to any other alias.
- **Run local Apex tests** after deploying. If tests fail or coverage is insufficient, stop and report — do not commit.
- **Keep commits scoped to the ticket**. Do not touch unrelated files or refactor code outside scope.
- **Update this file** after each successful run (max 5 new lines under "Recent changes").
- **Jira integration**: MCP tools available via `mcp__jira__*` — use to fetch tickets, create subtasks, post comments.

## Available Tools & Skills

- **Salesforce CLI** (`sf`): deploy, retrieve, execute Apex, run SOQL, manage orgs
- **Jira MCP**: fetch tickets, search with JQL, create subtasks, post comments
- **Installed skills** (in `.agents/skills/` and `.claude/skills/`): Apex generation, LWC, Flows, Data Cloud, OmniStudio, Code Analyzer, SOQL, metadata deployment, and more — use when relevant to the ticket

## Known Gotchas

- Developer Edition orgs enforce 75% Apex code coverage on deploy (like production).
- The project may not have all metadata locally — always check the org first before assuming something doesn't exist.
- Auth uses Client Credentials flow (not JWT). Token is fetched at workflow runtime and injected as `SF_ACCESS_TOKEN`.
- The agent runs via OpenRouter, not direct Anthropic API — if tool calls behave unexpectedly, report it in the Jira comment.

## Recent Changes (Agent Log)

- *(Dated entries added automatically after each successful ticket, e.g. "2026-07-10 (PROJ-101): Added AC_ExampleController, extended layout")*
