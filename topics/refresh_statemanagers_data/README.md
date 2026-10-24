# Refresh LWC State Manager Data — Winter ’27

![Salesforce](https://img.shields.io/badge/Salesforce-Winter%20%2727-0176D3)
![API](https://img.shields.io/badge/API-68.0-purple)
![LWC](https://img.shields.io/badge/LWC-State%20Manager-blue)

## Overview

Salesforce Winter ’27 introduces the `refresh()` action for supported built-in LWC state managers.

This example demonstrates how to refresh related-list data after an imperative Apex update, without recreating the state manager or reloading the page.

**Business use case:** An Account Case Recovery Desk that prioritizes aging customer support Cases and immediately refreshes their displayed priorities.

## Features

- Display related Cases on an Account record page.
- Open Case records by clicking their Case Number.
- Prioritize open Cases older than seven days using Apex.
- Refresh related-list data using `lightning/stateManagerRelatedListRecords`.
- Handle Apex update and refresh errors separately.
- Display updated priorities without a full page reload.

## Prerequisites

- A compatible Salesforce Winter ’27 org.
- Access to Account and Case records, including permission to update Case Priority.
- Salesforce CLI and VS Code with Salesforce Extensions (recommended).

## Installation

### 1. Deploy the Components

Deploy the Apex controller (`CaseRecoveryController`) and LWC (`accountCaseRecovery`).

```bash
sf org login web --alias MyOrg

sf project deploy start --source-dir force-app/main/default/classes/CaseRecoveryController.cls --source-dir force-app/main/default/lwc/accountCaseRecovery --target-org MyOrg
```

### 2. Add the LWC to the Account Page

1. Open **Setup → Lightning App Builder**.
2. Edit an Account Record Page.
3. Add **Account Case Recovery**.
4. Save and activate the page.

### 3. Test the Component

1. Set `AGING_THRESHOLD_DAYS` to `0` in `CaseRecoveryController` for testing.
2. Create a few open Cases with Low or Medium priority for an Account.
3. Open the Account and verify the Cases appear.
4. Click **Prioritize Aging Cases**.
5. Confirm the priorities change to High without reloading the page.

Restore `AGING_THRESHOLD_DAYS` to `7` after testing.

## Key Implementation

The component uses Salesforce's built-in related-list state manager:

```javascript
import stateManagerRelatedListRecords from 'lightning/stateManagerRelatedListRecords';
```

After the Apex update succeeds, the new `refresh()` action retrieves the latest data:

```javascript
if (this.cases.value.status === 'loaded') {
    await this.cases.value.refresh();
}
```

**Important:** `refresh()` only works when the state manager's status is `loaded`. The status remains `loaded` during the refresh, and the action returns a `Promise<void>`.

## Resources

- [Salesforce Winter ’27 Release Notes](https://help.salesforce.com/s/articleView?id=release-notes.rn_lwc_state_manager_refresh.htm&release=264&type=5)
- [Use Built-in State Managers](https://developer.salesforce.com/docs/platform/lwc/guide/reference-state-managers-use.html)
- [Related List Records State Manager](https://developer.salesforce.com/docs/platform/lwc/guide/reference-state-manager-related-list-records.html)

---

[← Back to Winter ’27 Training Project](../../README.md)