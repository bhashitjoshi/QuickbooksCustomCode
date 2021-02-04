/**
 * @description       : This class is use to fetch the customers from quickbook account and create them in salesforce 
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
global with sharing class QbAccountController {
    
    @AuraEnabled
    //Checking the Toggle button i.e if it is active or not.
    public static boolean fetchSyncAccount()
    {
        List<SyncQB__c> SyncQBList = new List<SyncQB__c>();
        SyncQBList = SyncQB__c.getAll().values();
        if(SyncQBList.size() > 0 ){
            
            SyncQB__c SyncQB = SyncQBList[0];
            return SyncQB.SyncAccount__c;
        }
        return false;
    }
    
    
    // This method is use to fetch customer from quickbooks and create appropropriate accounts and contacs in SF 
    
    @AuraEnabled
    public static void fetchQbCustomers()
    {
        
        if(QbAccountController.canReadObject('Quickbooks_Info_meta__mdt')){
            if(QbAccountController.canReadField('Quickbooks_Info_meta__mdt', 'label')&&
               QbAccountController.canReadField('Quickbooks_Info_meta__mdt', 'Access_Token__c')&&
               QbAccountController.canReadField('Quickbooks_Info_meta__mdt', 'Company_Id__c')&&
               QbAccountController.canReadField('Quickbooks_Info_meta__mdt', 'Environment__c')&&
               
               QbAccountController.canReadField('Quickbooks_Info_meta__mdt', 'Expires_in_Seconds__c')&&
               QbAccountController.canReadField('Quickbooks_Info_meta__mdt', 'Refresh_Token__c'))       
            {
                if(QbAccountController.canReadObject('Account')){
                    
                    if(QbAccountController.canCreateObject('Account')){
                        
                        
                        if(QbAccountController.canReadField('Account','Name'))
                        {
                            if(QbAccountController.canCreateField('Account','Name'))
                            {
                                
                                //Fetching access token and company id for API callout
                                Quickbooks_Info_meta__mdt quickbooksInfo=[Select Access_Token__c, Company_Id__c,Environment__c from Quickbooks_Info_meta__mdt where label='Quickbooks Access Token'];
                                String companyId= quickbooksInfo.Company_Id__c;
                                Blob payloadBlob = EncodingUtil.base64Decode(quickbooksInfo.Access_Token__c);
                                String accessToken =  payloadBlob.toString();
                                
                                String endPoint;
                                if(quickbooksInfo.Environment__c=='Production'){
                                    endPoint = 'https://quickbooks.api.intuit.com/v3/company/'+companyId+'/query?query=select%20%2A%20from%20Customer%20MAXRESULTS%201000&minorversion=51';
                                }
                                else{
                                    endPoint = 'https://sandbox-quickbooks.api.intuit.com/v3/company/'+companyId+'/query?query=select%20%2A%20from%20Customer%20MAXRESULTS%201000&minorversion=51';
                                    
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
                                    
                                    Map<String,Object> Responsemap = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                                    Map<String,Object> ResponsemapItem = (Map<String, Object>)Responsemap.get('QueryResponse');
                                    List<Object> lst_JsonParse = (List<Object>)ResponsemapItem.get('Customer');
                                    
                                    Map<String, Account> accMap = new Map<String, Account>();
                                    
                                    //Creating Account in salesforce
                                    List<Account> AccountList = new List<Account>();
                                    Account Acc;
                                    for(Object obj : lst_JsonParse)
                                    {
                                        Map<String,Object> mp_StrObj = (Map<string,Object>)obj;
                                        if((String)mp_StrObj.get('CompanyName') != NULL)
                                        {
                                            Acc = new Account();
                                            Acc.Name = (String)mp_StrObj.get('CompanyName');
                                            AccountList.add(Acc);
                                            
                                        }
                                    }
                                    Insert AccountList;
                                    
                                    accMap = new Map<String, Account>();
                                    
                                    for(Account a : AccountList)
                                    {
                                        accMap.put(a.Name, a);
                                    }
                                    
                                    if(QbAccountController.canReadObject('Contact')){
                                        
                                        if(QbAccountController.canCreateObject('Contact')){
                                            
                                            
                                            if(QbAccountController.canReadField('Contact','AccountId')&&
                                               QbAccountController.canReadField('Contact','CheckBeforeInsert__c')&&
                                               QbAccountController.canReadField('Contact','LastName')&&
                                               QbAccountController.canReadField('Contact','Display_Name__c')&&
                                               QbAccountController.canReadField('Contact','MailingStreet')&&
                                               QbAccountController.canReadField('Contact','MailingCity')&&
                                               QbAccountController.canReadField('Contact','MailingCountry')&&
                                               QbAccountController.canReadField('Contact','MailingPostalCode')&&
                                               QbAccountController.canReadField('Contact','MailingState')&&
                                               QbAccountController.canReadField('Contact','Phone')&&
                                               QbAccountController.canReadField('Contact','Environment__c')&&
                                               QbAccountController.canReadField('Contact','Email')&&
                                               
                                               QbAccountController.canReadField('Contact','Quickbooks_Customer_Id__c'))
                                            {
                                                if(QbAccountController.canCreateField('Contact','AccountId')&&
                                                   QbAccountController.canCreateField('Contact','CheckBeforeInsert__c')&&
                                                   QbAccountController.canCreateField('Contact','LastName')&&
                                                   QbAccountController.canCreateField('Contact','Display_Name__c')&&
                                                   QbAccountController.canCreateField('Contact','MailingStreet')&&
                                                   QbAccountController.canCreateField('Contact','MailingCity')&&
                                                   QbAccountController.canCreateField('Contact','MailingCity')&&
                                                   QbAccountController.canCreateField('Contact','MailingCountry')&&
                                                   QbAccountController.canCreateField('Contact','MailingPostalCode')&&
                                                   QbAccountController.canCreateField('Contact','MailingState')&&
                                                   QbAccountController.canCreateField('Contact','Phone')&&
                                                   QbAccountController.canCreateField('Contact','Email')&&
                                                   QbAccountController.canCreateField('Contact','Quickbooks_Customer_Id__c'))
                                                {
                                                    
                                                    //Creating Contacts in salesforce
                                                    List<Contact> CustomerList = new List<Contact>();
                                                    Contact Customer;
                                                    for(Object obj : lst_JsonParse)
                                                    {
                                                        Map<String,Object> mp_StrObj = (Map<string,Object>)obj;
                                                        
                                                        if((String)mp_StrObj.get('DisplayName') != NULL && (String)mp_StrObj.get('CompanyName') != NULL)
                                                        {
                                                            Customer = new Contact();
                                                            Acc = accMap.get((String)mp_StrObj.get('CompanyName'));
                                                            Customer.AccountId = acc.Id;
                                                            Customer.CheckBeforeInsert__c = true;
                                                            Customer.LastName = (String)mp_StrObj.get('FullyQualifiedName');
                                                            Customer.Display_Name__c = (String)mp_StrObj.get('DisplayName');
                                                            Customer.Quickbooks_Customer_Id__c = (String)mp_StrObj.get('Id');
                                                            if(mp_StrObj.get('BillAddr') != NULL)
                                                            {
                                                                Map<String,Object> mp_StrObj3 = (Map<string,Object>)mp_StrObj.get('BillAddr');
                                                                
                                                                if((String)mp_StrObj3.get('City') != NULL && (String)mp_StrObj3.get('City') != 'null')
                                                                    Customer.MailingCity = (String)mp_StrObj3.get('City');
                                                                
                                                                if((String)mp_StrObj3.get('Line1') != NULL && (String)mp_StrObj3.get('Line1') != 'null')
                                                                    Customer.MailingStreet = (String)mp_StrObj3.get('Line1');
                                                                
                                                                if((String)mp_StrObj3.get('Country') != NULL && (String)mp_StrObj3.get('Country') != 'null')
                                                                    Customer.MailingCountry = (String)mp_StrObj3.get('Country');
                                                                
                                                                if((String)mp_StrObj3.get('PostalCode') != NULL && (String)mp_StrObj3.get('PostalCode') != 'null')
                                                                    Customer.MailingPostalCode = (String)mp_StrObj3.get('PostalCode');
                                                                
                                                                if((String)mp_StrObj3.get('CountrySubDivisionCode') != NULL && (String)mp_StrObj3.get('CountrySubDivisionCode') != 'null')
                                                                    Customer.MailingState = (String)mp_StrObj3.get('CountrySubDivisionCode');
                                                            }
                                                            
                                                            if(mp_StrObj.get('PrimaryPhone') != NULL)
                                                            {
                                                                Map<String,Object> mp_StrObj4 = (Map<string,Object>)mp_StrObj.get('PrimaryPhone');
                                                                
                                                                if((String)mp_StrObj4.get('FreeFormNumber') != NULL  && (String)mp_StrObj4.get('FreeFormNumber') != 'null')
                                                                    Customer.Phone = (String)mp_StrObj4.get('FreeFormNumber');
                                                                
                                                            }
                                                            
                                                            if(mp_StrObj.get('PrimaryEmailAddr') != NULL){
                                                                Map<String,Object> mp_StrObj2 = (Map<string,Object>)mp_StrObj.get('PrimaryEmailAddr');
                                                                if((String)mp_StrObj2.get('Address') != NULL){
                                                                    Customer.Email = (String)mp_StrObj2.get('Address');
                                                                    
                                                                }
                                                            }
                                                            
                                                            if(quickbooksInfo.Environment__c=='Production')
                                                            {
                                                                customer.Environment__c='Production';
                                                            }
                                                            else{
                                                                customer.Environment__c='Sandbox';
                                                            }
                                                            CustomerList.add(Customer);
                                                        }
                                                    }
                                                    Insert CustomerList;
                                                    
                                                    SyncQB__c SyncQB = new SyncQB__c();
                                                    List<SyncQB__c> SyncQBList = new List<SyncQB__c>();
                                                    SyncQBList = SyncQB__c.getAll().values();
                                                    
                                                    if(SyncQBList.size() > 0 ){
                                                        
                                                        SyncQB = SyncQBList[0];
                                                        SyncQB.SyncAccount__c = true;
                                                        
                                                    }
                                                    else{
                                                        SyncQB.Name = 'syncAccount';
                                                        SyncQB.SyncAccount__c = true;
                                                    }
                                                    
                                                    upsert new List<SyncQB__c>{SyncQB};
                                                        
                                                        } else {
                                                            
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
        }
    } 
    
    public static void DeleteCustomers()
    {
        Delete [SELECT Id from Account where createdDate = today];
        Delete [SELECT Id from Contact where createdDate = today];
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