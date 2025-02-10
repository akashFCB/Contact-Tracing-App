public with sharing class CTPersonTriggerHandler {
    public static void beforeInsertHandler(List<Person__c> newRecords)
    {
        for (Person__c person : newRecords) {
            person.Health_Status__c  = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);    
        }
    }

    public static void beforeUpdateHandler(List<Person__c> record, Map<Id, Person__c> oldMap )
    {
        for(Person__c person: record)
        {
            if(oldMap.get(person.Id).Health_Status__c != person.Health_Status__c)
            {
                person.Status_Update_Date__c = Date.today();
            }
        }
    }

       // Before update operation for Person__c object
       public static void afterUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap){
        Set<Id> statusChange = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();
        for(Person__c person : newRecords){
            // check if the status changed in this transaction
            // also update Status_Update_Date__c
            if( person.Health_Status__c != oldRecordsMap.get(person.id).Health_Status__c){
                statusChange.add(person.Id);
            }
            if( person.Health_Status__c == 'Red' && oldRecordsMap.get(person.id).Health_Status__c != 'Red'){
                redStatus.add(person.Id);
            }
        }

        Set<Id> alreadyProcessed = new Set<Id>();
        alreadyProcessed.addAll(redStatus);

        Set<Id> orangeStatus = new Set<Id>();
        Set<Id> yellowStatus = new Set<Id>();

        List<Person__c> personToUpdate = new List<Person__c>();

        // lets add cohabitants
        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));
        // lets add primaryContacts
        Set<Id> primaryContacts = CTPersonController.getPrimaryContact(redStatus, alreadyProcessed);
        orangeStatus.addAll(primaryContacts);
        // lets add neighbours
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));
        // lets add secondaryContacts
        yellowStatus.addAll(CTPersonController.getSecondaryContact(primaryContacts, alreadyProcessed));


        for (ID personID : orangeStatus) {
            personToUpdate.add(new Person__c(Id = personID, Health_Status__c = 'Orange'));
        }
        for (Id personID : yellowStatus) {
            personToUpdate.add(new Person__c(Id = personID, Health_Status__c = 'Yellow'));
        }

        update personToUpdate;

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByPersonIds(statusChange);
        if(locationTraces != null && locationTraces.size() > 0){
            Set<Id> locationIds = new Set<Id>();
            for (Location_Tracing__c trace : locationTraces) {
                locationIds.add(trace.Location__c);
            }
            CTLocationController.updateRedScore(locationIds);
        }
       
    }
}