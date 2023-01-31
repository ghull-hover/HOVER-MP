global class MockGetJobs implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String jobs = '{' +
           ' "pagination": {' +
               ' "current_page": 1,' +
               ' "total_pages": 2,' +
               ' "total": 47' +
               '},' +
               ' "results": [' +
                    ' {' +
                        '"name": "Albright Standing Seam Roof",' +
                        '"deliverable_id": "2",' +
                        '"location_line_1": "123 HOVER Way",' +
                        '"location_line_2": null,' +
                        '"location_city": null,' +
                        '"location_region": null,' +
                        '"location_postal_code": null,' +
                        '"location_country": null,' +
                        '"location_lat": null,' +
                        '"location_lon": null,' +
                        '"id": 44918,' +
                        '"client_identifier": "9cca79f2-744e-4ac8-a0b4-759dacfc1407",' +
                        '"user_id": "12345"' + 
                    ' }' +
                ' ]' +
            '}';

        res.setBody(jobs);
        
        res.setStatusCode(200);
        return res;
    }
}