public  class HOVERQueueableJobAssignment implements Queueable{

    public String initialOrgID {get;set;}
    public String initialUserID {get;set;}
    public String hoverJobID {get;set;}
    public String userID {get;set;}
    public void execute (QueueableContext context) {

        System.debug('Assigning user for Job: ' + this.hoverJobID);
        HOVER.assignJobToUser(initialOrgID, initialUserID, hoverJobID, userID);

    }
}