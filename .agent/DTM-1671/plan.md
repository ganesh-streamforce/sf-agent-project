Here is the revised technical design for DTM-1671, incorporating the human feedback that the field should be created on the `Account` object.

# Design Plan: DTM-1671 (Revised)

## 1. Objective

Create a custom field on the **Account** object in Salesforce with the exact label **"company Address"** (lowercase “c” in “company”, capital “A” in “Address”) so it is available for use on Account records.

The design remains provisional because the ticket and feedback do not specify the field type, API name, length, security, or layout details. These must be confirmed before the field is fully configured and deployed.

## 2. Requirements

**Known requirement (from ticket):**

- Create a custom field with the label **“company Address”**.
- The exact casing must be preserved: lowercase “c” and capital “A”.

**Known requirement (from human feedback):**

- The field must be created on the **Account** object.

**Not specified in ticket or feedback:**

- Field type (e.g., Text, Text Area, Long Text Area, Picklist)
- Field length
- API name
- Required vs optional
- Page layout placement
- Record type restrictions
- Field-level security
- Help text
- Default value
- Business purpose

No acceptance criteria were documented in the ticket.

## 3. Existing Context

- The field will be added to the standard Account object.
- No existing behavior, dependencies, related work, comments, or previous decisions are documented in the ticket.
- It is unknown if a similar field (e.g., `BillingAddress`, `ShippingAddress`, or a previous custom address field) already exists on Account and might be related to this request.

## 4. Proposed Solution

Use standard Salesforce declarative configuration to create a custom field on the Account object. No Apex, Lightning Web Components, Flow, or integrations are required.

- **Object:** Account
- **Label:** `company Address`
- **API Name:** A valid API name must be used (label contains a space). Suggested names:
    - `company_Address__c` (matches label casing)
    - `Company_Address__c` (standard PascalCase convention)
    - `Company_Address__c` is generally preferred for API naming conventions.
- **Field Type:** To be confirmed. If no further direction, a default assumption of `Text(255)` is reasonable.
- **Required:** Optional by default, unless business requirements confirm otherwise.

The solution is intentionally minimal because only two requirements are confirmed (field label and target object).

## 5. Technical Design

The following field metadata will need to be configured:

| Attribute | Value / Decision |
|---|---|
| Object | Account |
| Label | `company Address` |
| API Name | To be confirmed, e.g., `Company_Address__c` |
| Data Type | To be confirmed |
| Field Length | To be confirmed; `255` if Text |
| Required | To be confirmed; default: Optional (unchecked) |
| Help Text | None, unless requested |
| Default Value | None, unless requested |
| Page Layout | To be confirmed (see Section 6) |
| Record Types | To be confirmed; default: all Account record types |
| Field-Level Security | To be confirmed; default: visible and editable for all profiles with Account object access |

No automation is required. Once created, the field will be available in field pickers, list views, reports, and the API on the Account object.

## 6. Salesforce Components

- **Custom Field** on the Account object.
- **Page Layout** changes: the field should be added to the relevant Account page layout(s) once confirmed. If not specified, a default layout (e.g., "Account Layout") will be used.
- **Field-Level Security** settings: to be confirmed. Default behavior grants Read/Edit access to all profiles with Account access.
- **Record Type assignments**: if Account record types exist, the field should be assigned to all record types unless business confirms otherwise.

No Apex classes, triggers, Flows, custom objects, or Lightning components are needed.

## 7. Data Model Changes

- Add one custom field to the **Account** object.
- No new object, lookup, master-detail relationship, or custom metadata is required.
- The API name must be unique across the Salesforce org.
- The field will be exposed in the Account object schema and API once created.

## 8. Integration Changes

None documented. No external systems, APIs, or middleware changes are required based on this ticket. If external integrations consume Account fields, the final API name should be communicated to integration owners, but no integration work is needed unless later requested.

## 9. Security and Permissions

No field-level security requirements were specified.

Recommended default:

- Granted to all profiles that already have access to the Account object.
- System Administrator should have full access (Read/Edit).
- If the field contains sensitive data, access should be restricted to specific profiles/permission sets, but that is not documented.

If Account record types exist, the field should be assigned to all record types unless business confirms otherwise.

