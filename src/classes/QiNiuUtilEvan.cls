public with sharing class QiNiuUtilEvan {

    
    FINAL STRING SECRETKEY = 'zUYHgWEqevP4uNwVKVDXux2NXW7PRI4Ijbs5rFXx';
    FINAL STRING ACCESSKEY = 'ivEa4_Lh31WM-9XeuwPA-i4EaRiBpNLipUL5TdAg';

    String scope;
    Long deadline;
 
    public QiNiuUtilEvan()
    {
        deadline = DateTime.now().addHours(1).getTime()/1000;
    }
    public String generateUploadToken(String fileName)
    {
        scope = 'qiniuforce:' + fileName;
        //PutPolicy putPolicy = new PutPolicy(SCOPE, deadline, returnUrl, returnBody);
        PutPolicy putPolicy = new PutPolicy(scope, deadline);
        String policyToJson = JSON.serialize(putPolicy);

        System.debug('*************'+policyToJson+'*************');
        String encodedPolicy = EncodingUtil.base64Encode(Blob.valueOf(policyToJson));
        System.debug('*************'+encodedPolicy+'*************');
        Blob sign = crypto.generateMac('hmacSHA1', Blob.valueOf(encodedPolicy), Blob.valueOf(SECRETKEY));
        String encodedSign = EncodingUtil.base64Encode(sign);
        System.debug('*************'+encodedSign+'*************');
        String uploadToken = ACCESSKEY + ':' + encodedSign + ':' + encodedPolicy;
        return uploadToken;
    }

    public String generateDownloadToken(String fileName)
    {
        String downloadToken;
        return downloadToken;
    }

    public void uploadFile()
    {
        FeedItem feed = getFile();
        String token = 'ivEa4_Lh31WM-9XeuwPA-i4EaRiBpNLipUL5TdAg:DOFHegh7TBUzHxMKM1I4fcrlHb8=:eyJzY29wZSI6InFpbml1Zm9yY2UiLCJkZWFkbGluZSI6MTQyMjUyMzE3MX0=';
        //String token = generateUploadToken(feed.ContentFileName);
        String boundary = '-----<s1312314124>';
        String frontier = '--' + boundary;
        String fileName = feed.ContentFileName;
        System.debug('&&&&&&&&&&&&&&&&'+fileName+'&&&&&&&&&&&&&&&');
        String fileBody = EncodingUtil.base64Encode(feed.ContentData);
        String bodyText = frontier + '\r\n' + 
        'Content-Disposition: form-data; name="token"' + '\r\n' + '\r\n' +  token  + '\r\n' + frontier + '\r\n' +
        'Content-Disposition: form-data; name="key"' + '\r\n' + '\r\n' + 'fileName' + '\r\n' + frontier + '\r\n' +
        'Content-Disposition: form-data; name="x:username"' + '\r\n' + '\r\n' + '\r\n' +
        'Content-Disposition: form-data; name="file"; fileName=' + '"' + fileName + '"' +'\r\n' + 
        'Content-Type: application/octet-stream' + '\r\n' + 'Content-Transfer-Encoding: binary' + '\r\n' + '\r\n' + '*************' + '\r\n' + frontier + '--';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://upload.qiniu.com');
        req.setMethod('POST');
        req.setHeader('Host','upload.qiniu.com');
        req.setHeader('Content-Type','multipart/form-data; boundary=' + boundary);
        req.setHeader('Content-Length',String.valueof(bodyText.length()));
        req.setBody(bodyText);
        System.debug('request body:' + '\r\n' + bodyText);

        HttpResponse res = new HttpResponse();
        Http http = new Http();
        res = http.send(req);
        System.debug(res.getBody());
    }

    public FeedItem getFile()
    {
        FeedItem feed = new FeedItem();
        List<FeedItem> feedItems = [select Id, Body, ContentData, ContentSize, ContentFileName from FeedItem limit 1000];
        for(FeedItem item : feedItems)
        {
            if(item.ContentSize > 0)
            {
                feed = item;
            }
        }
        return feed;
    }

    //class PutPolicy
    //{
    //    String scope;
    //    Long deadline;
    //    String returnUrl;
    //    String returnBody;
    //    PutPolicy(String scope, Long deadline, String returnUrl, String returnBody)
    //    {
    //        this.scope = scope;
    //        this.deadline = deadline;
    //        this.returnUrl = returnUrl;
    //        this.returnBody = returnBody;
    //    } 
    //}
    class PutPolicy
    {
        String scope;
        Long deadline;
        PutPolicy(String scope, Long deadline)
        {
            this.scope = scope;
            this.deadline = deadline;
        } 
    }
}