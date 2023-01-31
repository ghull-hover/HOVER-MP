global class Mock404 implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
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
            '}' +
        '}');
        res.setStatusCode(404);
        return res;

    }
}