/**
 * @description       : This class is use to update the status of invoices on a click of a button.
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/ 
global with sharing class updateInvoiceButtonApex { 
    
    @AuraEnabled
    //This method is use to check the particular invoice's status and update it on a click of a button
    public static String updateStatus(Id artId){
        String status='';
        
        if(updateInvoiceButtonApex.canReadObject('invoice__c')){
            
            if(updateInvoiceButtonApex.canUpdateObject('invoice__c')){
                
                
                if(updateInvoiceButtonApex.canReadField('invoice__c','Status__c')&&
                   updateInvoiceButtonApex.canReadField('invoice__c','QuickBooks_Invoice_Id__c')&&
                   updateInvoiceButtonApex.canReadField('invoice__c','id'))
                {
                    if(updateInvoiceButtonApex.canUpdateField('invoice__c','Status__c')&&
                       updateInvoiceButtonApex.canUpdateField('invoice__c','QuickBooks_Invoice_Id__c'))
                    {
                        
                        Invoice__c inv=[Select id,QuickBooks_Invoice_Id__c,Status__c from Invoice__C where id=:artId];
                        String InvId=inv.QuickBooks_Invoice_Id__c;
                        
                        if(updateInvoiceButtonApex.canReadObject('Quickbooks_Info_meta__mdt')){
                            
                            
                            if( updateInvoiceButtonApex.canReadField('Quickbooks_Info_meta__mdt', 'Access_Token__c')&&
                               updateInvoiceButtonApex.canReadField('Quickbooks_Info_meta__mdt', 'label')&&
                               updateInvoiceButtonApex.canReadField('Quickbooks_Info_meta__mdt', 'Environment__c')&&
                               
                               updateInvoiceButtonApex.canReadField('Quickbooks_Info_meta__mdt', 'Company_Id__c'))
                            {
                                
                                //Fetching the information of that selected inovice and checking if the balance is 0 or not.
                                //If the balance is 0 then is status is paid otherwisw not paid.
                                Quickbooks_Info_meta__mdt quickbooksInfo=[Select Access_Token__c, Company_Id__c,Environment__c from Quickbooks_Info_meta__mdt where label='Quickbooks Access Token'];
                                String companyId= quickbooksInfo.Company_Id__c;
                                System.debug('Access_Token__c->'+quickbooksInfo.Access_Token__c);
                                Blob payloadBlob = EncodingUtil.base64Decode(quickbooksInfo.Access_Token__c);
                                String accessToken =  payloadBlob.toString();
                                System.debug('blob=>'+accessToken);
                                Decimal Balance;
                                
                                string invoiceId = '\''+InvId+'\'';
                                String endPoint;
                                if(quickbooksInfo.Environment__c=='Production'){
                                    endPoint = 'https://quickbooks.api.intuit.com/v3/company/'+companyId+'/query?query=select%20Balance%20from%20Invoice%20where%20id%20%3D'+invoiceId+'&minorversion=52';
                                }
                                else{
                                    endPoint = 'https://sandbox-quickbooks.api.intuit.com/v3/company/'+companyId+'/query?query=select%20Balance%20from%20Invoice%20where%20id%20%3D'+invoiceId+'&minorversion=52';
                                    
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
                                
                                try{
                                    if (httpRes.getStatusCode() == 200) {
                                        
                                        
                                        Map<String, Object> mapOfQueryRes = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                                        Map<String, Object> mapOfQuery = (Map<String, Object>)mapOfQueryRes.get('QueryResponse');
                                        List<Object> mapOfInvoice = (List<Object>)mapOfQuery.get('Invoice');
                                        for(Object obj : mapOfInvoice) {
                                            Map<String, Object> mapOfInv = (Map<String, Object>)obj;
                                            Balance = (Decimal)mapOfInv.get('Balance');
                                            System.debug('Balance'+Balance);
                                            //If the balance is 0 update the status of invoice
                                            if(Balance==0)
                                            {
                                                
                                                Invoice__c updateinv=new Invoice__c();
                                                updateinv.id=artId;
                                                updateinv.Status__c='Paid';
                                                update updateinv;
                                                status='paid';
                                                System.debug('status-->'+status);
                                                
                                            }
                                            else{
                                                
                                                status='not paid';
                                                System.debug('statusasbhd');
                                            }
                                            
                                            
                                        }}
                                    else {
                                        
                                    }
                                    
                                    
                                }
                                catch(Exception e){
                                    
                                    System.debug('exp->'+e.getMessage());
                                }
                                
                                
                            }
                        }
                    }
                }
            }
        }
        System.debug('stattusajsnd->'+status);
        return status;
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
    public static Boolean canCreateObject(String objectName)
    {
        Schema.DescribeSObjectResult sObjResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        return sObjResult.isCreateable();
    }
    public static Boolean canCreateField(String objectName, String fieldName)
    {
        Schema.DescribeFieldResult sObjFieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        return sObjFieldResult.isCreateable();
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
    public static Boolean canDeleteObject(String objectName)
    {
        Schema.DescribeSObjectResult sObjResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        return sObjResult.isDeletable();
    }
    
}