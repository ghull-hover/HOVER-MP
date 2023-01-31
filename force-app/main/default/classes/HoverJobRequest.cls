public class HoverJobRequest {
    public String current_user_email;
    HoverJob job;
    
    public HoverJobRequest (String pcurrent_user_email, HoverJob aJob) {
        current_user_email = pcurrent_user_email;
        job = aJob;
    }

}