global class CustomFieldCreator {

    global class Request {
        @InvocableVariable(required=true label='Object API Name' description='Parent object e.g. Account or MyObject__c')
        global String objectApiName;

        @InvocableVariable(required=true label='Field API Name' description='Field name e.g. MyField or MyField__c')
        global String fieldApiName;

        @InvocableVariable(required=true label='Field Label' description='Display label e.g. My Field')
        global String fieldLabel;

        @InvocableVariable(required=true label='Field Type' description='Text, Number, Checkbox, Date, DateTime, Email, Phone, URL, Percent, Currency, TextArea, LongTextArea, RichTextArea, Picklist, MultiselectPicklist, Lookup, MasterDetail')
        global String fieldType;

        @InvocableVariable(label='Field Length' description='Length for Text (default 255) or LongTextArea/RichTextArea (default 32768)')
        global Integer fieldLength;

        @InvocableVariable(label='Precision' description='Total digits for Number/Currency/Percent (default 18)')
        global Integer fieldPrecision;

        @InvocableVariable(label='Scale' description='Decimal places for Number/Currency/Percent (default 0)')
        global Integer fieldScale;

        @InvocableVariable(label='Picklist Values' description='Comma-separated values e.g. Red,Blue,Green')
        global String picklistValues;

        @InvocableVariable(label='Related To Object' description='Target object for Lookup/MasterDetail e.g. Account')
        global String relatedToObject;
    }

    global class Response {
        @InvocableVariable global Boolean isSuccess;
        @InvocableVariable global String message;
    }

    @InvocableMethod(
        label='Create Custom Field'
        description='Creates a new custom field on any standard or custom object.'
        category='Schema'
        callout=true
    )
    global static List<Response> execute(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request req : requests) {
            Response res = new Response();
            try {
                if (String.isBlank(req.objectApiName) || String.isBlank(req.fieldApiName) ||
                    String.isBlank(req.fieldLabel) || String.isBlank(req.fieldType)) {
                    res.isSuccess = false;
                    res.message = 'objectApiName, fieldApiName, fieldLabel, and fieldType are all required.';
                    responses.add(res);
                    continue;
                }

                String fldName = req.fieldApiName;
                if (!fldName.endsWith('__c')) fldName += '__c';

                String sfType = normType(req.fieldType);
                if (sfType == null) {
                    res.isSuccess = false;
                    res.message = 'Unsupported type: ' + req.fieldType;
                    responses.add(res);
                    continue;
                }

                String fullName = req.objectApiName + '.' + fldName;
                String xml = '<fullName>' + esc(fullName) + '</fullName>' +
                             '<label>' + esc(req.fieldLabel) + '</label>' +
                             '<type>' + sfType + '</type>';

                if (sfType == 'Checkbox') {
                    xml += '<defaultValue>false</defaultValue>';
                }
                if (sfType == 'Text') {
                    xml += '<length>' + (req.fieldLength != null ? req.fieldLength : 255) + '</length>';
                }
                else if (sfType == 'LongTextArea' || sfType == 'RichTextArea') {
                    xml += '<length>' + (req.fieldLength != null ? req.fieldLength : 32768) + '</length>';
                    xml += '<visibleLines>5</visibleLines>';
                }
                else if (sfType == 'Number' || sfType == 'Currency' || sfType == 'Percent') {
                    xml += '<precision>' + (req.fieldPrecision != null ? req.fieldPrecision : 18) + '</precision>';
                    xml += '<scale>' + (req.fieldScale != null ? req.fieldScale : 0) + '</scale>';
                }
                else if (sfType == 'Picklist' || sfType == 'MultiselectPicklist') {
                    xml += '<valueSet><restricted>true</restricted><valueSetDefinition><sorted>false</sorted>';
                    if (String.isNotBlank(req.picklistValues)) {
                        for (String v : req.picklistValues.split(',')) {
                            v = v.trim();
                            if (String.isNotBlank(v)) {
                                xml += '<value><fullName>' + esc(v) + '</fullName><default>false</default><label>' + esc(v) + '</label></value>';
                            }
                        }
                    }
                    xml += '</valueSetDefinition></valueSet>';
                    if (sfType == 'MultiselectPicklist') xml += '<visibleLines>4</visibleLines>';
                }
                else if (sfType == 'Lookup' || sfType == 'MasterDetail') {
                    String relObj = String.isNotBlank(req.relatedToObject) ? req.relatedToObject : 'Account';
                    String relName = fldName.replace('__c', '') + 's';
                    xml += '<referenceTo>' + esc(relObj) + '</referenceTo>';
                    xml += '<relationshipLabel>' + esc(req.fieldLabel) + '</relationshipLabel>';
                    xml += '<relationshipName>' + esc(relName) + '</relationshipName>';
                    if (sfType == 'MasterDetail') {
                        xml += '<relationshipOrder>0</relationshipOrder>';
                        xml += '<reparentableMasterDetail>false</reparentableMasterDetail>';
                        xml += '<writeRequiresMasterRead>false</writeRequiresMasterRead>';
                    }
                }

                String metadata = '<metadata xsi:type="CustomField">' + xml + '</metadata>';
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

    private static String normType(String t) {
        if (String.isBlank(t)) return null;
        Map<String, String> m = new Map<String, String>{
            'text'=>'Text','number'=>'Number','checkbox'=>'Checkbox','date'=>'Date',
            'datetime'=>'DateTime','email'=>'Email','phone'=>'Phone','url'=>'Url',
            'percent'=>'Percent','currency'=>'Currency','textarea'=>'TextArea',
            'longtextarea'=>'LongTextArea','richtextarea'=>'RichTextArea',
            'picklist'=>'Picklist','multiselectpicklist'=>'MultiselectPicklist',
            'lookup'=>'Lookup','masterdetail'=>'MasterDetail'
        };
        return m.get(t.trim().toLowerCase());
    }
}