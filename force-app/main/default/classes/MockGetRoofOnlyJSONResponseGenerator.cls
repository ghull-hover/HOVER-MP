global class MockGetRoofOnlyJSONResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String measurements = '{' +
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
        '  },' +
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
        '}';

        res.setBody(measurements);
        
        res.setStatusCode(200);
        return res;
    }
}