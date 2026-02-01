public with sharing class ItemController {
    @AuraEnabled(cacheable=true)
    public static List<Item__c> getItems(String family, String type, String searchTerm) {
        String baseQuery = 'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c FROM Item__c';

        List<String> conditions = new List<String>();

        if (String.isNotBlank(family)) {
            conditions.add('Family__c = :family');
        }

        if (String.isNotBlank(type)) {
            conditions.add('Type__c = :type');
        }
        
        if (String.isNotBlank(searchTerm)) {
            String likeTerm = '%' + searchTerm + '%';
            conditions.add('Name LIKE :likeTerm OR Description__c LIKE :likeTerm');
        }
        
        if (!conditions.isEmpty()) {
            baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
        }

        return Database.query(baseQuery);
    }

    @AuraEnabled(cacheable=true)
    public static Integer getItemsCount(String family, String type, String searchTerm) {
        String baseQuery = 'SELECT COUNT() FROM Item__c';

        List<String> conditions = new List<String>();

        if (String.isNotBlank(family)) {
            conditions.add('Family__c = :family');
        }
        
        if (String.isNotBlank(type)) {
            conditions.add('Type__c = :type');
        }
        
        if (String.isNotBlank(searchTerm)) {
            String likeTerm = '%' + searchTerm + '%';
            conditions.add('Name LIKE :likeTerm OR Description__c LIKE :likeTerm');
        }

        if (!conditions.isEmpty()) {
            baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
        }

        return Database.countQuery(baseQuery);
    }
}