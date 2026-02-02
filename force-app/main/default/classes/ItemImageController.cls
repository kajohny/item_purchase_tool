public with sharing class ItemImageController {
    @AuraEnabled
    public static void fillItemImage(Id itemId) {
        if (itemId == null) {
            throw new AuraHandledException('item id is required');
        }

        Item__c it = [SELECT Id, Name, Image__c FROM Item__c WHERE Id = :itemId LIMIT 1];

        if (String.isNotBlank(it.Image__c)) return;

        String url = UnsplashService.getFirstImageUrl(it.Name);
        if (String.isNotBlank(url)) {
            it.Image__c = url;
            update it;
        }
    }
}