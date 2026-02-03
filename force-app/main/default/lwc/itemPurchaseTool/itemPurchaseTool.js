import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getItems from '@salesforce/apex/ItemController.getItems';
import getItemsCount from '@salesforce/apex/ItemController.getItemsCount';
import getAccount from '@salesforce/apex/GetAccountInfo.getAccount';
import checkout from '@salesforce/apex/PurchaseService.checkout';
import { NavigationMixin } from 'lightning/navigation';
import isCurrentUserManager from '@salesforce/apex/UserService.isCurrentUserManager';
import fillItemImage from '@salesforce/apex/ItemImageController.fillItemImage';
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import ITEM_OBJECT from '@salesforce/schema/Item__c';
import TYPE_FIELD from '@salesforce/schema/Item__c.Type__c';
import FAMILY_FIELD from '@salesforce/schema/Item__c.Family__c';

export default class ItemPurchaseTool extends NavigationMixin(LightningElement) {
    @api recordId;
    account;
    isManager=false;

    searchTerm = '';
    selectedType = '';
    selectedFamily = '';

    itemRecordTypeId;
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

    @wire(isCurrentUserManager)
    wiredIsManager({ data, error }) {
        if (data !== undefined ) {
            this.isManager = data;
        } else if (error) {
            console.error(error);
        }
    }

    wiredItemsResult;
    @wire(getItems, {
        family: '$selectedFamily',
        type: '$selectedType',
        searchTerm: '$searchTerm'
    })

    wiredItems(result) {
        this.wiredItemsResult = result;
        const { data, error } = result;
        if (data) this.items = data;
        if (error) console.error(error);
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
    
    @wire(getObjectInfo, { objectApiName: ITEM_OBJECT })
    itemObjectInfo({ data, error }) {
        if (data) {
            this.itemRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.error(error);
        }
    }

    typeOptions = [];
    @wire(getPicklistValues, { recordTypeId: '$itemRecordTypeId', fieldApiName: TYPE_FIELD })
    wiredTypePicklist({ data, error }) {
        if (data) {
            this.typeOptions = [
                { label: 'All', value: '' },
                ...data.values.map(v => ({
                    label: v.label,
                    value: v.value
                }))
            ];
        } else if (error) {
            console.error(error);   
        }
    }

    familyOptions = [];
    @wire(getPicklistValues, { recordTypeId: '$itemRecordTypeId', fieldApiName: FAMILY_FIELD })
    wiredFamilyPicklist({ data, error }) {
        if (data) {
            this.familyOptions = [
                { label: 'All', value: '' },
                ...data.values.map(v => ({
                    label: v.label,
                    value: v.value
                }))
            ];
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

    async handleCheckout() {
        try {
            const itemIds = this.cartItems.map(i => i.Id);

            const purchaseId = await checkout({accountId: this.recordId, itemIds: itemIds});

            this.closeCart();
            this.cartItems = [];

            console.log('purchaseId', purchaseId);

            const url = await this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: purchaseId,
                    objectApiName: 'Purchase__c',
                    actionName: 'view'
                }
            });

            window.location.assign(url);
        } catch (e) {
            console.error(e);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Checkout failed',
                    message: e?.body?.message || 'Unexpected error',
                    variant: error 
                })
            );
        }
    }
    
    isCreateItemOpen = false;
    openCreateItemModal() {
        this.isCreateItemOpen = true;
    }

    closeCreateItemModal() {
        this.isCreateItemOpen = false;
    }

    async handleItemCreated(event) {
        const itemId = event.detail.id;

        try {
            await fillItemImage({ itemId });
        } catch (e) {
            console.error('fillItemImage error', e);

            const msg = e?.body?.message || (Array.isArray(e?.body) ? e.body.map(x => x.message).join(', ') : null) || e?.message || 'Unknown error';


            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Item created, but image not loaded',
                    message: msg,
                    variant: 'warning'
                })
            );
        }

        this.closeCreateItemModal();

        if (this.wiredItemResult) {
            await refreshApex(this.wiredItemResult);
        }
    }
}