/**
 * @description       :  This class is use to craete invoice in Quickbook and salesforce, create/update products in Quickbook and salesforce
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
global with sharing class CreateInvoice {
    
    // This method is use to create product in quickbooks and form the invoice API body 
    @AuraEnabled
    public static string createProduct(String customerId, String selectedProducts, String QuoteId) {
        System.debug('customerId'+customerId);
        System.debug('selectedProducts'+selectedProducts);
        System.debug('QuoteId '+QuoteId);
        String status;
        try{
            
            CreateInvoiceWrapper createInvoicewrap = new CreateInvoiceWrapper();
            createInvoicewrap.line = new List<CreateInvoiceWrapper.Line>();
            createInvoicewrap.CustomerRef= new CreateInvoiceWrapper.CustomerRef();
            
            
            if(CreateInvoice.canReadObject('Contact')){
                
                if( CreateInvoice.canReadField('Contact', 'Id')&&
                   CreateInvoice.canReadField('Contact', 'Environment__c')&&
                   CreateInvoice.canReadField('Contact', 'Quickbooks_Customer_Id__c'))
                {
                    
                    Contact customer = [Select Id,Quickbooks_Customer_Id__c,Environment__c FROM Contact WHERE Id=:customerId];
                    
                    List<Object> productDetails = (List<Object>)JSON.deserializeUntyped(selectedProducts); 
                    
                    if(CreateInvoice.canReadObject('Quickbooks_Info_meta__mdt')){
                        
                        if( CreateInvoice.canReadField('Quickbooks_Info_meta__mdt', 'Access_Token__c')&&
                           CreateInvoice.canReadField('Quickbooks_Info_meta__mdt', 'label')&&
                           CreateInvoice.canReadField('Quickbooks_Info_meta__mdt', 'Environment__c')&&
                           
                           CreateInvoice.canReadField('Quickbooks_Info_meta__mdt', 'Company_Id__c'))
                        {
                            
                            //Fetching access token from metadata
                            Quickbooks_Info_meta__mdt quickbooksInfo=[Select Access_Token__c, Environment__c,Company_Id__c from Quickbooks_Info_meta__mdt where label='Quickbooks Access Token'];
                            String companyId= quickbooksInfo.Company_Id__c;
                            
                            
                            map<id,String> newQoteLineItem= new map<id,String>();
                            
                            if(CreateInvoice.canReadObject('Product2'))
                            {
                                if( CreateInvoice.canReadField('Product2', 'Id')&&
                                   CreateInvoice.canReadField('Product2', 'Quickbooks_Product_ID_Sandbox__c')&&
                                   CreateInvoice.canReadField('Product2', 'Quickbooks_Product_ID__c'))
                                {
                                    if(CreateInvoice.canUpdateObject('Product2')){
                                        //If Environment is Production
                                        if(quickbooksInfo.Environment__c=='production'){
                                           
                                            if(CreateInvoice.canUpdateField('Product2', 'Quickbooks_Product_ID__c'))
                                            {
                                                String productSfId;
                                                List<Product2> newQoteLineItemList= new List<Product2>();
                                                
                                                for(integer i=0;i<productDetails.size();i++) {
                                                    Map<String,Object> quoteLineItemMap = (Map<String, Object>)productDetails[i];
                                                    
                                                    Map<String,Object> product2Map = (Map<String, Object>)quoteLineItemMap.get('Product2');
                                                    
                                                    
                                                    productSfId=(String)product2Map.get('Id');
                                                    
                                                    //If Quickbooks_Product_ID__c = null then new product will be create in the quickbooks
                                                    if(product2Map.get('Quickbooks_Product_ID__c')==null){
                                                        
                                                        Blob payloadBlob = EncodingUtil.base64Decode(quickbooksInfo.Access_Token__c);
                                                        String accessToken =  payloadBlob.toString();
                                                        String endPoint = 'https://quickbooks.api.intuit.com/v3/company/'+companyId+'/item?minorversion=51';
                                                        HttpRequest httpReq = new HttpRequest();
                                                        HttpResponse httpRes = new HttpResponse();
                                                        Http http = new Http();
                                                        httpReq.setMethod('POST');
                                                        httpReq.setEndPoint(endPoint);
                                                        httpReq.setHeader('Content-Type','application/json');
                                                        httpReq.setHeader('Accept','application/json');
                                                        httpReq.setHeader('Authorization' , 'Bearer '+accessToken);
                                                        
                                                        JSONGenerator Productgen = JSON.createGenerator(true); 
                                                        Productgen.writeStartObject();
                                                        Productgen.writeStringField('Name', (String)product2Map.get('Name')); 
                                                        Productgen.writeFieldName('IncomeAccountRef');
                                                        Productgen.writeStartObject();
                                                        Productgen.writeStringField('value', '59');//This is hard coded account ID . This needs to changed.
                                                        Productgen.writeEndObject();
                                                        Productgen.writeStringField('Type', 'Service');
                                                        Productgen.writeEndObject();
                                                        
                                                        String jsonDataProduct = Productgen.getAsString();  
                                                        
                                                        httpReq.setBody(jsonDataProduct);
                                                        httpRes = http.send(httpReq);
                                                        
                                                        if (httpRes.getStatusCode() != 200) {
                                                            
                                                            status='product error'+httpRes.getBody();
                                                            
                                                            
                                                        } else {
                                                            // Making invoice body for API
                                                            if(customer.Environment__c=='production'){
                                                                status='ok';
                                                                Map<String,Object> Responsemap = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                                                                Map<String,Object> ResponsemapItem = (Map<String, Object>)Responsemap.get('Item');
                                                                
                                                                String QuickBookProductid=(String)ResponsemapItem.get('Id');
                                                                newQoteLineItem.put(productSfId,QuickBookProductid);
                                                                
                                                                
                                                                 CreateInvoiceWrapper.Line createLineItem = new CreateInvoiceWrapper.Line();
                                                                createLineItem.Amount = (Integer)quoteLineItemMap.get('UnitPrice');
                                                                createLineItem.DetailType = 'SalesItemLineDetail';
                                                                createLineItem.SalesItemLineDetail = new CreateInvoiceWrapper.SalesItemLineDetail();
                                                                createLineItem.SalesItemLineDetail.ItemRef = new CreateInvoiceWrapper.ItemRef();
                                                                createLineItem.SalesItemLineDetail.Qty = (Integer)quoteLineItemMap.get('Quantity');
                                                                createLineItem.SalesItemLineDetail.ItemRef.value = String.valueOf(QuickBookProductid);
                                                                createLineItem.SalesItemLineDetail.ItemRef.name = 'Services';
                                                                createLineItem.SalesItemLineDetail.TaxCodeRef = new CreateInvoiceWrapper.TaxCodeRef();
                                                                createLineItem.SalesItemLineDetail.TaxCodeRef.value = '3';
                                                                createInvoicewrap.line.add(createLineItem); 
                                                                
                                                            }
                                                            else{
                                                                status='Select contact of same environment.';
                                                                return status;
                                                            }
                                                        }
                                                    }
                                                    else{
                                                        if(customer.Environment__c=='production'){
                                                            // Making invoice body for API
                                                            CreateInvoiceWrapper.Line createLineItem = new CreateInvoiceWrapper.Line();
                                                            createLineItem.Amount = (Integer)quoteLineItemMap.get('UnitPrice');
                                                            createLineItem.DetailType = 'SalesItemLineDetail';
                                                            createLineItem.SalesItemLineDetail = new CreateInvoiceWrapper.SalesItemLineDetail();
                                                            createLineItem.SalesItemLineDetail.ItemRef = new CreateInvoiceWrapper.ItemRef();
                                                            createLineItem.SalesItemLineDetail.Qty = (Integer)quoteLineItemMap.get('Quantity');
                                                            createLineItem.SalesItemLineDetail.ItemRef.value = (String)product2Map.get('Quickbooks_Product_ID__c');
                                                            createLineItem.SalesItemLineDetail.ItemRef.name = 'Services';
                                                            createLineItem.SalesItemLineDetail.TaxCodeRef = new CreateInvoiceWrapper.TaxCodeRef();
                                                            createLineItem.SalesItemLineDetail.TaxCodeRef.value = '3';
                                                            createInvoicewrap.line.add(createLineItem);                
                                                            
                                                        }
                                                        else{
                                                            status='Select contact of same environment.';
                                                            return status;
                                                        }
                                                    }
                                                }
                                                
                                                
                                                createInvoicewrap.CustomerRef.value = String.valueof(customer.Quickbooks_Customer_Id__c);
                                                
                                                String createInvoiceBody=JSON.serialize(createInvoicewrap);
                                                
                                                
                                                
                                                status=createInvoice(customerId,createInvoiceBody, QuoteId);
                                                
                                                
                                                for (Id key : newQoteLineItem.keySet()) {
                                                    newQoteLineItemList.add(new Product2(Id = key, Quickbooks_Product_ID__c =(String)newQoteLineItem.get(key)));
                                                }
                                                
                                                if(newQoteLineItemList.size()>0){
                                                    update newQoteLineItemList;  
                                                    
                                                }  
                                            }
                                            
                                        }
                                        
                                        
                                        //If Environment is Sandbox.
                                        else{
                                            
                                            
                                            if(CreateInvoice.canUpdateField('Product2', 'Quickbooks_Product_ID_Sandbox__c'))
                                            {
                                                String productSfId;
                                                List<Product2> newQoteLineItemList= new List<Product2>();
                                                
                                                for(integer i=0;i<productDetails.size();i++) {
                                                    Map<String,Object> quoteLineItemMap = (Map<String, Object>)productDetails[i];
                                                    
                                                    Map<String,Object> product2Map = (Map<String, Object>)quoteLineItemMap.get('Product2');
                                                    
                                                    
                                                    productSfId=(String)product2Map.get('Id');
                                                    
                                                    //If Quickbooks_Product_ID__c = null then new product will be create in the quickbooks
                                                    if(product2Map.get('Quickbooks_Product_ID_Sandbox__c')==null){
                                                        
                                                        Blob payloadBlob = EncodingUtil.base64Decode(quickbooksInfo.Access_Token__c);
                                                        String accessToken =  payloadBlob.toString();
                                                        String endPoint = 'https://sandbox-quickbooks.api.intuit.com/v3/company/'+companyId+'/item?minorversion=51';
                                                        HttpRequest httpReq = new HttpRequest();
                                                        HttpResponse httpRes = new HttpResponse();
                                                        Http http = new Http();
                                                        httpReq.setMethod('POST');
                                                        httpReq.setEndPoint(endPoint);
                                                        httpReq.setHeader('Content-Type','application/json');
                                                        httpReq.setHeader('Accept','application/json');
                                                        httpReq.setHeader('Authorization' , 'Bearer '+accessToken);
                                                        
                                                        JSONGenerator Productgen = JSON.createGenerator(true); 
                                                        Productgen.writeStartObject();
                                                        Productgen.writeStringField('Name', (String)product2Map.get('Name')); 
                                                        Productgen.writeFieldName('IncomeAccountRef');
                                                        Productgen.writeStartObject();
                                                        Productgen.writeStringField('value', '59');//This is hard coded account ID . This needs to changed.
                                                        Productgen.writeEndObject();
                                                        Productgen.writeStringField('Type', 'Service');
                                                        Productgen.writeEndObject();
                                                        
                                                        String jsonDataProduct = Productgen.getAsString();  
                                                        
                                                        httpReq.setBody(jsonDataProduct);
                                                        httpRes = http.send(httpReq);
                                                        if (httpRes.getStatusCode() != 200) {
                                                            
                                                            status='product error'+httpRes.getBody();
                                                            
                                                            
                                                        } else {
                                                            // Making invoice body for API
                                                            if(customer.Environment__c=='Sandbox'){
                                                                status='ok';
                                                                Map<String,Object> Responsemap = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                                                                Map<String,Object> ResponsemapItem = (Map<String, Object>)Responsemap.get('Item');
                                                                
                                                                String QuickBookProductid=(String)ResponsemapItem.get('Id');
                                                                newQoteLineItem.put(productSfId,QuickBookProductid);
                                                                
                                                                
                                                                CreateInvoiceWrapper.Line createLineItem = new CreateInvoiceWrapper.Line();
                                                                createLineItem.Amount = (Integer)quoteLineItemMap.get('UnitPrice');
                                                                createLineItem.DetailType = 'SalesItemLineDetail';
                                                                createLineItem.SalesItemLineDetail = new CreateInvoiceWrapper.SalesItemLineDetail();
                                                                createLineItem.SalesItemLineDetail.ItemRef = new CreateInvoiceWrapper.ItemRef();
                                                                createLineItem.SalesItemLineDetail.Qty = (Integer)quoteLineItemMap.get('Quantity');
                                                                createLineItem.SalesItemLineDetail.ItemRef.value = String.valueOf(QuickBookProductid);
                                                                createLineItem.SalesItemLineDetail.ItemRef.name = 'Services';
                                                                createInvoicewrap.line.add(createLineItem); 
                                                                
                                                            }
                                                            else{
                                                                status='Select contact of same environment.';
                                                                return status;
                                                            }
                                                        }
                                                    }
                                                    else{
                                                        // Making invoice body for API
                                                        if(customer.Environment__c=='Sandbox'){
                                                            CreateInvoiceWrapper.Line createLineItem = new CreateInvoiceWrapper.Line();
                                                            createLineItem.Amount = (Integer)quoteLineItemMap.get('UnitPrice');
                                                            createLineItem.DetailType = 'SalesItemLineDetail';
                                                            createLineItem.SalesItemLineDetail = new CreateInvoiceWrapper.SalesItemLineDetail();
                                                            createLineItem.SalesItemLineDetail.ItemRef = new CreateInvoiceWrapper.ItemRef();
                                                            createLineItem.SalesItemLineDetail.Qty = (Integer)quoteLineItemMap.get('Quantity');
                                                            createLineItem.SalesItemLineDetail.ItemRef.value = (String)product2Map.get('Quickbooks_Product_ID_Sandbox__c');
                                                            createLineItem.SalesItemLineDetail.ItemRef.name = 'Services';
                                                            createInvoicewrap.line.add(createLineItem);                
                                                            
                                                        }
                                                        else{
                                                            status='Select contact of same environment.';
                                                            return status;
                                                        }
                                                    }
                                                }
                                                
                                                
                                                createInvoicewrap.CustomerRef.value = String.valueof(customer.Quickbooks_Customer_Id__c);
                                                
                                                String createInvoiceBody=JSON.serialize(createInvoicewrap);
                                                
                                                
                                                
                                                status=createInvoice(customerId,createInvoiceBody, QuoteId);
                                                
                                                
                                                for (Id key : newQoteLineItem.keySet()) {
                                                    newQoteLineItemList.add(new Product2(Id = key, Quickbooks_Product_ID_Sandbox__c =(String)newQoteLineItem.get(key)));
                                                }
                                                
                                                if(newQoteLineItemList.size()>0){
                                                    update newQoteLineItemList;  
                                                    
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
        catch(Exception e){
            
            
        }
        return status;
        
    }
    
    //This method is use to create Invoice
    public  static string createInvoice(String customerId ,String invoiceBody, String QuoteId) 
    {
        String status;
        String invoiceId;
        Integer invoiceTotalAmount;
        String invoiceNumber;
        String invoiceDomain;
        String AccountId;
        
        try{
            if(CreateInvoice.canReadObject('Contact')){
                
                if( CreateInvoice.canReadField('Contact', 'Id')&&
                   CreateInvoice.canReadField('Contact', 'AccountId')&&
                   CreateInvoice.canReadField('Contact', 'Quickbooks_Customer_Id__c'))
                {
                    Contact con=new Contact();
                    con=[select id,accountid from contact where id=:customerId];
                    AccountId=con.AccountId;
                    Contact customer = [Select Id,Quickbooks_Customer_Id__c FROM Contact WHERE Id=:customerId];
                    
                    
                    
                    if(CreateInvoice.canReadObject('Quickbooks_Info_meta__mdt')){
                        
                        
                        if( CreateInvoice.canReadField('Quickbooks_Info_meta__mdt', 'Access_Token__c')&&
                           CreateInvoice.canReadField('Quickbooks_Info_meta__mdt', 'label')&&
                           CreateInvoice.canReadField('Quickbooks_Info_meta__mdt', 'Environment__c')&&
                           CreateInvoice.canReadField('Quickbooks_Info_meta__mdt', 'Company_Id__c'))
                        {
                            //Fetching access token and call create invoice API
                            Quickbooks_Info_meta__mdt quickbooksInfo=[Select Access_Token__c,Environment__c, Company_Id__c from Quickbooks_Info_meta__mdt where label='Quickbooks Access Token'];
                            String companyId= quickbooksInfo.Company_Id__c;
                            Blob payloadBlob = EncodingUtil.base64Decode(quickbooksInfo.Access_Token__c);
                            String accessToken =  payloadBlob.toString();
                            String endPoint;
                            if(quickbooksInfo.Environment__c=='Production'){
                                endPoint = 'https://quickbooks.api.intuit.com/v3/company/'+companyId+'/invoice?minorversion=51';
                            }
                            else{
                                endPoint = 'https://sandbox-quickbooks.api.intuit.com/v3/company/'+companyId+'/invoice?minorversion=51';
                                
                            }
                            HttpRequest httpReq = new HttpRequest();
                            HttpResponse httpRes = new HttpResponse();
                            Http http = new Http();
                            httpReq.setMethod('POST');
                            httpReq.setEndPoint(endPoint);
                            httpReq.setHeader('Content-Type','application/json');
                            httpReq.setHeader('Accept','application/json');
                            httpReq.setHeader('Authorization' , 'Bearer '+accessToken);
                            
                            
                            
                            httpReq.setBody(invoiceBody);
                            httpRes = http.send(httpReq);
                            
                            
                            
                            if (httpRes.getStatusCode() != 200) {
                                
                                Status='invoice error'+httpRes.getBody();
                                
                                
                                
                            } else {
                                Status='ok';
                                //If invoice is created in quickbooks then we have to create invoice in SF also
                                Map<String,Object> invoiceDetailsMap = (Map<String,Object>)JSON.deserializeUntyped(httpRes.getBody());
                                
                                
                                Map<String,Object> invoiceDetails = (Map<String,Object>)invoiceDetailsMap.get('Invoice');
                                invoiceId=String.valueof(invoiceDetails.get('Id'));
                                invoiceDomain=String.valueof(invoiceDetails.get('domain'));
                                invoiceNumber=String.valueof(invoiceDetails.get('DocNumber'));
                                invoiceTotalAmount=Integer.valueof(invoiceDetails.get('TotalAmt'));
                                
                                if(CreateInvoice.canReadObject('Invoice__c')){
                                    if(CreateInvoice.canCreateObject('Invoice__c')){
                                        
                                        if( CreateInvoice.canReadField('Invoice__c', 'Total_Amount__c')&&
                                           CreateInvoice.canReadField('Invoice__c', 'QuoteID__c')&&
                                           CreateInvoice.canReadField('Invoice__c', 'Account_Name__c')&&
                                           CreateInvoice.canReadField('Invoice__c', 'Quickbooks_Invoice_Id__c')&&
                                           CreateInvoice.canReadField('Invoice__c', 'Environment__c')&&
                                           CreateInvoice.canReadField('Invoice__c', 'status__c')&&
                                           CreateInvoice.canReadField('Invoice__c', 'QuickBooks_Domain__c'))       
                                        {
                                            if( CreateInvoice.canCreateField('Invoice__c', 'Total_Amount__c')&&
                                               CreateInvoice.canCreateField('Invoice__c', 'Account_Name__c')&&
                                               CreateInvoice.canCreateField('Invoice__c', 'QuoteID__c')&&
                                               CreateInvoice.canCreateField('Invoice__c', 'Environment__c')&&
                                               CreateInvoice.canCreateField('Invoice__c', 'Quickbooks_Invoice_Id__c')&&
                                               CreateInvoice.canCreateField('Invoice__c', 'status__c')&&
                                               CreateInvoice.canCreateField('Invoice__c', 'QuickBooks_Domain__c'))       
                                            {
                                                Invoice__c createNewInvoice= new Invoice__c();
                                                createNewInvoice.Total_Amount__c=invoiceTotalAmount;
                                                createNewInvoice.QuoteID__c=QuoteId;
                                                createNewInvoice.Account_Name__c=AccountId;
                                                if(quickbooksInfo.Environment__c=='Production'){
                                                    createNewInvoice.Environment__c='Production';                            }
                                                else{
                                                    createNewInvoice.Environment__c='Sandbox';  
                                                }
                                                
                                                createNewInvoice.Quickbooks_Invoice_Id__c=invoiceId;
                                                createNewInvoice.QuickBooks_Domain__c=invoiceDomain;
                                                createNewInvoice.status__c='Not Paid';
                                                insert createNewInvoice;
                                                
                                            }}
                                    }
                                }}}}}}
        }
        catch(Exception e){
            
            
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
    
    
}