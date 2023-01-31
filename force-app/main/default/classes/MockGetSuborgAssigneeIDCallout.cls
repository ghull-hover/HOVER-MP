global class MockGetSuborgAssigneeIDCallout implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String users = ' {"users": [' +
            '{' +
                '"id": 1195562,' +
                '"first_name": "Sean",' +
                '"last_name": "Albright",' +
                '"email": "sean.albright+unlockedsub@hoverinc.com",' +
                '"time_zone": "Pacific Time (US & Canada)",' +
                '"aasm_state": "activated"' +
            '}],' +
            ' "results": [' +
                    ' {' +
                        '"id": 1195491,' +
                        '"first_name": "Tom",' +
                        '"last_name": "Cruise",' +
                        '"email": "tomcruise@hoverinc.com",' +
                        '"time_zone": "Pacific Time (US & Canada)",' +
                        '"aasm_state": "activated",' +
                        '"updated_at": "2022-09-15T18:50:23.398Z",' +
                        '"created_at": "2022-08-25T00:00:45.015Z",' +
                        '"require_job_approval": false,' +
                        '"last_sign_in_at": "2022-09-15T18:50:23.396Z",' +
                        '"acl_template": "admin",' +
                        '"test_data": true' +
                         
                    ' }' +
                ' ]' +
            '}';
    

        res.setBody(users);
        
        res.setStatusCode(200);
        return res;
    }
}