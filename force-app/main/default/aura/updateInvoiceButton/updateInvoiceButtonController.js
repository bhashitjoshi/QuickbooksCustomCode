({
    doInit : function(component, event, helper) {
        var artId = component.get("v.recordId");
        
        var action = component.get("c.updateStatus");
        action.setParams({ artId : artId})
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state',state);
              var getResult = response.getReturnValue();
              console.log('getResult->',getResult);
            if(getResult == 'paid'){
                        component.set("v.success",'Payment has been received. ');

              
            }else{
                
                        component.set("v.error" ,'Payment has not been received. ');

            
            }
        });
        $A.enqueueAction(action);
        
        
    
     // window.setTimeout(function(){window.location.reload()}, 2000);        


    }
})