@RestResource(urlMapping='/hoverwebhook')
global class HoverWebhook {
    @HttpPost
    global static String postWebhook() {
        System.debug('webhook fired!');
        // process the webhook - store it, trigger updated records, etc
        String body = RestContext.request.requestBody.toString();      
        String webhookID = Hover.processWebhook(body);
        return '{"status" : "success", "webhook_id" : "' + webhookID + '"}';  
    }
    
    @HttpGet
    global static String getWebhook() {
        return '{"status": "success"}';
    }

}