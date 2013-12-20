global class CreateTaskEmailExample implements Messaging.InboundEmailHandler 
{
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
	{
		// Create an inboundEmailResult object for returning the result of the Apex Email Service
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		String myPlainText= '';
		// Add the email plain text into the local variable
		myPlainText = email.plainTextBody;
		// New Task object to be created
		Task[] newTask = new Task[0];

		// Try to lookup any contacts based on the email from address
		// If there is more than 1 contact with the same email address,
		// an exception will be thrown and the catch statement will be called.
		try 
		{
			Account vCon = [Select Id, Name, PersonContactId From Account Where Id = :email.subject Limit 1];
			
			// Add a new Task to the contact record we just found above.
			newTask.add(new Task(Description = myPlainText, Priority = 'Normal', Status = 'Inbound Email',
				Subject = 'Reply to SMS Text', ActivityDate = date.today(), IsReminderSet = false, WhoId = vCon.PersonContactId));

			// Insert the new Task
			insert newTask;
			System.debug('New Task Object: ' + newTask );
		}
		// If an exception occurs when the query accesses
		// the contact record, a QueryException is called.
		// The exception is written to the Apex debug log.
		catch (QueryException e) 
		{
			System.debug('Query Issue: ' + e);
		}
		// Set the result to true. No need to send an email back to the user with an error message
		result.success = true;
		// Return the result for the Apex Email Service
		return result;
	}

	//TEST METHOD
	static testMethod void testCreateTaskEmailExample() 
	{
		// Create a new email and envelope object
     	Messaging.InboundEmail email = new Messaging.InboundEmail();
     	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
     
    	// Create the plainTextBody and fromAddres for the test
        email.plainTextBody = 'Here is my plainText body of the email';
        email.fromAddress ='eamon.kelly@enclude.ie';
     
    	CreateTaskEmailExample taskObjtoFail = new CreateTaskEmailExample();
    	taskObjtoFail.handleInboundEmail(email, env);

    	Account acct1 = new Account(firstname='some', lastname='driver');
		acct1.RecordTypeId = [Select Id From RecordType where Name = 'Client Account'].Id;
        insert acct1;
       

	    email.subject = acct1.id;
        
    	CreateTaskEmailExample taskObj = new CreateTaskEmailExample();
    	taskObj.handleInboundEmail(email, env);
    }
}