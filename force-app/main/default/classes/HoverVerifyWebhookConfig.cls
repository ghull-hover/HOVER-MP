public with sharing class HoverVerifyWebhookConfig {
    public class HoverVerifyWebhookConfigInput {
        @InvocableVariable
        public String verificationCode;

    }

    public HoverVerifyWebhookConfig() {

    }
    @InvocableMethod(label='Verify Webhook' description='Verify the registration of the HOVER webhook' category='HOVER')
    public static void invPutVerifyWebhook(List<HoverVerifyWebhookConfigInput> inputs) {
        HoverVerifyWebhookConfigInput input = inputs.get(0);
        HOVER.putVerifyWebhook(input.verificationCode);            
    }

}