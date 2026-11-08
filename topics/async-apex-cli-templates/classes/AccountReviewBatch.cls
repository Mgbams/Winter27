public with sharing class AccountReviewBatch implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {

    private Set<Id> accountIds;
    private Boolean simulateFailure;

    public AccountReviewBatch(Set<Id> accountIds, Boolean simulateFailure) {
        this.accountIds = accountIds;
        this.simulateFailure = simulateFailure;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Description, Site
            FROM Account
            WHERE Id IN :accountIds
            WITH USER_MODE
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        if (scope.isEmpty()) {
            return;
        }

        for (SObject record : scope) {
            Account acc = (Account) record;
            acc.Description = 'Reviewed by Batch Apex';
            acc.Site = null;
        }

        update as user scope;

        if (simulateFailure == true) {
            throw new ReviewFailureException('Simulated Account review failure.');
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Account review batch finished.');
    }

    public class ReviewFailureException extends Exception {}
}