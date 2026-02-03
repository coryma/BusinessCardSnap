public with sharing class CM_BusinessCard_Json_Parser {
    @InvocableMethod(label='Parse Business Card JSON to Events' description='Parses a JSON string of business cards into a collection of Business Card Processed platform events.')
    public static List<List<Business_Card_Processed__e>> parseJsonToEvents(List<String> jsonStrings) {
        List<List<Business_Card_Processed__e>> outputs = new List<List<Business_Card_Processed__e>>();
        if (jsonStrings == null || jsonStrings.isEmpty()) {
            outputs.add(new List<Business_Card_Processed__e>());
            return outputs;
        }

        Integer position = 0;
        for (String rawJson : jsonStrings) {
            position++;
            List<Business_Card_Processed__e> events = new List<Business_Card_Processed__e>();

            if (String.isBlank(rawJson)) {
                outputs.add(events);
                continue;
            }

            try {
                List<CM_BusinessCard_Controller.CM_CardData> cardDataList =
                    (List<CM_BusinessCard_Controller.CM_CardData>) JSON.deserialize(
                        rawJson,
                        List<CM_BusinessCard_Controller.CM_CardData>.class
                    );

                if (cardDataList != null) {
                    for (CM_BusinessCard_Controller.CM_CardData card : cardDataList) {
                        if (card == null) {
                            continue;
                        }
                        events.add(buildEvent(card));
                    }
                }
            } catch (Exception ex) {
                throw new FlowException(String.format(
                    Label.CM_BC_Err_JsonParseFailed,
                    new List<String>{ String.valueOf(position), String.valueOf(ex.getMessage()) }
                ));
            }

            outputs.add(events);
        }

        return outputs;
    }

    private static Business_Card_Processed__e buildEvent(CM_BusinessCard_Controller.CM_CardData card) {
        Business_Card_Processed__e eventRecord = new Business_Card_Processed__e();
        eventRecord.FirstName__c = clean(card.FirstName);
        eventRecord.LastName__c = fallbackLastName(card);
        eventRecord.Company__c = fallbackCompany(card);
        eventRecord.Title__c = clean(card.Title);
        eventRecord.Email__c = clean(card.Email);
        eventRecord.Phone__c = clean(card.Phone);
        eventRecord.MobilePhone__c = clean(card.MobilePhone);
        eventRecord.Street__c = clean(card.Street);
        eventRecord.City__c = clean(card.City);
        eventRecord.State__c = clean(card.State);
        eventRecord.PostalCode__c = clean(card.PostalCode);
        eventRecord.Country__c = clean(card.Country);
        eventRecord.Description__c = buildDescription(card);
        String createAs = resolveCreateAs(card);
        eventRecord.Create_As__c = createAs;
        eventRecord.LeadSource__c = clean(card.LeadSource);
        eventRecord.Matched_Account_Id__c = 'Contact'.equalsIgnoreCase(createAs)
            ? clean(card.ExistingAccountId)
            : null;
        return eventRecord;
    }

    private static String clean(String value) {
        return String.isBlank(value) ? null : value.trim();
    }

    private static String buildDescription(CM_BusinessCard_Controller.CM_CardData card) {
        List<String> parts = new List<String>();
        if (String.isNotBlank(card.Remark)) {
            parts.add(String.format(
                Label.CM_BC_Remark_Prefix,
                new List<String>{ card.Remark.trim() }
            ));
        }
        if (String.isNotBlank(card.Description)) {
            parts.add(card.Description.trim());
        }
        return parts.isEmpty() ? null : String.join(parts, '\n---\n');
    }

    private static String resolveCreateAs(CM_BusinessCard_Controller.CM_CardData card) {
        String desired = clean(card.CreateAs);
        if (desired == null) {
            return 'Lead';
        }
        if ('Contact'.equalsIgnoreCase(desired) && String.isNotBlank(card.ExistingAccountId)) {
            return 'Contact';
        }
        return 'Lead';
    }

    private static String fallbackLastName(CM_BusinessCard_Controller.CM_CardData card) {
        String lastName = clean(card.LastName);
        if (lastName != null) {
            return lastName;
        }
        String firstName = clean(card.FirstName);
        if (firstName != null) {
            return firstName;
        }
        String company = clean(card.Company);
        if (company != null) {
            return company;
        }
        return Label.CM_BC_Fallback_BusinessCard;
    }

    private static String fallbackCompany(CM_BusinessCard_Controller.CM_CardData card) {
        String company = clean(card.Company);
        if (company != null) {
            return company;
        }
        String lastName = clean(card.LastName);
        if (lastName != null) {
            return lastName;
        }
        String firstName = clean(card.FirstName);
        if (firstName != null) {
            return firstName;
        }
        return Label.CM_BC_Fallback_BusinessCard;
    }
}
