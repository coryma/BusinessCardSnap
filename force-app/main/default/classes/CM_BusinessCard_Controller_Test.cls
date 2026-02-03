@IsTest
private class CM_BusinessCard_Controller_Test {
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
    static void testControllerCore() {
        ContentVersion cv1 = createContentVersion('cv1');
        ContentVersion cv2 = createContentVersion('cv2');

        CM_BusinessCard_Controller.InitResult res = CM_BusinessCard_Controller.initBatchAndPersist(
            new List<Id>{ cv1.Id, cv2.ContentDocumentId }
        );
        System.assertNotEquals(null, res.batchId, 'batchId should be set');
        System.assertEquals(2, res.createdCount, 'should create two seed rows');

        List<CM_BusinessCard__c> cards = [
            SELECT Id, BatchId__c, ContentVersionId__c, ContentDocumentId__c
            FROM CM_BusinessCard__c
            WHERE BatchId__c = :res.batchId
            ORDER BY CreatedDate ASC
        ];
        System.assertEquals(2, cards.size());

        Integer i = 0;
        for (CM_BusinessCard__c c : cards) {
            c.Status__c = 'Recognized';
            c.Company__c = i == 0 ? 'Acme' : 'Beta';
            c.LastName__c = 'Last' + i;
            c.FirstName__c = 'First' + i;
            c.ExpectedCards__c = 1;
            c.ProcessedCards__c = 1;
            i++;
        }
        update cards;

        List<Id> seedIds = CM_BusinessCard_Controller.getSeedVersionIdsByBatch(res.batchId);
        System.assertEquals(2, seedIds.size());

        CM_BusinessCard_Controller.BatchProgress bp = CM_BusinessCard_Controller.getBatchProgress(res.batchId);
        System.assertEquals('ALL_RECOGNIZED', bp.status);

        List<CM_BusinessCard_Controller.CM_CardData> byBatch =
            CM_BusinessCard_Controller.getCardsByBatch(res.batchId);
        System.assertEquals(2, byBatch.size());

        List<CM_BusinessCard_Controller.CM_CardData> byVersionNoBatch =
            CM_BusinessCard_Controller.getCardsByVersion((Id) cards[0].ContentVersionId__c, null);
        System.assertEquals(1, byVersionNoBatch.size());

        List<CM_BusinessCard_Controller.CM_CardData> byVersionWithBatch =
            CM_BusinessCard_Controller.getCardsByVersion((Id) cards[0].ContentVersionId__c, res.batchId);
        System.assertEquals(1, byVersionWithBatch.size());

        CM_BusinessCard_Controller.updateDescriptions(res.batchId, new List<String>{ 'd1', 'd2' });
        CM_BusinessCard_Controller.updateDescriptionsForVersion(
            (Id) cards[0].ContentVersionId__c,
            new List<String>{ 'vd1' },
            res.batchId
        );

        CM_BusinessCard_Controller.BatchProgress bp2 =
            CM_BusinessCard_Controller.getProgressByVersionId((Id) cards[0].ContentDocumentId__c);
        System.assertEquals('ALL_RECOGNIZED', bp2.status);

        List<CM_BusinessCard_Controller.CM_CardData> byVersionId =
            CM_BusinessCard_Controller.getCardsByVersionId((Id) cards[0].ContentDocumentId__c);
        System.assertEquals(1, byVersionId.size());

        insert new Account(Name = 'Acme');
        List<CM_BusinessCard_Controller.AccountMatch> matches =
            CM_BusinessCard_Controller.findAccountDuplicates(new List<String>{ 'Acme', 'acme', 'Other' });
        System.assertEquals(3, matches.size());
        System.assert(matches[0].accounts.size() > 0, 'should match existing account');
    }

    @IsTest
    static void testGetCardProcessingResultMock() {
        CM_BusinessCard_Controller.TEST_LLM_OUTPUT =
            '[{\"Company\":\"Acme\",\"LastName\":\"Doe\",\"FirstName\":\"Jane\"}]';
        List<CM_BusinessCard_Controller.CM_CardData> out =
            CM_BusinessCard_Controller.getCardProcessingResult('069000000000000AAA');
        System.assertEquals(1, out.size());
        System.assertEquals('Acme', out[0].Company);
    }
}
