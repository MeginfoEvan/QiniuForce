public with sharing class QiNiuUtil {
    FINAL STRING SCOPE = 'testgeorge';
    FINAL STRING SECRETKEY = 'm2FkS57nIlsCH-oPTs5fx-hxrBJXinCc86xsnzPK';
    FINAL STRING ACCESSKEY = 'LcLorpL24SH1XF0_wAbrwZG5IDiLDlojn2FX0Bn-';

    //FINAL STRING SCOPE = 'testuploadqiniuspace:testImg1.jpg';
    //FINAL STRING SECRETKEY = '6QTOr2Jg1gcZEWDQXKOGZh5PziC2MCV5KsntT70j';
    //FINAL STRING ACCESSKEY = 'iN7NgwM31j4-BZacMjPrOQBs34UG1maYCAQmhdCV';

    Long deadline;
    //String returnUrl = 'http://www.baidu.com';
    //String returnBody = '{"name": $(fname),"size": $(fsize),"w": $(imageInfo.width),"h": $(imageInfo.height),"hash": $(etag)}';
    
    public QiNiuUtil() {}

    public String generateToken()
    {
        deadline = DateTime.now().addHours(1).getTime()/1000;
        //deadline = 1422248583;
        System.debug('################deadline' + deadline);
        PutPolicy putPolicy = new PutPolicy(SCOPE, deadline);
        String policyToJson = JSON.serialize(putPolicy);
                System.debug('********1.policyToJson:' + policyToJson + '**********');
        String encodedPolicy = EncodingUtil.base64Encode(Blob.valueOf(policyToJson));
                System.debug('********2.encodedPolicy:' + encodedPolicy + '**********');
        Blob sign = crypto.generateMac('hmacSHA1', Blob.valueOf(encodedPolicy), Blob.valueOf(SECRETKEY));
                System.debug('********3.sign:' + sign + '**********');
        String encodedSign = EncodingUtil.base64Encode(sign);
                System.debug('********4.encodedSign:' + encodedSign + '**********');

        //String encodedSign = testEncodedHMAC(encodedPolicy, SECRETKEY);
        System.debug('********4.encodedSign:' + encodedSign + '**********');
        String uploadToken = ACCESSKEY + ':' + encodedSign + ':' + encodedPolicy;
                System.debug('********5.uploadToken:' + uploadToken + '**********');
        return uploadToken;
    }

    public String getDownloadToken(String myBucket, String myFileNa)
    {
        deadline = DateTime.now().addHours(1).getTime()/1000;
        String downloadUrl = 'http://' + myBucket + '.qiniudn.com/' + myFileNa;
        downloadUrl += '?e=' + deadline;

        Blob sign = Crypto.generateMac('hmacSHA1', Blob.valueOf(downloadUrl), Blob.valueOf(SECRETKEY));
        String encodedSign = EncodingUtil.base64Encode(sign);

        String token = encodedSign + ':' + ACCESSKEY;

        String realDownloadUrl = downloadUrl + '&token=' + token;
        return realDownloadUrl;
    }

    public String getDownloadToken(String myFileName)
    {
        deadline = DateTime.now().addHours(1).getTime()/1000;
        String myFile = EncodingUtil.urlEncode(myFileName, 'UTF-8');
        String downloadUrl = 'http://7u2r2z.com1.z0.glb.clouddn.com/' + myFile;
        downloadUrl += '?e=' + deadline;

        Blob sign = Crypto.generateMac('hmacSHA1', Blob.valueOf(downloadUrl), Blob.valueOf(SECRETKEY));
        String encodedSign = EncodingUtil.base64Encode(sign);

        String token = ACCESSKEY + ':' + encodedSign;

        //downloadUrl = 'http://7u2r2z.com1.z0.glb.clouddn.com/' + myFile + '?e=' + deadline;
        String realDownloadUrl = downloadUrl + '&token=' + token;
        return realDownloadUrl;
    }

    public String testEncodedHMAC(String policy, String hashKey)
    {
        //String policy = 'eyJzY29wZSI6Im15LWJ1Y2tldDpzdW5mbG93ZXIuanBnIiwiZGVhZGxpbmUiOjE0NTE0OTEyMDAsInJldHVybkJvZHkiOiJ7XCJuYW1lXCI6JChmbmFtZSksXCJzaXplXCI6JChmc2l6ZSksXCJ3XCI6JChpbWFnZUluZm8ud2lkdGgpLFwiaFwiOiQoaW1hZ2VJbmZvLmhlaWdodCksXCJoYXNoXCI6JChldGFnKX0ifQ==';
        //String hashKey = 'MY_SECRET_KEY';
        Blob s = crypto.generateMac('hmacSHA1', Blob.valueOf(policy), Blob.valueOf(hashKey));
        String encodedSign = EncodingUtil.base64Encode(s);
        return encodedSign;
    }

    class PutPolicy
    {
        String scope;
        Long deadline;
        //String returnUrl;
        //String returnBody;
        PutPolicy(String scope, Long deadline)
        {
            this.scope = scope;
            this.deadline = deadline;
            //this.returnUrl = returnUrl;
            //this.returnBody = returnBody;
        }  
    }

    public String FileName { get; set; }
    public String Body 
    {
        get
        {
            Blob b = getImg();
            return getRequestBody(true, b);
        }
        set;
    }
    public String DownBody 
    {
        get
        {
            return null;
        }
        set;
    }
  
    public String getRequestBody(Boolean IsOnly, Blob fileBody)
    {
        String requestBody;
        if(IsOnly)
        {
            String frontier = 'akb48ljj1233613faslfnsefnalfefjslf';
            requestBody = '--' + frontier + '\n';
            requestBody += 'Content-Disposition: form-data; name=\"token\"\n';
            requestBody += generateToken() + '\n';
            requestBody += '--' + frontier + '\n';
            requestBody += 'Content-Disposition: form-data; name=\"key\"\n';
            requestBody += 'georgeFile\n';
            requestBody += '--' + frontier + '\n';
            requestBody += 'Content-Disposition: form-data; name=\"file\"; filename=\"testImg1\"\n';
            requestBody += 'Content-Type: application/octet-stream\n';
            requestBody += 'Content-Transfer-Encoding: binary\n';

            //add File Detail
            String fileDetail = EncodingUtil.base64Encode(fileBody);
            requestBody += fileDetail + '\r\n';
            requestBody += '--' + frontier + '--';
            System.debug(requestBody);
        }
        return requestBody;
    }
    
    public static Blob getImg()
    {
        List<FeedItem> feedItems = [select Id, Body, ContentData, ContentSize, ContentFileName from FeedItem ];
        Blob img;
        for(FeedItem item : feedItems)
        {
            if(item.ContentSize > 0)
            {
                System.debug('%%%%%' + item.ContentData);
                img = item.ContentData;
                break;
            }
        }
        System.debug('%%%%%');
        System.debug(img == null);
        return img;
    }

    public String sendRequest()
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //Set HTTPRequest Method
        req.setMethod('POST');
        //Set HTTPRequest header properties
        req.setEndpoint('http://up.qiniu.com');
        req.setHeader('Host','upload.qiniu.com');
        req.setHeader('content-type', 'multipart/form-data; boundary=<123456>');
        
        System.debug('caonima');
        
        req.setBody(Body);
        req.setHeader('Content-Length', '70000');
        HttpResponse res = new HttpResponse();
        try
        {
            res = h.send(req);
            System.debug('%%%%%%Status' + res.getStatusCode());
        }
        catch(Exception ex)
        {

        }
        System.debug('%%%%%%' + res.getBody());
        return res.getBody();
    }

    //Send Get Request to get some file
    public String sendGetRequest(Boolean IsSelf)
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');

        if(IsSelf)
        {
            //Set HTTPRequest Method
            System.debug('IsSelf%%%%%%%%');
            req.setEndpoint(getDownloadToken('testImg1.png'));
        }
        else
        {
            System.debug('NotIsSelf%%%%%%%%');
            req.setEndpoint('http://7u2noj.com1.z0.glb.clouddn.com/george');
        }

        HttpResponse res = new HttpResponse();
        try
        {
            res = h.send(req);
            System.debug('$$$$$%%%%%' + res.getStatusCode());
            //System.debug('$$$$$%%%%%' + res.getBody());
        }
        catch(Exception ex)
        {

        }
        return res.getBody();
    }

    public static void testSend()
    {
        QiniuUtil q = new QiniuUtil();
        String a = q.sendRequest();
        System.debug(a != null);
    }

    public static void testSendGet()
    {
        QiniuUtil q = new QiniuUtil();
        String a = q.sendGetRequest(true);
        System.debug('%%%%%%' + a);
    }

    public static void testSendNotSelf()
    {
        QiniuUtil q = new QiniuUtil();
        String a = q.sendGetRequest(false);
        System.debug('$$$$$$' + a);
        Blob img = Blob.valueOf(a);
    }

    public String Data{ get; set; }

    public PageReference testShow()
    {
        QiniuUtil q = new QiniuUtil();
        Data = EncodingUtil.base64Encode(Blob.valueOf(q.sendGetRequest(false)));
        return null;
    }
}