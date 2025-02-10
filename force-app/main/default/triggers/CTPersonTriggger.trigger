trigger CTPersonTriggger on Person__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                CTPersonTriggerHandler.beforeInsertHandler(Trigger.new);     
            }
            when AFTER_INSERT {
                
            }
            when BEFORE_UPDATE{
                CTPersonTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldMap);
            }
            /**
             * Note - We are using after update because here i am updating
             * record of one field and that is affecting 
             * fields of another record
             */
            when AFTER_UPDATE {
                CTPersonTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            }
        }

}