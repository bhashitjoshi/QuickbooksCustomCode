@isTest 
public class CreateInvoiceWrapperTest {

    @testSetup static void setup(){
        
    }
    @istest static void createInvoiceWrapperTest(){
        CreateInvoiceWrapper.CustomerRef c5  = new CreateInvoiceWrapper.CustomerRef();
        c5.value = 'test';
        CreateInvoiceWrapper.TaxCodeRef c4  = new CreateInvoiceWrapper.TaxCodeRef();
        c4.value = 'test';
        CreateInvoiceWrapper.ItemRef c3  = new CreateInvoiceWrapper.ItemRef();
        c3.name = 'test';
        c3.value = 'test';
        CreateInvoiceWrapper.SalesItemLineDetail c2  = new CreateInvoiceWrapper.SalesItemLineDetail();
        c2.Qty = 2;
        c2.TaxCodeRef = c4;
        c2.ItemRef = c3;
        CreateInvoiceWrapper.Line c1  = new CreateInvoiceWrapper.Line();
        c1.Amount = 10;
        c1.DetailType = 'test';
        c1.SalesItemLineDetail = c2; 
    }
}