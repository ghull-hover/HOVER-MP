public with sharing class HoverSlackMessage {
    public class HoverSlackMessageInput {
        @InvocableVariable
        public String message;

    }
    public HoverSlackMessage() {

    }
        // Generic method to post message to slack via process and flow builder
        @InvocableMethod(label='Post Message to Slack' description='Post a Message to Slack' category='HOVER')
        public static void invPostMessageToSlack(List<HoverSlackMessageInput> inputs) {
            HoverSlackMessageInput input = inputs.get(0);
            HoverSlack.postMessageToSlack(input.message);
        }

}