public with sharing class ContactTriggerHandler {
    public static void afterInsertHandler(List<Contact> newContacts)
    {
        Set<Id> accountIds = new Set<Id>();

            for(Contact con: newContacts)
            {
                if(String.isNotBlank(con.accountId))
                {
                   accountIds.add(con.AccountId);
                }
            }
        AccountContactService.updateActiveContacts(accountIds);
    }
    

    public static void afterUpdateHandler(List<Contact> records, Map<Id, Contact> oldContactMap)
    {
        Set<Id> accountIds = new Set<Id>();

        for(Contact con: records)
        {
            if(String.isNotBlank(con.accountId) && oldContactMap.get(con.Id).Active__c != con.Active__c)
            {
               accountIds.add(con.AccountId);
            }
            else if(oldContactMap.get(con.Id).AccountId != con.AccountId)
            {
                accountIds.add(con.AccountId);
                accountIds.add(oldContactMap.get(con.Id).AccountId);
            }
        }
        AccountContactService.updateActiveContacts(accountIds);
    }

    public static void afterDeleteHandler(List<Contact> records) {
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : records) {
            // Ensure both AccountId and con are not null before proceeding
            if (con != null && con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }
        // Only update active contacts if there are accountIds to update
        if (!accountIds.isEmpty()) {
            AccountContactService.updateActiveContacts(accountIds);
        }
    }

    public static void afterUndeleteHandler(List<Contact> Contacts)
    {
        Set<Id> accountIds = new Set<Id>();

            for(Contact con: Contacts)
            {
                if(String.isNotBlank(con.accountId))
                {
                   accountIds.add(con.AccountId);
                }
            }
        AccountContactService.updateActiveContacts(accountIds);         
    }
}
