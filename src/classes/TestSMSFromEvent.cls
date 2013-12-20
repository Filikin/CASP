@isTest
private class TestSMSFromEvent 
{
    static testMethod void SMSFromEventTest() 
    {
    	Contact testPerson = new Contact (LastName = 'me');
    	insert testPerson;
    	Event od1 = new Event (WhoID = testPerson.id, OwnerID=UserInfo.getUserId(), StartDateTime=DateTime.newInstance(2012,1,4,1,1,1), Subject='Test');
		od1.DurationInMinutes=60;
		od1.Send_SMS_reminder_now__c = true;
		insert od1;
		
		Event result = [select ID, Send_SMS_reminder_now__c from Event where ID=:od1.id];
		system.assertEquals(false, result.Send_SMS_reminder_now__c);
    }
}