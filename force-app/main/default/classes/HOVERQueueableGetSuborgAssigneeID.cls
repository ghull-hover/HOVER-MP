public  class HOVERQueueableGetSuborgAssigneeID implements Queueable{

    public String hoverJobID {get;set;}
    public String assigneeEmail {get;set;}
    public String userID {get;set;}
    public void execute (QueueableContext context) {


        System.debug('Assigning user for Job: ' + this.hoverJobID + ' email: ' + assigneeEmail + ' userID: ' + userID);
        HOVER.setSuborgAssigneeID(hoverJobID, userID, assigneeEmail);

    }
}