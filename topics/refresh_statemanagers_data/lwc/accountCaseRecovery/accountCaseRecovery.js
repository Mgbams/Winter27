import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import stateManagerRelatedListRecords from 'lightning/stateManagerRelatedListRecords';
import prioritizeAgingCases from '@salesforce/apex/CaseRecoveryController.prioritizeAgingCases';


const COLUMNS = [
    {
        label: 'Case Number',
        fieldName: 'caseUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'caseNumber' },
            target: '_blank'
        }
    },
    { label: 'Subject', fieldName: 'subject' },
    { label: 'Status', fieldName: 'status' },
    { label: 'Priority', fieldName: 'priority' }
];


export default class AccountCaseRecovery extends LightningElement {

    @api recordId;

    columns = COLUMNS;
    isProcessing = false;

    cases = stateManagerRelatedListRecords({
        parentRecordId: undefined,
        relatedListId: 'Cases',
        fields: [
            'Case.CaseNumber',
            'Case.Subject',
            'Case.Status',
            'Case.Priority'
        ],
        pageSize: 100
    });

    connectedCallback() {
        if (this.recordId) {
            this.cases.value.setParentRecordId(this.recordId);
        }
    }

    get isLoaded() {
        return this.cases.value.status === 'loaded';
    }

    get hasError() {
        return this.cases.value.status === 'error';
    }

    get disableAction() {
        return !this.isLoaded || this.isProcessing;
    }

    get caseRecords() {
        if (!this.isLoaded) {
            return [];
        }

        return (this.cases.value.data?.records ?? []).map(
            record => ({
                id: record.id,
                caseUrl: `/lightning/r/Case/${record.id}/view`,
                caseNumber: record.fields.CaseNumber?.value,
                subject: record.fields.Subject?.value,
                status: record.fields.Status?.value,
                priority: record.fields.Priority?.value
            })
        );
    }


    async handlePrioritize() {
        if (this.disableAction) {
            return;
        }

        this.isProcessing = true;

        let updatedCount;

        try {
            updatedCount = await prioritizeAgingCases({
                accountId: this.recordId
            });
        } catch (error) {
            this.showToast(
                'Update Failed',
                error?.body?.message ||
                    error?.message ||
                    'Unable to prioritize cases.',
                'error'
            );

            this.isProcessing = false;
            return;
        }

        try {
            if (this.cases.value.status !== 'loaded') {
                throw new Error('State manager is not loaded.');
            }

            // Winter '27: Refresh the state-managed data.
            await this.cases.value.refresh();

            this.showToast(
                'Cases Updated',
                `${updatedCount} aging case(s) prioritized.`,
                'success'
            );

        } catch (error) {
            this.showToast(
                'Cases Updated',
                `${updatedCount} case(s) updated, but the list could not be refreshed. Reload the page to see the latest data.`,
                'warning'
            );

        } finally {
            this.isProcessing = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}
