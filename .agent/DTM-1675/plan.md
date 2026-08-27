# Design Plan: DTM-1675

## 1. Objective
Create a minimal Apex utility class `CustomerTypeUpdater` that programmatically sets the `Customer_Type__c` field on an Account record to the value `"Standard"`. The class will be used by other Apex code (e.g., triggers, batch jobs, or anonymous Apex) to standardize the customer type.

## 2. Requirements
- **Functional**: A new Apex class named `CustomerTypeUpdater` with a method that updates the `Customer_Type__c` field to `"Standard"`.
- **Scope**: No triggers, flows, process builders, or additional configuration. No new fields or picklist values.
- **Simplicity**: Minimal implementation – no complex logic, error handling beyond basic DML exception handling, and no external dependencies.

## 3. Existing Context
- The `Customer_Type__c` custom field already exists on the Account object (assumed).
- No existing Apex class with similar functionality.
- The design has been previously reviewed and approved (branch `agent/design-DTM-1675`).

## 4. Proposed Solution
Create a single Apex class with one public static method. The method accepts an `Account` sObject, sets its `Customer_Type__c` field to `"Standard"`, and performs a DML update. A corresponding test class will be created to achieve 75%+ code coverage.

## 5. Technical Design

### Class: `CustomerTypeUpdater`
- **Access modifier**: `public`
- **Method**: `public static void updateCustomerType(Account acc)`
  - **Input**: An `Account` record (not null).
  - **Behavior**: Sets `acc.Customer_Type__c = 'Standard'` and then performs `update acc;`.
  - **Error handling**: Wrap DML in a try-catch block to catch `DmlException` and optionally rethrow or log (minimal – rethrow is simplest).
  - **Return type**: `void`.

### Test Class: `CustomerTypeUpdaterTest`
- **Access modifier**: `@isTest`
- **Test method(s)**: One test method that:
  - Creates an Account record with `Customer_Type__c` set to a different value (e.g., `'Premium'`).
  - Calls `CustomerTypeUpdater.updateCustomerType(acc)`.
  - Asserts that the field is now `'Standard'` and that the record is updated in the database (re-query).
- **Coverage**: Should cover the main path and the DML exception path (optional, but recommended for completeness).

## 6. Salesforce Components
- **Apex Class**: `CustomerTypeUpdater` (new)
- **Apex Test Class**: `CustomerTypeUpdaterTest` (new)
- **No other components** (no custom labels, settings, fields, or triggers).

## 7. Data Model Changes
- **None**. The `Customer_Type__c` field is assumed to already exist on Account. No new fields or objects.

## 8. Integration Changes
- **None**. The class is internal to Salesforce; no REST/SOAP APIs or external systems are involved.

## 9. Security and Permissions
- The class will be `public` and accessible to any Apex code running in the same org.
- No `with sharing` or `without sharing` keyword is required because the class does not query or manipulate records beyond the passed-in Account. However, to follow best practices, `without sharing` is acceptable since the caller controls the record. Alternatively, `public without sharing` can be used to avoid any sharing issues when the caller has different permissions. Given minimal complexity, `public class` (default `with sharing` in system context) is fine, but we recommend `public without sharing` to ensure the method works regardless of caller’s sharing mode. (Assumption: the caller will have access to the Account record.)
- No permission set or profile changes needed.

## 10. Testing Strategy
- **Unit test**: Create an Account, call the method, verify field value and DML success.
- **Edge cases**: Test with null Account (should throw exception – acceptable). Test with a record that fails DML (e.g., required field missing) – the try-catch will handle it.
- **Coverage**: Aim for 100% of the class logic.

## 11. Dependencies
- The `Customer_Type__c` field must exist on Account and be of a type that accepts the string `'Standard'` (Text or Picklist with that value). If picklist, the value must be an active picklist value.
- No other dependencies.

## 12. Assumptions
- `Customer_Type__c` is a custom field of type Text or Picklist, and `'Standard'` is a valid value.
- The method should perform DML (update) itself, not just set the field in memory.
- The class and method are `public` and `static`.
- A test class is required for deployment (Salesforce best practice).
- No special error handling beyond basic try-catch is needed.
- The Account record passed is already in memory (not a query result that needs re-querying).

## 13. Open Questions
1. **Method name**: `updateCustomerType` is assumed; could be `setCustomerTypeToStandard`. The approved design may have a specific name – we will use `updateCustomerType` as it is descriptive.
2. **Sharing mode**: `with sharing` vs `without sharing` – we assume `without sharing` to avoid potential issues, but the original design may specify otherwise. We will note this as a decision point.
3. **Test class scope**: Should the test class be included in the same ticket? The ticket does not mention it, but standard practice requires it. We will include it.
4. **DML exception handling**: Should the method silently swallow exceptions or rethrow? We recommend rethrowing to let the caller handle it, but minimal implementation could just let the exception propagate. We will include a try-catch that rethrows.

## 14. Implementation Sequence
1. Create the `CustomerTypeUpdater` class with the method.
2. Create the `CustomerTypeUpdaterTest` class.
3. Run all tests to ensure coverage and no failures.
4. Deploy to sandbox/UAT for validation.

## 15. Risks
- If `Customer_Type__c` is a picklist and `'Standard'` is not an active value, the DML will fail. This is a pre-existing data model risk.
- If the Account record has validation rules that prevent the update, the DML will fail. The method will propagate the exception.
- No other risks.

## 16. Developer/Admin Handoff
- **Developer tasks**:
  - Write the Apex class `CustomerTypeUpdater` (see technical design above).
  - Write the test class `CustomerTypeUpdaterTest`.
  - Ensure code coverage meets Salesforce requirements.
- **Admin tasks**:
  - Verify that `Customer_Type__c` field exists on Account and that `'Standard'` is a valid value (if picklist, add it if missing).
  - No other admin actions required.
- **QA tasks**:
  - Execute the test class and verify the method works in a sandbox.
  - Test with various Account records (existing, new, with different Customer_Type values).

## Final Recommendation
Proceed with the minimal implementation as described: a single public static method that sets the field and performs DML, plus a test class. This satisfies the business need with zero unnecessary complexity. The design aligns with the previously approved artifacts (branch `agent/design-DTM-1675`).