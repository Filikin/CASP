global class IncomingEmailManager implements Messaging.InboundEmailHandler 
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        // Create an inboundEmailResult object for returning the result of the Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        // Try to lookup who the last message was sent to based on the contact in the email subject
        try 
        { 
            SMS__c msgSent = [Select Id, OwnerId, Incoming_Message__c, Message_Received__c 
                from SMS__c 
                where To_Contact__c = :email.subject order by CreatedDate DESC Limit 1];
                
            Integer startOfReply = email.plainTextBody.indexOf('With:');
            if (startOfReply < 0)
            {
            	startOfReply = 0;
            }
            else
            {
            	startOfReply += 6;
            }
            
            // might want to send an SMS back to the owner
            String ownersMobile = '';
            try
            {
            	ownersMobile = [select MobilePhone from User where id = :msgSent.OwnerId].MobilePhone;
            }
            catch (Exception e)
            {
            	
            }
            
            String incoming = email.plainTextBody.substring (startOfReply);
            if (msgSent.Message_Received__c)
            {
            	// create a new SMS object
            	SMS__c newMsg = new SMS__c (OwnerId=msgSent.OwnerId, To_Contact__c=email.subject, Incoming_Message__c=incoming, Message_Received__c=true, Senders_mobile__c=ownersMobile);
            	insert newMsg;
            }
            else
            {
	            msgSent.Incoming_Message__c = incoming;
	            msgSent.Message_Received__c = true;
	            msgSent.Senders_mobile__c=ownersMobile; // just in case it changed since the last msg
				update msgSent;
            }
		}
		catch (Exception e) 
		{
			System.debug('Query Issue: ' + e);
			SMS__c newMsg = new SMS__c (Incoming_Message__c=e.getMessage(), Outgoing_Message__c='Error');
            	insert newMsg;
		}
		// Set the result to true. No need to send an email back to the user
		// with an error message
		result.success = true;
		// Return the result for the Apex Email Service
		return result;
	}

	static testMethod void testIncomingEmailManager() 
	{
		Test.startTest();
        Account acct1 = new Account(name='passenger account');
        insert acct1;
            
        Contact pass = new Contact(AccountId=acct1.Id,lastname='Passenger',firstname='apex', MobilePhone='0857130794');  
        insert pass;
        pass.Send_SMS_TXT__c='Outgoing message';
        update pass;
     
   		// Create a new email and envelope object
       Messaging.InboundEmail email = new Messaging.InboundEmail();
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
     
    	// Create the plainTextBody and fromAddres for the test
        email.plainTextBody = 'Eamon Kelly Replied With: Here is my plainText body of the email';
        email.fromAddress ='rmencke@salesforce.com';
        email.subject = pass.id;
     
    	IncomingEmailManager taskObj = new IncomingEmailManager();
    	taskObj.handleInboundEmail(email, env);
	   	taskObj.handleInboundEmail(email, env);
    	test.stopTest();
    	
    	 SMS__c msgTest = [Select Id, Incoming_Message__c, Outgoing_Message__c, Message_Received__c, Message_Sent__c 
                from SMS__c 
                where To_Contact__c = :email.subject order by CreatedDate Limit 1];
         
         system.assertEquals(msgTest.Incoming_Message__c, 'Here is my plainText body of the email');
         system.assert (msgTest.Message_Received__c);
         system.assert (msgTest.Message_Sent__c);
         system.assertEquals(msgTest.Outgoing_Message__c, 'Outgoing message');
    }
     
}