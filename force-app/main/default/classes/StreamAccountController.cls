public with sharing class StreamAccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getStreamAccounts() {
        return [SELECT Id, Name FROM Account WHERE Name LIKE 'stream%'];
    }
}