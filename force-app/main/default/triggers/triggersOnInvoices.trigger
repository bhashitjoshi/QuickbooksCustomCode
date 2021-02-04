trigger triggersOnInvoices on Invoice__c (before insert, before update, before delete) {
    
     if( Trigger.isInsert )
    {
        if(Trigger.isBefore)
        {
            invoice.preventInsertion(Trigger.new);
        }
        
    }
    else if(Trigger.isUpdate)
    {
        if(Trigger.isBefore)
        {
            for (Invoice__c sl: Trigger.new) 
            {
                Invoice__c oldSL = Trigger.oldMap.get(sl.ID);
                if((sl.Account_Name__c!=oldsL.Account_Name__c||sl.QuickBooks_Domain__c!=oldsL.QuickBooks_Domain__c||sl.Quickbooks_Invoice_Id__c!=oldsL.Quickbooks_Invoice_Id__c || sl.Total_Amount__c!=oldsL.Total_Amount__c))
                {
                    sl.addError('You cannnot edit Invoice.');
                }
            }
        }
    }
    
     else if(Trigger.isdelete){
        
        if(Trigger.isBefore){
            
            invoice.prevent_delete(Trigger.old);
        }
    }

}