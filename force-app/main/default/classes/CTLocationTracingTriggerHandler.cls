public with sharing class CTLocationTracingTriggerHandler {
    
    public static void beforeInsertHandler(List<Location_Tracing__c> traceRecords)
    {
        List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(traceRecords);
        for (Location_Tracing__c trace : duplicates) {
            trace.addError('duplicate record has been found. Location: '+ trace.Location__c + ' Person: '+ trace.Person__c );
        }
    }
}