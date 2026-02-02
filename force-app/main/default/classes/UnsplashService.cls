public with sharing class UnsplashService {
    public static String getFirstImageUrl(String query) {
        if (String.isBlank(query)) return null;

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:Unsplash/search/photos?query=' + EncodingUtil.urlEncode(query, 'UTF-8') + '&per_page=1');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            System.debug('Unsplash status=' + res.getStatusCode() + ' body=' + res.getBody());
            return null;
        }

        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        List<Object> results = (List<Object>) body.get('results');
        if (results == null || results.isEmpty()) return null;

        Map<String, Object> first = (Map<String, Object>) results[0];

        Map<String, Object> urls = (Map<String, Object>) first.get('urls');

        if (urls == null) return null;

        return (String) urls.get('small');
    }
}