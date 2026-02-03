@IsTest
private class ItemImageControllerTest {
    @IsTest
    static void testFillItemImage_setsImageUrl() {
        Item__c it = new Item__c(Name = 'Laptop', Price__c = 100, Type__c = 'Hardware', Family__c = 'Electronics');
        insert it;

        Test.setMock(HttpCalloutMock.class, new UnsplashHttpMock());

        Test.startTest();
        ItemImageController.fillItemImage(it.Id);
        Test.stopTest();

        Item__c updated = [SELECT Id, Image__c FROM Item__c WHERE Id = :it.Id];

        System.assertNotEquals(null, updated.Image__c, 'Image__c should be populated');
        System.assert(updated.Image__c.startsWith('https://'), 'Image__c should contain a url');
        System.assertEquals('https://images.unsplash.com/photo-test-small', updated.Image__c, 'Image__c should match mocked unpsplash url');
    }

    @IsTest
    static void testFillItemImage_nullId_throws() {
        Test.startTest();
        Boolean thrown = false;
        try {
            ItemImageController.fillItemImage(null);
        } catch (Exception ex) {
            thrown = true;
        }

        Test.stopTest();
        System.assert(thrown, 'Expected exception for null itemId');
    }
}