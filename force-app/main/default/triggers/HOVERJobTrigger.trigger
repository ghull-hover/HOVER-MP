/*
    After a new HOVER Job or "Connect" (Capture Request) has been created in SFDC, create it in HOVER
*/
trigger HOVERJobTrigger on HOVER_Job__c (after insert) {
    for(HOVER_Job__c job : Trigger.new) {
        if (job.Send_Connect_Request__c) {
            Hover.postCaptureRequest(job.Id);

        }
        else {
            Hover.createJobJSONFull(job.id);
            
        }
        
    }   
}