public with sharing class CTLocationController {
    public CTLocationController() {

    }

    //get updated location status
    public static List<Location__c> getRecentStatusChanges()
    {
        List<Location__c> result = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c 
        FROM Location__c 
        ORDER BY Status_Update_Date__c 
        DESC NULLS LAST LIMIT 100];
        return result;
    }

    // search Locattion method 
    public static List<Location__c> searchLocations(String searchTerm)
    {
        List<Location__c> result = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c 
        FROM Location__c 
        WHERE Name IN (:searchTerm)
            OR Pincode__c IN (:searchTerm)
            OR Address__c IN (:searchTerm)
        ORDER BY Status_Update_Date__c DESC NULLS LAST];

        return result;
    }

    //Get specific Location By Location ID
    public static Location__c getLocationById(String locationId)
    {
        List<Location__c> result = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status__c, Status_Update_Date__c 
                                    FROM Location__c 
                                    WHERE Id = :locationId];
        if(result !=null || result.size()>0)
        {
            Location__c location =  result[0];
            return location;
        }
        else {
            return null;
        }

        
    }

    /**
     * Location Count by Health Status
     * @return Map<String, Integer>
     */

     public static Map<String, Integer> getStatusCount()
     {
        Map<String, Integer> healthStatusCount = new Map<String, Integer>();
        for(AggregateResult result: [SELECT Status__c, COUNT(Id) locationCount FROM Location__c GROUP BY Status__c])
        {
            healthStatusCount.put(String.valueOf(result.get('Status__c')), Integer.valueOf(result.get('locationCount')));
        }

        return healthStatusCount;
     }

     public static void updateRedScore(Set<Id> locationIds)
     {  List<Location__c> locationToUpdate = new List<Location__c>();
        List<AggregateResult>  redLoationResult = [SELECT Location__c,  COUNT(Id) redScore
                                                    FROM Location_Tracing__c 
                                                    WHERE Person__r.Health_Status__c = 'Red'
                                                    AND Visit_Date__c = LAST_N_DAYS: 10
                                                    AND Location__c IN :locationIds
                                                    GROUP BY Location__c];
        for (AggregateResult redLoc : redLoationResult) {
            String locationId = String.valueOf(redLoc.get('Location__c'));
            Integer redScoreToUpdate = Integer.valueOf(redLoc.get('redScore'));
            String status = getStatus(redScoreToUpdate);
            locationToUpdate.add(new Location__c(Id = locationId, Red_Score__c = redScoreToUpdate, Status__c =status ));
        }
        if(locationToUpdate !=null && locationToUpdate.size()>0)
        {
            update locationToUpdate;
        }
    }

     public static String getStatus(Integer redScore)
     {
        if (redScore == 0) {
            return 'Green';
        } 
        else if(redScore <= 5)
        {
            return 'Yellow';
        }
        else if(redScore <= 10)
        {
            return 'Orange';
        }
        else {
            return 'Red';
        }
     }

}