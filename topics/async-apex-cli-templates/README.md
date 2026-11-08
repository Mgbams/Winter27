# Scaffold Async Apex with CLI Templates — Winter ’27

![Salesforce](https://img.shields.io/badge/Salesforce-Winter%20%2727-0176D3)
![CLI](https://img.shields.io/badge/Salesforce%20CLI-2.145.6%2B-blue)
![Apex](https://img.shields.io/badge/Apex-Batchable%20%26%20Queueable-purple)

## Overview

Salesforce Winter ’27 introduces `Batchable` and `Queueable` templates in Salesforce CLI for generating asynchronous Apex classes with built-in patterns.

This example demonstrates how to customize the generated classes, handle `BatchApexErrorEvent` failures, and use Queueable Finalizers to record execution outcomes.

**Business use cases:**
- **Batch Apex:** Review customer Accounts and flag records affected by batch failures.
- **Queueable Apex:** Update a Contact's department asynchronously and record success or failure using a Finalizer.

## Features

- Generate Batchable and Queueable classes using Salesforce CLI.
- Process Accounts using Batch Apex with `Database.RaisesPlatformEvents`.
- Handle `BatchApexErrorEvent` through a logic-less trigger and dedicated handler.
- Identify failed Account records using `JobScope`.
- Attach a Queueable Finalizer to handle successful and failed executions.
- Demonstrate transaction rollback and independent error handling.

## Prerequisites

- Salesforce CLI **2.145.6 or later**.
- Node.js **22 or later** for current npm-installed Salesforce CLI versions (Node.js 24 LTS recommended).
- An existing Salesforce DX project.
- A Salesforce development org with permission to create and update Accounts and Contacts.
- VS Code with Salesforce Extensions (recommended).

Verify your installation:

```bash
node --version
sf --version
sf template generate apex class --help
```

If you installed Salesforce CLI through npm, update Node.js if necessary and then update the CLI:

```bash
npm install --global @salesforce/cli
```

Official Salesforce CLI installers bundle their own Node.js runtime.

## Installation

### 1. Generate the Apex Classes

The following commands demonstrate the new CLI templates:

```bash
sf template generate apex class --name AccountReviewBatch --template Batchable --output-dir force-app/main/default/classes

sf template generate apex class --name ContactDepartmentQueueable --template Queueable --output-dir force-app/main/default/classes
```

The CLI generates the Apex class structures and their metadata files.

The business logic, `BatchApexErrorEvent` trigger, and trigger handler are custom implementations.

**Note:** If you're using the completed source code from this project, you don't need to regenerate the classes. The commands above demonstrate how the scaffolding was created.

### 2. Deploy the Components

Copy the following implementations into the appropriate `classes` and `triggers` directories of your Salesforce DX project, including their metadata files:

- `AccountReviewBatch`
- `AccountReviewErrorTrigger`
- `AccountReviewErrorTriggerHandler`
- `ContactDepartmentQueueable`

From the Salesforce DX project root, deploy the components:

```bash
sf org login web --alias MyOrg

sf project deploy start --source-dir force-app/main/default/classes/AccountReviewBatch.cls --source-dir force-app/main/default/classes/AccountReviewErrorTriggerHandler.cls --source-dir force-app/main/default/classes/ContactDepartmentQueueable.cls --source-dir force-app/main/default/triggers/AccountReviewErrorTrigger.trigger --target-org MyOrg
```

### 3. Test Batch Apex and BatchApexErrorEvent

Open **Developer Console → Debug → Open Execute Anonymous Window**.

Create three Accounts and simulate a batch failure:

```apex
List<Account> accounts = new List<Account>();
String suffix = String.valueOf(System.now().getTime());

for (Integer i = 1; i <= 3; i++) {
    accounts.add(new Account(
        Name = 'CLI Batch Demo ' + suffix + ' - ' + i
    ));
}

insert accounts;

Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

Database.executeBatch(new AccountReviewBatch(accountIds, true), 50);
```

After the batch and event subscriber finish, verify the records:

```soql
SELECT Name, Description, Site
FROM Account
WHERE Name LIKE 'CLI Batch Demo %'
ORDER BY CreatedDate DESC
LIMIT 3
```

**Expected failure result:**

- `Description` remains blank because the batch transaction rolled back.
- `Site` contains a failure message written by `AccountReviewErrorTriggerHandler`.

To test successful execution against those same demo Accounts:

```apex
List<Account> accounts = [
    SELECT Id
    FROM Account
    WHERE Name LIKE 'CLI Batch Demo %'
      AND CreatedById = :UserInfo.getUserId()
    ORDER BY CreatedDate DESC
    LIMIT 3
];

Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

Database.executeBatch(new AccountReviewBatch(accountIds, false), 50);
```

**Expected success result:**

- `Description` = `Reviewed by Batch Apex`
- `Site` = blank

### 4. Test Queueable Apex and Finalizer

Create a Contact and simulate an unhandled Queueable exception:

```apex
Contact con = new Contact(
    LastName = 'CLI Queue Demo ' +
        String.valueOf(System.now().getTime()),
    Department = 'Sales'
);

insert con;

System.enqueueJob(
    new ContactDepartmentQueueable(con.Id, true)
);
```

After the Queueable and Finalizer finish, verify:

```soql
SELECT LastName, Department, Description
FROM Contact
WHERE LastName LIKE 'CLI Queue Demo %'
ORDER BY CreatedDate DESC
LIMIT 1
```

**Expected failure result:**

- `Department` = `Sales` (Queueable update rolled back).
- `Description` = `Async department update failed` (written by the Finalizer).

Now test successful execution against the same Contact:

```apex
Contact con = [
    SELECT Id
    FROM Contact
    WHERE LastName LIKE 'CLI Queue Demo %'
      AND CreatedById = :UserInfo.getUserId()
    ORDER BY CreatedDate DESC
    LIMIT 1
];

System.enqueueJob(
    new ContactDepartmentQueueable(con.Id, false)
);
```

**Expected success result:**

- `Department` = `Customer Success`
- `Description` = `Async department update completed`

Inspect the asynchronous jobs under **Setup → Apex Jobs**.

## Key Implementation

### Batch Apex Error Handling

The generated Batchable structure includes:

```apex
implements Database.Batchable<SObject>,
           Database.RaisesPlatformEvents
```

When a batch execution encounters an unhandled exception, Salesforce publishes a `BatchApexErrorEvent`.

The trigger delegates processing to a handler:

```apex
trigger AccountReviewErrorTrigger
    on BatchApexErrorEvent (after insert) {

    AccountReviewErrorTriggerHandler.afterInsert(Trigger.new);
}
```

The handler identifies failures from `AccountReviewBatch`, extracts affected Account IDs from `JobScope`, and records the error in `Account.Site`.

**Important:** The event subscriber executes asynchronously in a separate transaction, allowing it to handle failures even when the batch transaction rolls back.

### Queueable Finalizer

The Queueable implements both interfaces:

```apex
implements System.Queueable, System.Finalizer
```

The Finalizer is attached during Queueable execution:

```apex
System.attachFinalizer(this);
```

It checks the parent job's execution result:

```apex
if (context.getResult() ==
    System.ParentJobResult.UNHANDLED_EXCEPTION) {

    Exception ex = context.getException();
    System.debug(LoggingLevel.ERROR, ex.getMessage());
}
```

**Important:** Queueable Finalizers execute in a separate transaction. Their operations can succeed after a parent Queueable failure, but remain subject to permissions, validation rules, and execution limits.

The examples use standard Salesforce fields for demonstration purposes. In production, use an appropriate logging or monitoring mechanism instead of repurposing business fields.

## Resources

- [Salesforce Winter ’27 Developer Guide](https://developer.salesforce.com/blogs/2026/10/developers-guide-to-the-winter-27-release)
- [Salesforce CLI Release Notes](https://github.com/forcedotcom/cli/blob/main/releasenotes/README.md)
- [Salesforce CLI — Generate Apex Class](https://developer.salesforce.com/docs/platform/salesforce-cli-reference/guide/cli_reference_template_generate_apex_class.html)
- [Firing Platform Events from Batch Apex](https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/apex-batch-platformevents.html)
- [BatchApexErrorEvent](https://developer.salesforce.com/docs/platform/platform-events/guide/sforce-api-objects-batchapexerrorevent.html)
- [Transaction Finalizers](https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/apex-transaction-finalizers.html)

---

[← Back to Winter ’27 Training Project](../../README.md)