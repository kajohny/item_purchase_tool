import { LightningElement, api } from 'lwc';

export default class ItemTile extends LightningElement {
    @api item;

    get itemId() {
        return this.item?.Id;
    }

    handleDetails() {
        if (!this.itemId) {
            console.error('itemTile: item or item.Id is missing', this.item);
            return;
        }

        this.dispatchEvent(
            new CustomEvent('details', {
                detail: { itemId: this.item.Id },
                bubbles: true,
                composed: true
            })
        );
    }

    handleAdd() {
        if (!this.itemId) {
            console.error('itemTile: item or item.Id is missing', this.item);
            return;
        }

        this.dispatchEvent(
            new CustomEvent('add', {
                detail: { itemId: this.item.Id },
                bubbles: true,
                composed: true
            })
        );
    }

}