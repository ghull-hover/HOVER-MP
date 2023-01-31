global class MockWebhookConfigCreationResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
            '{' +
            '"id": 4,' +
            '"owner_id": 10,' +
            '"owner_type": "Partner",' +
            '"url": "https://example.com/api/hover/v1/webhook",' +
            '"verified_at": null,' +
            '"content_type": "json",' +
            '"hmac_secret": "CvEbyJ1y0bOmg7YmPwLh9AgLHRzgBJysIpuRb7cP5GsyAF/167+VlgLGnzmjvxfIiStnQBpuydDgbURAudSoig==",' +
            '"last_error": null,' +
            '"created_at": "2017-11-03T02:39:07.221Z",' +
            '"updated_at": "2017-11-03T02:39:07.221Z"' +
          '}' 
          
        );
        res.setStatusCode(201);
        return res;

    }
}