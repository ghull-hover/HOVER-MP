global class MockGetJob implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String job = '{' +
            '"id": 44918,' +
            '"name": "Albright Standing Seam Roof",' +
            '"location_line_1": "123 HOVER Way",' +
            '"location_line_2": null,' +
            '"location_city": null,' +
            '"location_region": null,' +
            '"location_postal_code": null,' +
            '"location_country": null'    +
        '}';

        res.setBody(job);
        
        res.setStatusCode(200);
        return res;
    }
}