public class HelloWorld {
    
    public static String sayHello() {
        return 'Hello, World!';
    }
    
    public static String sayHelloTo(String name) {
        if (String.isBlank(name)) {
            return 'Hello, World!';
        }
        return 'Hello, ' + name + '!';
    }

}