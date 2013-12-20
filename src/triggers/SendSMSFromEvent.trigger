trigger SendSMSFromEvent on Event (before insert, before update) 
{
    List <SMS__c> Messages = new List<SMS__c>();
    for (Event oneEvent : trigger.new)
    {
    	if (oneEvent.Send_SMS_reminder_now__c && oneEvent.WhoId != null)
    	{
	    	ID client = oneEvent.WhoId;
	    	try
	    	{
	    		String msg = oneEvent.SMS_will_read__c.replace ('%STARTTIME%',oneEvent.StartDateTime.format());
                SMS__c oneMessage = new SMS__c (To_Contact__c = client, Outgoing_Message__c = msg, Message_Sent__c = TRUE);
                Messages.Add (oneMessage);
                oneEvent.Send_SMS_reminder_now__c = FALSE;
	    	}
	    	catch (System.NullPointerException e)
	    	{
	    	}
    	}
    }
    if (Messages.size() > 0)
    {
        insert Messages;
    }

}