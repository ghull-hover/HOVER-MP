global class MockAssignJobToUserCallout implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String result = '';
        res.setBody(result);     
        res.setStatusCode(204);
        return res;
    }
}