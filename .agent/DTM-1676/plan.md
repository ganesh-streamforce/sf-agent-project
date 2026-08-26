# Design Plan: DTM-1676

## 1. Objective
Create a custom text field `Company_Address__c` (Text, 255) on the Account object, configure Field-Level Security (FLS), and deploy the metadata from sandbox to production. The work includes both declarative (admin) and metadata/deployment (developer) activities.

## 2. Requirements
- A custom text field on Account with label “company Address”, API name `Company_Address__c`, length 255, not required, not unique, not an external ID, no default value.
- FLS: visible on all standard profiles, set to read-only by default (pending confirmation for read/write).
- Add field to relevant Account page layouts (if required – pending clarification).
- Retrieve field metadata and commit to source control under `force-app/main/default/objects/Account/fields/Company_Address__c.field-meta.xml`.
- Deploy to target environment (sandbox, UAT, production) via Change Set or SFDX.
- Post-deployment validation: SOQL query, check naming collisions, run existing Account test suite.
- Document deployment status per environment.

## 3. Existing Context
- The Account object is standard and already exists.
- No existing custom fields with the same API name are known.
- Related ticket DTM-1673 is referenced for branch linking.
- DTM-1671 may be a duplicate – pending clarification.
- No integration consumers are explicitly listed; naming collision check should be performed against known API endpoints.

## 4. Proposed Solution
- Create the field declaratively in a sandbox (e.g., a developer sandbox) via Setup > Object Manager > Account > Fields & Relationships.
- Configure FLS: set to visible on all standard profiles; set to read-only (default). If confirmation allows read-write, update accordingly.
- Add field to the standard Account page layout only if the requester confirms the requirement.
- Retrieve the field metadata using SFDX `source:retrieve` or a Change Set.
- Commit metadata to version control on a feature branch linked to DTM-1673 (e.g., `feature/DTM-1676`).
- Build a deployment package: either a Change Set (if profiles are not source-managed) or SFDX source push/convert (if profiles are source-managed). Include FLS in the profile metadata if profiles are source-controlled; otherwise, use a permission set to grant read access.
- Deploy to sandbox first, then UAT, then production.
- Validate: run SOQL, check for collisions, run Account test classes.
- Document deployment status in the ticket.

## 5. Technical Design
- **Field Definition**: `Company_Address__c` – Text(255), no required, no unique, no external ID, no default.
- **FLS Handling**:
  - If profiles are source-managed: modify the `<fieldPermissions>` for each profile to include `Company_Address__c` with `editable="false"` (or `"true"` if read-write). Ensure visibility is set.
  - If profiles are not source-managed: create a permission set (e.g., `Account_Company_Address_Read`) with field read access and assign to all users. Alternatively, use a Change Set to set FLS via the UI.
- **Page Layout**: Only include if explicitly requested. The field should be placed in a logical section (e.g., “Address Information”). If no layout change is needed, skip.
- **Naming Collision Check**: Query `FieldDefinition` for Account objects to ensure `Company_Address__c` is not already used by an installed package or managed field. Also check with integration teams if possible.
- **Regression Check**: Run all existing Apex test classes that reference Account (e.g., `AccountTriggerTest`, `AccountServiceTest`). Run any Flows or validation rules that involve Account. Ensure no new errors.

## 6. Salesforce Components
- Custom Field: `Company_Address__c` on Account object.
- Profile metadata (if source-managed): updates to `Admin`, `Standard User`, etc. to include field permissions.
- Permission Set (fallback): `Account_Company_Address_Read` (if profiles are not source-managed).
- Page Layout: Account Layout (if required).
- Optional: Deployment artifact (Change Set or SFDX package).

## 7. Data Model Changes
- **New Field**: `Account.Company_Address__c` – Text(255).
- No new objects, relationships, or indexes.
- No impact on existing fields.

## 8. Integration Changes
- No integration changes required.
- **Precaution**: Notify integration teams about the new field if any external system pulls Account data via API. The field will be queryable via SOQL.
- Check for any API consumers that may have naming conflicts (e.g., if `Company_Address__c` is used in an external system schema).

## 9. Security and Permissions
- **Field-Level Security**: Visible to all profiles; default read-only. If read-write is confirmed, update accordingly.
- **Object Permissions**: No changes needed (Account already accessible).
- **Sharing**: No changes.
- **Permission Set**: If profiles are not source-managed, a permission set will be created and assigned to all users (or a group) to ensure visibility.

