public class ActionController {

    public PageReference deleteRecords() {

        delete [
            SELECT Id
            FROM Account
            LIMIT 1
        ];

        return null;
    }
}