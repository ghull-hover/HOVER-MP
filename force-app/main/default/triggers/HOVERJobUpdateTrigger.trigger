/*
    After we have updated the Job in SFDC from the HOVER information after create, trigger the assignment to the suborg User.
    Because these are asynchronous callouts, this needs to be done in two steps and orchestrated to pass information from
    one step to the next:
    1. find the HOVER user ID for the desired assignee in the suborg
    2. do the assignment
*/
trigger HOVERJobUpdateTrigger on HOVER_Job__c (after update) {

    System.debug('In HOVERJobUpdateTrigger');

    HOVER_Job__c oldJob;
    for(HOVER_Job__c job : Trigger.new) {
        oldJob = Trigger.oldMap.get(job.ID);
        String initialOrgID = job.Initial_Org_ID__c;
        String initialUserID = job.Initial_User_ID__c;
        String hoverJobID = job.HOVER_Job_ID__c;
        String assigneeID = job.Suborg_Assignee__c;

        System.debug('initialOrgID: ' + initialOrgID);
        System.debug('initialUserID: ' + initialUserID);
        System.debug('hoverJobID: ' + hoverJobID);
        System.debug('assigneeID: ' + assigneeID);

        if (assigneeID != null && assigneeID != '' && assigneeID != initialUserID) {
            // only do the assignment logic if we have an assignee and it is different than the initial assignee

            if (job.Initial_Org_ID__c != oldJob.Initial_Org_ID__c) {
                // The Initial org ID changing from blank to populated indicates that the Job has just been updated in SFDC after creation in HOVER; 
                // Now Find the HOVER user ID of the desired assignee in the suborg
                System.debug('Finding assignee!');
    
                try {
                    User assignee = [select id, email from user where  id = :assigneeID limit 1];
                    String email = assignee.Email;
        
    
                    // queue this task since it's one of several REST callouts in this sequence
                    HOVERQueueableGetSuborgAssigneeID assigneeJob = new HOVERQueueableGetSuborgAssigneeID();
                    assigneeJob.hoverJobID = hoverJobID;
                    assigneeJob.assigneeEmail = email;
                    assigneeJob.userID = initialUserID;
                    ID queueID = System.enqueueJob(assigneeJob);
        
                    System.debug('ID in queue: ' + queueID);
    
                }
                catch (Exception e) {
                    System.debug('Exception: ' + e);
                }
    
            }     
            else {
                String userID = job.Suborg_Assignee_ID__c;

                if (userID != null && userID != '' && userID != oldJob.Suborg_Assignee_ID__c) {
                    // Now that we have the sub org assignee ID we can go ahead and queue the assignment task
                    System.debug('Assigning Job to suborg user...');
        
                    HOVERQueueableJobAssignment assignment = new HOVERQueueableJobAssignment();
                    assignment.initialOrgID = initialOrgID;
                    assignment.initialUserID = initialUserID;                     
                    assignment.hoverJobID = hoverJobID;
                    assignment.userID = userID;
        
                    ID queueID = System.enqueueJob(assignment);
                    System.debug('ID in queue: ' + queueID);
                  
                }
                else {
                    // something wrong with assignee ID
                    System.debug('Cannot process Assignee ID: ' + userID);
                }   
    
            } 
    
        }
        else {
            // the current user is in the parent org, proceed as is
            System.debug('No need to reassign, user already in parent org');
        }
    }   
    
}