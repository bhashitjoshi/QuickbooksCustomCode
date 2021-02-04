@isTest
public class reauthenticationTest 
{
	@isTest static void test1()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new reauthenticationApiTest());
        Reauthentication rt = new Reauthentication();
        String sch = '0 0 2 * * ?'; 
		System.schedule('Test  Check', sch, rt); 
        Test.stopTest();
    }
}