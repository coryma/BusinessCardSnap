@IsTest
private class CM_BusinessCard_Ocr_Job_Test {
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
    static void testExecuteRecognizedAndExtraInsert() {
        ContentVersion cv = createContentVersion('ocr1');

        CM_BusinessCard__c seed = new CM_BusinessCard__c();
        seed.BatchId__c = 'batch-ocr-1';
        seed.ContentDocumentId__c = cv.ContentDocumentId;
        seed.ContentVersionId__c = cv.Id;
        seed.Status__c = 'Recognizing';
        seed.Seed__c = true;
        insert seed;

        CM_BusinessCard_Ocr_Job.TEST_LLM_OUTPUT =
            '```json\\n[' +
            '{\"Company\":\"Acme\",\"LastName\":\"Doe\",\"FirstName\":\"Jane\"},' +
            '{\"Company\":\"Beta\",\"LastName\":\"Roe\",\"FirstName\":\"John\"}' +
            ']\\n```';

        new CM_BusinessCard_Ocr_Job('batch-ocr-1').execute(null);

        List<CM_BusinessCard__c> rows = [
            SELECT Status__c, Seed__c, ExpectedCards__c, ProcessedCards__c, Company__c
            FROM CM_BusinessCard__c
            WHERE BatchId__c = 'batch-ocr-1'
            ORDER BY CreatedDate ASC
        ];
        System.assertEquals(2, rows.size());
        System.assertEquals(true, rows[0].Seed__c);
        System.assertEquals('Recognized', rows[0].Status__c);
        System.assertEquals(2, Integer.valueOf(rows[0].ExpectedCards__c));
        System.assertEquals(2, Integer.valueOf(rows[0].ProcessedCards__c));
        System.assertEquals(false, rows[1].Seed__c);
    }

    @IsTest
    static void testExecuteFailedNoCard() {
        ContentVersion cv = createContentVersion('ocr2');

        CM_BusinessCard__c seed = new CM_BusinessCard__c();
        seed.BatchId__c = 'batch-ocr-2';
        seed.ContentDocumentId__c = cv.ContentDocumentId;
        seed.ContentVersionId__c = cv.Id;
        seed.Status__c = 'Recognizing';
        seed.Seed__c = true;
        insert seed;

        CM_BusinessCard_Ocr_Job.TEST_LLM_OUTPUT = '[]';
        new CM_BusinessCard_Ocr_Job('batch-ocr-2').execute(null);

        CM_BusinessCard__c updated = [
            SELECT Status__c, ExpectedCards__c, ProcessedCards__c
            FROM CM_BusinessCard__c
            WHERE Id = :seed.Id
        ];
        System.assertEquals('Failed', updated.Status__c);
        System.assertEquals(1, Integer.valueOf(updated.ExpectedCards__c));
        System.assertEquals(1, Integer.valueOf(updated.ProcessedCards__c));
    }

    @IsTest
    static void testExecuteMissingContentDoc() {
        CM_BusinessCard__c seed = new CM_BusinessCard__c();
        seed.BatchId__c = 'batch-ocr-3';
        seed.Status__c = 'Recognizing';
        seed.Seed__c = true;
        insert seed;

        CM_BusinessCard_Ocr_Job.TEST_LLM_OUTPUT =
            '[{\"Company\":\"Acme\",\"LastName\":\"Doe\"}]';
        new CM_BusinessCard_Ocr_Job('batch-ocr-3').execute(null);

        CM_BusinessCard__c updated = [
            SELECT Status__c, Remark__c
            FROM CM_BusinessCard__c
            WHERE Id = :seed.Id
        ];
        System.assertEquals('Failed', updated.Status__c);
        System.assert(updated.Remark__c != null && updated.Remark__c.contains('ContentDocumentId not found'));
    }
}
