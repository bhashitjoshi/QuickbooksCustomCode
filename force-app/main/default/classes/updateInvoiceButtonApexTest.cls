@isTest
private class updateInvoiceButtonApexTest {
    
    @isTest
    static void updateInvoicButtonApexMock()
    {
     
        //Creating the Test Data
        Account test = new Account(name='TestInvoice');
        insert test;
  
        opportunity o = new opportunity();
        o.Name = 'TestOpportunity';
        o.CloseDate=date.today().addMonths(2);
        o.StageName='IsWon';
        insert o;
        
        Quote q = new Quote();
        q.Name = 'TestQuote';
        q.opportunityId = o.id;
        insert q;
        
        Invoice__c TestInvoice = new Invoice__c(Quickbooks_Invoice_Id__c='19',QuickBooks_Domain__c='Quotes',Account_Name__c	=test.id,QuoteID__c=q.id,status__c='Not paid');
        insert TestInvoice;
        
        // Testing the Apex class and API
        
        System.Test.startTest();
                system.Test.setMock(HttpCalloutMock.class, new updateInvoiceButtonMock());
                updateInvoiceButtonApex.updateStatus(TestInvoice.id);


        System.Test.stopTest();

     }

}