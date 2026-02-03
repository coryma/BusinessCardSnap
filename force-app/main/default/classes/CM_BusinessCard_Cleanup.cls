public with sharing class CM_BusinessCard_Cleanup {
    public class Request {
        @InvocableVariable
        public Integer retentionDays;

        @InvocableVariable
        public Boolean deleteFiles;
    }

    @InvocableMethod(label='Cleanup Business Cards' description='Deletes old CM_BusinessCard__c records and optionally deletes related files.')
    public static void run(List<Request> requests) {
        Integer retentionDays = 30;
        Boolean deleteFiles = false;
        if (requests != null && !requests.isEmpty()) {
            Request req = requests[0];
            if (req != null) {
                if (req.retentionDays != null) {
                    retentionDays = req.retentionDays;
                }
                if (req.deleteFiles != null) {
                    deleteFiles = req.deleteFiles;
                }
            }
        }

        Datetime cutoff = System.now().addDays(-retentionDays);
        List<CM_BusinessCard__c> cards = [
            SELECT Id, ContentDocumentId__c
            FROM CM_BusinessCard__c
            WHERE Status__c IN ('Recognized', 'Failed')
            AND LastModifiedDate <= :cutoff
        ];
        if (cards.isEmpty()) {
            return;
        }

        Set<Id> docIds = new Set<Id>();
        for (CM_BusinessCard__c card : cards) {
            if (String.isNotBlank(card.ContentDocumentId__c)) {
                docIds.add((Id) card.ContentDocumentId__c);
            }
        }

        Database.delete(cards, false);

        if (!deleteFiles || docIds.isEmpty()) {
            return;
        }

        for (AggregateResult ar : [
            SELECT ContentDocumentId__c docId
            FROM CM_BusinessCard__c
            WHERE ContentDocumentId__c IN :docIds
            GROUP BY ContentDocumentId__c
        ]) {
            Id stillUsed = (Id) ar.get('docId');
            if (stillUsed != null) {
                docIds.remove(stillUsed);
            }
        }

        if (docIds.isEmpty()) {
            return;
        }

        List<ContentDocument> docs = [
            SELECT Id
            FROM ContentDocument
            WHERE Id IN :docIds
        ];
        if (!docs.isEmpty()) {
            Database.delete(docs, false);
        }
    }
}
