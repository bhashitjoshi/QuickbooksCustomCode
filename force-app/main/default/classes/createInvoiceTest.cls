@istest 
public class createInvoiceTest {
    @testSetup static void setupMethod(){
	 
    }
    
    @istest static void createInvoicetest(){
        
        Account acc=new Account(name='King Groceries');
        insert acc;
        Contact newcustomer=new Contact(Display_Name__c='King Groceries',Environment__c='Production',AccountId=acc.id,email='jdrew@myemail.com',Lastname='Test',CheckBeforeInsert__c=true);
        insert newcustomer;
        opportunity opp=new opportunity(name='test',CloseDate=System.today(),stagename='Closed Won');
        insert opp;
        quote newQuote=new Quote(name='test',OpportunityId=opp.id);
        insert newQuote;
        
        Product2 pro = new Product2();
        pro.Quickbooks_Product_ID_Sandbox__c = '1213122';
        pro.Name = 'Pro Test';
        INSERT pro;
        
        String jsonBody='{ "TrackQtyOnHand": true, "Name": "Garden Supplies", "QtyOnHand": 10, "IncomeAccountRef": { "name": "Sales of Product Income", "value": "79" }, "AssetAccountRef": { "name": "Inventory Asset", "value": "81" }, "InvStartDate": "2015-01-01", "Type": "Inventory", "ExpenseAccountRef": { "name": "Cost of Goods Sold", "value": "80" } }';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new createInvoiceMockFor200()); //HTTPResponseMockCalloutForIncome
        //CreateInvoice.CreateInvoiceWrapper invoiceWrapper = new CreateInvoice.CreateInvoiceWrapper();
        //CreateInvoiceWrapper.parse('{ "count": 0, "first_href": "string", "last_href": "string", "prev_href": "string", "href": "string", "next_href": "string", "items": [{ "category": "Rent", "startsOn": "2020-07-30T04:42:29.039Z", "owners": [{ "href": "string", "id": 0 }], "description": "string", "contribution_href": "string", "href": "string", "frequency": "Monthly", "net": { "amount": "67" }, "id": 0, "endsOn": "2020-07-30T04:42:29.039Z" }] }');
        
