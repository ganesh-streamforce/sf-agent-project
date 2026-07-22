global class CustomObjectCreator {

    global class Request {
        @InvocableVariable(required=true label='Object API Name' description='API name e.g. MyObject or MyObject__c')
        global String objectApiName;

        @InvocableVariable(required=true label='Label' description='Singular label e.g. My Object')
        global String label;

        @InvocableVariable(required=true label='Plural Label' description='Plural label e.g. My Objects')
        global String pluralLabel;
    }

    global class Response {
        @InvocableVariable global Boolean isSuccess;
        @InvocableVariable global String message;
    }

    @InvocableMethod(
        label='Create Custom Object'
        description='Creates a new custom object in Salesforce.'
        category='Schema'
        callout=true
    )
    global static List<Response> execute(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request req : requests) {
            Response res = new Response();
            try {
                if (String.isBlank(req.objectApiName) || String.isBlank(req.label) || String.isBlank(req.pluralLabel)) {
                    res.isSuccess = false;
                    res.message = 'objectApiName, label, and pluralLabel are all required.';
                    responses.add(res);
                    continue;
                }
                String apiName = req.objectApiName;
                if (!apiName.endsWith('__c')) apiName += '__c';

                String metadata =
                    '<metadata xsi:type="CustomObject">' +
                    '<fullName>' + esc(apiName) + '</fullName>' +
                    '<label>' + esc(req.label) + '</label>' +
                    '<pluralLabel>' + esc(req.pluralLabel) + '</pluralLabel>' +
                    '<deploymentStatus>Deployed</deploymentStatus>' +
                    '<sharingModel>ReadWrite</sharingModel>' +
                    '<nameField><label>' + esc(req.label) + ' Name</label><type>Text</type></nameField>' +
                    '</metadata>';

                Map<String, String> result = MetadataApiHelper.callMetadataApi(metadata);
                res.isSuccess = result.get('status') == 'success';
                res.message = result.get('message');
            } catch (Exception e) {
                res.isSuccess = false;
                res.message = e.getMessage();
            }
            responses.add(res);
        }
        return responses;
    }

    private static String esc(String s) {
        return s == null ? '' : s.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('"','&quot;');
    }
}