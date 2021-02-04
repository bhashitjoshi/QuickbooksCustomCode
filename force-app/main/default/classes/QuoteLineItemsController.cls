/**
 * @description       : This class is use give data to processIndicator LWC component.
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
global with sharing class QuoteLineItemsController {
    @AuraEnabled(Cacheable = true)
    
    //Returning Quote Items List Related to Quote
    public static String getQuoteLineItems(String recordId)
    {
        List<QuoteLineItem> quoteLineItemList=new List<QuoteLineItem>();
        
        if(QuoteLineItemsController.canReadObject('QuoteLineItem')){
            
            
            if( QuoteLineItemsController.canReadField('QuoteLineItem', 'QuoteId')&&
               QuoteLineItemsController.canReadField('QuoteLineItem', 'Product2Id')&&
               QuoteLineItemsController.canReadField('QuoteLineItem', 'Quantity')&&
               QuoteLineItemsController.canReadField('QuoteLineItem', 'UnitPrice')&&
               QuoteLineItemsController.canReadField('QuoteLineItem', 'Description'))       
            {
                if(QuoteLineItemsController.canReadObject('Product2')){
                    
                    
                    if( QuoteLineItemsController.canReadField('Product2', 'Name')&&
                       QuoteLineItemsController.canReadField('Product2', 'Quickbooks_Product_ID_Sandbox__c')&&
                       QuoteLineItemsController.canReadField('Product2', 'Quickbooks_Product_ID__c')){
                           quoteLineItemList = [SELECT QuoteId, Product2Id,Product2.Name,Product2.Quickbooks_Product_ID__c,Product2.Quickbooks_Product_ID_Sandbox__c,Quantity,UnitPrice,Description FROM QuoteLineItem WHERE QuoteId=:recordId];
                       }
                }
            }
        }
        return JSON.serialize(quoteLineItemList);
    }
    @AuraEnabled(Cacheable = true)
    
    
    //Returning Account Id to the Customer record edit form 
    public static String getCompanyId(String recordId){
        
        List<Quote>quoteList= new List<Quote>();
        if(QuoteLineItemsController.canReadObject('Quote')){
            
            
            if( QuoteLineItemsController.canReadField('Quote', 'AccountID')&&
               QuoteLineItemsController.canReadField('Quote', 'Id'))
            {
                
                
                quoteList = [SELECT AccountID FROM Quote WHERE Id=:recordId];
                
                
            }
        }
        
        return quoteList[0].AccountID;
        
        
    }
    
    @AuraEnabled(Cacheable = true)
    //Returning Customers list related to a account
    public static string getCustomers(String AccountId){
        List<Contact> CustomerList=new List<Contact>();
        if(QuoteLineItemsController.canReadObject('Contact')){
            
            
            if( QuoteLineItemsController.canReadField('Contact', 'Display_Name__c')&&
               QuoteLineItemsController.canReadField('Contact', 'Email')&& 
               QuoteLineItemsController.canReadField('Contact', 'Environment__c')&&
               QuoteLineItemsController.canReadField('Contact', 'Quickbooks_Customer_Id__c')&&
               QuoteLineItemsController.canReadField('Contact', 'AccountId'))
            {
                CustomerList=[Select Display_Name__c,Email,Environment__c from Contact Where AccountId=:AccountId AND Quickbooks_Customer_Id__c !=null ];
            }
        }
        return JSON.serialize(CustomerList); 
        
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