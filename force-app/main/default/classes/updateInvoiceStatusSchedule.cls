/**
 * @description       : This class is use to schedule the updateInvoicesStatusBatch class.
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
global with sharing class updateInvoiceStatusSchedule implements Schedulable{
    
    
    //This method is use to schedule updateInvoicesStatusBatch class 
    global static void execute(SchedulableContext sc)
    {
        Id batchJobId = Database.executeBatch(new updateInvoicesStatusBatch(), 1);
    }
    
}