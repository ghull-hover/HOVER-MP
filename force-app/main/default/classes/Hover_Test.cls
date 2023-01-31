@isTest
private class Hover_Test {
  
    @testSetup
    static void dataSetup() {
        /*
        Test.setMock(HttpCalloutMock.class, new MockCreateJobJSONFullResponseGenerator());

        HOVER_Job__c aJob = new HOVER_Job__c();
        aJob.Name = 'Test Job';
        aJob.Location_Line_1__c = '123 HOVER Way';
        aJob.deliverable_id__c = 'Complete';
        insert aJob;
        */
    }

    @isTest static void verifyData() {
        /*
        HOVER_Job__c aJob = [select name, location_line_1__c, deliverable_id__c, HOVER_Job_ID__c from HOVER_Job__c LIMIT 1];
        System.assertEquals('Complete', aJob.deliverable_id__c, 'Retrieved Job from test data');
        System.debug('HOver_Test.verifyData aJob.HOVER_Job_ID__c: ' + aJob.HOVER_Job_ID__c);
        */
    }

    @isTest static void testProcessWebhook() {
        String body = '{"job_estimated_hours_to_completion":0.0,"job_client_identifier":"3c84e077-3b2d-4b1c-bdbd-527f5d10e5c2","job_id":42678,"job_external_identifier":"a008b00000spiJxAAI","payment_partner_account_identifier":null,"event":"job-state-changed","state":"complete","webhook_id":2291}';
        String webhookID = Hover.processWebhook(body);
        System.assert(webhookID != body , 'Webhook Successful');
    }
    @isTest static void testProcessWebhookMalformedJSON() {
        String body = '{"fjkdjfjladfkj":"3c84e077-3b2d-4b1c-bdbd-527f5d10e5c2","job_ijdkfjkdjfjfrnal_identifier":"a008b00000spiJxAAI","payment_partner_account_identifier":null,"event":"job-state-changed","state":"complete","webhook_id":2291}';
        String webhookID = Hover.processWebhook(body);
        System.assert(webhookID != '' , 'Webhook malformed');
    }

    @isTest static void testProcessWebhookVerificationCode() {
        String body = '{"event":"webhook-verification-code","code":"f6b63b49-f790-4322-b647-a94d6d62043c","webhook_id":8786}';
        String webhookID = Hover.processWebhook(body);
        System.assert(webhookID != body , 'Webhook Successful');

    }

    @isTest static void testsetSuborgAssigneeID() {
        String jobID,  currentUserID,  email;
        HOVER_Job__c aJob = new HOVER_Job__c();
        aJob.Name = 'Test Job';
        aJob.Location_Line_1__c = '123 HOVER Way';
        aJob.deliverable_id__c = 'Complete';
        aJob.HOVER_Job_ID__c = '7211157';
        insert aJob;

        jobID = '7211157';
        currentUserID = '';
        email = '';
        Test.setMock(HttpCalloutMock.class, new MockGetSuborgAssigneeIDCallout());
        Hover.setSuborgAssigneeID(jobID, currentUserID, email);

    }
    @isTest static void testassignJobToUser() {
        String parentOrgID, jobID,  currentUserID,  email;
        HOVER_Job__c aJob = new HOVER_Job__c();
        aJob.Name = 'Test Job';
        aJob.Location_Line_1__c = '123 HOVER Way';
        aJob.deliverable_id__c = 'Complete';
        aJob.HOVER_Job_ID__c = '7211157';
        insert aJob;

        jobID = '7211157';
        currentUserID = '';
        email = '';
        parentOrgID = '';
        Test.setMock(HttpCalloutMock.class, new MockAssignJobToUserCallout());
        Hover.assignJobToUser(parentOrgID, jobID, currentUserID, email);

    }

