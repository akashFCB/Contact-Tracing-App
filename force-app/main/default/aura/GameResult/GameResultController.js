({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
                {label: 'Game Number', fieldName: 'Name', type: 'text'},
                {label: 'Mode', fieldName: 'Mode__c', type: 'text'},
                {label: 'Played On', fieldName: 'CreatedDate', type: 'date'},
                {label: 'Result', fieldName: 'Result__c', type: 'text'}
            ]);
    
    
            helper.fetchResult(component);
        
    },
    onResultHandler: function(component, event, helper)
    {
        helper.fetchResult(component);
    }
})
