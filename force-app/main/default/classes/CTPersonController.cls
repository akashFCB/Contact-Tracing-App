public with sharing class CTPersonController {
    public CTPersonController() {

    }
     // Generate token usiing MD5 hashing 
     public static String getToken(String mobileNo)
     {
         Blob secureToken = Blob.valueOf(mobileNo);
         Blob token = Crypto.generateDigest('MD5', secureToken);
         // using base64Encode method to get string from Blob
         return EncodingUtil.base64Encode(token);
     }

     //get method to retrieve heath changes
     public static List<Person__c> getRecentHealthChanges()
     {
        List<Person__c> personList =[SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
        FROM Person__c 
        ORDER BY Status_Update_Date__c DESC NULLS LAST 
        LIMIT 100 ];
        return personList;
     }

     //search people either by name, mob, or token
     public static List<Person__c> searchPeople(String searchTerm)
     {
        List<Person__c> result = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
        FROM Person__c
        WHERE Name LIKE :searchTerm
            OR Mobile__c LIKE :searchTerm
            OR Token__c LIKE :searchTerm
        ORDER BY Status_Update_Date__c DESC NULLS LAST ];
        return result;
     }

     //get person by ID as parameter
     public static Person__c getPersonByld(String personId)
     {
        List<Person__c> result = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c
        FROM Person__c
        WHERE Id =:personId ];
        if(result != null && result.size() > 0){
            return result[0];
        }
        return null;
    }

    /** Get Health status count
     * getHealthStatusCount()
     * @return Map<String,Integer>
     */ 

     public static Map<String, Integer> getHealthStatusCount()
     {
        Map<String, Integer> healthStatusCountMap = new Map<String, Integer>();
        for(AggregateResult result: [SELECT Health_Status__c, COUNT(Id) statusCount 
                                     FROM Person__c 
                                     GROUP BY Health_Status__c])
       {
          healthStatusCountMap.put(String.ValueOf(result.get('Health_Status__c')), Integer.valueOf(result.get('statusCount')));
       }

        return healthStatusCountMap;
     }

     public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed)
     {
      List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
      List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                  WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds) 
                                                  AND Contact_Type__c = 'Cohabitant'
                                                  AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN : healthStatuses)];
      Set<Id> cohabitants = new Set<Id>();
      for(People_Tracing__c pt : peopleTraces){
          if(!alreadyProcessed.contains(pt.Person_1__c)){
              cohabitants.add(pt.Person_1__c);
              alreadyProcessed.add(pt.Person_1__c);
          }
          if(!personIds.contains(pt.Person_2__c)){
              cohabitants.add(pt.Person_2__c);
              alreadyProcessed.add(pt.Person_2__c);
          }
      }
      return cohabitants;
     }


     public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed)
     {
      List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds) 
                                                AND Contact_Type__c = 'Neighbour'
                                                AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];
            Set<Id> neighbours = new Set<Id>();
            for(People_Tracing__c pt : peopleTraces){
               if(!alreadyProcessed.contains(pt.Person_1__c)){
                   neighbours.add(pt.Person_1__c);
                   alreadyProcessed.add(pt.Person_1__c);
               }
               if(!alreadyProcessed.contains(pt.Person_2__c)){
                   neighbours.add(pt.Person_2__c);
                   alreadyProcessed.add(pt.Person_2__c);
               }
           }
            return neighbours;
     }

     public static Set<Id> getPrimaryContact (Set<Id> personIds, Set<Id> alreadyProcessed)
     {
      List<String> healthStatuses = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds) 
                                                    AND Contact_Type__c = 'Other'
                                                    AND Contact_Date__c = LAST_N_DAYS:10
                                                    AND (Person_1__r.Health_Status__c IN :healthStatuses OR Person_2__r.Health_Status__c IN :healthStatuses)];
        Set<Id> primaryContacts = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                primaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!alreadyProcessed.contains(pt.Person_2__c)){
                primaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return primaryContacts;
     }

     public static Set<Id> getSecondaryContact (Set<Id> primaryContactsIds, Set<Id> alreadyProcessed)
     {
      List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                    WHERE (Person_1__c IN :primaryContactsIds OR Person_2__c IN :primaryContactsIds) 
                                                    AND Contact_Type__c = 'Other'
                                                    AND Contact_Date__c = LAST_N_DAYS:10
                                                    AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];
        Set<Id> secondaryContacts = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces){
            if(!alreadyProcessed.contains(pt.Person_1__c)){
                secondaryContacts.add(pt.Person_1__c);
                alreadyProcessed.add(pt.Person_1__c);
            }
            if(!alreadyProcessed.contains(pt.Person_2__c)){
                secondaryContacts.add(pt.Person_2__c);
                alreadyProcessed.add(pt.Person_2__c);
            }
        }
        return secondaryContacts;
     }



     }