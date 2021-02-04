/**
 * @description       : This class is use to create customer in quickbooks and contacts/customers in  salesforce
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
global with sharing class CreateCustomer { 
    
    
    //This method is use to craete new Quickboooks customer/ salesforce contact 
    //Fetcing the customer information from the proccessIndicator component
    @AuraEnabled
    global static String create(String detailsOfCustomer,String customerId) 
    {
        String status;
        try{
            Map<String,Object> customerDetails = (Map<String,Object>)JSON.deserializeUntyped(detailsOfCustomer);
            if(CreateCustomer.canReadObject('Account'))
            {
                if(CreateCustomer.canReadField('Account','name')&&
                   CreateCustomer.canReadField('Account','id'))
                {
                    String accountId=(String)customerDetails.get('Companyname');
                    Account acc=[Select name,id from Account Where id=:accountId];
                    String accountName=acc.name;
                    
                    if(CreateCustomer.canReadObject('Quickbooks_Info_meta__mdt')){
                        
                        
                        if( CreateCustomer.canReadField('Quickbooks_Info_meta__mdt', 'Access_Token__c')&&
                           CreateCustomer.canReadField('Quickbooks_Info_meta__mdt', 'label')&&
                           CreateCustomer.canReadField('Quickbooks_Info_meta__mdt', 'Environment__c')&&
                           
                           CreateCustomer.canReadField('Quickbooks_Info_meta__mdt', 'Company_Id__c'))
                        {
                            //Fetching access token from metadta ande decoding it.
                            
                            Quickbooks_Info_meta__mdt quickbooksInfo=[Select Access_Token__c,Environment__c, Company_Id__c from Quickbooks_Info_meta__mdt where label='Quickbooks Access Token'];
                            String companyId= quickbooksInfo.Company_Id__c;
                            
                            //Calling craete customer API
                            Blob payloadBlob = EncodingUtil.base64Decode(quickbooksInfo.Access_Token__c);
                            String accessToken =  payloadBlob.toString();
                            String endPoint;
                            if(quickbooksInfo.Environment__c=='Production'){
                                endPoint = 'https://quickbooks.api.intuit.com/v3/company/'+companyId+'/customer?minorversion=51';
                            }
                            else{
                                endPoint = 'https://sandbox-quickbooks.api.intuit.com/v3/company/'+companyId+'/customer?minorversion=51';
                                
                            }
                            HttpRequest httpReq = new HttpRequest();
                            HttpResponse httpRes = new HttpResponse();
                            Http http = new Http();
                            httpReq.setMethod('POST');
                            httpReq.setEndPoint(endPoint);
                            httpReq.setHeader('Content-Type','application/json');
                            httpReq.setHeader('charset','UTF-8');
                            httpReq.setHeader('Authorization' , 'Bearer '+accessToken);
                            string FName = '';
                            string LName = '';
                            string PrimaryEmailAddr = '';
                            string DisplayName = '';
                            string Title = '';
                            string PrimaryPhone = '';
                            string City = '';
                            string PostalCode = '';
                            string Line1 = '';
                            string Country = '';
                            string GivenName = '';
                            
                            
                            
                            if((String)customerDetails.get('firstName')!= NULL && (String)customerDetails.get('firstName')!= 'null')
                                FName = (String)customerDetails.get('firstName');
                            
                            if((String)customerDetails.get('lastName')!= NULL && (String)customerDetails.get('lastName')!= 'null')
                                LName = (String)customerDetails.get('lastName');
                            
                            if((String)customerDetails.get('email')!= NULL && (String)customerDetails.get('email')!= 'null')
                                PrimaryEmailAddr = (String)customerDetails.get('email');
                            
                            if((String)customerDetails.get('customerName')!= NULL && (String)customerDetails.get('customerName')!= 'null')
                                DisplayName = (String)customerDetails.get('customerName');
                            
                            if((String)customerDetails.get('title')!= NULL && (String)customerDetails.get('title')!= 'null')
                                Title = (String)customerDetails.get('title');
                            
                            if((String)customerDetails.get('phone')!= NULL && (String)customerDetails.get('phone')!= 'null')
                                PrimaryPhone = (String)customerDetails.get('phone');
                            
                            if((String)customerDetails.get('city')!= NULL && (String)customerDetails.get('city')!= 'null')
                                City = (String)customerDetails.get('city');
                            
                            if((String)customerDetails.get('postalCode')!= NULL && (String)customerDetails.get('postalCode')!= 'null')
                                PostalCode = (String)customerDetails.get('postalCode');
                            
                            if((String)customerDetails.get('street')!= NULL && (String)customerDetails.get('street')!= 'null')
                                Line1 = (String)customerDetails.get('street');
                            
                            if((String)customerDetails.get('country')!= NULL && (String)customerDetails.get('country')!= 'null')
                                Country = (String)customerDetails.get('country');
                            
                            if((String)customerDetails.get('customerName')!= NULL && (String)customerDetails.get('customerName')!= 'null')
                                GivenName = (String)customerDetails.get('customerName');
                            
                            
                            httpReq.setBody('{ "FullyQualifiedName": "'+FName+LName+'", "PrimaryEmailAddr": { "Address": "'+PrimaryEmailAddr+'" }, "DisplayName": "'+DisplayName+'", "Title": "'+Title+'", "PrimaryPhone": { "FreeFormNumber": "'+PrimaryPhone+'" }, "CompanyName": "'+accountName+'", "BillAddr": { "City":"'+City+'", "PostalCode":"'+PostalCode+'", "Line1": "'+Line1+'", "Country":"'+Country+'"}, "GivenName":"'+GivenName+'" }');
                            httpRes = http.send(httpReq);
                            //If the customer is not created in quickbooks, we have to delete it from SF also.
                            if (httpRes.getStatusCode() != 200) {
                                if(CreateCustomer.canReadObject('Contact'))
                                {
                                    if(CreateCustomer.canReadField('Contact','Id')&&
                                       CreateCustomer.canReadField('Contact','Quickbooks_Customer_Id__c'))
                                    {
                                        if(CreateCustomer.canDeleteObject('Contact')){
                                            
                                            contact customer = [Select Id,Quickbooks_Customer_Id__c FROM contact WHERE Id=:customerId];
                                            delete customer;
                                        }
                                    }
                                    
                                    Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(httpRes.getBody());
                                    Map<String,Object> reponseFault = (Map<String,Object>)responseMap.get('Fault');
                                    list<Object> reponseError = (list<Object>)reponseFault.get('Error');
                                    Map<String,Object> reponseMessageMap = (Map<String,Object>)reponseError[0];
                                    
                                    String reponseMessage = (String)reponseMessageMap.get('Message');
                                    if(reponseMessage=='Duplicate Name Exists Error'){
                                        status='Duplicate';
                                    }
                                    else{
                                        status=httpRes.getBody()+httpRes.getStatusCode() + ' ' + httpRes.getStatus();
                                    }
                                    
                                }} else {
                                    
                                    //If the customer is created in quickbooks, update the related contact with customer id in SF.
                                    status='ok';
                                    
                                    //If Environment is Production
                                    if(CreateCustomer.canReadObject('Contact'))
                                    {
                                        
                                        if(CreateCustomer.canReadField('Contact','Id')&&
                                           CreateCustomer.canReadField('Contact','Environment__c')&&
                                           CreateCustomer.canReadField('Contact','Quickbooks_Customer_Id__c'))
                                        {
                                            
                                            if(CreateCustomer.canUpdateObject('Contact')){
                                                
                                                if(CreateCustomer.canUpdateField('Contact','Environment__c')&&
                                                   CreateCustomer.canUpdateField('Contact','Quickbooks_Customer_Id__c')){
                                                       Contact customer = [Select Id,Quickbooks_Customer_Id__c,Environment__c FROM Contact WHERE Id=:customerId];
                                                       Dom.Document doc = new Dom.Document();  
                                                       doc.load( httpRes.getBody() );  
                                                       Dom.XMLNode rootElement = doc.getRootElement();  
                                                       for ( Dom.XMLNode childElement : rootElement.getChildElements() ) {  
                                                           for ( Dom.XMLNode detailElement : childElement.getChildElements() )  
                                                           {
                                                               if(detailElement.getName()=='Id')
                                                               {
                                                                   customer.Quickbooks_Customer_Id__c = detailElement.getText();
                                                                   
                                                                   if(quickbooksInfo.Environment__c=='Production'){
                                                                       customer.Environment__c='Production';                           
                                                                   }
                                                                   else{
                                                                       customer.Environment__c='Sandbox';
                                                                   }
                                                               }
                                                           }
                                                       }  
                                                       
                                                       update customer;
                                                       
                                                   }
                                            }
                                            
                                        }
                                        
                                    }
                                }
                        }
                    }
                }
            }
            
        }
        catch(Exception e){
            
            status='Exception message'+e.getMessage()+'==='+'Exception line no.'+e.getLineNumber();
        }
        
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