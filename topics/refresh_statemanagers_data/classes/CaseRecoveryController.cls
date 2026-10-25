public with sharing class CaseRecoveryController {

    private static final Integer AGING_THRESHOLD_DAYS = 0;

    @AuraEnabled
    public static Integer prioritizeAgingCases(Id accountId) {

        if (accountId == null) {
            AuraHandledException ex = new AuraHandledException('An Account Id is required.');
            ex.setMessage('An Account Id is required.');
            throw ex;
        }

        Datetime cutoffDate = System.now().addDays(-AGING_THRESHOLD_DAYS);

        List<Case> agingCases = [
            SELECT Id, Priority
            FROM Case
            WHERE AccountId = :accountId
              AND IsClosed = false
              AND CreatedDate <= :cutoffDate
              AND Priority != 'High'
            WITH USER_MODE
            ORDER BY CreatedDate ASC
            LIMIT 100
        ];

        if (agingCases.isEmpty()) {
            return 0;
        }

        for (Case supportCase : agingCases) {
            supportCase.Priority = 'High';
        }

        update as user agingCases;

        return agingCases.size();
    }
}