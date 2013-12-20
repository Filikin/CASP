/*

Author: Eamon Kelly, Enclude

Purpose: The Description field on CASP Event has been renamed Case Note.
A second picklist field has the value Case Note Type e.g. Counsellor Key Note, Key Work Case Note
For each Case Note Type, I want to add the Case Note, with date and user name,  to the corresponding field on the Contact object

20/12/2013 
1) the date of the note should be the Start date of Event (as staff usually put in entries v late)
2) the note be deleted in the EVENT after update
3) change the format
	a. Have carriage return after name and date
	b. Little Line under entry --------
Called from: before insert trigger

*/
trigger LastKeyWorkingDate on Event (before insert) 
{
    List<Event> EventList = new List<Event>();
    Map<Id, Event> mapEventsToWho = new Map<Id, Event>();
    Set<Id> whoIds = new Set<Id>();

    for(Event t : Trigger.new)
    {
        if (t.WhoId != null)
        {
           //Add the events to the Map and Set
            mapEventsToWho.put(t.WhoId, t);
            whoIds.add(t.WhoId);
        }
    }
    
    List<Contact> clients = [select Id, Last_Key_Working_Data__c, Project_Worker_Case_Notes__c, Counsellor_Case_Notes__c, Family_Support_Case_Notes__c,
    	CE_Recovery_Case_Notes__c, Prison_Links_Case_Notes__c, Medical_Case_Notes__c from Contact where ID in :whoIDs];
    for (Contact client: clients)
    {
    	Event evt = mapEventsToWho.get(client.Id);
      	if (evt.Casp_Type__c == 'Key Work') client.Last_Key_Working_Data__c=system.today();
      	if (evt.Note_Type__c == 'Project Worker Case notes') client.Project_Worker_Case_Notes__c = appendText (evt, client.Project_Worker_Case_Notes__c);
       	if (evt.Note_Type__c == 'Counsellor Case notes') client.Counsellor_Case_Notes__c = appendText (evt, client.Counsellor_Case_Notes__c);
       	if (evt.Note_Type__c == 'Family Support Case notes') client.Family_Support_Case_Notes__c = appendText (evt, client.Family_Support_Case_Notes__c);
       	if (evt.Note_Type__c == 'CE Recovery Case notes') client.CE_Recovery_Case_Notes__c = appendText (evt, client.CE_Recovery_Case_Notes__c);
       	if (evt.Note_Type__c == 'Prison Links Case notes') client.Prison_Links_Case_Notes__c = appendText (evt, client.Prison_Links_Case_Notes__c);
       	if (evt.Note_Type__c == 'Medical Case Notes') client.Medical_Case_Notes__c = appendText (evt, client.Medical_Case_Notes__c);
    }
   	If (clients.size() > 0 )  update clients;

	public String appendText (Event evt, String currentNotes)
	{
		String newNote = evt.Description;
		if (newNote <> null)
    	{
    		if (currentNotes == null) currentNotes = '';
    		currentNotes = evt.StartDateTime.Date().format() + ' ' + UserInfo.getName() + '\r\n' + newNote + '\r\n------------\r\n' + currentNotes;
    		evt.Description = '';
    	}
		return currentNotes;		
	}
}