public with sharing class CM_BusinessCard_Duplicate_Finder {
    // Query with the last 4 digits so formatted values like 02-2712-3456 still surface
    // as candidates, then rely on normalized exact matching to eliminate false positives.
    private static final Integer PHONE_SUFFIX_LEN = 4;
    private static final Integer MAX_QUERY_ROWS = 500;

    public class Request {
        @InvocableVariable(required=true)
        public String targetObjectApiName;
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String phone;
        @InvocableVariable
        public String mobilePhone;
    }

    public class Result {
        @AuraEnabled
        @InvocableVariable
        public String matchedRecordId;
        @AuraEnabled
        @InvocableVariable
        public String matchedBy;
        @AuraEnabled
        @InvocableVariable
        public String matchedRecordLabel;
        @AuraEnabled
        @InvocableVariable
        public String targetObjectApiName;
    }

    private class Probe {
        String email;
        String normalizedEmail;
        Set<String> normalizedPhones = new Set<String>();
        Set<String> phoneSuffixes = new Set<String>();
    }

    private class MatchEval {
        Integer score = 0;
        List<String> matchedKeys = new List<String>();
    }

    @InvocableMethod(
        label='Find Lead / Contact Duplicate'
        description='Finds an existing Lead or Contact by email or phone.'
    )
    public static List<Result> findDuplicates(List<Request> requests) {
        String targetObjectApiName = getTargetObjectFromRequests(requests);
        List<Probe> probes = toProbes(requests);
        return findDuplicatesForProbes(targetObjectApiName, probes);
    }

    @AuraEnabled(cacheable=false)
    public static List<Result> findDuplicatesForTarget(String targetObjectApiName, String cardsJson) {
        return findDuplicatesForProbes(targetObjectApiName, toProbes(cardsJson));
    }

    private static List<Result> findDuplicatesForProbes(String targetObjectApiName, List<Probe> probes) {
        List<Result> outputs = new List<Result>();
        for (Integer i = 0; i < probes.size(); i++) {
            outputs.add(emptyResult(targetObjectApiName));
        }
        if (!isSupportedTarget(targetObjectApiName) || probes.isEmpty()) {
            return outputs;
        }

        List<SObject> candidates = queryCandidates(targetObjectApiName, probes);
        for (Integer i = 0; i < probes.size(); i++) {
            outputs[i] = findBestMatch(targetObjectApiName, probes[i], candidates);
        }
        return outputs;
    }

    private static Result findBestMatch(String targetObjectApiName, Probe probe, List<SObject> candidates) {
        Result best = emptyResult(targetObjectApiName);
        Integer bestScore = 0;

        for (SObject candidate : candidates) {
            MatchEval eval = evaluateMatch(probe, candidate);
            if (eval.score <= 0) {
                continue;
            }
            if (eval.score > bestScore) {
                bestScore = eval.score;
                best = emptyResult(targetObjectApiName);
                best.matchedRecordId = String.valueOf(candidate.get('Id'));
                best.matchedBy = String.join(eval.matchedKeys, ';');
                best.matchedRecordLabel = buildRecordLabel(targetObjectApiName, candidate);
            }
        }
        return best;
    }

    private static MatchEval evaluateMatch(Probe probe, SObject candidate) {
        MatchEval eval = new MatchEval();
        if (probe == null) {
            return eval;
        }

        String candidateEmail = normalizeEmail((String) candidate.get('Email'));
        if (probe.normalizedEmail != null && candidateEmail == probe.normalizedEmail) {
            eval.matchedKeys.add('Email');
            eval.score += 10;
        }

        Set<String> candidatePhones = new Set<String>();
        addPhoneKey(candidatePhones, normalizePhone((String) candidate.get('Phone')));
        addPhoneKey(candidatePhones, normalizePhone((String) candidate.get('MobilePhone')));
        if (hasPhoneIntersection(probe.normalizedPhones, candidatePhones)) {
            eval.matchedKeys.add('Phone');
            eval.score += 5;
        }
        return eval;
    }

    private static Boolean hasPhoneIntersection(Set<String> probePhones, Set<String> candidatePhones) {
        if (probePhones == null || candidatePhones == null || probePhones.isEmpty() || candidatePhones.isEmpty()) {
            return false;
        }
        for (String phone : probePhones) {
            if (candidatePhones.contains(phone)) {
                return true;
            }
        }
        return false;
    }

    private static List<SObject> queryCandidates(String targetObjectApiName, List<Probe> probes) {
        Set<String> emailValues = new Set<String>();
        Set<String> phoneSuffixes = new Set<String>();
        for (Probe probe : probes) {
            if (probe == null) {
                continue;
            }
            if (probe.email != null) {
                emailValues.add(probe.email);
            }
            phoneSuffixes.addAll(probe.phoneSuffixes);
        }

        List<String> whereParts = new List<String>();
        if (!emailValues.isEmpty()) {
            whereParts.add('Email IN (' + joinQuotedValues(emailValues) + ')');
        }
        for (String suffix : phoneSuffixes) {
            if (String.isBlank(suffix)) {
                continue;
            }
            String escaped = String.escapeSingleQuotes(suffix);
            whereParts.add('Phone LIKE \'%' + escaped + '\'');
            whereParts.add('MobilePhone LIKE \'%' + escaped + '\'');
        }
        if (whereParts.isEmpty()) {
            return new List<SObject>();
        }

        String query =
            'SELECT Id, Email, Phone, MobilePhone, LastModifiedDate, FirstName, LastName'
            + (targetObjectApiName == 'Lead' ? ', Company' : '')
            + ' FROM ' + targetObjectApiName
            + ' WHERE ' + String.join(whereParts, ' OR ')
            + ' ORDER BY LastModifiedDate DESC NULLS LAST LIMIT ' + MAX_QUERY_ROWS;
        return Database.query(query);
    }

    private static String buildRecordLabel(String targetObjectApiName, SObject candidate) {
        List<String> parts = new List<String>();
        String firstName = clean((String) candidate.get('FirstName'));
        String lastName = clean((String) candidate.get('LastName'));
        if (firstName != null) {
            parts.add(firstName);
        }
        if (lastName != null) {
            parts.add(lastName);
        }
        String name = String.join(parts, ' ').trim();
        if (String.isNotBlank(name)) {
            return name;
        }
        if (targetObjectApiName == 'Lead') {
            String company = clean((String) candidate.get('Company'));
            if (company != null) {
                return company;
            }
        }
        String email = clean((String) candidate.get('Email'));
        if (email != null) {
            return email;
        }
        return targetObjectApiName;
    }

    private static Result emptyResult(String targetObjectApiName) {
        Result out = new Result();
        out.targetObjectApiName = targetObjectApiName;
        out.matchedRecordId = null;
        out.matchedBy = null;
        out.matchedRecordLabel = null;
        return out;
    }

    private static List<Probe> toProbes(List<Request> requests) {
        List<Probe> probes = new List<Probe>();
        if (requests == null) {
            return probes;
        }
        for (Request req : requests) {
            Probe probe = new Probe();
            if (req != null) {
                hydrateProbe(probe, req.email, req.phone, req.mobilePhone);
            }
            probes.add(probe);
        }
        return probes;
    }

    private static List<Probe> toProbes(String cardsJson) {
        List<Probe> probes = new List<Probe>();
        if (String.isBlank(cardsJson)) {
            return probes;
        }

        Object raw = JSON.deserializeUntyped(cardsJson);
        if (!(raw instanceof List<Object>)) {
            return probes;
        }

        for (Object item : (List<Object>) raw) {
            Probe probe = new Probe();
            if (item instanceof Map<String, Object>) {
                Map<String, Object> row = (Map<String, Object>) item;
                hydrateProbe(
                    probe,
                    row.containsKey('Email') ? String.valueOf(row.get('Email')) : null,
                    row.containsKey('Phone') ? String.valueOf(row.get('Phone')) : null,
                    row.containsKey('MobilePhone') ? String.valueOf(row.get('MobilePhone')) : null
                );
            }
            probes.add(probe);
        }
        return probes;
    }

    private static void hydrateProbe(Probe probe, String email, String phone, String mobilePhone) {
        probe.email = clean(email);
        probe.normalizedEmail = normalizeEmail(email);
        addPhoneKey(probe.normalizedPhones, normalizePhone(phone));
        addPhoneKey(probe.normalizedPhones, normalizePhone(mobilePhone));
        for (String normalizedPhone : probe.normalizedPhones) {
            probe.phoneSuffixes.add(phoneSuffix(normalizedPhone));
        }
    }

    private static String getTargetObjectFromRequests(List<Request> requests) {
        if (requests == null) {
            return null;
        }
        for (Request req : requests) {
            if (req != null && String.isNotBlank(req.targetObjectApiName)) {
                return req.targetObjectApiName.trim();
            }
        }
        return null;
    }

    private static Boolean isSupportedTarget(String targetObjectApiName) {
        return targetObjectApiName == 'Lead' || targetObjectApiName == 'Contact';
    }

    private static String normalizeEmail(String value) {
        String cleaned = clean(value);
        return cleaned == null ? null : cleaned.toLowerCase();
    }

    private static String normalizePhone(String value) {
        String cleaned = clean(value);
        if (cleaned == null) {
            return null;
        }
        String digits = cleaned.replaceAll('[^0-9]', '');
        return String.isBlank(digits) ? null : digits;
    }

    private static String phoneSuffix(String digits) {
        if (String.isBlank(digits)) {
            return null;
        }
        return digits.length() <= PHONE_SUFFIX_LEN
            ? digits
            : digits.substring(digits.length() - PHONE_SUFFIX_LEN);
    }

    private static void addPhoneKey(Set<String> target, String value) {
        if (target != null && String.isNotBlank(value)) {
            target.add(value);
        }
    }

    private static String clean(String value) {
        return String.isBlank(value) ? null : value.trim();
    }

    private static String joinQuotedValues(Set<String> values) {
        List<String> quoted = new List<String>();
        for (String value : values) {
            if (String.isBlank(value)) {
                continue;
            }
            quoted.add('\'' + String.escapeSingleQuotes(value) + '\'');
        }
        return quoted.isEmpty() ? '\'\'': String.join(quoted, ',');
    }
}