@IsTest
private class CM_BusinessCard_Utility_Test {
    private static ContentVersion createContentVersion(String title) {
        ContentVersion cv = new ContentVersion();
        cv.Title = title;
        cv.PathOnClient = title + '.png';
        cv.VersionData = Blob.valueOf('test-' + title);
        insert cv;
        return [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];
    }

    @IsTest
    static void testParseStringArray() {
        CM_BusinessCard_Parse_String_Array.Input in1 = new CM_BusinessCard_Parse_String_Array.Input();
        in1.json = '["068AAA","069BBB"]';
        CM_BusinessCard_Parse_String_Array.Input in2 = new CM_BusinessCard_Parse_String_Array.Input();
        in2.json = '068CCC';
        CM_BusinessCard_Parse_String_Array.Input in3 = new CM_BusinessCard_Parse_String_Array.Input();
        in3.json = 'not-json';

        List<CM_BusinessCard_Parse_String_Array.Output> out =
            CM_BusinessCard_Parse_String_Array.run(new List<CM_BusinessCard_Parse_String_Array.Input>{ in1, in2, in3 });

        System.assertEquals(3, out.size());
        System.assertEquals(2, out[0].values.size());
        System.assertEquals('068CCC', out[1].values[0]);
        System.assertEquals('not-json', out[2].values[0]);
    }

    @IsTest
    static void testJsonParser() {
        String json = '[' +
            '{\"Company\":\"Acme\",\"LastName\":\"\",\"FirstName\":\"Jane\",\"CreateAs\":\"Lead\",\"LeadSource\":\"Cold Call\"},' +
            '{\"Company\":\"Beta\",\"LastName\":\"Roe\",\"FirstName\":\"John\",\"CreateAs\":\"Contact\",\"ExistingAccountId\":\"001000000000001AAA\"}' +
            ']';

        List<List<Business_Card_Processed__e>> outputs =
            CM_BusinessCard_Json_Parser.parseJsonToEvents(new List<String>{ json });

        System.assertEquals(1, outputs.size());
        System.assertEquals(2, outputs[0].size());
        System.assertEquals('Jane', outputs[0][0].LastName__c);
        System.assertEquals('Acme', outputs[0][0].Company__c);
        System.assertEquals('001000000000001AAA', outputs[0][1].Matched_Account_Id__c);
    }

    @IsTest
    static void testImageHelper() {
        ContentVersion cv = createContentVersion('img1');

        Id docId = CM_BusinessCard_Image_Helper.getDocIdFromVersion(cv.Id);
        System.assertEquals(cv.ContentDocumentId, docId);

        Id docId2 = CM_BusinessCard_Image_Helper.getDocIdFromVersion(cv.ContentDocumentId);
        System.assertEquals(cv.ContentDocumentId, docId2);
    }

    @IsTest
    static void testLeadSourceValidator() {
        String valid = null;
        for (Schema.PicklistEntry pe : Lead.LeadSource.getDescribe().getPicklistValues()) {
            if (pe.isActive()) {
                valid = pe.getValue();
                break;
            }
        }
        System.assertNotEquals(null, valid, 'Expected a LeadSource value');

        CM_BusinessCard_LeadSource_Validator.Request req1 = new CM_BusinessCard_LeadSource_Validator.Request();
        req1.leadSource = ' ' + valid.toLowerCase() + ' ';
        CM_BusinessCard_LeadSource_Validator.Request req2 = new CM_BusinessCard_LeadSource_Validator.Request();
        req2.leadSource = 'NotARealValue';

        List<CM_BusinessCard_LeadSource_Validator.Result> res =
            CM_BusinessCard_LeadSource_Validator.validate(
                new List<CM_BusinessCard_LeadSource_Validator.Request>{ req1, req2 }
            );
        System.assertEquals(true, res[0].isValid);
        System.assertEquals(valid, res[0].normalized);
        System.assertEquals(false, res[1].isValid);
    }

    @IsTest
    static void testCleanup() {
        ContentVersion cv = createContentVersion('cleanup1');

        CM_BusinessCard__c card = new CM_BusinessCard__c();
        card.Status__c = 'Recognized';
        card.ContentDocumentId__c = cv.ContentDocumentId;
        insert card;

        CM_BusinessCard_Cleanup.Request req = new CM_BusinessCard_Cleanup.Request();
        req.retentionDays = -1;
        req.deleteFiles = true;
        CM_BusinessCard_Cleanup.run(new List<CM_BusinessCard_Cleanup.Request>{ req });

        System.assertEquals(0, [SELECT count() FROM CM_BusinessCard__c WHERE Id = :card.Id]);
    }
}