## 10. Testing Strategy

- Verify the field is created on the **Account** object with the exact label **“company Address”**.
- Verify the API name is valid and follows org naming conventions.
- Create a test Account record and confirm the field is visible on the intended page layout.
- Enter data into the field and confirm it saves correctly.
- If the field is required, confirm that records cannot be saved without it.
- Test field-level security by logging in as a representative user/profile.
- Confirm availability for the correct Account record types, if applicable.

No Apex unit tests are required for a declarative custom field.

## 11. Dependencies

- Salesforce org access with permission to create custom fields on the Account object.
- Confirmation of the field type, API name, length, and other attributes from the requester or product owner.
- No code or integration dependencies are documented.

## 12. Assumptions

The following assumptions are made only for a provisional design and must be validated before implementation:

- The field type is text-based; `Text(255)` is a placeholder until confirmed.
- The API name will be based on the label or chosen to fit org naming standards (PascalCase is recommended).
- The field should be optional and visible to all appropriate users unless otherwise specified.
- No record type restrictions or special security settings are needed unless requested.

## 13. Open Questions (Still Unresolved)

1. **What field type is required?** (Text, Text Area, Long Text Area, Picklist, etc.)
2. **What API name should be used?** (e.g., `Company_Address__c`, `company_Address__c`)
3. **What is the maximum field length?** (e.g., 255, 1000)
4. **Should the field be required or optional?**
5. **Which page layouts should include the field?** (e.g., Account Layout, specific record type layouts)
6. **Are there Account record type restrictions?**
7. **Which profiles or permission sets should have Read/Edit access?**
8. **Is help text or a default value needed?**
9. **What is the business purpose of this field?** (e.g., for storing an alternative company address, billing address, shipping address? This may affect field type and naming.)
10. **Does a similar field already exist on Account?** (e.g., `BillingAddress`, `ShippingAddress`, or a previous custom field)

## 14. Implementation Sequence

Implementation should not begin until the open questions (Section 13) are answered.

Once confirmed:

1. Confirm the field type, API name, length, and security requirements.
2. In Salesforce Setup, navigate to Object Manager > Account > Fields & Relationships > New.
3. Create the custom field with the label exactly **“company Address”**.
4. Configure the field type, length, API name, required status, and help text.
5. Set field-level security for the appropriate profiles/permission sets.
6. Add the field to the relevant Account page layouts and record types.
7. Save the field and verify visibility and usability by creating a test Account record.

## 15. Risks

- **Wrong field type:** Changing a Text field to a Text Area or other type after data has been entered may be difficult or impossible without data loss.
- **Wrong API name:** Renaming an API name after deployment may break existing integrations or reports.
- **Exact label not preserved:** The label “company Address” may be auto-corrected or incorrectly capitalized if not entered carefully.
- **API name collision:** The chosen API name may already exist on Account.
- **Unintended access:** The field may be visible to too many users if field-level security is not configured properly.
- **Scope ambiguity:** Because the ticket and feedback are minimal, there is a risk of overbuilding or underbuilding the requested feature. The business purpose is unknown.

## 16. Developer/Admin Handoff

Implementation work required:

- An administrator will create the custom field through Salesforce Setup or source-based metadata deployment.
- The administrator must ensure the field is created on the **Account** object.
- The administrator must ensure the field label is exactly **“company Address”**.
- The administrator must select the confirmed field type, length, and API name.
- The administrator must configure field-level security.
- The administrator must add the field to the confirmed page layouts and record types.
- Testing should be performed by creating a sample Account record and verifying the field behaves as expected.

No Apex, Flow, or Lightning component development is required for this ticket.

## Final Recommendation

The recommended technical approach is a **standard Salesforce declarative custom field** on the **Account** object, using the label **“company Address”** and a valid API name such as `Company_Address__c` or `company_Address__c`.

However, the ticket is still missing critical implementation details (field type, API name, length, security, layout). The safest next step is to **clarify the remaining open questions** in Section 13 before any field is created. If forced to proceed with minimum safe assumptions, create an optional `Text(255)` field on the Account object with the exact label “company Address” and API name `Company_Address__c`, but **this assumption must be explicitly confirmed by the requester**.