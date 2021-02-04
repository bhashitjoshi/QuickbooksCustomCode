@isTest
global class QbAccountControllerTest implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req)  {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "QueryResponse": { "Customer": [ { "Taxable": true, "BillAddr": { "Id": "149", "Line1": "null", "City": "null", "Country": "null", "CountrySubDivisionCode": "CA", "PostalCode": "null" }, "Notes": "Here are other details.", "Job": false, "BillWithParent": false, "Balance": 0, "BalanceWithJobs": 0, "CurrencyRef": { "value": "USD", "name": "United States Dollar" }, "PreferredDeliveryMethod": "Print", "IsProject": false, "ClientEntityId": "0", "domain": "QBO", "sparse": false, "Id": "75", "SyncToken": "0", "MetaData": { "CreateTime": "2020-07-14T02:16:58-07:00", "LastUpdatedTime": "2020-07-14T05:10:02-07:00" }, "Title": "Mr.", "GivenName": "James", "MiddleName": "B", "FamilyName": "King", "Suffix": "Jr", "FullyQualifiedName": "abhi", "CompanyName": "King Groceries", "DisplayName": "abhi", "PrintOnCheckName": "King Groceries", "Active": true, "PrimaryPhone": { "FreeFormNumber": "8989898989" }, "PrimaryEmailAddr": { "Address": "abhi@gmail.com" } }]}}'); 
        res.setStatusCode(200);
        return res;
        
    }
    
    @isTest static void fetchQbCCustomersTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QbAccountControllerTest()); //HTTPResponseMockCalloutForIncome
        QbAccountController.fetchQbCustomers();  
        Test.stopTest();
    }
    @isTest static void fetchSyncAccountTest(){
        Test.startTest();
        QbAccountController.fetchSyncAccount();  
        Test.stopTest();
    }
    
    @isTest static void canUpdateObjectTest(){
        Test.startTest();
        QbAccountController.canUpdateObject('Account');  
        Test.stopTest();
    }
    @isTest static void canUpdateFieldTest(){
        Test.startTest();
        QbAccountController.canUpdateField('Account','Name');  
        Test.stopTest();
    }
    @isTest static void canDeleteObjectTest(){
        Test.startTest();
        QbAccountController.canDeleteObject('Account');  
        Test.stopTest();
    }
}