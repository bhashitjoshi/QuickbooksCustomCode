@isTest
public class invoiceTest {
    
    @isTest static void test1(){
        Account acc=new Account(name='test1');
        insert acc;
        Contact newCustomer=new Contact(Display_Name__c='test',AccountId=acc.id,email='test@gmail.com',Lastname='Test',CheckBeforeInsert__c=true);
        insert newCustomer;
        Invoice__c newInvoice=new Invoice__c(Account_Name__c=newCustomer.id,QuickBooks_Domain__c='test');
        List<Invoice__c> testList=new list<Invoice__c>();
        testList.add(newInvoice);
        invoice.preventInsertion(testList);
        invoice.prevent_delete(testList);
        
    }
    @isTest static void test2(){
        Account acc=new Account(name='test1');
        insert acc;
        Contact newCustomer=new Contact(Display_Name__c='test',AccountId=acc.id,email='test@gmail.com',Lastname='Test',CheckBeforeInsert__c=true);
        insert newCustomer;
        Invoice__c newInvoice=new Invoice__c(Account_Name__c=newCustomer.id);
        List<Invoice__c> testList=new list<Invoice__c>();
        testList.add(newInvoice);
        invoice.preventInsertion(testList);
        
    }

}