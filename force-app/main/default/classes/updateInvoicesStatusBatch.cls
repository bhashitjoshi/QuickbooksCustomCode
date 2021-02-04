/**
 * @description       : This class is use to update the status of invoices in batch.
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
global with sharing class updateInvoicesStatusBatch implements Database.Batchable<sObject>,Database.stateful,Database.AllowsCallouts {
    
    global List<Invoice__c> finalInvoiceList=new List<Invoice__c>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String value='Not paid';
        String query = 'SELECT Id, Name,Quickbooks_Invoice_Id__c FROM Invoice__c where status__C=\'Not paid\'';
        return Database.getQueryLocator(query);
    }
    
    //THis method is use to fetch the status of all invoices which has status= 'not paid' and update them if the status got chnaged 
    global void execute(Database.BatchableContext BC, List<Invoice__c> invList) {
        if(updateInvoicesStatusBatch.canReadObject('Quickbooks_Info_meta__mdt')){
            
            
            if( updateInvoicesStatusBatch.canReadField('Quickbooks_Info_meta__mdt', 'Access_Token__c')&&
               updateInvoicesStatusBatch.canReadField('Quickbooks_Info_meta__mdt', 'label')&&
               updateInvoicesStatusBatch.canReadField('Quickbooks_Info_meta__mdt', 'Environment__c')&&
               
               updateInvoicesStatusBatch.canReadField('Quickbooks_Info_meta__mdt', 'Company_Id__c'))
            {
                Quickbooks_Info_meta__mdt quickbooksInfo=[Select Access_Token__c, Company_Id__c,Environment__c from Quickbooks_Info_meta__mdt where label='Quickbooks Access Token'];
                for(invoice__c inv:invList)
                {
                    if(updateInvoicesStatusBatch.canReadObject('invoice__c')){
                        
                        if(updateInvoicesStatusBatch.canUpdateObject('invoice__c')){
                            if(updateInvoicesStatusBatch.canReadField('invoice__c','Quickbooks_Invoice_Id__c'))
                            {
                                
                                // process each batch of records default size is 200
                                String companyId= quickbooksInfo.Company_Id__c;
                                Blob payloadBlob = EncodingUtil.base64Decode(quickbooksInfo.Access_Token__c);
                                String accessToken =  payloadBlob.toString();
                                String endPoint;
                                if(quickbooksInfo.Environment__c=='Production'){
                                    endPoint = 'https://quickbooks.api.intuit.com/v3/company/'+companyId+'/query?query=select%20*%20from%20Invoice%20where%20id%20=%20\''+inv.Quickbooks_Invoice_Id__c+'\'%20AND%20balance=\'0\'';
                                }
                                else{
                                    endPoint = 'https://sandbox-quickbooks.api.intuit.com/v3/company/'+companyId+'/query?query=select%20*%20from%20Invoice%20where%20id%20=%20\''+inv.Quickbooks_Invoice_Id__c+'\'%20AND%20balance=\'0\'';
                                    
                                }
                                HttpRequest httpReq = new HttpRequest();
                                HttpResponse httpRes = new HttpResponse();
                                Http http = new Http();
                                httpReq.setMethod('GET');
                                httpReq.setEndPoint(endPoint);
                                httpReq.setHeader('Content-Type','text/plain');
                                httpReq.setHeader('Accept','application/json');
                                httpReq.setHeader('Authorization' , 'Bearer '+accessToken);
                                httpRes = http.send(httpReq);
                                
                                if (httpRes.getStatusCode() == 200) {
                                    
                                    
                                    Map<String, Object> mapOfQueryRes = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                                    Map<String, Object> mapOfQuery = (Map<String, Object>)mapOfQueryRes.get('QueryResponse');
                                    
                                    
                                    
                                    
                                    if(updateInvoicesStatusBatch.canReadField('invoice__c','Status__c'))
                                    {
                                        if(updateInvoicesStatusBatch.canUpdateField('invoice__c','Status__c'))
                                        {
                                            if((List<Object>)mapOfQuery.get('Invoice')!=null)
                                            {
                                                finalInvoiceList.add(inv);
                                            }
                                        }
                                    } 
                                    if(finalInvoiceList.size()>0)
                                    {
                                        for(invoice__c finalInvoice:finalInvoiceList)
                                        {
                                            finalInvoice.Status__c='Paid';
                                        }
                                    }
                                    update finalInvoiceList;
                                    
                                    
                                     
                                }}
                        }}
                }}
        }
    }
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
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
    
    public static Boolean canUpdateObject(String objectName)
    {
        Schema.DescribeSObjectResult sObjResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        return sObjResult.isUpdateable();
    }
    public static Boolean canUpdateField(String objectName, String fieldName)
    {
        Schema.DescribeFieldResult sObjFieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        return sObjFieldResult.isUpdateable();
    }
    
    
}