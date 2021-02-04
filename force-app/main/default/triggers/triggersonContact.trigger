trigger triggersonContact on Contact (before insert, before update,before delete) {
    
     if( Trigger.isInsert )
    {
        if(Trigger.isBefore)
        {
            customer.preventInsertion(Trigger.new);
        }
        
    }
    else if(Trigger.isUpdate)
    {
        if(Trigger.isBefore)
        {
            for (Contact sl: Trigger.new) 
            {
                Contact oldSL = Trigger.oldMap.get(sl.ID);
                if(oldsL.Quickbooks_Customer_Id__c==null)
                {
                    system.debug('Update');
                }
                else if((sl.AccountId!=oldsL.AccountId||sl.MailingPostalCode!=oldsL.MailingPostalCode||sl.Quickbooks_Customer_Id__c!=oldsL.Quickbooks_Customer_Id__c||sl.MailingState!=oldsL.MailingState||sl.MailingStreet!=oldsL.MailingStreet||sl.Title!=oldsL.Title||sl.MailingCity!=oldsL.MailingCity||sl.MailingCountry!=oldsL.MailingCountry||sl.Display_Name__c!=oldsL.Display_Name__c||sl.Email!= oldSL.Email)||(sl.FirstName!=oldSL.FirstName)||(sl.LastName!=oldSL.LastName)||(sl.Phone!=oldSL.Phone||sl.CheckBeforeInsert__c!=oldSL.CheckBeforeInsert__c))
                {
                    sl.addError('You cannnot edit Customer.');
                }
            }
        }
    }
    
     else if(Trigger.isdelete){
        
        if(Trigger.isBefore){
            
           // customer.prevent_delete(Trigger.old);
        }
    }

}