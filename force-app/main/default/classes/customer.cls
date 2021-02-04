/**
 * @description       : This class is use to put restrictions in contact object
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
global with sharing class customer {
    
    
    // Method to Prevent insertion of Customer apart from the lwc component
    
    global static void preventInsertion(list<Contact> newlist)
    {
        try{
            if(customer.canReadObject('Contact')){
                if(customer.canReadField('Contact','CheckBeforeInsert__c')&&
                   customer.canReadField('Contact','Quickbooks_Customer_Id__c')){
                       
                       // Only those customer can not be inserted in which value of 'CheckBeforeInsert__c' field is false and quickbook customer id is not null. 
                       if(newlist[0].CheckBeforeInsert__c==false && (newlist[0].Quickbooks_Customer_Id__c!=null || newlist[0].Environment__c!=null) )
                       {
                           newlist[0].adderror('QuickBooks customer Id should be Null.');
                       }
                       
                   }
            }
            
            
        }
        catch(Exception e){
            
            
        }
    }
    
    
    
    
    public static Boolean canReadObject(String objectName)
    {
        Schema.DescribeSObjectResult sObjResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        return sObjResult.isAccessible();
    }
    public static Boolean canReadField(String objectName, String fieldName)
    {
        
        Schema.DescribeFieldResult sObjFieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        return sObjFieldResult.isAccessible();
    }
    
}