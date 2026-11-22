# Custom Row Causes on Standard Objects — Salesforce Winter ’27

![Salesforce](https://img.shields.io/badge/Salesforce-Winter%20'27-00A1E0) ![API](https://img.shields.io/badge/API-68.0-blue) ![Apex](https://img.shields.io/badge/Apex-Sharing-1798C1)

[← Back to Winter ’27 topics](../../README.md)

## Overview

Winter ’27 adds **custom sharing reasons (`RowCause`) to supported standard objects**. Unlike shares with the default `Manual` reason, shares with a custom reason remain when record ownership changes. They can also be identified and revoked independently of users’ Manual shares.

This example uses `CaseShare` to grant **Edit** access to the user selected in `Case.Assigned_Expert__c`, using the custom reason `Escalation_Expert__c`.

## Features

- Defines a custom sharing reason for **Case**.
- Adds an optional **Assigned Expert** lookup to **User**.
- Uses an Apex service to grant or revoke shares when the assigned expert changes.
- Keeps the trigger limited to a service call.
- Leaves unrelated Manual shares untouched.

## Prerequisites

- A Winter ’27 org supporting **Metadata API 68.0** and custom sharing reasons on Case.
- Salesforce CLI and a project using `sourceApiVersion: "68.0"`.
- Case org-wide default: **Private** or **Public Read Only**. A share granting Edit access is unnecessary when the default already grants Edit.
- Permission to deploy metadata and Apex; privileged authorization for Apex-managed sharing operations.
- Two active test users with the appropriate Case object permissions.

## Installation

The example uses these metadata components:

```text
force-app/main/default/
├── objects/Case/
│   ├── fields/Assigned_Expert__c.field-meta.xml
│   └── sharingReasons/Escalation_Expert__c.sharingReason-meta.xml
├── classes/CaseExpertSharingService.cls
└── triggers/CaseExpertSharingTrigger.trigger
```

1. Deploy the **lookup field** and **sharing reason** before deploying code that references them.
2. Deploy `CaseExpertSharingService` and `CaseExpertSharingTrigger`.
3. Configure field-level security for `Assigned_Expert__c` and place it on the appropriate Case page.

Example CLI deployment from the project root (adjust paths if your project layout differs):

```bash
sf project deploy start --source-dir force-app/main/default/objects/Case/fields/Assigned_Expert__c.field-meta.xml --source-dir force-app/main/default/objects/Case/sharingReasons/Escalation_Expert__c.sharingReason-meta.xml --target-org YOUR_ORG_ALIAS
sf project deploy start --source-dir force-app/main/default/classes/CaseExpertSharingService.cls --source-dir force-app/main/default/triggers/CaseExpertSharingTrigger.trigger --target-org YOUR_ORG_ALIAS
```

## How to Test

1. Create a Case and set **Assigned Expert** to User A (who is not the owner).
2. Confirm a `CaseShare` record has `RowCause = 'Escalation_Expert__c'` and `CaseAccessLevel = 'Edit'`.
3. Transfer ownership to User B. Confirm the custom share remains.
4. Change **Assigned Expert** to another user. Confirm the previous custom-reason share is removed and the new one is created.
5. Verify that unrelated Manual shares are unaffected.

```sql
SELECT CaseId, UserOrGroupId, RowCause, CaseAccessLevel
FROM CaseShare
WHERE CaseId = '500XXXXXXXXXXXXXXX'
```

Replace the placeholder Case ID with a real record ID.

## Key Implementation Notes

- `CaseExpertSharingTrigger` delegates to `CaseExpertSharingService.sync(Trigger.new, Trigger.oldMap)`.
- The service uses `Escalation_Expert__c` to identify **only its own shares**.
- Salesforce automatically grants owners access, so the example doesn't add a share when the assigned expert is also the owner. **Limitation:** If that owner later loses ownership without an expert-field change, the field-change-only implementation won't create a replacement share. Handle this separately if your production requirements include that scenario.
- **OWD matters:** Salesforce rejects a *trivial share level* (for example, granting Edit when the Case default is already Edit).
- Deleting this share does not necessarily remove all user access; other sharing mechanisms can still apply.
- Before production deployment, validate bulk processing, duplicate-share handling, field-change authorization, and unit-test coverage.

## Troubleshooting

| Error or symptom | Check |
| --- | --- |
| `element fullName missing for a child of type SharingReason` | Include `<fullName>Escalation_Expert__c</fullName>` in the sharing reason XML. |
| `trivial share level Edit, for organization with default level Edit` | Review **Setup → Sharing Settings → Case**; an Edit share must add access beyond OWD. |
| Expert cannot open the Case | Check object permissions and all applicable sharing rules, not only the `CaseShare` row. |
| Custom reason missing | Confirm metadata deployment and org support for API 68.0. |

## Resources

- [Salesforce Developers: Protect Apex Shares — Custom Row Causes on Standard Objects](https://developer.salesforce.com/blogs/2026/10/protect-apex-shares-custom-row-causes-on-standard-objects)
- [Apex Developer Guide: Sharing a Record Using Apex](https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/apex-bulk-sharing-creating-with-apex.html)
- [Metadata API: SharingReason](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-sharingreason.html)

[← Back to Winter ’27 topics](../../README.md)