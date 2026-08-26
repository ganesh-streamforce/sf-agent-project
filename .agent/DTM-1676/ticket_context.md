## Context Document for Jira Ticket DTM-1676

### 1. Ticket Summary
- **Title:** [TEST] Create a custom field "company Address"
- **Type:** Task
- **Priority:** Minor
- **Status:** To Do
- **Assignee/Reporter:** Siva Kumar
- **Created:** 26-Aug-2026
- **Due:** 28-Aug-2026
- **Project:** Development Task Master (DTM)

### 2. Business & Functional Requirement
Create a custom text field on the **Account** object with the following specification. The work includes both declarative (admin) and metadata/deployment (developer) activities to enable promotion from sandbox to production.

### 3. Field Specification
| Property        | Value                  |
|-----------------|------------------------|
| **Object**      | Account                |
| **Label**       | company Address        |
| **API Name**    | Company_Address__c     |
| **Type**        | Text                   |
| **Length**      | 255                    |
| **Required**    | No                     |
| **Unique**      | No                     |
| **External ID** | No                     |
| **Default Value** | None                 |

### 4. Requirements Breakdown
#### Admin Tasks (Declarative)
1. Create the field in a sandbox via *Setup > Object Manager > Account > Fields & Relationships*.
2. Configure Field-Level Security (FLS):
   - Make visible on all standard profiles.
   - Set to **read-only** by default (change to read/write if data entry is needed – pending confirmation from requester).
3. Add the field to relevant Account page layouts (if required – pending clarification).
4. Manually verify the field appears in Object Manager and FLS is correct for a test user.

#### Developer Tasks (Metadata & Deployment)
1. Retrieve the field metadata (e.g., via SFDX or Change Set) and place it in the source-controlled package under `force-app/main/default/objects/Account/fields/Company_Address__c.field-meta.xml`.
2. Commit metadata to version control (branch linked to this ticket) and open a pull request referencing **DTM-1673**.
3. Build a deployment package (Change Set, SFDX, or CI pipeline) to promote the field from sandbox to the target org (including FLS/permission set metadata if profiles are source-managed).
4. Post-deployment validation:
   - Confirm field is queryable: `SELECT Id, Company_Address__c FROM Account LIMIT 1`.
   - Check for naming collisions with integrations/APIs consuming Account.
5. Regression check: ensure no Apex triggers, Flows, or validation rules break due to the new field; run existing Account-related test suite.
6. Update ticket with deployment status per environment (sandbox/UAT/production).

### 5. Acceptance Criteria
- [ ] `Company_Address__c` is created on the Account object as Text(255).
- [ ] FLS is configured and verified across profiles.
- [ ] Field metadata is committed to source control.
- [ ] Successfully deployed via Change Set or SFDX to the target environment.
- [ ] Field is queryable via SOQL after deployment.
- [ ] No regressions in existing Account-related automations or tests.

### 6. Open Questions (Pending Clarification from Siva Kumar)
| # | Question |
|---|----------|
| 1 | Confirm target object: Is it indeed Account, or a different object? |
| 2 | Is production deployment required, or should this stay sandbox-only given the `[TEST]` prefix in the summary? |
| 3 | Should the field be added to any specific page layout or record type? |
| 4 | Is this work a duplicate or a re-test of the already-completed **DTM-1671**? |

### 7. Dependencies & Related Work
- **DTM-1673** – referenced for the pull request branch/link.
- **DTM-1671** – identified as a possible duplicate; needs clarification.
- No other linked issues, comments, or attachments exist.

### 8. Notes & Missing Information
- **FLS read-only vs. read-write** – Pending explicit confirmation from Siva.
- **Deployment target org** – Not specified (presumably production, but open question #2).
- **Page layout association** – Listed as “if required”; not confirmed.
- **Testing environment** – No details on sandbox name or UAT environment.
- **Integration consumers** – No list provided; validation should check for naming collisions.
- **Branch naming strategy** – Not defined; only reference to DTM-1673.
- **Regression test suite** – Not detailed; assume all existing Account test classes.

### 9. Constraints
- No constraints explicitly stated.
- The `[TEST]` prefix may indicate a test environment, but production deployment is mentioned in the description, creating ambiguity.

---

*This document is intended for the Design Agent to understand the full requirement without revisiting the raw Jira ticket.*