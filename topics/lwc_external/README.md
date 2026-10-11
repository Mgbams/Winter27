# Third-Party Web Components in LWC — Winter ’27

![Salesforce](https://img.shields.io/badge/Salesforce-Winter%20%2727-0176D3)
![API](https://img.shields.io/badge/API-68.0-purple)
![LWC](https://img.shields.io/badge/LWC-lwc%3Aexternal-blue)

## Overview

Salesforce Winter ’27 makes **third-party Web Components in LWC Generally Available (GA)**.

This example demonstrates how to reuse an existing JavaScript Web Component library in Salesforce using `lwc:external`, without rewriting its functionality.

**Library:** [barcode-components](https://github.com/oyooyo/barcode-components)

## Features

- Generate QR codes and Code 128B barcodes.
- Dynamically update barcodes when an attendee reference changes.
- Load a third-party library using Salesforce Static Resources and `loadScript()`.
- Render native Custom Elements with `lwc:external`.
- Handle initialization errors in French or English using `@salesforce/i18n/lang`.

No Apex or external API is required.

## Prerequisites

- A compatible Salesforce org with **Lightning Web Security (LWS)** enabled.
- Salesforce CLI and VS Code with Salesforce Extensions (recommended).

## Installation

### 1. Upload the JavaScript Library

Download [barcode-components.min.js](https://raw.githubusercontent.com/oyooyo/barcode-components/master/barcode-components.min.js).

In Salesforce, navigate to **Setup → Static Resources → New**.

| Field | Value |
|---|---|
| Name | `barcodeComponents` |
| File | `barcode-components.min.js` |
| Cache Control | `Private` |

Save the Static Resource.

### 2. Deploy the LWC

The component is named `attendeeBarcodeDemo`.

After placing its files under `force-app/main/default/lwc/attendeeBarcodeDemo`, authenticate and deploy:

```bash
sf org login web --alias MyOrg

sf project deploy start --source-dir force-app/main/default/lwc/attendeeBarcodeDemo --target-org MyOrg
```

### 3. Test the Component

1. Open Lightning App Builder.
2. Add **Attendee Barcode Demo** to a Home, App, or Record page.
3. Save and activate the page.
4. Verify that the QR code and Code 128B barcode appear.
5. Change the attendee reference and confirm that both update dynamically.

## Key Implementation

The library is loaded from Salesforce:

```javascript
import { loadScript } from 'lightning/platformResourceLoader';
import barcodeComponents from '@salesforce/resourceUrl/barcodeComponents';
```

Its Custom Elements are rendered using `lwc:external`:

```html
<qr-code lwc:external data={attendeeReference} scale="4"></qr-code>

<code-128b lwc:external data={attendeeReference} scale="2"></code-128b>
```

The LWC checks that both elements are registered before rendering them.

## Resources

- [Salesforce Winter ’27 Release Notes](https://help.salesforce.com/s/articleView?id=release-notes.rn_lwc_custom_element_mode.htm&release=264&type=5)
- [Use Third-Party Web Components in LWC](https://developer.salesforce.com/docs/platform/lwc/guide/create-use-third-party-components.html)
- [barcode-components GitHub Repository](https://github.com/oyooyo/barcode-components)

---

[← Back to Winter ’27 Training Project](../../README.md)