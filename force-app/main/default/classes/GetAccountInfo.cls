public with sharing class GetAccountInfo {
    @AuraEnabled(cacheable=true)
    public static Account getAccount(Id accountId) {
        return [SELECT id, Name, AccountNumber, Industry FROM Account WHERE Id = :accountId LIMIT 1];
    }
}