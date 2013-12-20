@isTest
private class TestCaseNotesFromEvent
{
    static testMethod void CaseNotesFromEventTest() 
    {
    	Contact testPerson = new Contact (LastName = 'me');
    	insert testPerson;
    	Event od1 = new Event (WhoID = testPerson.id, OwnerID=UserInfo.getUserId(), StartDateTime=DateTime.newInstance(2012,1,4,1,1,1), Subject='Test');
    	od1.DurationInMinutes = 60;
		od1.Casp_Type__c = 'Key Work';
		od1.Note_Type__c = 'Project Worker Case notes';
		od1.Description = 'Project case notes test';
		insert od1;
		
		Contact result = [select ID, Last_Key_Working_Data__c, Project_Worker_Case_Notes__c, Counsellor_Case_Notes__c from Contact where ID=:testPerson.id];
		system.assertEquals(system.today(), result.Last_Key_Working_Data__c);
		system.assert (result.Project_Worker_Case_Notes__c.contains ('Project case notes test'));
		system.assertEquals (null, result.Counsellor_Case_Notes__c);
    }
}