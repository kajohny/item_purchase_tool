public with sharing class UserService {
    @AuraEnabled(cacheable=true) 
    public static Boolean isCurrentUserManager() {
        return [SELECT IsManager__c FROM User WHERE Id = :UserInfo.getUserId()].IsManager__c;
    }
}