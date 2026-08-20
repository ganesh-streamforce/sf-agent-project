# Design Plan: DTM-1671

## 1. Objective

Create a custom field in Salesforce whose label is exactly **"company Address"** (lowercase “c” in “company”, capital “A” in “Address”) so it is available for use in the appropriate object.

The ticket does not specify the object, field type, length, API name, security, or layout details. Therefore, this design is intentionally provisional; the missing details must be confirmed before implementation.

## 2. Requirements

**Known requirement:**

- Create a custom field with the label **“company Address”**.
- The exact casing must be preserved: lowercase “c” and capital “A”.

**Not specified in ticket:**

- Target object
- Field type
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

No current behavior, dependencies, related work, comments, or previous decisions are documented in the ticket. It is not known whether an existing similar field already exists in the Salesforce org.

## 4. Proposed Solution

Use standard Salesforce declarative configuration to create a custom field. No Apex, Lightning Web Components, Flow, or integrations are required.

The field should be created using:

- **Label:** `company Address`
- **API Name:** A valid API name must be used because the label contains a space. Suggested names include `company_Address__c` or `Company_Address__c`, depending on org naming conventions.
- **Field Type:** To be confirmed; if no further direction is given, a default assumption of `Text(255)` is reasonable for an address-like field.
- **Required:** Optional by default, unless business requirements confirm otherwise.

The solution is intentionally minimal because the ticket contains only one clear requirement: the field label.

## 5. Technical Design

The following field metadata will need to be configured:

| Attribute | Value / Decision |
|---|---|
| Label | `company Address` |
| API Name | To be confirmed, e.g., `company_Address__c` |
| Object | To be confirmed |
| Data Type | To be confirmed |
| Field Length | To be confirmed; `255` if Text |
| Required | To be confirmed; default: Optional |
| Help Text | None, unless requested |
| Default Value | None, unless requested |
| Page Layout | To be confirmed |
| Record Types | To be confirmed; default: all |
| Field-Level Security | To be confirmed; default: visible and editable for all profiles with object access |

No automation is required. Once created, the field will be available in field pickers, list views, and the API.

## 6. Salesforce Components

- **Custom Field** on the target object.
- **Page Layout** changes, if the field needs to be visible on record pages.
- **Field-Level Security** settings, if access needs to be restricted.
- **Record Type assignments**, if the field should only appear for certain record types.

No Apex classes, triggers, Flows, custom objects, or Lightning components are needed.

## 7. Data Model Changes

- Add one custom field to the selected object.
- No new object, lookup, master-detail relationship, or custom metadata is required.
- The API name must be unique across the Salesforce org.
- The field will be exposed in the Salesforce object schema and API once created.

## 8. Integration Changes

None documented. No external systems, APIs, or middleware changes are required based on this ticket. If external integrations consume Salesforce fields, the final API name should be communicated, but no integration work is needed unless later requested.

## 9. Security and Permissions

No field-level security requirements were specified.

Recommended default:

- Granted to all profiles that already have access to the target object.
- System Administrator should have full access.
- If the field contains sensitive data, access should be restricted to specific profiles/permission sets, but that is not documented in the ticket.

If record types exist, the field should be assigned to all record types unless the business confirms otherwise.

## 10. Testing Strategy

- Verify the field is created with the exact label **“company Address”**.
- Verify the API name is valid and follows org naming conventions.
- Create a test record and confirm the field is visible on the intended page layout.
- Enter data into the field and confirm it saves correctly.
- If the field is required, confirm that records cannot be saved without it.
- Test field-level security by logging in as a representative user/profile.
- Confirm availability for the correct record types, if applicable.

No Apex unit tests are required for a declarative custom field.

## 11. Dependencies

- Salesforce org access with permission to create custom fields.
- Confirmation of the target object and field type from the requester or product owner.
- No code or integration dependencies are documented.

## 12. Assumptions

The following assumptions are made only for a provisional design and must be validated before implementation:

- The field will be created on an existing standard or custom object. The most likely candidate is **Account**, but this is not stated in the ticket.
- The field type is text-based; `Text(255)` is a placeholder until confirmed.
- The API name will be based on the label or chosen to fit org naming standards.
- The field should be optional and visible to all appropriate users unless otherwise specified.
- No record type restrictions or special security settings are needed unless requested.

## 13. Open Questions

1. Which Salesforce object should the field be created on?
2. What field type is required? Text, Text Area, Long Text Area, or something else?
3. What API name should be used?
4. What is the maximum field length?
5. Should the field be required or optional?
6. Which page layouts should include the field?
7. Are there record type restrictions?
8. Which profiles or permission sets should have access?
9. Is help text or a default value needed?
10. What is the business purpose of this field?
11. Does a similar field already exist in the org?

## 14. Implementation Sequence

Implementation should not begin until the open questions are answered.

Once confirmed:

1. Confirm the target object, field type, API name, and security requirements.
2. In Salesforce Setup, navigate to Object Manager > target object > Fields & Relationships > New.
3. Create the custom field with the label exactly **“company Address”**.
4. Configure the field type, length, and API name.
5. Set field-level security for the appropriate profiles/permission sets.
6. Add the field to the relevant page layouts and record types.
7. Save the field and verify visibility and usability.

## 15. Risks

- **Wrong object:** Creating the field on the wrong object would require rework and cleanup.
- **Wrong field type:** Changing a text field to a text area or other type may be difficult after data is entered.
- **Exact label not preserved:** The label “company Address” may be auto-corrected or incorrectly capitalized if not entered carefully.
- **API name collision:** The chosen API name may already exist.
- **Unintended access:** The field may be visible to too many users if field-level security is not configured properly.
- **Scope ambiguity:** Because the ticket is minimal, there is a risk of overbuilding or underbuilding the requested feature.

## 16. Developer/Admin Handoff

Implementation work required:

- An administrator will create the custom field through Salesforce Setup or source-based metadata deployment.
- The administrator must ensure the field label is exactly **“company Address”**.
- The administrator must select the confirmed object, field type, length, and API name.
- The administrator must configure field-level security.
- The administrator must add the field to the confirmed page layouts and record types.
- Testing should be performed by creating a sample record and verifying the field behaves as expected.

No Apex, Flow, or Lightning component development is required for this ticket.

## Final Recommendation

The recommended technical approach is a **standard Salesforce declarative custom field** on the target object, using the label **“company Address”** and a valid API name such as `company_Address__c` or `Company_Address__c`.

However, the ticket is missing critical implementation details. The safest next step is to **pause implementation and clarify the open questions** in Section 13 before any field is created. If forced to proceed with the minimum safe assumption, create an optional `Text(255)` field on the **Account** object with the exact label “company Address”, but this assumption must be explicitly confirmed by the requester.