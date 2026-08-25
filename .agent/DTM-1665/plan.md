# Design Plan: DTM-1665

## 1. Objective
Create a custom field named **“company address”** on the standard **Account** object to store an address value that is not covered by the existing standard address fields (Billing, Shipping).

## 2. Requirements
- A new custom field must be added to the Account object.
- The field label must be **“company address”**.
- No additional requirements (data type, length, validation, security, layout placement) are specified in the ticket.

## 3. Existing Context
- The Account object already contains standard address fields: `BillingAddress`, `ShippingAddress`, and possibly custom address fields.
- No existing custom field with the label “company address” is present.
- The ticket has been through multiple design iterations and was escalated for manual review due to exceeding the maximum revision cycles.

## 4. Proposed Solution
Add a custom field of type **Text Area (Long)** with a length of **255 characters** to the Account object. This is a reasonable default for a free‑form address field. The field will be optional, not unique, and not an External ID. It will be added to the default Account page layout and made visible to all standard profiles (with FLS read/edit access granted to the System Administrator and any profiles that require it).

## 5. Technical Design
- **Object:** Account
- **Field Label:** Company Address
- **Field Name (API):** `Company_Address__c`
- **Data Type:** Text Area (Long)
- **Length:** 255 characters
- **Required:** No
- **Unique:** No
- **External ID:** No
- **Default Value:** None
- **Help Text:** (Optional) “Enter the company’s primary address.”
- **Description:** (Optional) “Custom field for company address.”
- **Page Layout:** Add to the default Account layout (and any other layouts as determined during implementation).
- **Record Types:** Apply to all record types (no record type restrictions unless specified later).
- **Field‑Level Security:** Initially grant Read/Edit to System Administrator; other profiles can be adjusted per business needs.

## 6. Salesforce Components
- **Custom Field** on Account object.
- **Page Layout** modification (add field to Account layout).
- **Field‑Level Security** settings (via profiles/permission sets).

No other components (Flows, Apex, Validation Rules, etc.) are required unless future requirements dictate.

## 7. Data Model Changes
- Add one custom field `Company_Address__c` (Text Area (Long)) to the Account object.
- No new objects, relationships, or formula fields.

## 8. Integration Changes
- No integration changes are anticipated. If external systems need to populate this field, API access will be available via the standard Account object API.

## 9. Security and Permissions
- **Field‑Level Security:** The field will be visible by default to all profiles that have access to the Account object. The System Administrator will have full read/edit access. Other profiles can be restricted as needed.
- **Sharing:** No changes; standard Account sharing rules apply.
- **Permission Sets:** No new permission sets required.

## 10. Testing Strategy
- **Unit Test:** Verify the field appears on the Account record page and can be populated with text up to 255 characters.
- **Integration Test:** Confirm the field is accessible via SOQL, REST, and SOAP APIs.
- **Security Test:** Ensure FLS restrictions work as configured.
- **Regression Test:** Ensure existing Account functionality (reports, list views, validation rules) is not broken.

## 11. Dependencies
- None. The field creation is independent of other work items.

## 12. Assumptions
- The field is intended for free‑form text entry (not a structured address compound field).
- The field is optional and not required for record creation.
- The field should be added to the default Account page layout.
- No validation rules, formulas, or triggers are needed at this time.
- The field will be used for a company address that is distinct from Billing/Shipping addresses.

## 13. Open Questions
1. **Data Type:** Should the field be a simple Text (255) or Text Area (Long) or even a compound Address field? (Assumed Text Area (Long) for flexibility.)
2. **Length:** Is 255 characters sufficient? (Could be increased to 1000+ if needed.)
3. **Required:** Should the field be required under any condition?
4. **Unique / External ID:** Are uniqueness or external ID constraints needed?
5. **Page Layouts:** Which specific page layouts and record types should include this field?
6. **Field‑Level Security:** Which profiles should have read/edit access beyond System Administrator?
7. **Business Purpose:** What business process does this field support? (Could affect validation or integration.)
8. **Existing Address Fields:** How does this relate to BillingAddress/ShippingAddress? Should it replace or supplement them?
9. **Data Migration:** Is there existing data to populate into this field?
10. **Help Text / Description:** Should descriptive text be added?

## 14. Implementation Sequence
1. Create the custom field `Company_Address__c` (Text Area (Long), 255 chars) on Account.
2. Add the field to the default Account page layout.
3. Configure Field‑Level Security (grant read/edit to System Admin; other profiles as needed).
4. Deploy to sandbox for testing.
5. After testing, deploy to production.

## 15. Risks
- **Low risk** – Adding a simple text field is a standard, low‑impact operation.
- **Risk of ambiguity** – Without clear requirements, the field may not meet actual business needs, leading to rework.
- **Risk of duplicate data** – If the field overlaps with existing address fields, data inconsistency may occur.

## 16. Developer/Admin Handoff
- **Implementation work required:**
  - Create the custom field via Setup > Object Manager > Account > Fields & Relationships > New.
  - Set field type to Text Area (Long), length 255, label “Company Address”, API name `Company_Address__c`.
  - Add field to the Account page layout (drag to desired section).
  - Set field‑level security for all profiles (default: visible and editable for System Administrator; other profiles can be adjusted).
  - Optionally add help text and description.
- **No Apex, Flow, or other automation required.**
- **Deployment:** Use change set or metadata API to deploy to production.

## Final Recommendation
Proceed with creating a **Text Area (Long)** custom field named **Company Address** on the Account object, with a length of 255 characters, optional, and added to the default page layout. This is the simplest, most flexible approach that satisfies the stated requirement. All open questions should be clarified with the business owner before final deployment to ensure the field meets actual needs.