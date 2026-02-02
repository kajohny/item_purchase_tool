public with sharing class PurchaseService {
    public class CheckoutRequest {
        @AuraEnabled public Id accountId;
        @AuraEnabled public List<Id> itemIds;
    }

    @AuraEnabled
    public static Id checkout(Id accountId, List<Id> itemIds) {
        if (accountId == null) {
            throw new AuraHandledException('AccountId is required');
        }
        if (itemIds == null || itemIds.isEmpty()) {
            throw new AuraHandledException('Cart is empty');
        }

        List<Item__c> items = [SELECT Id, Price__c FROM Item__c WHERE Id IN :itemIds];

        if (items.isEmpty()) {
            throw new AuraHandledException('No items found');
        }

        Purchase__c purchase = new Purchase__c(ClientId__c = accountId);
        insert purchase;

        List<PurchaseLine__c> lines = new List<PurchaseLine__c>();
        for (Item__c it : items) {
            lines.add(new PurchaseLine__c(
                PurchaseId__c = purchase.Id,
                ItemId__c = it.Id,
                Amount__c = 1,
                UnitCost__c = it.Price__c
            ));
        }
        insert lines;

        return purchase.Id;
    }
}