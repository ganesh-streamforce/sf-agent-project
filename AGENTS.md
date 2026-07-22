# Project Knowledge Base — Salesforce AI Agent

> **Purpose**: This is the **source of truth** for the agent. Read it at the start of every run and update it at the end of every successful run. Keep entries short and factual — every token is precious.

---

## 1. Project Identity

| Attribute | Value |
|-----------|-------|
| **Purpose** | SFDX project for Salesforce admin/developer automation (Apex, LWC, Flows, metadata, permissions, configuration) |
| **Trigger** | Jira ticket assigned → GitHub Actions workflow runs |
| **Workflow** | `.github/workflows/agent.yml` — checkout → branch → auth → run agent → deploy → test → commit/PR |
| **Model** | `deepseek/deepseek-v4-flash` via OpenRouter (`ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN` secrets) |
| **Max turns** | 75 (`--max-turns 75` in agent.yml) |

## 2. Org & Auth

| Item | Value |
|------|-------|
| Auth flow | Client Credentials (OAuth 2.0) |
| Secrets | `SF_CLIENT_ID`, `SF_CLIENT_SECRET`, `SF_INSTANCE_URL` |
| Org alias | `target-org` |
| Org type | Developer Edition (treated as "production" — 75% Apex coverage enforced) |
| API version | `64.0` |
| Namespace | None (empty string) |

## 3. Project Structure — Signal Map

> This section tells you what each part of the file tree *means*, so you can navigate by intent.

```
force-app/          → Authoritative metadata source. May be empty — retrieve from org first.
scripts/
  apex/             → Anonymous Apex scripts for one-shot org utilities (e.g., data cleanup, migrations)
  soql/             → SOQL reference queries (read-only, for inspection)
config/
  project-scratch-def.json  → Scratch org definition (dev/test only)
.agents/skills/     → Salesforce skills (from skills-lock.json)
.claude/
  skills/           → Additional Claude skills
.github/
  workflows/
    agent.yml       → Main CI/CD pipeline (triggered by Jira automation)
    test-connections.yml → Connection health check workflow
.notes/
  README.md         → Agent memory system docs (read this first)
  current.md        → Last run context (read at start, update during run)
  archive/          → Historical run notes (one per completed ticket)
AGENTS.md           ← This file (project knowledge base)
CLAUDE.md           → Agent instructions (always loaded into context at start)
.mcp.json           → MCP server configuration (Jira, etc.)
```

## 4. Canonical Workflow — What "Done" Looks Like

> Follow this exact sequence for every ticket. Deviate only when the ticket explicitly requires it.

```
1. READ TICKET — Fetch the Jira issue. Understand scope, objects, and acceptance criteria.
2. RETRIEVE — If force-app/ is empty or missing relevant metadata, run `sf project retrieve start` to pull from target-org.
3. IMPLEMENT — Make changes scoped strictly to the ticket. No refactoring, no unrelated files.
4. DEPLOY — `sf project deploy start` to target-org. Fix any deployment errors.
5. TEST — Run Apex tests. If any fail or coverage < 75%, STOP. Do not commit.
6. LOG — Add a dated entry to AGENTS.md §9 "Recent Changes".
7. COMMENT — Post a Jira summary: what was done, test results, PR link.
8. COMMIT — Commit code + AGENTS.md update. Push branch. Open PR.
```

## 5. Key Heuristics

> Use these guiding principles when the rules don't cover a specific situation.

- **Org-first, not assumption-first**: This project may not have all metadata locally. Always check the org via `sf project retrieve start` before concluding something doesn't exist.
- **Scoped commits**: Each commit should contain exactly one logical change. If the ticket requires 3 things, make 3 commits + 1 AGENTS.md update.
- **Test before trust**: Developer Edition enforces 75% coverage like production. Run tests after every deploy. If they fail, stop and report — never commit broken tests.
- **Jira subtasks → one per deliverable**: Create one subtask per distinct deliverable (e.g., "Create Apex class", "Configure permission set", "Update layout"). This keeps the PR reviewable.
- **When in doubt, don't commit**: If validation fails or you're uncertain about a change's safety, post a Jira comment explaining the failure instead.

## 7. Available Tools

- **Salesforce CLI** (`sf`): deploy, retrieve, execute Apex, run SOQL, manage orgs
- **Jira MCP** (`mcp__jira__*`): fetch tickets, search with JQL, create subtasks, post comments
- **Skills** (`.agents/skills/` + `.claude/skills/`): Apex, LWC, Flows, Data Cloud, OmniStudio, Code Analyzer, SOQL, metadata deployment — use when relevant to the ticket

## 8. Known Pitfalls

- Developer Edition: 75% Apex coverage required on deploy (same as production).
- Auth: Client Credentials flow (not JWT). Token injected at runtime as `SF_ACCESS_TOKEN`.
- Model: OpenRouter — not direct Anthropic API. Tool calls may behave unexpectedly (malformed commands, silent skips, early stops). If that happens, report it in the Jira comment.
- No `force-app/` yet: first deploy will fail unless you retrieve metadata first.

## 9. Recent Changes (Agent Log)

> Add one line per successful ticket. Format: `YYYY-MM-DD (PROJ-###): Brief description of what was done`

- *(2026-07-22): Updated context files per Anthropic context engineering best practices)*
- (2026-07-22): AOI-142 — Created Client/Prospect/Competitor Account layouts with per-record-type profile assignments and record type visibility; Customer_Type__c picklist already existed; Account Type dependent picklist values already configured in record types; deployed and tested (37/37 passing)