    @isTest static void testExecuteGET() {
        String api, contentType;
        api = '/api/v2/jobs/';
        contentType = 'application/json';
        Test.setMock(HttpCalloutMock.class, new MockExecuteGETResponseGenerator());
        HttpResponse aResponse = Hover.executeGET(api, contentType);
        Integer statusCode = aResponse.getStatusCode();
        System.assertEquals(200, statusCode, 'Got Jobs Successfully');


    }
    @isTest static void testExecuteREST() {
        String api, method, contentType, body;
        api = '/api/v2/jobs/';
        contentType = 'application/json';
        method = 'POST';
        body = '{"name": "value"}';
        Test.setMock(HttpCalloutMock.class, new MockExecuteGETResponseGenerator());
        HttpResponse aResponse = Hover.executeREST(api, method, contentType, body);
        Integer statusCode = aResponse.getStatusCode();
        System.assertEquals(200, statusCode, 'POSTed successfully');


    }

    @isTest static void testExecutePUT() {
        String api, contentType;
        api = '/api/v2/jobs/';
        contentType = 'application/json';
        Test.setMock(HttpCalloutMock.class, new MockExecuteGETResponseGenerator());
        HttpResponse aResponse = Hover.executePUT(api);
        Integer statusCode = aResponse.getStatusCode();
        System.assertEquals(200, statusCode, 'PUT is Successful');

    }
    @isTest static void testCreateJobJSONFull() {

        // simulate the response from calling the HOVER jobs endpoint to create a new job
        Test.setMock(HttpCalloutMock.class, new MockCreateJobJSONFullResponseGenerator());

        // insert a new job into SFDC, this will fire the trigger that calls HOVER.createJobJSONFull - no need to call it directly
        HOVER_Job__c aJob = new HOVER_Job__c();
        aJob.Name = 'Test Job';
        aJob.Location_Line_1__c = '123 HOVER Way';
        aJob.deliverable_id__c = 'Complete';
        insert aJob;
        String jobID = aJob.Id;



    }
/*
    @isTest static void testGetMeasurements() {
        String sfRecordID = 'a008b00000spxKSAAY';
        String hoverJobID = '42892';

        // need to create test data for this job and then pass that ID in
        Test.setMock(HttpCalloutMock.class, new MockExecuteGETResponseGenerator());
        Hover.getMeasurements(hoverJobID, sfRecordID);

    }
    @isTest static void testGetMeasurements404() {
        String sfRecordID = 'a008b00000spxKSAAY';
        String hoverJobID = '42892';

        // need to create test data for this job and then pass that ID in
        Test.setMock(HttpCalloutMock.class, new Mock404());
        Hover.getMeasurements(hoverJobID, sfRecordID);

    }
    */
    @isTest static void testGetMeasurementsJSON() {

		Hover_Job__c aJob = new HOVER_Job__c();
            aJob.Area_Facades_Other__c = 0;
            aJob.Area_Facades_Siding__c = 0;
            aJob.Area_Openings_Other__c = 0;
            aJob.Area_Openings_Siding__c = 0;
            aJob.Area_Total_Other__c = 0;
            aJob.Area_Total_Siding__c = 0;
            aJob.Deliverable_ID__c = 'Complete';
            aJob.HOVER_Job_ID__c = '12345';
        insert aJob;

        // need to create test data for this job and then pass that ID in

        Test.setMock(HttpCalloutMock.class, new MockGetAdminUserId());
        //Hover.getMeasurementsJSON(aJob.HOVER_Job_ID__c, aJob.Id);

    }
    /*
    @isTest static void testGetMeasurementsJSON404() {

		Hover_Job__c aJob = new HOVER_Job__c();
            aJob.Area_Facades_Other__c = 0;
            aJob.Area_Facades_Siding__c = 0;
            aJob.Area_Openings_Other__c = 0;
            aJob.Area_Openings_Siding__c = 0;
            aJob.Area_Total_Other__c = 0;
            aJob.Area_Total_Siding__c = 0;
            aJob.Deliverable_ID__c = 'Complete';
            aJob.HOVER_Job_ID__c = '12345';
        insert aJob;


        // need to create test data for this job and then pass that ID in
        Test.setMock(HttpCalloutMock.class, new Mock404());
        Hover.getMeasurementsJSON(aJob.HOVER_Job_ID__c, aJob.Id);

    }
    */
    @isTest static void testRetrieveJob() {



        // need to create test data for this job and then pass that ID in
        Test.setMock(HttpCalloutMock.class, new MockGetJob());
        Hover.retrieveJob('12345');

    }
    @isTest static void testRetrieveJob404() {



        // need to create test data for this job and then pass that ID in
        Test.setMock(HttpCalloutMock.class, new Mock404());
        Hover.retrieveJob('12345');

    }
    @isTest static void testHoverJob() {

        HoverJob aJob = new HoverJob();
        HoverJob aHoverJob = new HoverJob('job name', '123 HOVER Way', '1025', '123');
        aHoverJob.location_line_2 = 'aJob.location_line_2__c';
        aHoverJob.location_city = 'aJob.location_city__c';
        aHoverJob.location_region = 'aJob.location_region__c';
        aHoverJob.location_postal_code = 'aJob.location_postal_code__c';
        aHoverJob.location_country = 'aJob.location_country__c';
        aHoverJob.customer_email = 'aJob.customer_email__c';
        aHoverJob.customer_phone = 'aJob.customer_phone__c';
        aHoverJob.deliverable_id = 3;
        HoverJobRequest aJobRequest = new HoverJobRequest('email@hover.to', aHoverJob);
        System.assertEquals('job name', aHoverJob.name);

    }

