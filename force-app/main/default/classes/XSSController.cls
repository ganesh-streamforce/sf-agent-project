public class XSSController {

    public String getParam() {

        return ApexPages.currentPage()
            .getParameters()
            .get('input');
    }
}