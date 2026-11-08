trigger AccountReviewErrorTrigger on BatchApexErrorEvent (after insert) {
    AccountReviewErrorTriggerHandler.afterInsert(Trigger.new);
}
