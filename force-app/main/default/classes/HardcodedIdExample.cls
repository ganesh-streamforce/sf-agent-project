public class HardcodedIdExample {
    public void testMethod1() {
        Account acc = [
            SELECT Id
            FROM Account
            WHERE Id = '0015g00000ABCDe'
        ];
    }
}