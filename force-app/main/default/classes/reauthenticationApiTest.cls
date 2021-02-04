@isTest
global class reauthenticationApiTest implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req)  {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody('{ "access_token": "ZXlKbGJtTWlPaUpCTVRJNFEwSkRMVWhUTWpVMklpd2lZV3huSWpvaVpHbHlJbjAuLmtUb3B6eFBfYldoMTZuRHluVjhkUEEuUmJZRmZiNkNZbHU5anJVd0JIUHYySkFkY1A4elBDcFdFOUhIODBvVmVHcElwekVQN0Q5MEpNalZXWG5Vek9UcTZaV2lSZk5YU21DaW5mZjdLamEyTld4Yl9ZR3RmU0ItRDVLbFhkdkFvUDlvOXRvNkhaeWdxa1NfQjlhUFdGRHM2ejN6QjdoNnhCT2dxU25NZ2xFa1U0MHVqOXphckFxRjZlYU45MkpEZ3pLV3lLTGVRWWt1bVlUUlBISC13NjE4RS1jYkxjdXJnbHl5N3VNajZ5TzI3SmFFMlhHSnFEb2dLWTlkakZuZU5od0pKQ1h3Vl9xOVdzOHdTUFNPUzlDNjJLY0ZCdFo4S2JTVncwNTk5aHR5UklFdXhQMXR2TEhRbkswb2c3bFBoOGhfVVAxOUhKckpDYk5SQjcxcHpHLWtDTENpTk9Gc2s0ZU9SczVUeVFwaHp1eEE0dWtpaEI5dDV3QUpHQW9BaFlLN0ZLZ0RIZEd3VVYwd0NFdmRXam1UMGR5Z2oxZTZ0YmUwdUN4NjBWYjhsdllfUnZYUG1ma3N0bTJ5eTVNcmMxR2dPZV9qTkNMUHlmWVFkeGZmSmFPVVN1dHRoWGlmMGNBWkM3VG5jZ3ZsX19ucURDaUthZENzcllhekd6cjVuS3ZhbGRtSW5TYjkyQXotQmRpZDF4aWEybkctSXFhNVhfTUU4Y0pvQk90NWI3RjZ3bEp2Q3lEcEJEbVNFRzJpYlRrUU1NNTRacHNzeE9HRXl6bmN1cExwbnF4bExPbGpKRDNsWUNXWGVUajljamtUVkU1RHpCeEE2N0xYRHZiN0M2Z3Iwc0lvbGV0TGNwQ045U2RHR1EwMUZVNzhmd3M2c3E2Y3pkYm5ZTFBRbG9BLUozRUFwSU9OS09SY3p1a004NEpHY2FBbjNsWmljdkQ4T3BKbjBmYS1tc2NtMVlKYzJEMGR6Q1FKemJtSWhMNzZ6Zm9UMndWYlZLX21xV3UxVDAwLkk2bVVYWlJ1UUtNT0RfTER2Z2pWSmc = ", "expires_in": 3600, "refresh_token": "QUIxMTYwNDczNjkxNHNYdEs4WW52NHlOZmRJMUU3aFhYNXVDeVgxblNmM09scURYR04 =", "token_type": "bearer", "x_refresh_token_expires_in":8659741 }');
        res.setBody('{access_token=ZXlKbGJtTWlPaUpCTVRJNFEwSkRMVWhUTWpVMklpd2lZV3huSWpvaVpHbHlJbjAuLmtUb3B6eFBfYldoMTZuRHluVjhkUEEuUmJZRmZiNkNZbHU5anJVd0JIUHYySkFkY1A4elBDcFdFOUhIODBvVmVHcElwekVQN0Q5MEpNalZXWG5Vek9UcTZaV2lSZk5YU21DaW5mZjdLamEyTld4Yl9ZR3RmU0ItRDVLbFhkdkFvUDlvOXRvNkhaeWdxa1NfQjlhUFdGRHM2ejN6QjdoNnhCT2dxU25NZ2xFa1U0MHVqOXphckFxRjZlYU45MkpEZ3pLV3lLTGVRWWt1bVlUUlBISC13NjE4RS1jYkxjdXJnbHl5N3VNajZ5TzI3SmFFMlhHSnFEb2dLWTlkakZuZU5od0pKQ1h3Vl9xOVdzOHdTUFNPUzlDNjJLY0ZCdFo4S2JTVncwNTk5aHR5UklFdXhQMXR2TEhRbkswb2c3bFBoOGhfVVAxOUhKckpDYk5SQjcxcHpHLWtDTENpTk9Gc2s0ZU9SczVUeVFwaHp1eEE0dWtpaEI5dDV3QUpHQW9BaFlLN0ZLZ0RIZEd3VVYwd0NFdmRXam1UMGR5Z2oxZTZ0YmUwdUN4NjBWYjhsdllfUnZYUG1ma3N0bTJ5eTVNcmMxR2dPZV9qTkNMUHlmWVFkeGZmSmFPVVN1dHRoWGlmMGNBWkM3VG5jZ3ZsX19ucURDaUthZENzcllhekd6cjVuS3ZhbGRtSW5TYjkyQXotQmRpZDF4aWEybkctSXFhNVhfTUU4Y0pvQk90NWI3RjZ3bEp2Q3lEcEJEbVNFRzJpYlRrUU1NNTRacHNzeE9HRXl6bmN1cExwbnF4bExPbGpKRDNsWUNXWGVUajljamtUVkU1RHpCeEE2N0xYRHZiN0M2Z3Iwc0lvbGV0TGNwQ045U2RHR1EwMUZVNzhmd3M2c3E2Y3pkYm5ZTFBRbG9BLUozRUFwSU9OS09SY3p1a004NEpHY2FBbjNsWmljdkQ4T3BKbjBmYS1tc2NtMVlKYzJEMGR6Q1FKemJtSWhMNzZ6Zm9UMndWYlZLX21xV3UxVDAwLkk2bVVYWlJ1UUtNT0RfTER2Z2pWSmc=, expires_in=3600, refresh_token=QUIxMTYwNDczNjkxNHNYdEs4WW52NHlOZmRJMUU3aFhYNXVDeVgxblNmM09scURYR04=, token_type=bearer, x_refresh_token_expires_in=8659741}');
        res.setStatusCode(200);
        return res;
        
    }
    
    @isTest global static void reauthenticateTest(){
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new reauthenticationApiTest()); //HTTPResponseMockCalloutForIncome
        
        reauthenticationApi.reauthenticate();  
        Test.stopTest();
    }
    
    @isTest static void canUpdateObjectTest(){
        Test.startTest();
        ReauthenticationApi.canUpdateObject('Account');  
        Test.stopTest();
    }
    @isTest static void canUpdateFieldTest(){
        Test.startTest();
        ReauthenticationApi.canUpdateField('Account','Name');  
        Test.stopTest();
    }
    @isTest static void canCreateFieldTest(){
        Test.startTest();
        ReauthenticationApi.canCreateField('Account','Name');  
        Test.stopTest();
    }
   @isTest static void canCreateObjectTest(){
        Test.startTest();
        ReauthenticationApi.canCreateObject('Account');  
        Test.stopTest();
    }
   @isTest static void canReadObjectTest(){
        Test.startTest();
        ReauthenticationApi.canCreateObject('Account');  
        Test.stopTest();
    }
   @isTest static void canReadFieldTest(){
        Test.startTest();
        ReauthenticationApi.canCreateField('Account','Name');  
        Test.stopTest();
    }
}