@AGENTS.md

## Claude-specific guardrails

- Never deploy to any org alias other than "target-org".
- Never modify files outside `force-app/`.
- Before committing anything, deploy to "target-org" and run local Apex
  tests. If any test fails, or code coverage is insufficient, stop and
  report the failure — do not commit or push.
- Keep commits scoped to the ticket. Do not touch unrelated files, and do
  not "clean up" or refactor code that isn't part of this ticket's scope.
- When creating subtasks in Jira, keep them small and specific — one
  subtask per distinct deliverable (e.g. one for the Apex class, one for
  the permission set, not one giant subtask for everything).
- After a successful run, update AGENTS.md with anything a future run
  would benefit from knowing (new conventions, gotchas hit, objects or
  fields touched). Add at most 5 new lines total. Do not restate anything
  already documented there.
- Always end a run by posting a comment on the Jira ticket summarizing
  what was done, the test results, and a link to the PR if one was opened.
- If you are unsure whether a change is safe (e.g. it looks like it could
  affect data not scoped to this ticket, or requires a permission the
  integration user doesn't have), stop and report rather than guessing.

## Current environment notes

- Salesforce auth uses the Client Credentials flow (`SF_CLIENT_ID` +
  `SF_CLIENT_SECRET` + `SF_INSTANCE_URL`), not JWT.
- Model provider is OpenRouter, currently configured to
  `deepseek/deepseek-v4-flash`. This is a newer setup — if tool calls
  behave unexpectedly (a bash command malformed, a step silently skipped,
  the loop stopping early), report exactly what happened in the Jira
  comment so it's visible for debugging, rather than retrying silently.
