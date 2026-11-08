/**
 * @description Handles BatchApexErrorEvent failures
 *              for AccountReviewBatch.
 */
public without sharing class AccountReviewErrorTriggerHandler {

    /**
     * @description Marks demo Accounts affected by
     *              failed Batch Apex execute transactions.
     * @param events Published batch error events.
     */
    public static void afterInsert(List<BatchApexErrorEvent> events) {
        if (events == null || events.isEmpty()) {
            return;
        }

        Set<Id> jobIds = new Set<Id>();

        for (BatchApexErrorEvent evt : events) {
            if (
                String.isNotBlank(evt.AsyncApexJobId) &&
                evt.Phase == 'EXECUTE' &&
                String.isNotBlank(evt.JobScope) &&
                evt.DoesExceedJobScopeMaxLength != true
            ) {
                jobIds.add((Id) evt.AsyncApexJobId);
            }
        }

        if (jobIds.isEmpty()) {
            return;
        }

        Map<Id, AsyncApexJob> jobs = new Map<Id, AsyncApexJob>([
            SELECT Id, ApexClass.Name
            FROM AsyncApexJob
            WHERE Id IN :jobIds
            WITH SYSTEM_MODE
        ]);

        Map<Id, String> failureNotes = new Map<Id, String>();

        for (BatchApexErrorEvent evt : events) {
            if (
                String.isBlank(evt.AsyncApexJobId) ||
                evt.Phase != 'EXECUTE' ||
                String.isBlank(evt.JobScope) ||
                evt.DoesExceedJobScopeMaxLength == true
            ) {
                continue;
            }

            AsyncApexJob job = jobs.get((Id) evt.AsyncApexJobId);

            if (
                job == null ||
                job.ApexClass == null ||
                job.ApexClass.Name != 'AccountReviewBatch'
            ) {
                continue;
            }

            String note = (
                'FAILED ' + evt.ExceptionType + ': ' + evt.Message
            ).abbreviate(80);

            for (String item : evt.JobScope.split(',')) {
                if (String.isBlank(item)) {
                    continue;
                }

                Id recordId = (Id) item.trim();

                if (recordId.getSObjectType() == Account.SObjectType) {
                    failureNotes.put(recordId, note);
                }
            }
        }

        if (failureNotes.isEmpty()) {
            return;
        }

        Set<Id> affectedIds = failureNotes.keySet();

        List<Account> accounts = [
            SELECT Id, Site
            FROM Account
            WHERE Id IN :affectedIds
              AND Name LIKE 'CLI Batch Demo %'
            WITH SYSTEM_MODE
        ];

        if (accounts.isEmpty()) {
            return;
        }

        for (Account acc : accounts) {
            acc.Site = failureNotes.get(acc.Id);
        }

        update as system accounts;
    }
}