import { LightningElement, api, wire } from 'lwc';
import getAccount from '@salesforce/apex/GetAccountInfo.getAccount';

export default class ItemPurchaseTool extends LightningElement {
    @api recordId;
    account;

    @wire(getAccount, { accountId: '$recordId'})
    wiredAccount({ data, error }) {
        if (data) {
            this.account = data;
        } else if (error) {
            console.error(error);
        }
    }
}