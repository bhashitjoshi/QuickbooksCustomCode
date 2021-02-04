/**
 * @description       : This class is use to put restrictions in invoice object
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
global with sharing class invoice {
    
    // Method to Prevent insertion of invoice apart from the API
    
    global static void preventInsertion(list<Invoice__c> newlist)
    {
        try{
            if(invoice.canReadObject('Invoice__c')){
                if(invoice.canReadField('Invoice__c','QuickBooks_Domain__c')){
                    // Only those Invoice can be inserted which is created from API. 
                    if(newlist[0].QuickBooks_Domain__c==null)
                    {
                        newlist[0].adderror('You can only create Invoice from Quotes');
                    }
                }
            } 
            
        }
        catch(Exception e){
            
            
        }
    }
    
    //Method is used to Prevent the deletion of Invoices
    
    global static void prevent_delete(list<Invoice__c> invoices_list){
        try{
            if(invoice.canReadObject('Invoice__c')){
                if(invoice.canReadField('Invoice__c','QuickBooks_Domain__c')){
                    list<Invoice__c> deletelist=new list<Invoice__c>();
                    
                    for(Invoice__c t:invoices_list)
                    {
                        if(t.QuickBooks_Domain__c!=null)
                        {
                            t.adderror('You can not delete this record');
                        }
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