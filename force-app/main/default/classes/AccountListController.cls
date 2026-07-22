public with sharing class AccountListController {
    public List<Account> accounts { get; set; }

    public AccountListController() {
        accounts = [
            SELECT Id, Name, Site, Phone, Owner.Alias
            FROM Account
            LIMIT 100
        ];
    }
}