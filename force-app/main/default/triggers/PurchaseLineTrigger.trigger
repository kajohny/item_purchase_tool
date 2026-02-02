trigger PurchaseLineTrigger on PurchaseLine__c (after insert, after update, after delete, after undelete) {
    PurchaseLineTriggerHandler.recalculateTotals(Trigger.new, Trigger.oldMap, Trigger.operationType);
}