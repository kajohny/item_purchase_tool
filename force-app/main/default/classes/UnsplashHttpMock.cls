@IsTest
global class UnsplashHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assert(
            req.getEndpoint() != null && req.getEndpoint().contains('/search/photos'),
            'Expected Unsplash search/photos endpoint, got: ' + req.getEndpoint()
        );

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');

        String body = 
            '{' +
            '  "total": 1,' +
            '  "total_pages": 1,' +
            '  "results": [' +
            '    {' +
            '    "id": "abc",' +
            '      "urls": {' +
            '        "small": "https://images.unsplash.com/photo-test-small"' +
            '      }' +
            '    }' +
            '  ]' +
            '}';

        res.setBody(body);
        return res;
    }
}