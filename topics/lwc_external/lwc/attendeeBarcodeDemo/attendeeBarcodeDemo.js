import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import barcodeComponents from '@salesforce/resourceUrl/barcodeComponents';

// Import the current user's Salesforce language.
import LANG from '@salesforce/i18n/lang';

export default class AttendeeBarcodeDemo extends LightningElement {
    attendeeReference = 'KINGSLEY-2026-10-13';

    libraryLoaded = false;
    loadStarted = false;
    loadError;

    // Check whether the user's language is French.
    get isFrench() {
        return LANG === 'fr' || LANG.startsWith('fr-');
    }

    renderedCallback() {
        if (this.loadStarted) {
            return;
        }

        this.loadStarted = true;

        loadScript(this, barcodeComponents)
            .then(() => {
                const qrRegistered = !!customElements.get('qr-code');
                const barcodeRegistered = !!customElements.get('code-128b');

                if (!qrRegistered || !barcodeRegistered) {
                    const errorMessage = this.isFrench ?
                        "La bibliothèque de codes-barres a été chargée, mais les composants personnalisés n'ont pas été enregistrés." :
                        'Barcode library loaded but custom elements were not registered.';
                    throw new Error(errorMessage);
                }

                this.libraryLoaded = true;
            })
            .catch((error) => {
                //'Unable to initialize barcode library.'
                const errorMessage = this.isFrench ?
                    "Impossible d'initialiser la bibliothèque de codes-barres." :
                    'Unable to initialize the barcode library.';
                this.loadError = error?.message || errorMessage;
            });
    }

    handleReferenceChange(event) {
        const reference = event.target.value.trim();

        // Keep the example compatible with Code 128B.
        const isPrintableAscii = /^[\x20-\x7E]+$/.test(reference);

        if (reference && isPrintableAscii) {
            this.attendeeReference = reference;
        }
    }
}