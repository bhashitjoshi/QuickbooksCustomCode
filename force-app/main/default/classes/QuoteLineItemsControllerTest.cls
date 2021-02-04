@isTest
public class QuoteLineItemsControllerTest {
    
    @testSetup static void setup(){
        Opportunity opp1 = new Opportunity(Name = 'Test1',StageName = 'Closed Won',CloseDate = Date.parse('03/19/2020'),Amount = 100);
        insert opp1;
        Quote quo=new Quote();
        quo.name='Test1';
        quo.OpportunityId=opp1.id;
        insert quo;
    }
    
    @isTest static void test1(){
        Quote  quo=[select id from Quote];
        
        QuoteLineItemsController.getQuoteLineItems(quo.id);
        QuoteLineItemsController.getCompanyId(quo.id);
        
        
        
    }
    
    @isTest static void test2(){
        Account acc=new Account(name='test1');
        insert acc;
        QuoteLineItemsController.getCustomers(acc.id);
        
    }
    
}