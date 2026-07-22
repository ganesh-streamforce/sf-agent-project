public with sharing class AccountSearchController {

    /**
     * Wrapper class to hold account search results with aggregated opportunity data.
     */
    public class AccountSearchResult {
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public Decimal totalOppAmount { get; set; }
        @AuraEnabled public Integer oppCount { get; set; }

        public AccountSearchResult(Id accountId, String accountName, Decimal totalOppAmount, Integer oppCount) {
            this.accountId = accountId;
            this.accountName = accountName;
            this.totalOppAmount = totalOppAmount;
            this.oppCount = oppCount;
        }
    }

    /**
     * Searches accounts by name and returns aggregated opportunity amounts.
     * Uses a wildcard LIKE match: searchTerm is wrapped with % on both sides.
     *
     * @param searchTerm Partial or full account name to search for
     * @return List<AccountSearchResult> Accounts with total opportunity amounts
     */
    @AuraEnabled(cacheable=false)
    public static List<AccountSearchResult> searchAccounts(String searchTerm) {
        if (String.isBlank(searchTerm)) {
            return new List<AccountSearchResult>();
        }

        String likeTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';

        List<Account> accounts = [
            SELECT Id, Name,
                   (SELECT Id, Amount FROM Opportunities WHERE Amount != null)
            FROM Account
            WHERE Name LIKE :likeTerm
            ORDER BY Name
            LIMIT 50
        ];

        List<AccountSearchResult> results = new List<AccountSearchResult>();

        for (Account acc : accounts) {
            Decimal totalAmount = 0;
            Integer oppCount = 0;

            if (acc.Opportunities != null && !acc.Opportunities.isEmpty()) {
                oppCount = acc.Opportunities.size();
                for (Opportunity opp : acc.Opportunities) {
                    if (opp.Amount != null) {
                        totalAmount += opp.Amount;
                    }
                }
            }

            results.add(new AccountSearchResult(
                acc.Id,
                acc.Name,
                totalAmount,
                oppCount
            ));
        }

        return results;
    }
}