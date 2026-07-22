public class NoSharingDemo {
    public List<Account> getAccounts() {
        return [SELECT Id, Name FROM Account];
    }
}