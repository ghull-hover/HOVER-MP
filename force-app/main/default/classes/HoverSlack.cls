public class HoverSlack {

    public class HoverSlackInput {
        @InvocableVariable
        public String jobID;

        @InvocableVariable
        public String sfRecordID;
        
        @InvocableVariable
        public String webhookID;
        
        @InvocableVariable
        public String state;
    }
    


    // This method exposes the capability to process and flow builder
    @InvocableMethod(label='Post Job Update to Slack' description='Post information when a HOVER Job updates to the slack channel' category='HOVER')
    public static void invPostJobUpdateToSlack(List<HoverSlackInput> inputs) {
        HoverSlackInput input = inputs.get(0);
        postToSlackWebhook(input.webhookID, input.jobID, input.state, input.sfRecordID);
    }
    
    // This method does the work (in the future) of posting to the Slack Webhook
    @future(callout=true)
    public static void postToSlackWebhook(String webhookID, String jobID, String state, String sfRecordID) {
        
        String webhook_destination = External_Webhook__c.getOrgDefaults().external_url__c;
        
        System.debug('Posting to Slack');
        String baseURL = 'https://hooks.slack.com';
        String method = 'POST';
        String api = webhook_destination;
        String contentType = 'application/json';
        String body = '{"text":"HOVER Job <https://qbranch6-dev-ed.lightning.force.com/lightning/r/HOVER_Job__c/' + sfRecordID + '/view|*' + jobID + '*> is _' + state + '_!"}';
        System.debug('Message body: ' + body);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(baseURL + api);
        request.setMethod(method);
        request.setBody(body);
        request.setHeader('Content-Type', contentType);
        Http http = new Http();
        System.debug('before sending slack request');
        System.debug('request: ' + request);
        
        HttpResponse response = http.send(request);
        System.debug('after sending refresh request');
        if(response.getStatusCode() == 200) {
            System.debug(response.getBody());
            // Deserialize the JSON string into collections of primitive data types.
        }    
      
        
        
    }    

    
    // This method does the work (in the future) of posting to the Slack Webhook
    @future(callout=true)
    public static void postMessageToSlack(String message) {
        
        String webhook_url = External_Webhook__c.getOrgDefaults().external_url__c;
        
        System.debug('Posting to Slack');
        String baseURL = 'https://hooks.slack.com';
        String method = 'POST';
        String api = webhook_url;
        String contentType = 'application/json';

        String body = '{"text":"' + message.replaceAll('\"', '') + '"}';

        System.debug('Message body: ' + body);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(baseURL + api);
        request.setMethod(method);
        request.setBody(body);
        request.setHeader('Content-Type', contentType);
        Http http = new Http();
        System.debug('request: ' + request);
        try {
            HttpResponse response = http.send(request);
            System.debug('Status posting to slack: ' + response.getStatusCode());
        }
        catch (Exception e) {
            System.debug(e.getMessage());
        }
      
        
        
    }        
}