public with sharing class QiNiuUtil {
    FINAL STRING SECRETKEY = 'm2FkS57nIlsCH-oPTs5fx-hxrBJXinCc86xsnzPK';
    FINAL STRING ACCESSKEY = 'LcLorpL24SH1XF0_wAbrwZG5IDiLDlojn2FX0Bn-';
    String scope;
    Long deadline;
    Integer limitImagSize;
   
    public QiNiuUtil()
    {
        scope = 'testgeorge';
        deadline = DateTime.now().addHours(1).getTime()/1000;
        limitImagSize = 20480;
    }
/**--------------------------------upload-------------------------------------------------**/
    public String generateUploadToken(String key)
    {
        scope = scope + ':' + key;
        PutPolicy putPolicy = new PutPolicy(scope, deadline);
        String policyToJson = JSON.serialize(putPolicy);
        System.debug('*************'+policyToJson+'*************');
        String encodedPolicy = EncodingUtil.base64Encode(Blob.valueOf(policyToJson));
        System.debug('*************'+encodedPolicy+'*************');
        Blob sign = crypto.generateMac('hmacSHA1', Blob.valueOf(encodedPolicy), Blob.valueOf(SECRETKEY));
        String encodedSign = EncodingUtil.base64Encode(sign);
        System.debug('*************'+encodedSign+'*************');
        String uploadToken = ACCESSKEY + ':' + encodedSign.replace('/', '_').replace('+','-') + ':' + encodedPolicy;
        return uploadToken;
    }

    public void uploadFile(FeedItem feed)
    {
        String key = feed.ContentFileName;
        String token = generateUploadToken(key);
        String boundary = '-----s1312314124';
        String frontier = '--' + boundary;
        String fileName = feed.ContentFileName;
        System.debug('&&&&&&&&&&&&&&&&'+ fileName + '&&&&&&&&&&&&&&&&'+key+'&&&&&&&&&&&&&&&');
        String fileBody = EncodingUtil.base64Encode(feed.ContentData);
        String bodyText = frontier + '\r\n' + 
        'Content-Disposition: form-data; name="token"' + '\r\n' + '\r\n' + token + '\r\n' + frontier + '\r\n' +
        'Content-Disposition: form-data; name="key"' + '\r\n' + '\r\n' + key + '\r\n' + frontier + '\r\n' +
        'Content-Disposition: form-data; name="x:username"' + '\r\n' + '\r\n' + '\r\n' +  frontier + '\r\n' +
        'Content-Disposition: form-data; name="file"; fileName=' + '"' + fileName + '"' +'\r\n' + 
        'Content-Type: application/octet-stream' + '\r\n' + 'Content-Transfer-Encoding: binary' + '\r\n' + '\r\n' + fileBody + '\r\n' + frontier + '--';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://upload.qiniu.com');
        req.setMethod('POST');
        req.setHeader('Host','upload.qiniu.com');
        req.setHeader('Content-Type','multipart/form-data; boundary=' + boundary);
        req.setHeader('Content-Length',String.valueof(bodyText.length()+feed.ContentSize));
        req.setBody(bodyText);
        System.debug('request Content-Type:' + req.getHeader('Content-Type'));
        System.debug('request Content-Length:' + req.getHeader('Content-Length'));
        System.debug('request Body:' + '\r\n' + bodyText);

        HttpResponse res = new HttpResponse();
        Http http = new Http();
        res = http.send(req);
        System.debug(res.getBody());
    }

     public void uploadAllFile()
    {
        for(FeedItem feed : getAllFile())
        {
           uploadFile(feed);
        }
    }

     public List<FeedItem> getAllFile()
    {
        List<FeedItem> feedItems = new List<FeedItem>();
        for(FeedItem feed : [select Id, Body, ContentData, ContentSize, ContentFileName from FeedItem limit 1000])
        {
            if(feed.ContentSize > limitImagSize)
            {
                feedItems.add(feed);
            }
        }
        return feedItems;
    }

/**--------------------------------DownLoad-------------------------------------------------**/

    /**Send Get Request to download some file**/
    public Blob getImageBlob(Boolean IsSelf, String fileName, String domain)
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        //set height and width for image
        String operation = getOperation('100', '100'); 

        if(IsSelf)
        {
            //Set HTTPRequest Endpoint
            req.setEndpoint(getRealDownLoadUrlWithTokenCompress(fileName, domain, operation));
        }
        else
        {
            req.setEndpoint('http://' + domain + '/george');
        }

        HttpResponse res = new HttpResponse();
        try
        {
            res = h.send(req);
            List<String> headers = res.getHeaderKeys();
            for(String a : headers)
            {
                System.debug('KeyStart');
                System.debug( a + ': ' + res.getHeader(a));
            }
            System.debug(res.getStatusCode());
        }
        catch(Exception ex)
        {

        }
        return res.getBodyAsBlob();
    }

    public String getRealDownloadUrlWithTokenFull(String myFileName, String domain)
    {
        //String myFile = EncodingUtil.urlEncode(myFileName, 'UTF-8');
        String downloadUrl = 'http://' + domain + '/' + myFileName;
        downloadUrl += '?e=' + deadline;
        Blob sign = Crypto.generateMac('hmacSHA1', Blob.valueOf(downloadUrl), Blob.valueOf(SECRETKEY));
        String encodedSign = EncodingUtil.base64Encode(sign);
        
        encodedSign = encodedSign.replace('/', '_').replace('+', '-');
        
        String token = ACCESSKEY + ':' + encodedSign;
        //downloadUrl = 'http://7u2r2z.com1.z0.glb.clouddn.com/' + myFile + '?e=' + deadline;
        String realDownloadUrl = downloadUrl + '&token=' + token;
        return realDownloadUrl;
    }

    public String getRealDownLoadUrlWithTokenCompress(String myFileName, String domain, String operation)
    {
        //String myFile = EncodingUtil.urlEncode(myFileName, 'UTF-8');
        String downloadUrl = 'http://' + domain + '/' + myFileName;
        downloadUrl += '?' + operation + '&e=' + deadline;
        Blob sign = Crypto.generateMac('hmacSHA1', Blob.valueOf(downloadUrl), Blob.valueOf(SECRETKEY));
        String encodedSign = EncodingUtil.base64Encode(sign);
        
        encodedSign = encodedSign.replace('/', '_').replace('+', '-');
        
        String token = ACCESSKEY + ':' + encodedSign;
        //downloadUrl = 'http://7u2r2z.com1.z0.glb.clouddn.com/' + myFile + '?e=' + deadline;
        String realDownloadUrl = downloadUrl + '&token=' + token;
        return realDownloadUrl;
    }

    public static String getOperation(String height, String width)
    {
        //'imageView/2/h/100'
        String operation = 'imageView/2/h/' + height + '/w/' + width;
        return operation; 
    }

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