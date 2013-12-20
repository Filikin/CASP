public with sharing class OutgoingEmailManager 
{
	/* this code no longer used, but the test is still needed for the trigger
	public void SendSMSEmail (ID toContactID)
	{
		Messaging.reserveSingleEmailCapacity(1);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {'smsenclude@enclude.ie'}; 
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Enclude SMS');
		mail.setSubject ('SMS Message');
		
		String orgName = Label.Org_Short_Name;
		Contact target = [select ID, FirstName, Last_SMS_TXT__c, Send_SMS_TXT__c, Email, MobilePhone, LastName from Contact where ID = :toContactID limit 1];
		String templateString = 'Hi {0} {1}### {2}# {3}#{4}#{0} {5}#{6}#';
		if (target.Email == null)
		{
			templateString = 'Hi {0} {1}### {2}# #{4}#{0} {5}#{6}#';
		}
		String[] arguments = new String[]{target.FirstName, target.Send_SMS_TXT__c, target.id, target.Email, target.MobilePhone, target.LastName, orgName}; 
		String body = String.format (templateString, arguments);
		mail.setPlainTextBody (body);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
		target.Last_SMS_TXT__c = target.Send_SMS_TXT__c;
		target.Send_SMS_TXT__c = '';
		update target;
	}
*/	
	static testMethod void testSendSMSEmail() 
	{
		Test.startTest();
        Account acct1 = new Account(name='passenger account');
        insert acct1;
            
        Contact pass = new Contact(AccountId=acct1.Id,lastname='Passenger',firstname='apex', Send_SMS_TXT__c='Outgoing message', MobilePhone='0857130794');  
        insert pass;
    }
}