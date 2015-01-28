public with sharing class QiNiuUtilEvan {

    
    //FINAL STRING SECRETKEY = 'zUYHgWEqevP4uNwVKVDXux2NXW7PRI4Ijbs5rFXx';
    //FINAL STRING ACCESSKEY = 'ivEa4_Lh31WM-9XeuwPA-i4EaRiBpNLipUL5TdAg';

    FINAL STRING SECRETKEY = '6QTOr2Jg1gcZEWDQXKOGZh5PziC2MCV5KsntT70j';
    FINAL STRING ACCESSKEY = 'iN7NgwM31j4-BZacMjPrOQBs34UG1maYCAQmhdCV';

    String scope;
    Long deadline;
    //String returnUrl = 'http://www.baidu.com';
    //String returnBody = '{"name": $(fname),"size": $(fsize),"w": $(imageInfo.width),"h": $(imageInfo.height),"hash": $(etag)}';
    public QiNiuUtilEvan()
    {
        deadline = DateTime.now().addHours(1).getTime()/1000;
    }
    public String generateUploadToken(String fileName)
    {
        scope = 'qiniuforce:' + fileName + '.png';
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
        String token = generateUploadToken(feed.ContentFileName);
        String frontier = '--<splite>';
        String fileName = feed.ContentFileName;
        String fileBody = EncodingUtil.base64Encode(feed.ContentData);
        String bodyText = frontier + '\n' + 
        'Content-Disposition: form-data; name="token"' + '\n' +  token  + '\n' + frontier + '\n' +
        'Content-Disposition: form-data; name="file"; fileName=' + fileName  +'\n' + 
        'Content-Type: application/octet-stream' + '\n' + 'Content-Transfer-Encoding: binary' + '\n' + fileBody  + '\n' + frontier + '--';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://upload.qiniu.com');
        req.setMethod('POST');
        req.setHeader('Host','upload.qiniu.com');
        req.setHeader('Content-Type','multipart/form-data; boundary=<splite>');
        req.setHeader('Content-Length',String.valueof(bodyText.length()));
        req.setBody(bodyText);

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
                break;
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