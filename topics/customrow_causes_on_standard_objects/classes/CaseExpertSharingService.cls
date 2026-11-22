/**
 * Synchronizes Case expert sharing using a custom RowCause.
 * Creates or removes shares when Assigned_Expert__c changes.
 */
public without sharing class CaseExpertSharingService {

    private static final String REASON =
        Schema.CaseShare.RowCause.Escalation_Expert__c;

    public static void sync(
        List<Case> newCases,
        Map<Id, Case> oldMap
    ) {
        Set<Id> toRevoke = new Set<Id>();
        List<CaseShare> toGrant = new List<CaseShare>();
        Map<Id, Case> casesById = new Map<Id, Case>(newCases);
        Map<Id, String> errors = new Map<Id, String>();

        for (Case c : newCases) {
            Id oldExpert = oldMap == null
                ? null
                : oldMap.get(c.Id).Assigned_Expert__c;

            Id newExpert = c.Assigned_Expert__c;

            if (newExpert == oldExpert) {
                continue;
            }

            if (oldExpert != null) {
                toRevoke.add(c.Id);
            }

            if (newExpert != null && newExpert != c.OwnerId) {
                toGrant.add(new CaseShare(
                    CaseId = c.Id,
                    UserOrGroupId = newExpert,
                    CaseAccessLevel = 'Edit',
                    RowCause = REASON
                ));
            }
        }

        // Remove previous expert shares.
        if (!toRevoke.isEmpty()) {
            List<CaseShare> staleShares = [
                SELECT Id, CaseId
                FROM CaseShare
                WHERE CaseId IN :toRevoke
                AND RowCause = :REASON
                WITH SYSTEM_MODE
            ];

            List<Database.DeleteResult> results =
                Database.delete(
                    staleShares,
                    false,
                    AccessLevel.SYSTEM_MODE
                );

            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    errors.put(
                        staleShares[i].CaseId,
                        results[i].getErrors()[0].getMessage()
                    );
                }
            }
        }

        // Do not grant access if revocation failed.
        List<CaseShare> validGrants = new List<CaseShare>();

        for (CaseShare share : toGrant) {
            if (!errors.containsKey(share.CaseId)) {
                validGrants.add(share);
            }
        }

        // Grant access to newly assigned experts.
        if (!validGrants.isEmpty()) {
            List<Database.SaveResult> results =
                Database.insert(
                    validGrants,
                    false,
                    AccessLevel.SYSTEM_MODE
                );

            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    errors.put(
                        validGrants[i].CaseId,
                        results[i].getErrors()[0].getMessage()
                    );
                }
            }
        }

        // Report errors directly on the Case records.
        for (Id caseId : errors.keySet()) {
            casesById.get(caseId).addError(
                'Expert access could not be updated: '
                + errors.get(caseId)
            );
        }
    }
}