        // CreateInvoice.CreateInvoiceWrapper invoiceWrapper = new CreateInvoice.CreateInvoiceWrapper.parse('{ "Line": [ { "DetailType": "SalesItemLineDetail", "Amount": 100.0, "SalesItemLineDetail": { "ItemRef": { "name": "Services", "value": "1" } } } ], "CustomerRef": { "value": "1" } '}');
        //CreateInvoiceWrapper.parse('{ "Line": [ { "DetailType": "SalesItemLineDetail", "Amount": 100.0, "SalesItemLineDetail": { "ItemRef": { "name": "Services", "value": "1" } } } ], "CustomerRef": { "value": "1" } }');
        CreateInvoice.createInvoice(newcustomer.id,jsonBody,newQuote.id);  
        Test.stopTest();
    }
    
    @istest static void createProductTest(){
        
        Account acc=new Account(name='King Groceries');
        insert acc;
        Contact newcustomer=new Contact(Display_Name__c='King Groceries',Environment__c='Sandbox',AccountId=acc.id,email='jdrew@myemail.com',Lastname='Test',CheckBeforeInsert__c=true);
        insert newcustomer;
        opportunity opp=new opportunity(name='test',CloseDate=System.today(),stagename='Closed Won');
        insert opp;
        quote newQuote=new Quote(name='test',OpportunityId=opp.id);
        insert newQuote;
        String jsonBody='[{"Product2Name":"SLA: Gold","attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/0QL3h0000001VqrGAE"},"QuoteId":"0Q03h0000005Gb4CAE","Product2Id":"01t3h0000029hc3AAA","Quantity":2,"UnitPrice":30000,"Id":"0QL3h0000001VqrGAE","Product2":{"attributes":{"type":"Product2","url":"/services/data/v49.0/sobjects/Product2/01t3h0000029hc3AAA"},"Name":"SLA: Gold","Id":"01t3h0000029hc3AAA","Quickbooks_Product_ID__c":"12"}}]';
        // String jsonBody='{"Product2Name":"GenWatt Propane 100kW","attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/0QL3h0000001VxMGAU"},"QuoteId":"0Q03h0000005Gj4CAE","Product2Id":"01t3h0000029hbxAAA","Quantity":1,"UnitPrice":15000,"Id":"0QL3h0000001VxMGAU","Product2":{"attributes":{"type":"Product2","url":"/services/data/v49.0/sobjects/Product2/01t3h0000029hbxAAA"},"Name":"GenWatt Propane 100kW","Quickbooks_Product_ID__c":"131","Id":"01t3h0000029hbxAAA"}},{"Product2Name":"GenWatt Gasoline 750kW","attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/0QL3h0000001VxNGAU"},"QuoteId":"0Q03h0000005Gj4CAE","Product2Id":"01t3h0000029hc1AAA","Quantity":2,"UnitPrice":75000,"Id":"0QL3h0000001VxNGAU","Product2":{"attributes":{"type":"Product2","url":"/services/data/v49.0/sobjects/Product2/01t3h0000029hc1AAA"},"Name":"GenWatt Gasoline 750kW","Quickbooks_Product_ID__c":"132","Id":"01t3h0000029hc1AAA}}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateProductMockFor200()); //HTTPResponseMockCalloutForIncome
        
        CreateInvoice.createProduct(newcustomer.id,jsonBody,newQuote.id);  
        Test.stopTest();
    }
    
     @istest static void createProductTestSandbox(){
        
        Account acc=new Account(name='King Groceries');
        insert acc;
        Contact newcustomer=new Contact(Display_Name__c='King Groceries',Environment__c='Sandbox',AccountId=acc.id,email='jdrew@myemail.com',Lastname='Test',CheckBeforeInsert__c=true);
        insert newcustomer;
        opportunity opp=new opportunity(name='test',CloseDate=System.today(),stagename='Closed Won');
         insert opp;
         quote newQuote=new Quote(name='test',OpportunityId=opp.id);
         insert newQuote;
         
         Product2 pro = new Product2();
         pro.Quickbooks_Product_ID_Sandbox__c = '1213122';
         pro.Name = 'Pro Test';
         INSERT pro;
         
        String jsonBody='[ { "Product2Name":"SLA: Gold", "attributes":{ "type":"QuoteLineItem", "url":"/services/data/v49.0/sobjects/QuoteLineItem/0QL3h0000001VqrGAE" }, "QuoteId":"0Q03h0000005Gb4CAE", "Product2Id":"01t3h0000029hc3AAA", "Quantity":2, "UnitPrice":30000, "Id":"0QL3h0000001VqrGAE", "Product2":{ "attributes":{ "type":"Product2", "url":"/services/data/v49.0/sobjects/Product2/01t3h0000029hc3AAA" }, "Name":"SLA: Gold", "Id":"01t3h0000029hc3AAA", "Quickbooks_Product_ID_Sandbox__c" : "3647364" } } ]';
        // String jsonBody='{"Product2Name":"GenWatt Propane 100kW","attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/0QL3h0000001VxMGAU"},"QuoteId":"0Q03h0000005Gj4CAE","Product2Id":"01t3h0000029hbxAAA","Quantity":1,"UnitPrice":15000,"Id":"0QL3h0000001VxMGAU","Product2":{"attributes":{"type":"Product2","url":"/services/data/v49.0/sobjects/Product2/01t3h0000029hbxAAA"},"Name":"GenWatt Propane 100kW","Quickbooks_Product_ID__c":"131","Id":"01t3h0000029hbxAAA"}},{"Product2Name":"GenWatt Gasoline 750kW","attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/0QL3h0000001VxNGAU"},"QuoteId":"0Q03h0000005Gj4CAE","Product2Id":"01t3h0000029hc1AAA","Quantity":2,"UnitPrice":75000,"Id":"0QL3h0000001VxNGAU","Product2":{"attributes":{"type":"Product2","url":"/services/data/v49.0/sobjects/Product2/01t3h0000029hc1AAA"},"Name":"GenWatt Gasoline 750kW","Quickbooks_Product_ID__c":"132","Id":"01t3h0000029hc1AAA}}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateProductMockFor200()); //HTTPResponseMockCalloutForIncome
        
        CreateInvoice.createProduct(newcustomer.id,jsonBody,newQuote.id);  
        Test.stopTest();
    }
    
    public static Quickbooks_Info_meta__mdt getChangedCustomMetadataRecord(String newValue) {
        Quickbooks_Info_meta__mdt quickbooksInfo=[Select Access_Token__c, Environment__c,Company_Id__c from Quickbooks_Info_meta__mdt where label='Quickbooks Access Token'];
        quickbooksInfo.Environment__c = newValue;
        System.debug('quickbooksInfo-'+quickbooksInfo);
        return quickbooksInfo;
    }
     @istest static void createProductTest1(){
        Account acc=new Account(name='King Groceries');
        insert acc;
        Contact newcustomer=new Contact(Display_Name__c='King Groceries',Environment__c='Sandbox',AccountId=acc.id,email='jdrew@myemail.com',Lastname='Test',CheckBeforeInsert__c=true);
        insert newcustomer;
        opportunity opp=new opportunity(name='test',CloseDate=System.today(),stagename='Closed Won');
        insert opp;
        quote newQuote=new Quote(name='test',OpportunityId=opp.id);
        insert newQuote;
        String jsonBody='[{"Product2Name":"SLA: Gold","attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/0QL3h0000001VqrGAE"},"QuoteId":"0Q03h0000005Gb4CAE","Product2Id":"01t3h0000029hc3AAA","Quantity":2,"UnitPrice":30000,"Id":"0QL3h0000001VqrGAE","Product2":{"attributes":{"type":"Product2","url":"/services/data/v49.0/sobjects/Product2/01t3h0000029hc3AAA"},"Name":"SLA: Gold","Id":"01t3h0000029hc3AAA","Quickbooks_Product_ID__c":"12"}}]';
        // String jsonBody='{"Product2Name":"GenWatt Propane 100kW","attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/0QL3h0000001VxMGAU"},"QuoteId":"0Q03h0000005Gj4CAE","Product2Id":"01t3h0000029hbxAAA","Quantity":1,"UnitPrice":15000,"Id":"0QL3h0000001VxMGAU","Product2":{"attributes":{"type":"Product2","url":"/services/data/v49.0/sobjects/Product2/01t3h0000029hbxAAA"},"Name":"GenWatt Propane 100kW","Quickbooks_Product_ID__c":"131","Id":"01t3h0000029hbxAAA"}},{"Product2Name":"GenWatt Gasoline 750kW","attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/0QL3h0000001VxNGAU"},"QuoteId":"0Q03h0000005Gj4CAE","Product2Id":"01t3h0000029hc1AAA","Quantity":2,"UnitPrice":75000,"Id":"0QL3h0000001VxNGAU","Product2":{"attributes":{"type":"Product2","url":"/services/data/v49.0/sobjects/Product2/01t3h0000029hc1AAA"},"Name":"GenWatt Gasoline 750kW","Quickbooks_Product_ID__c":"132","Id":"01t3h0000029hc1AAA}}';
		createInvoiceTest.getChangedCustomMetadataRecord('production');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateProductMockFor200()); //HTTPResponseMockCalloutForIncome
        
        CreateInvoice.createProduct(newcustomer.id,jsonBody,newQuote.id);  
        Test.stopTest();
    }
    @istest static void canCreateFieldTest(){
        CreateInvoice.canCreateField('Account','Name');
    }
        @istest static void canCreateObjectTest(){
        CreateInvoice.canCreateObject('Account');
    }
}