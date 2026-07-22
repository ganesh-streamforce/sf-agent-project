public class CRUDDemo {
    public static void updateAccounts() {
        List<Account> accts = [SELECT Id, Name FROM Account];
        for (Account a : accts) {
            a.Name = a.Name + ' (updated)';
        }
        update accts;
    }
}