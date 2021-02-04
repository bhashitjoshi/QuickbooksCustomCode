/**
 * @description       : This class is use to authenticate the quickbook account and store the token in metadata
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
global with sharing class QuickBookConnectionApex implements Metadata.DeployCallback {
    
    public static boolean button{get;set;}
    
    
    public static String redirect_URI = 'https://cypress-developer-edition.na111.force.com';
    // Client id and secret of production 
    
    public static String client_Id = 'ABfJWVOp4pMGKaLWJ6RoSLsLfcSTJTzSD2pWqOaTAOj1DmAU1Z';
    public static String consumer_Secret = 'pammPvOsCnGowsd12aHUG4zsOAlmwjBwsjNsI6qV';
    
    //Client id and secret of Client's Sandbox
    public static String client_Id_SandBox = 'AB9gu7Lc1CQGXwDJCiBL5CmlxNubUC5W77dEJeHNtJLuvuh3i5';
    public static String consumer_Secret_SandBox = 'jDHNzBeEdcYoeZZvrSeIZV3JyiIrGB45paWrFlYC';
    
    
    
    // Constructor for visibility of  close button
    global QuickBookConnectionApex(){
        button=false;
        
    }
    global static PageReference doAuthorizationQuickBooks(){
        
        String authorization_endpoint = 'https://appcenter.intuit.com/connect/oauth2';
        
        
        String scope = 'com.intuit.quickbooks.accounting';
        String final_EndPoint;
        SyncQB__c SyncQB = new SyncQB__c();
        List<SyncQB__c> SyncQBList = new List<SyncQB__c>();
        SyncQBList = SyncQB__c.getAll().values();
        
        if(SyncQBList.size() > 0 ){
            
            SyncQB = SyncQBList[0];
            SyncQB.Environment__c = 'Production';
            
            
        }
        else{
            SyncQB.Name = 'Environment';
            SyncQB.Environment__c = 'Production';
            
        }
        
        upsert new List<SyncQB__c>{SyncQB};
            final_EndPoint = authorization_endpoint+'?client_id='+client_Id+'&response_type=code&scope='+
            scope+'&state='+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/QuickBookConnectionVf&redirect_uri='+redirect_URI;
        
        PageReference pageRef = new PageReference(final_EndPoint);
        
        return pageRef;
        
    }
    
    global static PageReference doAuthorizationQuickBooksSandbox(){
        
        String authorization_endpoint = 'https://appcenter.intuit.com/connect/oauth2';
        
        
        String scope = 'com.intuit.quickbooks.accounting';
        String final_EndPoint;
        SyncQB__c SyncQB = new SyncQB__c();
        List<SyncQB__c> SyncQBList = new List<SyncQB__c>();
        SyncQBList = SyncQB__c.getAll().values();
        
        if(SyncQBList.size() > 0 ){
            
            SyncQB = SyncQBList[0];
            
            SyncQB.Environment__c = 'Sandbox';
            
            
        }
        else{
            SyncQB.Name = 'Environment';
            
            
            SyncQB.Environment__c = 'Sandbox';
            
        }
        
        upsert new List<SyncQB__c>{SyncQB};
            
            final_EndPoint = authorization_endpoint+'?client_id='+client_Id_SandBox+'&response_type=code&scope='+
            scope+'&state='+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/QuickBookConnectionVf&redirect_uri='+redirect_URI;
        
        PageReference pageRef = new PageReference(final_EndPoint);
        
        return pageRef;
        
    }
    
    // This method is use to fetch the access code from the URL and then Get the access token
    // In this methid we are also scheduling 2 classes i.e updateInvoiceStatusSchedule andReauthentication
    global static void doFetchAccessToken(){
        
        String Env;
        //Fetcing the access code
        
        String oAuthCode = ApexPages.currentPage().getParameters().get('code');
        if(oAuthCode!=null){
            
            //Fetching Environment value from Custom setting
            List<SyncQB__c> SyncQBList = new List<SyncQB__c>();
            SyncQBList = SyncQB__c.getAll().values();
            if(SyncQBList.size() > 0 ){
                
                SyncQB__c SyncQB = SyncQBList[0];
                Env=SyncQB.Environment__c;
            }
            
            if(QuickBookConnectionApex.canReadObject('Quickbooks_Info_meta__mdt')){
                
                if(QuickBookConnectionApex.canReadField('Quickbooks_Info_meta__mdt', 'label')&&
                QuickBookConnectionApex.canReadField('Quickbooks_Info_meta__mdt', 'Access_Token__c')&&
                   QuickBookConnectionApex.canReadField('Quickbooks_Info_meta__mdt', 'Company_Id__c')&&
                   
                   QuickBookConnectionApex.canReadField('Quickbooks_Info_meta__mdt', 'Environment__c')&&
                   QuickBookConnectionApex.canReadField('Quickbooks_Info_meta__mdt', 'Expires_in_Seconds__c')&&
                   QuickBookConnectionApex.canReadField('Quickbooks_Info_meta__mdt', 'Refresh_Token__c'))       
                {
                    String encodedString;
                    if(Env=='Production'){
                        encodedString = EncodingUtil.base64Encode(Blob.valueOf(client_Id+':'+consumer_Secret));
                    }
                    else{
                        encodedString = EncodingUtil.base64Encode(Blob.valueOf(client_Id_SandBox+':'+consumer_Secret_SandBox));
                        
                    }
                    String endPoint = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer';
                    String requestBody = 'grant_type=authorization_code&code='+oAuthCode+'&redirect_uri='+redirect_URI;
                    String errorMessage ='';
                    
                    //Authenticating SF with Quickbooks and fetching the accesstoken and refresh token 
                    HttpRequest httpReq = new HttpRequest();
                    HttpResponse httpRes = new HttpResponse();
                    Http http = new Http();
                    httpReq.setMethod('POST');
                    httpReq.setEndPoint(endPoint);
                    httpReq.setHeader('Authorization' , 'Basic '+encodedString);
                    httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
                    httpReq.setBody(requestBody);
                    try{
                        httpRes = http.send(httpReq);
                        if(httpRes.getStatusCode() == 200){
                            Map<String, Object> response_Map;
                            try{
                                response_Map = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                            }
                            catch(exception ex)
                            {
                                
                            }
                            
                            // Fetching the access token and refresh token form the respose and saveing it in custom metadata.
                            
                            
                            String companyId = ApexPages.currentPage().getParameters().get('realmId');
                            String accessToken = EncodingUtil.base64Encode(Blob.valueof((String)response_Map.get('access_token')));
                            
                            String refreshToken = EncodingUtil.base64Encode(Blob.valueof((String)response_Map.get('refresh_token')));
                            Decimal expiresIn = (Decimal)response_Map.get('expires_in');
                            Decimal expiresInRefToken = (Decimal)response_Map.get('x_refresh_token_expires_in');
                            
                            String label='Quickbooks Access Token';
                            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
                            customMetadata.fullName  = 'Quickbooks_Info_meta.Quickbooks_Access_Token';
                            customMetadata.label = label;
                            
                            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
                            
                            customField1.field = 'Access_Token__c';
                            customField1.value = accessToken;
                            customMetadata.values.add(customField1);
                            
                            Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();
                            customField2.field = 'Company_Id__c';
                            customField2.value = companyId;
                            customMetadata.values.add(customField2);
                            
                            Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
                            
                            customField3.field = 'Expires_in_Seconds__c';
                            customField3.value = expiresIn;
                            customMetadata.values.add(customField3);
                            
                            Metadata.CustomMetadataValue customField4 = new Metadata.CustomMetadataValue();
                            customField4.field = 'Refresh_Token__c';
                            customField4.value = refreshToken;
                            customMetadata.values.add(customField4);
                            
                            Metadata.CustomMetadataValue customField5 = new Metadata.CustomMetadataValue();
                            
                            customField5.field = 'Refresh_Token_Expires_in__c';
                            customField5.value = expiresInRefToken;
                            customMetadata.values.add(customField5);
                            
                            
                            Metadata.CustomMetadataValue customField6 = new Metadata.CustomMetadataValue();
                            
                            customField6.field = 'Environment__c';
                            if(Env=='Production'){
                                customField6.value = 'Production';
                            }
                            else{
                                customField6.value = 'Sandbox';
                            }
                            customMetadata.values.add(customField6);
                            
                            
                            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
                            mdContainer.addMetadata(customMetadata);
                            QuickBookConnectionApex callback = new QuickBookConnectionApex();
                            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
                            
                            
                            button=true;
                            
                            if(Env=='Production'){
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Successfully Authenticated with Quickbooks Production System!!!'));
                            }
                            else{
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Successfully Authenticated with Quickbooks Sandbox System!!!'));
                            }
                            
                            Integer jobCount=[SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.JobType = '7'];
                            if(jobCount==0){
                                System.schedule('Refresh Token Job 1', '0 30 * * * ?', new Reauthentication());
                                System.schedule('Refresh Token Job 2', '0 59 * * * ?', new Reauthentication());
                                System.schedule('Invoice Status Update Job 3', '0 16 22 ? * * *', new updateInvoiceStatusSchedule());
                                
                            }
                        }else{
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'137Unexpected Error while communicating with Quickbooks API'+
                                                                       'Status '+httpRes.getStatus()+' and Status Code '));
                        }
                        
                    }catch(System.Exception e){
                        if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                            errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                                +' Remote Site Setting and add '+' '+ endPoint +' Endpoint';
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
                            //return null;
                        }else{
                            errorMessage = '149 Unexpected Error while communicating with Quickbooks API. '
                                +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
                            //return null;
                        }
                    }}
                
            }
        }
        
    }
    
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
        } else {
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