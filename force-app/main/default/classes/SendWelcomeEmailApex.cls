public with sharing class SendWelcomeEmailApex {
    
    public class Request {
        @InvocableVariable(required=true)
        public Id enrollmentId;  // Pass Enrollment__c Id from Flow
    }

    @InvocableMethod(label='Send Welcome Email' description='Send Welcome Email for Telelangue Enrollment')
    public static void sendEmail(List<Request> requests) {
        system.debug('HI mail');
    }
}