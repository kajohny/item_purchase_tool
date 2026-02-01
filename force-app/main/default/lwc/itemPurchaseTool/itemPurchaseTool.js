import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getItems from '@salesforce/apex/ItemController.getItems';
import getItemsCount from '@salesforce/apex/ItemController.getItemsCount';
import getAccount from '@salesforce/apex/GetAccountInfo.getAccount';

export default class ItemPurchaseTool extends LightningElement {
    @api recordId;
    account;

    searchTerm = '';
    selectedType = '';
    selectedFamily = '';

    items = [];
    cartItems = [];
    itemsCount = 0;
    cartColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Type', fieldName: 'Type__c' },
        { label: 'Family', fieldName: 'Family__c' },
        { label: 'Price', fieldName: 'Price__c', type: 'number' }
    ];

    isDetailsOpen = false;
    selectedItemId;

    isCartOpen = false;

    @wire(getAccount, { accountId: '$recordId'})
    wiredAccount({ data, error }) {
        if (data) {
            this.account = data;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getItems, {
        family: '$selectedFamily',
        type: '$selectedType',
        searchTerm: '$searchTerm'
    })

    wiredItems({ data, error }) {
        if (data) {
            this.items = data;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getItemsCount, {
        family: '$selectedFamily',
        type: '$selectedType',
        searchTerm: '$searchTerm'
    })

    wiredCount({ data, error }) {
        if (data !== undefined) {
            this.itemsCount = data;
        } else if (error) {
            console.error(error);
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    handleTypeChange(event) {
        this.selectedType = event.detail.value;
    }

    handleFamilyChange(event) {
        this.selectedFamily = event.detail.value;
    }

    handleAddToCart(event) {
        const itemId = event.detail?.itemId;

        const item = this.items.find(i => i.Id === itemId);
        if (!item) {
            console.error('Add: item not found', itemId);
            return;
        }

        const exists = this.cartItems.some(ci => ci.Id === itemId);
        if (!exists) {
            this.cartItems = [...this.cartItems, item];
        }
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Added to cart',
                message: item.Name,
                variant: 'success'
            })
        );
    }

    handleOpenDetails(event) {
        this.selectedItemId = event.detail.itemId;
        this.isDetailsOpen = true;
    }

    closeDetails() {
        this.isDetailsOpen = false;
        this.selectedItemId = null;
    }

    handleOpenCart() {
        this.isCartOpen = true;
    }

    closeCart() {
        this.isCartOpen = false;
    }

    handleCheckout() {
        this.dispatchEvent(
            new ShowToastEvent({
            title: 'Checkout',
            message: 'sss',
            variant: 'sss'
            })
        );
    }
}