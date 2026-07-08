@IsTest
private class CM_BusinessCard_Duplicate_Finder_Test {
    @IsTest
    static void testFindLeadDuplicateByPhone() {
        Lead existingLead = new Lead(
            LastName = 'Chen',
            Company = 'Acme',
            Phone = '02-2712-3456'
        );
        insert existingLead;

        CM_BusinessCard_Duplicate_Finder.Request requestRow = new CM_BusinessCard_Duplicate_Finder.Request();
        requestRow.targetObjectApiName = 'Lead';
        requestRow.phone = '(02) 2712-3456';

        List<CM_BusinessCard_Duplicate_Finder.Result> results =
            CM_BusinessCard_Duplicate_Finder.findDuplicates(
                new List<CM_BusinessCard_Duplicate_Finder.Request>{ requestRow }
            );

        System.assertEquals(1, results.size());
        System.assertEquals(existingLead.Id, results[0].matchedRecordId);
        System.assertEquals('Phone', results[0].matchedBy);
        System.assertEquals('Lead', results[0].targetObjectApiName);
    }

    @IsTest
    static void testFindContactDuplicateByEmailAndMobilePhoneFromJson() {
        Account existingAccount = new Account(Name = 'Beta Corp');
        insert existingAccount;

        Contact existingContact = new Contact(
            LastName = 'Wang',
            FirstName = 'Iris',
            Email = 'iris@example.com',
            MobilePhone = '0912-345-678',
            AccountId = existingAccount.Id
        );
        insert existingContact;

        List<CM_BusinessCard_Duplicate_Finder.Result> results =
            CM_BusinessCard_Duplicate_Finder.findDuplicatesForTarget(
                'Contact',
                '[{"Email":"IRIS@example.com","MobilePhone":"0912345678"}]'
            );

        System.assertEquals(1, results.size());
        System.assertEquals(existingContact.Id, results[0].matchedRecordId);
        System.assertEquals('Email;Phone', results[0].matchedBy);
        System.assertEquals('Contact', results[0].targetObjectApiName);
        System.assertEquals('Iris Wang', results[0].matchedRecordLabel);
    }
}