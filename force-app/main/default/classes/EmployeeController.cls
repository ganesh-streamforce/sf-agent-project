public with sharing class EmployeeController {

    // Wrapper for delete result
    public class DeleteResultWrapper {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
    }

    @AuraEnabled
    public static List<Employee__c> getEmployees() {
        return [SELECT Id, Name__c, Email__c, Phone__c, Department__c, IsActive__c FROM Employee__c WHERE IsActive__c = TRUE];
    }

    @AuraEnabled
    public static Employee__c getEmployeeById(Id empId) {
        return [SELECT Id, Name__c, Email__c, Phone__c, Department__c, IsActive__c FROM Employee__c WHERE Id = :empId LIMIT 1];
    }

    @AuraEnabled
    public static void updateEmployee(Employee__c emp) {
        update emp;
    }

    @AuraEnabled
    public static DeleteResultWrapper deleteEmployee(Id empId) {
        DeleteResultWrapper result = new DeleteResultWrapper();

        try {
            Employee__c emp = [SELECT Id, IsActive__c FROM Employee__c WHERE Id = :empId];

            // Optional business logic: prevent deletion of active employees
            if (emp.IsActive__c) {
                result.success = false;
                result.message = 'Active employees cannot be deleted.';
                return result;
            }

            delete emp;

            result.success = true;
            result.message = 'Employee deleted successfully.';
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error: ' + e.getMessage();
        }

        return result;
    }

    @AuraEnabled
    public static Employee__c createEmployee(Employee__c emp) {
        insert emp;
        return emp;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getDepartmentOptions() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Employee__c.Department__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistValues) {
            options.add(entry.getLabel());
        }
        return options;
    }
}