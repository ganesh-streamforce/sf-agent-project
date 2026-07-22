/**
 * @description
 * Service class that demonstrates PMD-compliant
 * CRUD operations on Account records.
 */
public with sharing class CompliantAccountService {

    /**
     * @description
     * Retrieves Account records for the supplied Ids.
     *
     * @param accountIds
     * Set of Account record Ids to query.
     *
     * @return
     * List<Account> containing matching records.
     */
    public static List<Account> getAccounts(
        Set<Id> accountIds
    ) {

        if (accountIds == null ||
            accountIds.isEmpty()) {

            return new List<Account>();
        }

        if (!Schema.sObjectType.Account.isAccessible()) {

            return new List<Account>();
        }

        return [
            SELECT Id,
                   Name
            FROM Account
            WHERE Id IN :accountIds
        ];
    }

    /**
     * @description
     * Updates Account records after validating
     * update permissions.
     *
     * @param accountsToUpdate
     * List of Account records to update.
     */
    public static void updateAccounts(
        List<Account> accountsToUpdate
    ) {

        if (accountsToUpdate == null ||
            accountsToUpdate.isEmpty()) {

            return;
        }

        if (!Schema.sObjectType.Account.isUpdateable()) {

            return;
        }

        update accountsToUpdate;
    }
}