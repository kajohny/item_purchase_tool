public with sharing class PurchaseLineTriggerHandler {
    public static void recalculateTotals(List<PurchaseLine__c> newList, Map<Id, PurchaseLine__c> oldMap, System.TriggerOperation op) {
        Set<Id> purchaseIds = new Set<Id>();

        if (op == System.TriggerOperation.AFTER_DELETE) {
            for (PurchaseLine__c pl : oldMap.values()) {
                if (pl.PurchaseId__c != null) purchaseIds.add(pl.PurchaseId__c);
            }
        } else {
            for (PurchaseLine__c pl : newList) {
                if (pl.PurchaseId__c != null) purchaseIds.add(pl.PurchaseId__c);
            }
            if (oldMap != null) {
                for (PurchaseLine__c pl : oldMap.values()) {
                    if (pl.PurchaseId__c != null) purchaseIds.add(pl.PurchaseId__c);
                }
            }
        }

        if(purchaseIds.isEmpty()) return;

        List<PurchaseLine__c> lines = [SELECT PurchaseId__c, Amount__c, UnitCost__c FROM PurchaseLine__c WHERE PurchaseId__c IN :purchaseIds];

        Map<Id, Decimal> totalItemsByPurchase = new Map<Id, Decimal>();
        Map<Id, Decimal> grandTotalByPurchase = new Map<Id, Decimal>();

        for (PurchaseLine__c pl : lines) {
            Decimal amount = pl.Amount__c == null ? 0 : pl.Amount__c;
            Decimal unitCost = pl.UnitCost__C == null ? 0 : pl.UnitCost__c;

            totalItemsByPurchase.put(pl.PurchaseId__c, 
                                    (totalItemsByPurchase.get(pl.PurchaseId__c) == null ? 0 : totalItemsByPurchase.get(pl.PurchaseId__c)) + amount
            );
            
            grandTotalByPurchase.put(pl.PurchaseId__c, 
                                    (grandTotalByPurchase.get(pl.PurchaseId__c) == null ? 0 : grandTotalByPurchase.get(pl.PurchaseId__c)) + (amount * unitCost) 
            );
        }

        List<Purchase__c> updates = new List<Purchase__c>();
        for (Id pid : purchaseIds) {
            updates.add(new Purchase__c(
                Id = pid,
                TotalItems__c = totalItemsByPurchase.containsKey(pid) ? totalItemsByPurchase.get(pid) : 0,
                GrandTotal__c = grandTotalByPurchase.containsKey(pid) ? grandTotalByPurchase.get(pid) : 0
            ));
        }

        update updates;
    }
}