    @isTest static void testHoverWebhook() {
        String response = HoverWebhook.getWebhook();

        HOVER_Job__c aJob = new HOVER_Job__c();
        aJob.Name = 'Test Job';
        aJob.Location_Line_1__c = '123 HOVER Way';
        aJob.deliverable_id__c = 'Complete';
        insert aJob;

        String body = '{"job_estimated_hours_to_completion":0.0,"job_client_identifier":"3c84e077-3b2d-4b1c-bdbd-527f5d10e5c2","job_id":12345,"job_external_identifier":"'+ aJob.Id + '","payment_partner_account_identifier":null,"event":"job-state-changed","state":"complete","webhook_id":2291}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/hoverwebhook';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
       	RestContext.response= res;
        Test.setMock(HttpCalloutMock.class, new MockGetMeasurementsJSONResponseGenerator());

        Test.startTest();
        String postResponse = HoverWebhook.postWebhook();
        Test.stopTest();
        
        

    }

    @isTest static void testPostMessageToSlack() {
        Test.setMock(HttpCalloutMock.class, new MockExecuteGETResponseGenerator());
        HoverSlack.postMessageToSlack('test message');

    }
    @isTest static void testInvPostJobUpdateToSlack() {
        Test.setMock(HttpCalloutMock.class, new MockExecuteGETResponseGenerator());
        List<HoverSlack.HoverSlackInput> inputs = new List<HoverSlack.HoverSlackInput>();
        HoverSlack.HoverSlackInput input = new HoverSlack.HoverSlackInput();
        input.jobID = '';
        input.sfRecordID = '';
        input.state = '';
        input.webhookID = '';
        inputs.add(input);

        HoverSlack.invPostJobUpdateToSlack(inputs);

    }


