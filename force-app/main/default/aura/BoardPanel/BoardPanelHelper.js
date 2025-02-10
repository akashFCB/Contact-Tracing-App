({
    addResultRecord: function (component, gameResult) {
       
        const modeValue = component.get("v.selectedMode").toUpperCase();
        // create apex method call action
        const action = component.get("c.addResult");
    
        
        // set parameters
        action.setParams({
            result: gameResult.toUpperCase(),
            mode: modeValue
        });

        // define a callback
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state !== "SUCCESS") {
                console.error("Error in saving record");
            }
        });
        // call apex method
        $A.enqueueAction(action);
    },
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
});