## 10. Testing Strategy
- **Unit Tests**: No new code, so no new unit tests. Run existing Account-related test classes to confirm no regressions.
- **Manual Tests**:
  - Verify field appears in Object Manager.
  - Verify FLS for a test user: field is visible but read-only (or editable per confirmation).
  - Verify field appears on the Account page layout (if added).
  - Run SOQL: `SELECT Id, Company_Address__c FROM Account LIMIT 1` – should return rows without error.
- **Integration/Regression**: Run all Apex tests, Flow tests, and validation rules that involve Account.
- **Deployment Validation**: After each deployment, repeat the SOQL query and test FLS.

## 11. Dependencies
- **DTM-1673**: Branch/PR must reference this ticket.
- **DTM-1671**: Clarify if this work is a duplicate; if yes, cancel or reuse.
- **Sandbox environment**: Must have a sandbox (e.g., Developer or Full Copy) to create the field declaratively.
- **Source control**: Access to Git repository, SFDX CLI, and org authentication.
- **Target org**: Production org access (if deployment is required).

## 12. Assumptions
- The target object is indeed **Account** (pending open question #1).
- The `[TEST]` prefix is a placeholder; production deployment is required as stated in the description (pending open question #2).
- Profiles are **not** source-managed (common in many orgs); therefore, FLS will be handled via a permission set or Change Set UI. If source-managed, adjust accordingly.
- No existing custom fields conflict with `Company_Address__c`.
- The developer has access to a sandbox and can run SFDX commands.
- Branch naming will follow the pattern `feature/DTM-1676` (or as per team convention).

## 13. Open Questions
| # | Question | Resolution Needed |
|---|----------|-------------------|
| 1 | Is the target object indeed Account? | Confirm with Siva Kumar. |
| 2 | Is production deployment required, or should this stay sandbox-only? | Clarify intent of `[TEST]` prefix. |
| 3 | Should the field be added to a specific page layout or record type? | Ask Siva Kumar. |
| 4 | Is this work a duplicate of DTM-1671? | Verify with Siva Kumar. |
| 5 | Are profiles source-managed in this org? | Determine deployment approach. |
| 6 | Should FLS be read-only or read-write? | Await confirmation from requester. |

## 14. Implementation Sequence
1. **Clarify Open Questions**: Resolve all open questions before starting work.
2. **Admin (Declarative)**:
   - Log into sandbox (e.g., `dev-sandbox`).
   - Create field via Setup > Object Manager > Account > Fields & Relationships.
   - Configure FLS (read-only default, unless confirmed otherwise).
   - Add field to page layout (if confirmed).
3. **Developer (Metadata)**:
   - Retrieve field metadata using SFDX: `sfdx force:source:retrieve -m CustomField:Account.Company_Address__c`.
   - Retrieve profile/permission set metadata if needed.
   - Commit to Git under `force-app/main/default/objects/Account/fields/Company_Address__c.field-meta.xml`.
   - Create a branch `feature/DTM-1676` and open a PR referencing DTM-1673.
4. **Build Deployment Package**:
   - If using Change Set: create outbound change set with the field and any FLS/permission set metadata.
   - If using SFDX: convert to metadata API format or use `sfdx force:source:deploy`.
5. **Deploy**: Sandbox -> UAT -> Production (or as environment order dictates).
6. **Post-Deployment Validation**:
   - Run SOQL query.
   - Verify FLS for a test user.
   - Run all Account tests.
   - Check for naming collisions with integrations.
7. **Update Ticket**: Mark deployment status per environment, link to PR, close.

## 15. Risks
- **Duplicate Work**: If DTM-1671 is the same, effort may be wasted.
- **FLS Misconfiguration**: If profiles are source-managed and FLS is not included, the field may be invisible. Mitigation: include profile metadata in the deployment.
- **Naming Collision**: If another package uses the same API name, deployment will fail. Mitigation: check before deployment.
- **Regression**: Existing triggers or flows may unexpectedly break if they reference all fields. Unlikely, but run tests.
- **Deployment Failure**: Change Set or SFDX may fail due to metadata dependencies. Mitigation: deploy to sandbox first.

## 16. Developer/Admin Handoff
- **Admin (Siva Kumar)**: Create the field declaratively in the sandbox, configure FLS, and add to page layout if needed. Provide the sandbox name and login credentials to the developer.
- **Developer**: Retrieve metadata, commit to version control, build deployment package, deploy to production, run validation.
- **Both**: Collaborate on resolving open questions and testing.

# Final Recommendation
Proceed with the declarative creation of `Company_Address__c` on Account in a sandbox, then retrieve metadata and deploy via SFDX or Change Set. Use a permission set for FLS if profiles are not source-managed. Clarify the open questions before starting work to avoid rework. The solution is straightforward and low-risk, but careful attention to deployment metadata and regression testing is required.