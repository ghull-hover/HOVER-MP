trigger HOVERRegisterWebhookTrigger on HOVER_Webhook_Config__c (after insert) {
    for(HOVER_Webhook_Config__c config : Trigger.new) {
        Hover.postWebhookConfig(config.Id);
    }   

}