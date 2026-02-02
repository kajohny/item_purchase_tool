@IsTest
private class PurchaseServiceTest {

    @TestSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Acc');
        insert acc;

        List<Item__c> items = new List<Item__c> {
            new Item__c(Name='Item 1', Price__c=100),
            new Item__c(Name='Item 2', Price__c=200)
        };
        insert items;
    }

    @IsTest
    static void testCheckoutCreatesPurchaseAndLinesAndTotals() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Item__c> items = [SELECT Id, Price__c FROM Item__c ORDER BY CreatedDate ASC];

        Test.startTest();
        Id purchaseId = PurchaseService.checkout(acc.Id, new List<Id>{ items[0].Id, items[1].Id });
        Test.stopTest();

        Purchase__c p = [SELECT Id, ClientId__c, TotalItems__c, GrandTotal__c FROM Purchase__c WHERE Id = :purchaseId];

        System.assertEquals(acc.Id, p.ClientId__c);
        System.assertEquals(2, p.TotalItems__c);
        System.assertEquals(30, p.GrandTotal__c);

        Integer lineCount = [SELECT COUNT() FROM PurchaseLine__c WHERE PurchaseId__c = :purchaseId];
        System.assertEquals(2, lineCount);
    }
}