    @isTest static void testHoverRoofMeasurements() {
        String roofMeasurements = '{' +
        '  "roof": {' +
        '    "roof_facets": { "area": 2139, "total": 11, "length": null },' +
        '    "ridges_hips": { "area": null, "total": 5, "length": 87.17 },' +
        '    "valleys": { "area": null, "total": 5, "length": 56.92 },' +
        '    "rakes": { "area": null, "total": 16, "length": 146.0 },' +
        '    "gutters_eaves": { "area": null, "total": 11, "length": 137.83 },' +
        '    "flashing": { "area": null, "total": 9, "length": 33.67 },' +
        '    "step_flashing": { "area": null, "total": 10, "length": 35.83 },' +
        '    "pitch": [' +
        '      { "roof_pitch": "7/12", "area": 1026, "percentage": 47.98 },' +
        '      { "roof_pitch": "8/12", "area": 629, "percentage": 29.4 },' +
        '      { "roof_pitch": "4/12", "area": 405, "percentage": 18.95 },' +
        '      { "roof_pitch": "6/12", "area": 68, "percentage": 3.17 }' +
        '    ],' +
        '    "waste_factor": {' +
        '      "area": {' +
        '        "zero": 2139,' +
        '        "plus_5_percent": 2246,' +
        '        "plus_10_percent": 2353,' +
        '        "plus_15_percent": 2460,' +
        '        "plus_20_percent": 2567' +
        '      }' +
        '    }' +
        '  }' +
        '}';
        
        System.debug('roofMeasurements: ' + roofMeasurements);
        
        HoverRoofMeasurements aRoofMeasurement = (HoverRoofMeasurements)JSON.deserialize(roofMeasurements, HoverRoofMeasurements.class);
        System.debug('flashing: ' + aRoofMeasurement.roof.flashing);
        
    }
    @isTest static void testGetMeasurementsJSONRoofOnly() {

            Hover_Job__c aJob = new HOVER_Job__c();
                aJob.Area_Facades_Other__c = 0;
                aJob.Area_Facades_Siding__c = 0;
                aJob.Area_Openings_Other__c = 0;
                aJob.Area_Openings_Siding__c = 0;
                aJob.Area_Total_Other__c = 0;
                aJob.Area_Total_Siding__c = 0;
                aJob.Deliverable_ID__c = 'Roof Only';
                aJob.HOVER_Job_ID__c = '12345';
            insert aJob;   

        // need to create test data for this job and then pass that ID in
        Test.setMock(HttpCalloutMock.class, new MockGetRoofOnlyJSONResponseGenerator());
        Hover.getMeasurementsJSON(aJob.HOVER_Job_ID__c, aJob.Id);

    }

    @isTest static void testGetMeasurementsJSONUnknownDeliverable() {

        Hover_Job__c aJob = new HOVER_Job__c();
            aJob.Area_Facades_Other__c = 0;
            aJob.Area_Facades_Siding__c = 0;
            aJob.Area_Openings_Other__c = 0;
            aJob.Area_Openings_Siding__c = 0;
            aJob.Area_Total_Other__c = 0;
            aJob.Area_Total_Siding__c = 0;
            aJob.Deliverable_ID__c = 'Total Living Area';
            aJob.HOVER_Job_ID__c = '12345';
        insert aJob;   

    // need to create test data for this job and then pass that ID in
    Test.setMock(HttpCalloutMock.class, new MockGetRoofOnlyJSONResponseGenerator());
    Hover.getMeasurementsJSON(aJob.HOVER_Job_ID__c, aJob.Id);

}

    @isTest static void testFetchTestUpdateStatus() {
        String api, contentType;
        api = '/api/v2/jobs/';
        contentType = 'application/json';
        Test.setMock(HttpCalloutMock.class, new MockGetJobs());
        String aResponse = Hover.fetchTestUpdateStatus('12345');

    }


    @isTest static void testCaptureRequestClasses() {

        HoverJob aJob = new HoverJob();
        HoverJob aHoverJob = new HoverJob('job name', '123 HOVER Way', '1025', '123');
        aHoverJob.location_line_2 = 'aJob.location_line_2__c';
        aHoverJob.location_city = 'aJob.location_city__c';
        aHoverJob.location_region = 'aJob.location_region__c';
        aHoverJob.location_postal_code = 'aJob.location_postal_code__c';
        aHoverJob.location_country = 'aJob.location_country__c';
        aHoverJob.customer_email = 'aJob.customer_email__c';
        aHoverJob.customer_phone = 'aJob.customer_phone__c';
        aHoverJob.deliverable_id = 3;

        HoverCaptureRequest aCaptureRequest = new HoverCaptureRequest();
        aCaptureRequest.job_attributes = aHoverJob;
        aCaptureRequest.capturing_user_email = 'test@foo.com';
        aCaptureRequest.capturing_user_name = 'Test Foo';
        aCaptureRequest.capturing_user_phone = '310-867-5309';

        HoverCaptureRequestWrapper aCaptureRequestWrapper = new HoverCaptureRequestWrapper();
        aCaptureRequestWrapper.capture_request = aCaptureRequest;
        aCaptureRequestWrapper.current_user_email = 'current@foo.com';
        aCaptureRequestWrapper.current_user_id = '12345';


    }

