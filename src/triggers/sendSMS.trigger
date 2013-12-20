trigger sendSMS on Contact (before update) 
{
    List <SMS__c> Messages = new List<SMS__c>();
    for (Contact oneContact : trigger.new)
    {
    	try
    	{
	        if (oneContact.Send_SMS_TXT__c <> null) // && oneContact.MobilePhone <> null)
	        {
	            if (oneContact.Send_SMS_TXT__c.Length() > 0 && oneContact.MobilePhone.Length() > 0)
	            {
	                SMS__c oneMessage = new SMS__c (To_Contact__c = oneContact.ID, Outgoing_Message__c = oneContact.Send_SMS_TXT__c, Message_Sent__c = TRUE);
	                Messages.Add (oneMessage);
	                
	                oneContact.Last_SMS_TXT__c = oneContact.Send_SMS_TXT__c;
	                oneContact.Send_SMS_TXT__c = '';
	            }
	        }
    	}
    	catch (System.NullPointerException e)
    	{
   			oneContact.Send_SMS_TXT__c = 'No mobile phone number';
    	}
    }
    if (Messages.size() > 0)
    {
        insert Messages;
    }
}