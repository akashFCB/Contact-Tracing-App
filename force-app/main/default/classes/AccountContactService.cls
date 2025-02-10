public with sharing class AccountContactService {
    public static void updateActiveContacts(Set<Id> accountIds)
    {
        List<AggregateResult> resultList = [SELECT AccountId, COUNT(Id) totalContacts 
                                                FROM Contact 
                                                WHERE accountId IN:accountIds
                                                AND Active__c = true
                                                GROUP BY AccountId];

        List<Account> accountsToUpdate = new List<Account>();
        for(AggregateResult result: resultList)
        {
            String accId = String.valueOf(result.get('AccountId'));
            Integer totalContacts = Integer.valueOf(result.get('totalContacts'));
            Account acc = new Account(Id = accId, Active_Contacts__c = totalContacts);
            accountsToUpdate.add(acc);
        }
        update accountsToUpdate;
    }
    
    
}