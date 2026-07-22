public class HardcodedIdDemo {
    public Account getDefault() {
        return [
    SELECT Id
    FROM Account
    WHERE Id = '001x000xxx35tPN'
];
    }
}