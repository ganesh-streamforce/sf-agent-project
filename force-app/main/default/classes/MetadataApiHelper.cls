// Shared helper — used by both CustomObjectCreator and CustomFieldCreator
global class MetadataApiHelper {

    global static Map<String, String> callMetadataApi(String metadataXml) {
        try {
            // Using Named Credential merge field instead of UserInfo.getSessionId()
            // because getSessionId() returns null in headless API/MCP contexts.
            String soap =
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                '<soapenv:Header><SessionHeader xmlns="http://soap.sforce.com/2006/04/metadata">' +
                '<sessionId>{!$Credential.OAuthToken}</sessionId>' +
                '</SessionHeader></soapenv:Header>' +
                '<soapenv:Body><createMetadata xmlns="http://soap.sforce.com/2006/04/metadata">' +
                metadataXml +
                '</createMetadata></soapenv:Body></soapenv:Envelope>';

            HttpRequest req = new HttpRequest();
            // Using the Named Credential
            req.setEndpoint('callout:Salesforce_Metadata_API/services/Soap/m/62.0');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml; charset=utf-8');
            req.setHeader('SOAPAction', '""');
            req.setBody(soap);
            req.setTimeout(120000);

            HttpResponse res = new Http().send(req);

            if (res.getStatusCode() == 200 && res.getBody().contains('<success>true</success>')) {
                return new Map<String, String>{ 'status' => 'success', 'message' => 'Created successfully.' };
            }
            String body = res.getBody();
            Pattern p = Pattern.compile('<message>(.*?)</message>');
            Matcher m = p.matcher(body);
            String errMsg = m.find() ? m.group(1) : body;
            return new Map<String, String>{ 'status' => 'error', 'message' => errMsg };
        } catch (Exception e) {
            return new Map<String, String>{ 'status' => 'error', 'message' => e.getMessage() };
        }
    }
}