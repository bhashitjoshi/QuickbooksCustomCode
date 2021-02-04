@isTest
public class customerTest {
    
    @isTest static void test1(){
        Account acc=new Account(name='test1');
        insert acc;
        Contact newcustomer=new Contact(Display_Name__c='test',AccountId=acc.id,email='test@gmail.com',Quickbooks_Customer_Id__c='test',Lastname='Test');
        List<Contact> testList=new list<Contact>();
        testList.add(newcustomer);
        customer.preventInsertion(testList);
        
    }

}