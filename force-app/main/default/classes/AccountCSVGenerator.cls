public with sharing class AccountCSVGenerator {
    public static void generateAccountsCSVFile() {
        // 1. Calculate yesterday's date range
        Date yesterday = Date.today().addDays(-1);
        Datetime startOfYesterday = Datetime.newInstance(yesterday, Time.newInstance(0, 0, 0, 0));
        Datetime endOfYesterday = Datetime.newInstance(yesterday, Time.newInstance(23, 59, 59, 999));

        // 2. Query Accounts created yesterday
        List<Account> accounts = [
            SELECT Id, Name, Industry, Phone, CreatedDate
            FROM Account
            WHERE CreatedDate >= :startOfYesterday AND CreatedDate <= :endOfYesterday
        ];

        // 3. Generate CSV Content (headers first)
        String csvContent = 'Id,Name,Industry,Phone,CreatedDate\n';

        String fileName;
        if (accounts.isEmpty()) {
            System.debug('No Accounts created yesterday. Generating empty CSV.');
            fileName = 'No Data is There -' + yesterday.format() + '.csv';
        } else {
            for (Account acc : accounts) {
                csvContent += 
                    '"' + acc.Id + '",' +
                    '"' + acc.Name + '",' +
                    '"' + (acc.Industry != null ? acc.Industry : '') + '",' +
                    '"' + (acc.Phone != null ? acc.Phone : '') + '",' +
                    '"' + acc.CreatedDate.format() + '"\n';
            }
            fileName = 'Accounts-' + yesterday.format() + '.csv';
        }

        // 4. Create the CSV file (ContentVersion)
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = fileName.replace('.csv', '');
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = Blob.valueOf(csvContent);
        contentVersion.IsMajorVersion = true;

        insert contentVersion;

        System.debug('CSV File created with title: ' + contentVersion.Title);
    }
}