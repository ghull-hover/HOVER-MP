global class MockCreateJobJSONFullResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'+
            '"job": {'+
                '"id": 12345,'+
                '"user_name": "jseanalbright+qbranch7@gmail.com",'+
                '"user_id": 1025,'+
                '"location_line_1": "123 HOVER Way",'+
                '"location_line_2": null,'+
                '"location_city": "San Francisco",'+
                '"location_region": "California",'+
                '"location_postal_code": "94109",'+
                '"location_country": null,'+
                '"state": "uploading"'+
           '}' +
        '}');
        res.setStatusCode(201);
        return res;
    }

}