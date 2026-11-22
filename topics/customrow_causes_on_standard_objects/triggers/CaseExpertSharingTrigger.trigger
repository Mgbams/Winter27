trigger CaseExpertSharingTrigger on Case (after insert, after update) {
    CaseExpertSharingService.sync(Trigger.new, Trigger.oldMap);
}