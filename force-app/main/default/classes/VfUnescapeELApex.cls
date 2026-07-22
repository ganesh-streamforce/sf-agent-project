public class VfUnescapeELApex {

    public String someVar { get; set; }

    public VfUnescapeELApex() {
        someVar = ApexPages.currentPage()
            .getParameters()
            .get('q');
    }
}