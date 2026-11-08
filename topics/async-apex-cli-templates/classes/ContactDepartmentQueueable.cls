public with sharing class ContactDepartmentQueueable implements System.Queueable, System.Finalizer {

    private Id contactId;
    private Boolean simulateFailure;

    public ContactDepartmentQueueable(Id contactId, Boolean simulateFailure) {
        this.contactId = contactId;
        this.simulateFailure = simulateFailure;
    }

    public void execute(System.QueueableContext context) {
        System.attachFinalizer(this);

        Contact con = [
            SELECT Id, Department
            FROM Contact
            WHERE Id = :contactId
            WITH USER_MODE
            LIMIT 1
        ];

        con.Department = 'Customer Success';
        update as user con;

        if (simulateFailure == true) {
            throw new ContactSyncException('Simulated Contact update failure.');
        }
    }

    public void execute(System.FinalizerContext context) {
        String outcome;

        if (context.getResult() ==
            System.ParentJobResult.UNHANDLED_EXCEPTION) {

            Exception ex = context.getException();

            System.debug(LoggingLevel.ERROR, 'Queueable failed: ' + ex.getMessage());

            outcome = 'Async department update failed';
        } else {
            outcome = 'Async department update completed';
        }

        Contact con = new Contact(Id = contactId, Description = outcome);

        update as user con;
    }

    public class ContactSyncException extends Exception {}
}