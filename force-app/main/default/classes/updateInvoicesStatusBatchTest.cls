@isTest(seeAllData=false)
private class updateInvoicesStatusBatchTest {

  @isTest
    static void updateInvoicButtonApexMock()
    {
        
        //Creating the Test Data
        Account acc = new Account(name='TestInvoice');
        insert acc;
  
        opportunity opp = new opportunity();
        opp.Name = 'TestOpportunity';
        opp.CloseDate=date.today().addMonths(2);
        opp.StageName='IsWon';
        insert opp;
         
        Quote q = new Quote();
        q.Name = 'TestQuote';
        q.opportunityId = opp.id;
        insert q;
        
        
        list<Invoice__c > listInvoice = new list<Invoice__c >();
       
             Invoice__c TestInvoice = new Invoice__c(Quickbooks_Invoice_Id__c='1',QuickBooks_Domain__c='Quotes',Account_Name__c=acc.id,QuoteID__c=q.id,status__C='Not paid');
             listInvoice.add(TestInvoice);
        
            insert listInvoice;
        
        // Testing the Apex class and API
        System.Test.startTest();
                  System.Test.setMock(HttpCalloutMock.class, new updateInvoicesStatusBatchMock());
                  updateInvoicesStatusBatch obj = new updateInvoicesStatusBatch();
                  DataBase.executeBatch(obj); 
        System.Test.stopTest();

     }
    
   
        
 

}