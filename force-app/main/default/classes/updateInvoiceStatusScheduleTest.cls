@isTest
public class updateInvoiceStatusScheduleTest 
{
	@isTest static void test1()
    {
        Test.startTest();
        updateInvoiceStatusSchedule rt = new updateInvoiceStatusSchedule();
        String sch = '0 0 2 * * ?'; 
		System.schedule('Test  Check', sch, rt); 
        Test.stopTest();
    }
}