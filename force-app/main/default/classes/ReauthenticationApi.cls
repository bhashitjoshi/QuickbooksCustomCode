/**
 * @description       : This class is use to reauthenticate the access token from the refresh token.
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
global with sharing class ReauthenticationApi {
    
    
    // Client id and secret of production 
    
    public static String client_Id = 'ABfJWVOp4pMGKaLWJ6RoSLsLfcSTJTzSD2pWqOaTAOj1DmAU1Z';
    public static String consumer_Secret = 'pammPvOsCnGowsd12aHUG4zsOAlmwjBwsjNsI6qV';
    
    //Client id and secret of Client's Sandbox
    public static String client_Id_SandBox = 'AB9gu7Lc1CQGXwDJCiBL5CmlxNubUC5W77dEJeHNtJLuvuh3i5';
    public static String consumer_Secret_SandBox = 'jDHNzBeEdcYoeZZvrSeIZV3JyiIrGB45paWrFlYC';
    
    //This method is use to age Reauthenticate the quickbooks and update the custom metadata
    @future(callout=true)
    public static void reauthenticate()
    {
        String encodedString;
        String endPoint = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer';
        
        if(ReauthenticationApi.canReadObject('Quickbooks_Info_meta__mdt')){
            
            if(ReauthenticationApi.canReadField('Quickbooks_Info_meta__mdt', 'label')&&
               ReauthenticationApi.canReadField('Quickbooks_Info_meta__mdt', 'Access_Token__c')&&
               ReauthenticationApi.canReadField('Quickbooks_Info_meta__mdt', 'Company_Id__c')&&
               ReauthenticationApi.canReadField('Quickbooks_Info_meta__mdt', 'Environment__c')&&
               
               ReauthenticationApi.canReadField('Quickbooks_Info_meta__mdt', 'Expires_in_Seconds__c')&&
               ReauthenticationApi.canReadField('Quickbooks_Info_meta__mdt', 'Refresh_Token__c'))       
            {
                
                Quickbooks_Info_meta__mdt quickbooksInfo = [SELECT Access_Token__c,Refresh_Token__c,Environment__c FROM Quickbooks_Info_meta__mdt LIMIT 1];
                
                String env=quickbooksInfo.Environment__c;
                //Setting the header according to the Quickbook Evnvironment.
                if(quickbooksInfo.Environment__c=='Production'){
                    encodedString = EncodingUtil.base64Encode(Blob.valueOf(client_Id+':'+consumer_Secret));
                }
                else{
                    encodedString = EncodingUtil.base64Encode(Blob.valueOf(client_Id_SandBox+':'+consumer_Secret_SandBox));
                }
                String requestBody = 'grant_type=refresh_token&refresh_token=';
                if(quickbooksInfo!=null && quickbooksInfo.Refresh_Token__c !=null){
                    Blob payloadBlob = EncodingUtil.base64Decode(quickbooksInfo.Refresh_Token__c);
                    requestBody+= payloadBlob.toString();
                }else{
                }
                String errorMessage ='';
                
                HttpRequest httpReq = new HttpRequest();
                HttpResponse httpRes = new HttpResponse();
                Http http = new Http();
                httpReq.setMethod('POST');
                httpReq.setEndPoint(endPoint);
                httpReq.setHeader('Authorization' , 'Basic '+encodedString);
                httpReq.setHeader('Content-Type' , 'application/x-www-form-urlencoded');
                httpReq.setBody(requestBody);
                
                httpRes = http.send(httpReq);
                try{
                    
                    if(httpRes.getStatusCode() == 200){
                        
                        Map<String, Object> response_Map = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                        
                        
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
                        if(env=='Production'){
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
                        
                    }
                    
                }
                
                
                catch(System.Exception e){
                    
                    if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                        errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -&amp;gt; Administer -&amp;gt; Security Control -&amp;gt;'
                            +' Remote Site Setting and add '+' '+ endPoint +' Endpoint';
                        
                    }else{
                        errorMessage = 'Unexpected Error while communicating with Quickbooks API. '
                            +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
                        
                    }
                    
                    
                    
                    
                    
                }}}
        
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
}