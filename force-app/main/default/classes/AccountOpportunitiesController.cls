public with sharing class AccountOpportunitiesController {
    
    /**
     * Search for accounts by name and return their aggregated opportunity amounts
     * @param accountName The name of the account to search for
     * @return List of accounts with their aggregated opportunity amounts
     */
    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> searchAccounts(String accountName) {
        List<AccountWrapper> results = new List<AccountWrapper>();
        
        // Validate input
        if (String.isBlank(accountName)) {
            return results;
        }
        
        // Search for accounts matching the search term
        String searchTerm = '%' + accountName + '%';
        List<Account> accounts = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name LIKE :searchTerm 
            LIMIT 100
        ];
        
        if (accounts.isEmpty()) {
            return results;
        }
        
        // Get opportunity amounts aggregated for each account
        Map<Id, AggregateResult> opportunityAggregates = new Map<Id, AggregateResult>();
        
        try {
            List<AggregateResult> aggregates = [
                SELECT AccountId, SUM(Amount) totalAmount
                FROM Opportunity
                WHERE AccountId IN :new Map<Id, Account>(accounts).keySet()
                AND StageName NOT IN ('Closed Lost', 'Closed Won')
                GROUP BY AccountId
            ];
            
            for (AggregateResult agg : aggregates) {
                opportunityAggregates.put((Id)agg.get('AccountId'), agg);
            }
        } catch (Exception e) {
            System.debug('Error fetching opportunities: ' + e.getMessage());
        }
        
        // Build wrapper results
        for (Account acc : accounts) {
            Decimal opportunityAmount = 0;
            
            if (opportunityAggregates.containsKey(acc.Id)) {
                AggregateResult agg = opportunityAggregates.get(acc.Id);
                opportunityAmount = (Decimal)agg.get('totalAmount');
            }
            
            results.add(new AccountWrapper(
                acc.Id,
                acc.Name,
                opportunityAmount
            ));
        }
        
        return results;
    }
    
    /**
     * Wrapper class to return account data with opportunity aggregates
     */
    public class AccountWrapper {
        @AuraEnabled
        public Id Id { get; set; }
        
        @AuraEnabled
        public String Name { get; set; }
        
        @AuraEnabled
        public Decimal opportunityAmount { get; set; }
        
        @AuraEnabled
        public String accountUrl { 
            get {
                return '/' + Id;
            } 
        }
        
        public AccountWrapper(Id accountId, String accountName, Decimal amount) {
            this.Id = accountId;
            this.Name = accountName;
            this.opportunityAmount = amount;
        }
    }
}