    @isTest static void testPostCaptureRequest() {

        // simulate the response from calling the HOVER jobs endpoint to create a new job
        Test.setMock(HttpCalloutMock.class, new MockPostCaptureRequestResponseGenerator());

        // insert a new job into SFDC, this will fire the trigger that calls HOVER.createJobJSONFull - no need to call it directly
        HOVER_Job__c aJob = new HOVER_Job__c();
        aJob.Name = 'Test Job';
        aJob.Location_Line_1__c = '123 HOVER Way';
        aJob.deliverable_id__c = 'Complete';
        aJob.Send_Connect_Request__c = true;
    
        insert aJob;
        String jobID = aJob.Id;


    }

    @isTest static void testHOVERJobUpdateTrigger() {
        // simulate the response from calling the HOVER jobs endpoint to create a new job
        Test.setMock(HttpCalloutMock.class, new MockCreateJobJSONFullResponseGenerator());

        User testAssignee = [select id from user limit:1];

        HOVER_Job__c aJob = new HOVER_Job__c();
        aJob.Name = 'Test Job';
        aJob.Location_Line_1__c = '123 HOVER Way';
        aJob.deliverable_id__c = 'Complete';
        //aJob.Suborg_Assignee__c = '0051g000009dbQmAAI';
        aJob.Suborg_Assignee__c = testAssignee.Id;
    
        insert aJob;
        String jobID = aJob.Id;
        aJob.Initial_Org_ID__c = '492855';
        aJob.Initial_User_ID__c = '1195491';
        update aJob;

    }
    @isTest static void testHOVERJobUpdateTriggerPostAssigneeLookup() {
        // simulate the response from calling the HOVER jobs endpoint to create a new job
        Test.setMock(HttpCalloutMock.class, new MockCreateJobJSONFullResponseGenerator());
        User testAssignee = [select id from user limit:1];

        HOVER_Job__c aJob = new HOVER_Job__c();
        aJob.Name = 'Test Job';
        aJob.Location_Line_1__c = '123 HOVER Way';
        aJob.deliverable_id__c = 'Complete';
        //aJob.Suborg_Assignee__c = '0051g000009dbQmAAI';
        aJob.Suborg_Assignee__c = testAssignee.Id;
        aJob.Initial_Org_ID__c = '492855';
        insert aJob;
        String jobID = aJob.Id;
        aJob.Initial_Org_ID__c = '492855';
        aJob.Initial_User_ID__c = '1195491';
        aJob.Suborg_Assignee_ID__c = '1195562';
        update aJob;

    }

    @isTest static void testPostWebhookConfig() {

        Test.setMock(HttpCalloutMock.class, new MockWebhookConfigCreationResponse()); 
        HOVER_Webhook_Config__c aConfig = new HOVER_Webhook_Config__c();
        aConfig.URL__c = '';
        aConfig.Content_Type__c = '';
        aConfig.Name = 'config';
        insert aConfig;

    }

    @isTest static void testHoverVerifyWebhookConfig() {
        Test.setMock(HttpCalloutMock.class, new MockExecuteGETResponseGenerator());
        List<HoverVerifyWebhookConfig.HoverVerifyWebhookConfigInput> inputs = new List<HoverVerifyWebhookConfig.HoverVerifyWebhookConfigInput>();
        HoverVerifyWebhookConfig.HoverVerifyWebhookConfigInput input = new HoverVerifyWebhookConfig.HoverVerifyWebhookConfigInput();
        input.verificationCode = 'f6b63b49-f790-4322-b647-a94d6d62043c';
        inputs.add(input);

        HOVER_Webhook_Config__c theConfig = new HOVER_Webhook_Config__c();
        theConfig.Verification_Code__c = 'f6b63b49-f790-4322-b647-a94d6d62043c';
        insert theConfig;


        HoverVerifyWebhookConfig.invPutVerifyWebhook(inputs);

    }


}