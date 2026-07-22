public class LoopLimitsDemo {
    public static void process(List<Account> accs) {
        for (Account a : accs) {
            update a;
        }
    }
}