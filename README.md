# ☁️ Salesforce Winter ’27 — Training Project

![Salesforce](https://img.shields.io/badge/Salesforce-Winter%20%2727-0176D3)
![API Version](https://img.shields.io/badge/API-68.0-purple)
![Salesforce CLI](https://img.shields.io/badge/Salesforce-CLI-green)

A collection of practical **Salesforce Winter ’27 feature demonstrations**, organized by topic.

This repository explores new Salesforce capabilities through examples, technical explanations, and deployment instructions.

Each topic has its own README describing the feature, implementation, prerequisites, and testing steps.

---

## 📋 Topics

| Topic | Description | API Version |
|---|---|---|
| [Third-Party Web Components in LWC](topics/lwc-external/README.md) | Integrate an existing JavaScript Web Component library into LWC using `lwc:external`. Demonstrates dynamic QR code and barcode generation. | 68.0 |
| [Refresh State Manager Data](topics/refresh_statemanagers_data/README.md) | Refresh State Manager Data | 68.0 |
| [async-apex-cli-templates](topics/async-apex-cli-templates/README.md) | async-apex-cli-templates | 68.0 |

More Winter ’27 examples will be added as the project evolves.

---

## ⚙️ Prerequisites

Before getting started, make sure you have:

- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)
- [Git](https://git-scm.com/)
- Access to a compatible Salesforce Developer Edition org, sandbox, or scratch org
- [Visual Studio Code](https://code.visualstudio.com/) with the [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode) (recommended)

Some features have additional requirements. Check each topic's README before deployment.

For the `lwc-external` demonstration, **Lightning Web Security (LWS)** must be enabled.

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Mgbams/Winter27.git
cd Winter27
```

### 2. Authenticate to Salesforce

Authenticate to your Salesforce org using Salesforce CLI:

```bash
sf org login web --alias MyOrg --set-default
```

For a sandbox, use the sandbox login URL:

```bash
sf org login web --instance-url https://test.salesforce.com --alias MySandbox
```

### 3. Choose a Topic

Each topic contains its own implementation notes and instructions.

Start with:

**[Use Third-Party Web Components in LWC (GA)](topics/lwc-external/README.md)**

This example demonstrates how to:

- Load an existing third-party JavaScript library from a Salesforce Static Resource.
- Use native Custom Elements inside LWC with `lwc:external`.
- Generate QR codes and Code 128B barcodes.
- Update barcode values dynamically.
- Handle library initialization errors.

### 4. Prepare the Third-Party Library

The `lwc-external` example uses the open-source [barcode-components](https://github.com/oyooyo/barcode-components) library.

Before deploying the LWC, download the library's browser-ready JavaScript bundle and upload it to your Salesforce org:

1. Navigate to **Setup → Static Resources**.
2. Click **New**.
3. Set the resource name to `barcodeComponents`.
4. Upload the downloaded `barcode-components.min.js` file.
5. Set Cache Control to `Private`.
6. Save the resource.

The LWC accesses this library through:

```javascript
import barcodeComponents from '@salesforce/resourceUrl/barcodeComponents';
```

For further details, refer to the [topic README](topics/lwc-external/README.md).

### 5. Deploy the LWC

Deploy the component to your authenticated Salesforce org.

If the source files are available under the standard Salesforce DX directory, use:

```bash
sf project deploy start \
  --source-dir force-app/main/default/lwc/attendeeBarcodeDemo \
  --target-org MyOrg
```

If the example source is stored only under `topics/lwc-external`, follow that topic's README to place it in the appropriate Salesforce DX source directory before deployment.

### 6. Test the Component

After deployment:

1. Open Lightning App Builder.
2. Edit a compatible Home, App, or Record page.
3. Add **Attendee Barcode Demo**.
4. Save and activate the page.
5. Confirm that the QR code and Code 128B barcode appear.
6. Change the attendee reference and verify that the codes update.

The example requires Lightning Web Security and the `barcodeComponents` Static Resource to be available in the target org.

---

## 🔁 Deploying to an Existing Sandbox

Authenticate to your sandbox:

```bash
sf org login web \
  --instance-url https://test.salesforce.com \
  --alias MySandbox
```

Then deploy the required topic's Salesforce source:

```bash
sf project deploy start \
  --source-dir force-app/main/default/lwc/attendeeBarcodeDemo \
  --target-org MySandbox
```

If you're deploying a different feature, use the corresponding source paths and instructions in its topic README.

---

## 🧪 Testing

Testing procedures depend on the feature.

For LWC examples, follow the manual or automated tests described in the topic README.

For topics containing Apex tests, Salesforce CLI provides:

```bash
sf apex run test \
  --target-org MyOrg \
  --result-format human
```

Running Apex tests is not required merely to demonstrate a client-side JavaScript barcode component.

---

## 🧯 Troubleshooting

| Issue | Suggested solution |
|---|---|
| Source files not found | Check the source paths in your Salesforce DX project. |
| Authentication expired | Re-authenticate using `sf org login web`. |
| Deployment fails | Check deployment errors, org permissions, and metadata API compatibility. |
| Static Resource not found | Confirm that `barcodeComponents` exists under Setup → Static Resources. |
| Barcode components not registered | Verify the uploaded JavaScript bundle and review browser console errors. |
| Barcode components do not render | Check Lightning Web Security and the third-party library's compatibility. |
| Component not visible in App Builder | Verify the component's `isExposed` setting and supported targets. |

---

## 🤝 Contributing

Contributions and suggestions are welcome.

To add a new Winter ’27 topic:

1. Create a dedicated folder under `topics/`.
2. Include a topic-specific `README.md`.
3. Add the required Salesforce source files or clear instructions for obtaining external dependencies.
4. Document prerequisites, deployment, and testing.
5. Add the new topic to the table in this README.

Please keep examples focused, readable, and easy to reproduce.

---

## 📚 Resources

- [Salesforce Winter ’27 Release Notes](https://help.salesforce.com/s/articleView?id=release-notes.rn_lwc_custom_element_mode.htm&release=264&type=5)
- [Salesforce Developer Documentation](https://developer.salesforce.com/docs)
- [Lightning Web Components Developer Guide](https://developer.salesforce.com/docs/platform/lwc/guide)
- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)

---

**Last updated:** October 11, 2026