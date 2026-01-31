@IsTest
private class ItemControllerTest {
    @TestSetup
    static void setupData() {
        Item__c item = new Item__c(Name = 'Test Item', Description__c = 'Test Description', Family__c = 'Electronics', Type__c = 'Hardware', Price__c = 100);
        insert item;
    }

    @IsTest
    static void testGetItems() {
        Test.startTest();
        List<Item__c> items = ItemController.getItems('Electronics', 'Hardware', 'Test');
        Test.stopTest();

        System.assertEquals(1, items.size());
    }

    @IsTest
    static void testGetItemsCount() {
        Test.startTest();
        Integer count = ItemController.getItemsCount('Electronics', 'Hardware', 'Test');
        Test.stopTest();

        System.assertEquals(1, count);
    }
}

