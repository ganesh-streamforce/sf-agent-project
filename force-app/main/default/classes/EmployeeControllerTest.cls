@isTest
private class EmployeeControllerTest {

    @testSetup
    static void setupData() {
        // Insert active and inactive employees for testing
        List<Employee__c> employees = new List<Employee__c>{
            new Employee__c(Name__c = 'John Doe', Email__c = 'john@example.com', Phone__c = '1234567890', Department__c = 'HR', IsActive__c = true),
            new Employee__c(Name__c = 'Jane Smith', Email__c = 'jane@example.com', Phone__c = '0987654321', Department__c = 'IT', IsActive__c = false)
        };
        insert employees;
    }

    @isTest
    static void testCreateEmployee() {
        Employee__c emp = new Employee__c(
            Name__c = 'Test User',
            Email__c = 'testuser@example.com',
            Phone__c = '1111111111',
            Department__c = 'HR',
            IsActive__c = true
        );
        Test.startTest();
        Employee__c result = EmployeeController.createEmployee(emp);
        Test.stopTest();

        System.assertNotEquals(null, result.Id);
        System.assertEquals('Test User', result.Name__c);
    }

    @isTest
    static void testGetEmployees() {
        Test.startTest();
        List<Employee__c> activeEmployees = EmployeeController.getEmployees();
        Test.stopTest();

        System.assertNotEquals(0, activeEmployees.size());
        for (Employee__c emp : activeEmployees) {
            System.assertEquals(true, emp.IsActive__c);
        }
    }

    @isTest
    static void testGetEmployeeById() {
        Employee__c emp = [SELECT Id FROM Employee__c WHERE Name__c = 'John Doe' LIMIT 1];
        Test.startTest();
        Employee__c result = EmployeeController.getEmployeeById(emp.Id);
        Test.stopTest();

        System.assertEquals(emp.Id, result.Id);
    }

    @isTest
    static void testUpdateEmployee() {
        Employee__c emp = [SELECT Id, Phone__c FROM Employee__c WHERE Name__c = 'John Doe' LIMIT 1];
        emp.Phone__c = '2222222222';

        Test.startTest();
        EmployeeController.updateEmployee(emp);
        Test.stopTest();

        Employee__c updatedEmp = [SELECT Phone__c FROM Employee__c WHERE Id = :emp.Id];
        System.assertEquals('2222222222', updatedEmp.Phone__c);
    }

    @isTest
    static void testDeleteInactiveEmployee() {
        Employee__c emp = [SELECT Id FROM Employee__c WHERE IsActive__c = false LIMIT 1];

        Test.startTest();
        EmployeeController.DeleteResultWrapper result = EmployeeController.deleteEmployee(emp.Id);
        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals('Employee deleted successfully.', result.message);
    }

    @isTest
    static void testDeleteActiveEmployee() {
        Employee__c emp = [SELECT Id FROM Employee__c WHERE IsActive__c = true LIMIT 1];

        Test.startTest();
        EmployeeController.DeleteResultWrapper result = EmployeeController.deleteEmployee(emp.Id);
        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals('Active employees cannot be deleted.', result.message);
    }

    @isTest
    static void testGetDepartmentOptions() {
        Test.startTest();
        List<String> options = EmployeeController.getDepartmentOptions();
        Test.stopTest();

        System.assert(options != null && options.size() > 0, 'Picklist values should be returned');
    }

    @isTest
static void testDeleteThrowsException() {
    Id fakeId = 'a02Qy00000KsX6jABC'; // Use a non-existing or fake Id

    Test.startTest();
    EmployeeController.DeleteResultWrapper result = EmployeeController.deleteEmployee(fakeId);
    Test.stopTest();

    System.assertEquals(false, result.success);
    System.assert(result.message.startsWith('Error:'), 'Error message should be returned');
}
}