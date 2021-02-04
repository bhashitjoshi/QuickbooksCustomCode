@isTest
public class QuickBookConnectionApexTest {
    @isTest static void QuickBookConnectionApexMethod()  {
   
        Test.startTest();
        QuickBookConnectionApex quickBook = new QuickBookConnectionApex();
        //Test.setMock(HttpCalloutMock.class, new QuickBookConnectionApexMockClass());
        QuickBookConnectionApex.doAuthorizationQuickBooks();
        QuickBookConnectionApex.doAuthorizationQuickBooksSandbox();
        
      
        Test.stopTest();
        
    }
    @isTest static void QuickBookConnectionApexMethod2()  {
       
        Test.startTest();
        QuickBookConnectionApex quickBook = new QuickBookConnectionApex();
        Test.setMock(HttpCalloutMock.class, new QuickBookConnectionApexMockClass());
        
        PageReference pageRef = Page.quickbookconnectionvf; // Add your VF page Name here
        pageRef.getParameters().put('code', 'abcxyz');
        pageRef.getParameters().put('realmId', '4620816365068782330');
        Test.setCurrentPage(pageRef);
        QuickBookConnectionApex.doFetchAccessToken();        
      
        Test.stopTest();
        
    }
    
}