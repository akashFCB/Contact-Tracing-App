public with sharing class CTLocationTriggerHandler {
    public static void beforeInsertHandler(List<Location__c> newRecords)
    {
        for(Location__c location : newRecords) {
            location.Status__c = 'Green';
        }
    }

    public static void beforeUpdateHandler(List<Location__c> records, Map<Id, Location__c> oldMap)
    {
        for(Location__c record: records)
        {
            if(record.Status__c != oldMap.get(record.Id).Status__c)
            {
                record.Status_Update_Date__c = Date.today();
            }
           
        }

    }

    public static void afterUpdateHandler(List<Location__c> existingRecords, Map<Id, Location__c> oldMap)
    {
        List<String> exceptRedOrange = new List<String>{'Red', 'Orange'};
        Set<Id> statusChange = new Set<Id>();
        for (Location__c record : existingRecords) {
            if (record.Status__c == 'Red' && oldMap.get(record.Id).Status__c != 'Red') {
                statusChange.add(record.Id);
            }
        List<Location_Tracing__c> locationTraaces = CTLocationTracingController.getLocationsByLocationIds(statusChange);
            Set<Id> personIDs = new Set<Id>();
            for (Location_Tracing__c trace : locationTraaces) {
                personIDs.add(trace.Person__c);
            }
        List<Person__c> peopleToUpdate = new List<Person__c>();
        for (Id pId : personIDs) {
            peopleToUpdate.add(new Person__c(Id= pid, Health_Status__c = 'Yellow'));
        }
        if(peopleToUpdate.size()>0)
        {
            update peopleToUpdate;
        }
        }

    }
}