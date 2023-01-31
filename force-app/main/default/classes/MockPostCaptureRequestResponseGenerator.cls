global class MockPostCaptureRequestResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
            '{' +
            '"id": 41440,' +
            '"capturing_user_name": "Luke Groundrunner",' +
            '"capturing_user_phone": "",' +
            '"capturing_user_email": "lgroundrunner@test.com",' +
            '"capturing_user_id": 332141,' +
            '"requesting_user_id": 307444,' +
            '"identifier": "Zjz-Nw",' +
            '"claim_number": null,' +
            '"state": "connected",' +
            '"signup_type": "homeowner",' +
            '"job_attributes": {' +
              '"name": "Capture Request Test Job",' +
              '"location_line_1": "634 2nd St.",' +
              '"location_line_2": "Suite 300",' +
              '"location_city": "San Francisco",' +
              '"location_region": "California",' +
              '"location_postal_code": "94107",' +
              '"external_identifier": "",' +
              '"deliverable_id": 3,' +
              '"client_identifier": "be0d7649-c510-4a5b-a1de-17a56224eda7"' +
            '},' +
            '"captured_user_id": null,' +
            '"pending_job_id": 1500715,' +
            '"requesting_user": {' +
              '"name": "Han Duet",' +
              '"email": "hduet@test.com",' +
              '"org": {' +
                '"id": 200016,' +
                '"name": "Capture Request Test Job",' +
                '"preferences": {' +
                  '"external_identifier_label": "Lead Number",' +
                  '"external_identifier_required": false' +
                '}' +
              '}' +
            '},' +
            '"org_id": 200016' +
          '}'
          
        );
        res.setStatusCode(201);
        return res;
    }

}