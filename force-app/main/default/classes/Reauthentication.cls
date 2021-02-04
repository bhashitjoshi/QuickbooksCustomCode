/**
 * @description       : This class is use to schedule the ReauthenticationApi class.
 * @author            : Ashish Sharma
 * @group             : 
 * @last modified on  : 09-14-2020
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   09-14-2020   Ashish Sharma   Initial Version
**/
global with sharing class Reauthentication implements Schedulable{
     
    
    
    // this method is use to schedule the ReauthenticationApi class
    global static void execute(SchedulableContext sc)
    {
        
        ReauthenticationApi.reauthenticate();
    }
    
}