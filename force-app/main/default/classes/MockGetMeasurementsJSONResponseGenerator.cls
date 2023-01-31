global class MockGetMeasurementsJSONResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
            '"area": {' +
                '"facades": {' +
                    '"siding": 2386,' +
                    '"other": 223' +
                '},' +
                '"openings": {' +
                    '"siding": 243,' +
                    '"other": 30' +
                '},' +
                '"unknown": {' +
                    '"siding": null,' +
                    '"other": 0' +
                '},' +
                '"total": {' +
                    '"siding": 2629,' +
                    '"other": 253' +
                '}' +
            '},' +
            '"results": [' +
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
        '}');
        res.setStatusCode(200);
        return res;
    }
}