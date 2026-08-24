# Design Plan: DTM-1673

## 1. Objective
Create a custom field named **“company Address”** in the Salesforce org. The `[TEST]` prefix and the fact that this ticket is a clone of a completed task (DTM-1671) indicate this may be a test or re‑execution of a previous field creation.

## 2. Requirements
- **Only stated requirement:** A custom field with the label **“company Address”** must exist.
- No object, field type, validation, or layout requirements are provided.
- No acceptance criteria are defined.

## 3. Existing Context
- DTM-1673 is a clone of DTM-1671 (same summary, status Done). No details of DTM-1671’s implementation are available.
- The project “Development Task Master” is an internal tracking project, not a specific Salesforce project.
- No existing fields with a similar name are documented.

## 4. Proposed Solution
Given the lack of detail and the `[TEST]` label, the safest approach is to create a **simple text custom field** on a common object (e.g., Account) as a placeholder. This satisfies the literal requirement and can be adjusted later if real business needs emerge. The field will be created in a **sandbox** (or developer org) unless explicitly directed otherwise.

## 5. Technical Design
- **Object:** Account (assumed – see Assumptions)
- **Field Label:** `company Address` (exact casing as specified)
- **Field Name (API):** `Company_Address__c` (standard conversion: replace space with underscore, add `__c`)
- **Field Type:** Text (length 255 characters) – simplest type, no validation
- **Description:** “Custom field created for DTM-1673 test task”
- **Help Text:** (optional, leave blank)
- **Required:** No
- **Unique:** No
- **External ID:** No
- **Case Sensitive:** No
- **Default Value:** None
- **Sharing:** Inherits from object (no special settings)

**Page Layouts:** Not added to any layout by default. If the task is purely a test, visibility is not required. If needed, the field can be added to the Account layout later.

**Record Types:** Not assigned to any record type.

**Profiles/Permission Sets:** Field-level security will be set to **visible and read-only** for all profiles (or as per standard profile settings). No special permission sets created.

## 6. Salesforce Components
- **Custom Field** on Account object: `Company_Address__c` (Text, 255)

No other components (flows, Apex, LWC, validation rules) are required.

## 7. Data Model Changes
- Addition of one custom field on the Account object.
- No new objects, relationships, or indexes.

## 8. Integration Changes
None. The field is not exposed via API or used in any integration.

## 9. Security and Permissions
- **Field-Level Security:** Set to **Visible** and **Read-Only** for all standard profiles (or as per org’s default). If the field is intended for data entry, change to **Read/Write** for appropriate profiles.
- **Object Permissions:** No changes to Account object permissions.
- **Sharing:** No changes.

## 10. Testing Strategy
- **Unit Test (manual):** Verify the field exists in Setup > Object Manager > Account > Fields & Relationships.
- **UI Test:** Open an Account record and confirm the field is present (if added to layout) or can be added via “Fields” related list.
- **API Test:** Use Workbench or SOQL to query `Company_Address__c` on an Account record.
- **Regression:** Ensure no existing functionality is broken (unlikely for a single text field).

## 11. Dependencies
- Access to a Salesforce org (sandbox or developer) with permission to create custom fields.
- No external dependencies.

## 12. Assumptions
1. **Object:** Account is assumed because it is a standard, widely-used object. If the field is needed on a different object (e.g., Contact, Opportunity, custom object), the design must be updated.
2. **Field Type:** Text (255) is assumed as the simplest type. If a longer text area, picklist, or other type is required, the design changes.
3. **Test vs. Production:** The `[TEST]` prefix suggests this is a non‑production task. The field should be created in a sandbox or developer org. If production is required, additional governance (change set, deployment) is needed.
4. **No existing field:** It is assumed no field with the same API name exists. If it does, the task may be redundant or require a different name.
5. **No business process:** The field is not tied to any automation, validation, or reporting.

## 13. Open Questions
1. **What object should the field be placed on?** (Account, Contact, Opportunity, custom object?)
2. **What field type is required?** (Text, Text Area, Picklist, Email, etc.)
3. **Is this a production or sandbox task?** The `[TEST]` label implies sandbox, but confirmation is needed.
4. **Should the field be added to any page layouts or record types?**
5. **Are there any length, format, or validation requirements?**
6. **Is this a duplicate of DTM-1671?** If DTM-1671 already created the field, this ticket may be a mistake or a re‑test.

## 14. Implementation Sequence
1. **Clarify open questions** with the requester (Siva Kumar) – especially object and field type.
2. **If no clarification received** within a reasonable time, proceed with the assumed design (Account, Text 255) in a sandbox.
3. **Create the custom field** via Setup > Object Manager > Account > Fields & Relationships > New.
4. **Set field-level security** (visible, read-only for all profiles).
5. **Verify field creation** and update ticket status.
6. **Document the decision** in the ticket comments.

## 15. Risks
- **Ambiguity risk:** The field may be created on the wrong object or with the wrong type, requiring rework.
- **Duplicate risk:** If DTM-1671 already created the field, this task may be redundant.
- **Production risk:** If the field is created in production without proper testing, it could affect existing data or processes (low risk for a simple text field).

## 16. Developer/Admin Handoff
**Implementation work required:**
- Create a custom field on the **Account** object (or other object after clarification) with:
  - Label: `company Address`
  - API Name: `Company_Address__c`
  - Type: Text (255)
  - No required, unique, or default values.
- Set field-level security to **visible** for all profiles (read-only or read/write as per org policy).
- Optionally add the field to the Account page layout (if requested).
- No Apex, Flow, or other automation.

**Testing:**
- Confirm field exists in Setup.
- Confirm field appears on Account record (if added to layout).
- Run a simple SOQL query to verify.

**Deployment:**
- If in sandbox, use change set or Salesforce CLI to deploy to production only after clarification that this is a production requirement.

## Final Recommendation
**Proceed with the assumed design (Account, Text 255) in a sandbox** after attempting to clarify the open questions. This satisfies the literal requirement while minimizing risk. If the requester provides additional details, the design can be adjusted accordingly. The `[TEST]` prefix strongly suggests this is a non‑critical task, so a simple, reversible implementation is appropriate.