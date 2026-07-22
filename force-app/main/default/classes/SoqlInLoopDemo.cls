public class SoqlInLoopDemo {
    public static void processIds(Set<Id> ids) {
        for (Id i : ids) {
            Account a = [SELECT Id, Name FROM Account WHERE Id = :i];
            System.debug(a);
        }
    }
}