public class DeleteAllAccounts {
    
    public static void deleteAll() {
        // Query all Account records (up to 50,000)
        List<Contact> accountsToDelete = [SELECT Id FROM Contact];

        if (!accountsToDelete.isEmpty()) {
            try {
                delete accountsToDelete;
                System.debug(accountsToDelete.size() + ' Accounts deleted successfully.');
            } catch (DmlException e) {
                System.debug('Error deleting Accounts: ' + e.getMessage());
            }
        } else {
            System.debug('No Accounts found to delete.');
        }
    }
}