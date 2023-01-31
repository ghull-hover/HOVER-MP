/*
    After we receive the webhook with "complete" status the flow will raise a platform event.
    Process that event by getting the measurements associated with the Job
*/
trigger ProcessJobComplete on HOVER_Job_Complete__e (after insert) {
    if(Trigger.isAfter) {
        String eventID;
        String jobID;
        String hoverJobID;
        for(HOVER_Job_Complete__e event : Trigger.new) {
            /*
            try {
                hoverJobID = event.HOVER_Job_ID__c;
                jobID = event.SF_Record_ID__c;
                if (hoverJobID == '') {
                    HoverApexException hex = new HoverApexException();
                    hex.setMessage('hoverJobID is blank - should never happen');
                    throw hex;
                }
                System.debug('job ID: ' + jobID);
                System.debug('HOVER Job ID: ' + hoverJobID);
                Hover.getMeasurements(hoverJobID, jobID);
                Hover.getMeasurementsJSON(hoverJobID, jobID);   
            }
            catch (Exception e) {
                HOVER_Exception__e hoverException = new HOVER_Exception__e();
                String message = 'ProcessJobComplete failed with exception: ' + e.getMessage();
                hoverException.Description__c = message;
                Database.SaveResult result = EventBus.publish(hoverException);
                System.debug(message);
            }
            */
            hoverJobID = event.HOVER_Job_ID__c;
            jobID = event.SF_Record_ID__c;
            System.debug('job ID: ' + jobID);
            System.debug('HOVER Job ID: ' + hoverJobID);
            Hover.getMeasurements(hoverJobID, jobID);
            Hover.getMeasurementsJSON(hoverJobID, jobID);   

        }
    }

}