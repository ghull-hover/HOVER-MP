public class Hover {

    public static HoverJobRequest jobRequest {get;set;}


    /*
        Process a HOVER Webhook 
            - parse the JSON for the individual fields
            - Insert a Webhook (associating it with the corresponding HOVER Job)
    */
    public static String processWebhook(String body) {
        System.debug('webhook body: ' + body);

        String webhookID = '';

        try {
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(body);
        
            // store every inbound webhook
            Hover_Webhook__c webhook = new Hover_Webhook__c(Name='webhook');
            webhook.Request__c = body;
            webhook.Content_Available__c = String.valueOf(result.get('content-available')); //abnormal naming convention '-'
            webhook.Event__c = String.valueOf(result.get('event'));
            webhook.Job_Estimated_Hours_to_Completion__c = String.valueOf(result.get('job_estimated_hours_to_completion'));
            webhook.Job_External_Identifier__c = String.valueOf(result.get('job_external_identifier'));
            webhook.Job_ID__c = String.valueOf(result.get('job_id'));
            webhook.Webhook_ID__c = String.valueOf(result.get('webhook_id'));
            webhook.State__c = String.valueOf(result.get('state'));
            webhook.HOVER_Job_ID__c	= String.valueOf(result.get('job_external_identifier'));

            if (webhook.Event__c.equalsIgnoreCase('webhook-verification-code')) {
                String verificationCode = String.valueOf(result.get('code'));
                webhook.Verification_Code__c = verificationCode;
                HOVER_Webhook_Config__c theConfig = [select HOVER_Webhook_ID__c, URL__c, Content_Type__c, Status__c from HOVER_Webhook_Config__c WHERE HOVER_Webhook_ID__c = :webhook.Webhook_ID__c limit 1];
                theConfig.Verification_Code__c = verificationCode;
                update theConfig;
                
            }
            if (webhook.Event__c.equalsIgnoreCase('capture-request-state-changed')) {

            }
            insert webhook;
            webhookID = webhook.id;            

        }
        catch (Exception e) {
            HOVER_Exception__e hoverException = new HOVER_Exception__e();
            String message = 'HOVER.processWebhook failed with exception: ' + e.getMessage();
            hoverException.Description__c = message;
            Database.SaveResult result = EventBus.publish(hoverException);
            System.debug(message);

        }

        return webhookID;
        
    }


    public static HttpResponse executeREST(String api, String method, String contentType, String body) {

        // convenience method to execute a REST API - not sure if needed now with named credentials ...

        System.debug('using named credentials');

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:HOVER' + api);
        request.setMethod(method);
        request.setBody(body);
        request.setHeader('Content-Type', contentType);
        Http http = new Http();
        HttpResponse response = http.send(request);

        return (response);            
    }
   


    @future (callout=true)
    public static void setSuborgAssigneeID(String jobID, String currentUserID, String email) {
        System.debug('Setting Suborg Assignee ID...');
        String emailEncoded = EncodingUtil.urlEncode(email, 'UTF-8');
        

        String api = '/api/v1/users?current_user_id=' + currentUserID + 'page=1&search=' + emailEncoded + '&sort_by=last_name&sort_order=asc';
        String contentType = 'application/json';
		HttpResponse response = Hover.executeGET(api, contentType);
        Integer statusCode = response.getStatusCode();

        if(statusCode == 200) {
            System.debug('Found User');
            String responseBody = response.getBody();
            System.debug('response body: ' + responseBody);
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            // Cast the values in the 'results' key as a list
            List<Object> users = (List<Object>) result.get('users');
            System.debug('Received the following user Array:');
            System.debug(users);
            if (users.size() > 0) {
                System.debug('user 0: ');
                System.debug(users[0]);
                Map<String,Object> user = (Map<String,Object>) users[0];
                System.debug(user);
                String assigneeID =  String.valueOf(user.get('id'));
                System.debug ('suborg Assignee ID: ' + assigneeID);
                System.debug('HOVER Job ID: ' + jobID);
                if (Schema.sObjectType.HOVER4SF__HOVER_Job__c.isUpdateable()){
                    System.debug('Object is Updatable');
                	HOVER_Job__c aJob = [select ID from HOVER_Job__c where HOVER_Job_ID__c = :jobID LIMIT 1];
                	aJob.Suborg_Assignee_ID__c = assigneeID;
                	update aJob;
                } 
                else{
                    System.debug('HOVER_Job__c cannot be updated. Check user permissions and try again');
                }
    
            }
            else {
                // did not find a user for the email address
                System.debug('Did not find a user for email: ' + email + ' encoded as: ' + emailEncoded);

                // throw platform event here?
            }

        }
        else {
            System.debug('Failed executing user search');
            // how to handle from here - platform event?
        }
    }

    @future (callout=true)
    public static void assignJobToUser(String parentOrgID, String currentUserID, String jobID, String userID) {

        System.debug('Assigning Job to Suborg User...');
        HOVERJobAssignmentRequest assignmentRequest = new HOVERJobAssignmentRequest();
        assignmentRequest.current_user_id = currentUserID;
        assignmentRequest.user_id = userID;
        String body = JSON.serialize(assignmentRequest);
        System.debug('the assignment body: ' + body);
    
        String api = '/api/v1/orgs/' + parentOrgID + '/jobs/' + jobID + '/assign';
        String contentType = 'application/json';
        String method = 'POST';
        HttpResponse response = Hover.executeREST(api, method, contentType, body);
        Integer statusCode = response.getStatusCode();

        if(statusCode == 204) {
            System.debug('Assignment Successful!');
            // platform event to notify?
        }
        else {
            System.debug('Assignment Failed executing: ' + api);
            System.debug('with body: ' + body);
            // how to handle from here - platform event?
        }
    }



    /*
        Create a Job in HOVER for the given HOVER Job in Salesforce identified by jobID
    */
    
    @future (callout=true)
    public static void createJobJSONFull(String jobID) {
        System.debug('Job ID: ' + jobID);
        String contentType = 'application/json';
        String method = 'POST';
        String api = '/api/v1/jobs';
        String adminUserId = Hover.getAdminUserId();
        String hoverWalletId = Hover.getWalletId(adminUserId);
        
        Integer statusCode;


		// map for picklist deliverable values
        Map<String,Integer> deliverables = new Map<String,Integer>();
        deliverables.put('Roof Only', 2);
        deliverables.put('Complete', 3);
        deliverables.put('Total Living Area Plus', 5);
        deliverables.put('Total Living Area', 6);
        deliverables.put('Capture Only, Photos Only', 7);


        // get the Job using SOQL
        Hover_Job__c aJob = [select name, 
                             location_line_1__c, 
                             location_line_2__c, 
                             location_city__c, 
                             location_region__c, 
                             location_postal_code__c, 
                             location_country__c,
                             customer_email__c,
                             customer_phone__c,
                             deliverable_id__c,
                             assignee__r.email,
                             id from HOVER_Job__c where id = :jobID limit 1 ];
        HoverJob aHoverJob = new HoverJob(aJob.Name, aJob.Location_Line_1__c, '', aJob.Id);
        aHoverJob.location_line_2 = aJob.location_line_2__c;
        aHoverJob.location_city = aJob.location_city__c;
        aHoverJob.location_region = aJob.location_region__c;
        aHoverJob.location_postal_code = aJob.location_postal_code__c;
        aHoverJob.location_country = aJob.location_country__c;
        aHoverJob.customer_email = aJob.customer_email__c;
        aHoverJob.customer_phone = aJob.customer_phone__c;
        deliverables.get(aJob.deliverable_id__c);
        aHoverJob.deliverable_id = deliverables.get(aJob.deliverable_id__c);
        aHoverJob.wallet_id = hoverWalletId;

        HoverJobRequest aJobRequest = new HoverJobRequest(aJob.assignee__r.email, aHoverJob);
        String body = JSON.serialize(aJobRequest);
        System.debug('the body: ' + body);
    
        //HttpResponse response = Hover.executeREST(bearerToken, api, method, contentType, body);
        HttpResponse response = Hover.executeREST(api, method, contentType, body);
        // If the request is successful, parse the JSON response.
        statusCode = response.getStatusCode();
        if(statusCode == 201) {
            System.debug(response.getBody());
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // Cast the values in the 'results' key as a list
            Map<String, Object> job = (Map<String,Object>) result.get('job');
            System.debug('Received the following job:');
            System.debug(job);
            String hoverJobID = String.valueOf(job.get('id'));
            String status = String.valueOf(job.get('state'));
            if (Schema.sObjectType.HOVER4SF__HOVER_Job__c.isUpdateable()){
            	System.debug('HOVER Job ID: ' + hoverJobID);
            	aJob.HOVER_Job_ID__c = hoverJobId;
            	aJob.State__c = status;
            	update aJob;
            	}
           		 else{
                    System.debug('HOVER_Job__c cannot be updated. Check user permissions and try again');
                }
        }
        else {
            // anything beside a 201 is a problem - publish a platform event to inform
            HOVER_Exception__e hoverException = new HOVER_Exception__e();
            String message = 'HOVER.createJobJSONFull failed with status code: ' + response.getStatusCode() + ': ' + response.getBody();
            hoverException.Description__c = message;
            Database.SaveResult result = EventBus.publish(hoverException);
            System.debug(message);

        }
        
 
    }    
    /*
        Create a Job in HOVER for the given HOVER Job in Salesforce identified by jobID
    */
    
    @future (callout=true)
    public static void postCaptureRequest(String jobID) {
        System.debug('Job ID: ' + jobID);
        String contentType = 'application/json';
        String method = 'POST';
        String api = '/api/v2/capture_requests';
        Integer statusCode;
        String adminUserId = Hover.getAdminUserId();
        String hoverWalletId = Hover.getWalletId(adminUserId);


		// map for picklist deliverable values
        Map<String,Integer> deliverables = new Map<String,Integer>();
        deliverables.put('Roof Only', 2);
        deliverables.put('Complete', 3);
        deliverables.put('Total Living Area Plus', 5);
        deliverables.put('Total Living Area', 6);
        deliverables.put('Capture Only, Photos Only', 7);


        // get the Job using SOQL
        Hover_Job__c aJob = [select name, 
                             location_line_1__c, 
                             location_line_2__c, 
                             location_city__c, 
                             location_region__c, 
                             location_postal_code__c, 
                             location_country__c,
                             customer_email__c,
                             customer_phone__c,
                             deliverable_id__c,
                             assignee__r.email,
                             Capturing_User_Email__c,
                             Capturing_User_Name__c,
                             Capturing_User_Phone__c,
                             id from HOVER_Job__c where id = :jobID limit 1 ];
        HoverJob aHoverJob = new HoverJob(aJob.Name, aJob.Location_Line_1__c, '', aJob.Id);
        aHoverJob.location_line_2 = aJob.location_line_2__c;
        aHoverJob.location_city = aJob.location_city__c;
        aHoverJob.location_region = aJob.location_region__c;
        aHoverJob.location_postal_code = aJob.location_postal_code__c;
        aHoverJob.location_country = aJob.location_country__c;
        aHoverJob.customer_email = aJob.customer_email__c;
        aHoverJob.customer_phone = aJob.customer_phone__c;
        deliverables.get(aJob.deliverable_id__c);
        aHoverJob.deliverable_id = deliverables.get(aJob.deliverable_id__c);
        aHoverJob.wallet_id = hoverWalletId;

        HoverCaptureRequest aCaptureRequest = new HoverCaptureRequest();
        aCaptureRequest.capturing_user_name = aJob.Capturing_User_Name__c;
        aCaptureRequest.capturing_user_email = aJob.Capturing_User_Email__c;
        aCaptureRequest.capturing_user_phone = aJob.Capturing_User_Phone__c;
        aCaptureRequest.job_attributes = aHoverJob;

        HoverCaptureRequestWrapper aCaptureRequestWrapper = new HoverCaptureRequestWrapper();
        aCaptureRequestWrapper.current_user_email = aJob.Assignee__r.email;
        aCaptureRequestWrapper.capture_request = aCaptureRequest;

        String body = JSON.serialize(aCaptureRequestWrapper);
        System.debug('the body for the capture request: ' + body);
    
        //HttpResponse response = Hover.executeREST(bearerToken, api, method, contentType, body);
        HttpResponse response = Hover.executeREST(api, method, contentType, body);
        // If the request is successful, parse the JSON response.
        statusCode = response.getStatusCode();
        String responseBody;
        if(statusCode == 201) {
            responseBody = response.getBody();
            System.debug(responseBody);
            if (Schema.sObjectType.HOVER4SF__HOVER_Job__c.isUpdateable()){
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                System.debug('After deserializing capture request response');
                // Cast the values in the 'results' key as a list
                String captureRequestID =  String.valueOf(result.get('id'));
                String hoverJobID =  String.valueOf(result.get('pending_job_id'));
                String status = String.valueOf(result.get('state'));
                String connectIdentifier = String.valueOf(result.get('identifier'));
    
                System.debug('Capture Request ID: ' + captureRequestID);
                System.debug('Pending Job ID: ' + hoverJobID);
                System.debug('Status: ' + status);
                aJob.HOVER_Job_ID__c = hoverJobId;
                aJob.State__c = status;
                aJob.Capture_Request_ID__c = captureRequestID;
                aJob.Connect_Identifier__c = connectIdentifier;
                aJob.Connect_Link__c = 'https://hover.to/api/v2/capture_requests/' + connectIdentifier;
                
                update aJob;
            }
            else {
                System.debug('HOVER_Job__c cannot be updated. Check user permissions and try again');
                }
            // Deserialize the JSON string into collections of primitive data types.
        }
        else {
            // anything beside a 201 is a problem - publish a platform event to inform
            HOVER_Exception__e hoverException = new HOVER_Exception__e();
            String message = 'HOVER.postCaptureRequest failed with status code: ' + response.getStatusCode() + ': ' + response.getBody();
            hoverException.Description__c = message;
            Database.SaveResult result = EventBus.publish(hoverException);
            System.debug(message);

        }
        
 
    }    
    @future (callout=true)
    public static void getMeasurements(String jobID, String sfRecordID) {
        getJobMeasurements(jobID, sfRecordID);
    }
    
    public static Blob getJobMeasurements(String jobID, String sfRecordID) {
        
        String method = 'GET';
        String api = '/api/v2/jobs/' + jobID + '/measurements.pdf';
		Blob measurementsBody;
		HttpResponse response = Hover.executeGET(api, '');
		Schema.DescribeSObjectResult checkJobWritePermissions = HOVER4SF__HOVER_Job__c.sObjectType.getDescribe();
     
        if(response.getStatusCode() == 200 && checkJobWritePermissions.isCreateable()) {
            measurementsBody = response.getBodyAsBlob();
        }    
        else {
            HOVER_Exception__e hoverException = new HOVER_Exception__e();
            String message = 'HOVER.getJobMeasurements failed with status code: ' + response.getStatusCode() + ': ' + response.getBody();
            hoverException.Description__c = message;
            Database.SaveResult result = EventBus.publish(hoverException);
            System.debug(message);

        }
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'measurements-'+jobID +'.pdf'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Measurements for Job: ' + jobID; // Display name of the files
        conVer.VersionData = measurementsBody;
        conVer.TagCsv = '{"HOVERJobID" : "' + jobID + '"}';
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
         
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = sfRecordID; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
      
        return measurementsBody;
        
    }  
    
    public static HoverJob retrieveJob(String jobID) {
        
        String method = 'GET';
        String api = '/api/v2/jobs/' + jobID;
        String contentType = 'application/json';
        HoverJob aHoverJob = new HoverJob();
        
		HttpResponse response = Hover.executeGET(api, contentType);

        System.debug('after sending refresh request');
        if(response.getStatusCode() == 200) {
            System.debug(response.getBody());
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            aHoverJob.name = String.valueOf(result.get('name'));
            System.debug('aHoverJob: ' + aHoverJob);
          
        } 
        else {
            HOVER_Exception__e hoverException = new HOVER_Exception__e();
            String message = 'HOVER.retrieveJob failed with status code: ' + response.getStatusCode() + ': ' + response.getBody();
            hoverException.Description__c = message;
            Database.SaveResult result = EventBus.publish(hoverException);
            System.debug(message);

        }   
      
        return aHoverJob;
        
    }       
    public static HttpResponse executeGET(String api, String contentType) {
        System.debug('using named credentials');

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:HOVER' + api);
        request.setMethod('GET');
        request.setHeader('Content-Type', contentType);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response: ' + response);

        return (response);            
    }


    @future (callout=true)
    public static void getMeasurementsJSON(String jobID, String sfRecordID) {
        getJobMeasurementsJSON(jobID, sfRecordID);
    }
    
    public static void parseJSONMeasurements(String measurements, String sfRecordID) {
		Hover_Job__c aJob = [select Area_Facades_Other__c , 
                             Area_Facades_Siding__c , 
                             Area_Openings_Other__c , 
                             Area_Openings_Siding__c , 
                             Area_Total_Other__c , 
                             Area_Total_Siding__c ,
                             Deliverable_ID__c,
                             id from HOVER_Job__c where id = :sfRecordID limit 1 ];
      

  		// map for picklist deliverable values
        Map<String,Integer> deliverables = new Map<String,Integer>();
        deliverables.put('Roof Only', 2);
        deliverables.put('Complete', 3);
        deliverables.put('Total Living Area Plus', 5);
        deliverables.put('Total Living Area', 6);
        deliverables.put('Capture Only, Photos Only', 7);

        Integer deliverableID = deliverables.get(aJob.deliverable_id__c);

      
        try {
            if (deliverableID == 2 && Schema.sObjectType.HOVER4SF__HOVER_Job__c.isUpdateable()) { // Roof Only
                HoverRoofMeasurements aRoofMeasurement = (HoverRoofMeasurements)JSON.deserialize(measurements, HoverRoofMeasurements.class);
                aJob.Roof_Facets_Area__c = aRoofMeasurement.roof.roof_facets.area;
                aJob.Roof_Facets_Length__c = aRoofMeasurement.roof.roof_facets.length;
                aJob.Roof_Facets_Total__c = aRoofMeasurement.roof.roof_facets.total;
                aJob.Ridges_Hips_Area__c = aRoofMeasurement.roof.ridges_hips.area;
                aJob.Ridges_Hips_Length__c = aRoofMeasurement.roof.ridges_hips.length;
                aJob.Ridges_Hips_Total__c = aRoofMeasurement.roof.ridges_hips.total;
                aJob.Valleys_Area__c = aRoofMeasurement.roof.valleys.area;
                aJob.Valleys_Length__c = aRoofMeasurement.roof.valleys.length;
                aJob.Valleys_Total__c = aRoofMeasurement.roof.valleys.total;
                aJob.Rakes_Area__c = aRoofMeasurement.roof.rakes.area;
                aJob.Rakes_Length__c = aRoofMeasurement.roof.rakes.length;
                aJob.Rakes_Total__c = aRoofMeasurement.roof.rakes.total;
                aJob.Gutters_Eaves_Area__c = aRoofMeasurement.roof.gutters_eaves.area;
                aJob.Gutters_Eaves_Length__c = aRoofMeasurement.roof.gutters_eaves.length;
                aJob.Gutters_Eaves_Total__c = aRoofMeasurement.roof.gutters_eaves.total;
                aJob.Flashing_Area__c = aRoofMeasurement.roof.flashing.area;
                aJob.Flashing_Length__c = aRoofMeasurement.roof.flashing.length;
                aJob.Flashing_Total__c = aRoofMeasurement.roof.flashing.total;
                aJob.Step_Flashing_Area__c = aRoofMeasurement.roof.step_flashing.area;
                aJob.Step_Flashing_Length__c = aRoofMeasurement.roof.step_flashing.length;
                aJob.Step_Flashing_Total__c = aRoofMeasurement.roof.step_flashing.total;
                aJob.Waste_Factor_Area_Zero__c = aRoofMeasurement.roof.waste_factor.area.zero;
                aJob.Waste_Factor_Area_Plus_5_Percent__c = aRoofMeasurement.roof.waste_factor.area.plus_5_percent;
                aJob.Waste_Factor_Area_Plus_10_Percent__c = aRoofMeasurement.roof.waste_factor.area.plus_10_percent;
                aJob.Waste_Factor_Area_Plus_15_Percent__c = aRoofMeasurement.roof.waste_factor.area.plus_15_percent;
                aJob.Waste_Factor_Area_Plus_20_Percent__c = aRoofMeasurement.roof.waste_factor.area.plus_20_percent;

                update aJob;


            }
            else if (deliverableID == 3 && Schema.sObjectType.HOVER4SF__HOVER_Job__c.isUpdateable()) { // complete
                Map<String, Object> json = (Map<String, Object>) JSON.deserializeUntyped(measurements);
                Map<String, Object> area = (Map<String,Object>) json.get('area');
                
                Map<String, Object> facades = (Map<String,Object>) area.get('facades');
                Integer areaFacadesSiding = Integer.valueOf(facades.get('siding')); 
                System.debug('sidingArea: ' + areaFacadesSiding);
                Integer areaFacadesOther = Integer.valueOf(facades.get('other')); 
                
                Map<String, Object> openings = (Map<String,Object>) area.get('openings');
                Integer areaOpeningsSiding = Integer.valueOf(openings.get('siding')); 
                Integer areaOpeningsOther = Integer.valueOf(openings.get('other')); 
        
                Map<String, Object> unknown = (Map<String,Object>) area.get('unknown');
                Integer areaUnknownSiding = Integer.valueOf(unknown.get('siding')); 
                Integer areaUnknownOther = Integer.valueOf(unknown.get('other')); 
                
                Map<String, Object> total = (Map<String,Object>) area.get('total');
                Integer areaTotalSiding = Integer.valueOf(total.get('siding')); 
                Integer areaTotalOther = Integer.valueOf(total.get('other')); 
        
                
                aJob.Area_Facades_Siding__c = areaFacadesSiding;
                aJob.Area_Facades_Other__c = areaFacadesOther;
                aJob.Area_Openings_Other__c = areaOpeningsOther;
                aJob.Area_Openings_Siding__c = areaOpeningsSiding;
                aJob.Area_Total_Other__c = areaTotalOther;
                aJob.Area_Total_Siding__c = areaTotalSiding;
                update aJob;
            }
            else {
                HOVER_Exception__e hoverException = new HOVER_Exception__e();
                String message = 'HOVER.parseJSONMeasurements failed with unknown deliverable ID: ' + deliverableID;
                hoverException.Description__c = message;
                Database.SaveResult result = EventBus.publish(hoverException);
                System.debug(message);
    
            }
    
        }
        catch (Exception e) {
            HOVER_Exception__e hoverException = new HOVER_Exception__e();
            String message = 'HOVER.parseJSONMeasurements failed with exception: ' + e.getMessage();
            hoverException.Description__c = message;
            Database.SaveResult result = EventBus.publish(hoverException);
            System.debug(message);

        }

    }
    
    public static String getJobMeasurementsJSON(String jobID, String sfRecordID) {
        
        String method = 'GET';
        String api = '/api/v2/jobs/' + jobID + '/measurements.json?version=summarized_json';
		String measurementsBody;
		HttpResponse response = Hover.executeGET(api, '');
        
        Schema.DescribeSObjectResult checkJobWritePermissions = HOVER4SF__HOVER_Job__c.sObjectType.getDescribe();
     
        if(response.getStatusCode() == 200 && checkJobWritePermissions.isCreateable()){
            measurementsBody = response.getBody();
            parseJSONMeasurements(measurementsBody, sfRecordID);
            
        }
        else {
            HOVER_Exception__e hoverException = new HOVER_Exception__e();
            String message = 'HOVER.getJobMeasurementsJSON failed with status code: ' + response.getStatusCode() + ': ' + response.getBody();
            hoverException.Description__c = message;
            Database.SaveResult result = EventBus.publish(hoverException);
            System.debug(message);
        }    
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = 'measurements-'+jobID +'.json'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'JSON Measurements for Job: ' + jobID; // Display name of the files
        conVer.VersionData = Blob.valueOf (measurementsBody);
        //conVer.HOVER_Job_ID__c = jobID;
        conVer.TagCsv = '{"HOVERJobID" : "' + jobID + '"}';
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
         
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = sfRecordID; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
      
        return measurementsBody;
        
    }
    
    @AuraEnabled
    public static String fetchTestUpdateStatus(String jobID) {
        //obtain the current_user_id 
        String method = 'GET';
        String api = '/api/v2/jobs/' + jobID;
        String contentType = 'application/json';
        
        HoverJob aHoverJob = new HoverJob();
        
        //call the jobs endpoint in HOVER to get current_user_id
		HttpResponse response = Hover.executeGET(api, contentType);
    
    	Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        aHoverJob.hover_user_id = String.valueOf(result.get('user_id'));
    	String currentUserID =  aHoverJob.hover_user_id;
    	System.debug(currentUserId);
          
        String apiPath = '/api/v2/jobs/' + jobID + '/set_test_state.json?state=complete&current_user_id=' + currentUserId;
        HttpResponse secondResponse = Hover.updateJobStatus(apiPath, contentType, currentUserId);
         System.debug('Patch request invoked');
   		return currentUserId;
		}

    public static HttpResponse updateJobStatus(String apiPath, String contentType, String currentUserId) {
        System.debug('Patch Request User ID: ' + currentUserId);

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:HOVER' + apiPath);
        request.setMethod('PATCH');
        request.setHeader('Content-Type', contentType);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response: ' + response);

        return (response);            
    }


    public static HttpResponse executePUT(String api) {
        System.debug('using named credentials');

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:HOVER' + api);
        request.setMethod('PUT');
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response: ' + response);

        return (response);            
    }

    /*
        Register a webhook in HOVER for the given HOVER Webhook Config in Salesforce identified by webhookConfigID
    */
    
    @future (callout=true)
    public static void postWebhookConfig(String webhookConfigID) {
        System.debug('Webhook Config ID: ' + webhookConfigID);
        String contentType = 'application/json';
        String method = 'POST';
        String api = '/api/v2/webhooks';
        Integer statusCode;



        // get the Webhook Config using SOQL
        HOVER_Webhook_Config__c theConfig = [select URL__c, Content_Type__c from HOVER_Webhook_Config__c WHERE ID = :webhookConfigID limit 1];
        HOVERWebhookConfig aConfig = new HOVERWebhookConfig();
        aConfig.content_type = theConfig.Content_Type__c;
        aConfig.url = theConfig.URL__c;
        HOVERWebhookConfigWrapper aWrapper = new HOVERWebhookConfigWrapper();
        aWrapper.webhook = aConfig;

        String body = JSON.serialize(aWrapper);
        System.debug('the body for the webhook config: ' + body);
    
        HttpResponse response = Hover.executeREST(api, method, contentType, body);
        // If the request is successful, parse the JSON response.
        statusCode = response.getStatusCode();
        String responseBody;
        if(statusCode == 201 && Schema.sObjectType.HOVER4SF__HOVER_Webhook__c.isUpdateable()) {
            responseBody = response.getBody();
            System.debug(responseBody);
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            // Cast the values in the 'results' key as a list
            String hoverWebhookID = String.valueOf(result.get('id'));
            System.debug('HOVER Webhook ID: ' + hoverWebhookID);
            theConfig.HOVER_Webhook_ID__c = hoverWebhookID;
            update theConfig;
        }
        else {
            // anything beside a 201 is a problem - publish a platform event to inform
            HOVER_Exception__e hoverException = new HOVER_Exception__e();
            String message = 'HOVER.postWebhookConfig failed with status code: ' + response.getStatusCode() + ': ' + response.getBody();
            hoverException.Description__c = message;
            Database.SaveResult result = EventBus.publish(hoverException);
            System.debug(message);
        }
        
    }        
    @future (callout=true)
    public static void putVerifyWebhook(String verificationCode) {
        System.debug('Webhook verification code: ' + verificationCode);
        String api = '/api/v2/webhooks/' + verificationCode + '/verify';
        HttpResponse response =  HOVER.executePUT(api);
        String responseBody = '';
        if (response.getStatusCode() == 200) {
            // get the Webhook Config using SOQL
            // Deserialize the JSON string into collections of primitive data types.
            System.debug('Retrieve HOVER Webhook Config by Verification code: ' + verificationCode);

            HOVER_Webhook_Config__c theConfig = [select HOVER_Webhook_ID__c, URL__c, Content_Type__c, Status__c, Verification_Code__c from HOVER_Webhook_Config__c WHERE Verification_Code__c = :verificationCode limit 1];
            System.debug('theConfig internal ID: ' + theConfig.Id);
            theConfig.Status__c = 'Verified';
            update theConfig;
         
        }
        else {
            // anything beside a 200 is a problem - publish a platform event to inform
            HOVER_Exception__e hoverException = new HOVER_Exception__e();
            String message = 'HOVER.putVerifyWebhook failed with status code: ' + response.getStatusCode() + ': ' + response.getBody();
            hoverException.Description__c = message;
            Database.SaveResult result = EventBus.publish(hoverException);
            System.debug(message);

        }
    }
    
    //this method obtains the first user ID of all admin users for an org
	//the initial purpose is to obtain the user ID and subsequently call the List Wallets endpoint
	//in order to obtain the wallet ID of a parent org
	public static String getAdminUserId(){
        
        String method = 'GET';
        String api = '/api/v2/users?admin=true';
        String contentType = 'application/json';
    	String adminUserId = '';

        
		HttpResponse response = Hover.executeGET(api, contentType);
        Integer statusCode = response.getStatusCode();

        System.debug('after sending refresh request');
        if(statusCode == 200) {
            System.debug('Found User');
            String responseBody = response.getBody();
            System.debug('response bode: ' + responseBody);
            Map<String, Object> userResults = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            List<Object> users = (List<Object>) userResults.get('results');
             if (users.size() > 0) {
                System.debug('how now brown cow');
           	 	Map<String,Object> user = (Map<String,Object>) users[0];
            	adminUserId = String.valueOf(user.get('id'));

            }
            else {
                // did not find a user for the email address
                System.debug('No Admin Users Found');

                // throw platform event here?
            }

        }
        else {
            System.debug('Failed executing user search');
            // how to handle from here - platform event?
        }

        System.debug(adminUserId);
    	return adminUserId;
    }
  
    public static String getWalletId(String adminUserId){ 
	 String method = 'GET';
     String api = '/api/v2/wallets?current_user_id=' + adminUserId;
     String contentType = 'application/json';
   	 String walletId = '';
        
	 HttpResponse response = Hover.executeGET(api, contentType);
     Integer statusCode = response.getStatusCode();
        
     if(statusCode == 200) {
            System.debug('Found Wallet ID');
            String responseBody = response.getBody();
            System.debug('response body: ' + responseBody);
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(responseBody);  	
            List<Object> wallets = (List<Object>) result.get('results');	
            if (wallets.size() > 0) {
           	 	Map<String,Object> wallet = (Map<String,Object>) wallets[0];
            	adminUserId = String.valueOf(wallet.get('id'));
                System.debug(adminUserId);
    	        return adminUserId;

            }
            else {
                // did not find a user for the email address
                System.debug('No Admin Users Found');

                // throw platform event here?
            }

        }
        else {
            System.debug('Failed executing ');
            // how to handle from here - platform event?
        }

        System.debug(adminUserId);
    	return adminUserId;
    }  
}