public with sharing class QiniuUtilGeorge {
	FINAL STRING SCOPE = 'testgeorge';
    FINAL STRING SECRETKEY = 'm2FkS57nIlsCH-oPTs5fx-hxrBJXinCc86xsnzPK';
    FINAL STRING ACCESSKEY = 'LcLorpL24SH1XF0_wAbrwZG5IDiLDlojn2FX0Bn-';
    Long deadline;
    /*
     *   get download url that
     */
    public String getRealDownLoadUrlWithTokenCompress(String myFileName, String domain, String operation)
    {
        deadline = DateTime.now().addHours(1).getTime()/1000;
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

    public String getRealDownloadUrlWithTokenFull(String myFileName, String domain)
    {
        deadline = DateTime.now().addHours(1).getTime()/1000;
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

    public static String getOperation(String height, String width)
    {
        //'imageView/2/h/100'
        String operation = 'imageView/2/h/' + height + '/w/' + width;
        return operation; 
    }

    //Send Get Request to download some file
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

    public String Img { get; set; }
    public PageReference testGeo()
    {
        QiniuUtilGeorge q = new QiniuUtilGeorge();
        Blob blo = q.getImageBlob(true, 'testImg1.png', '7u2r2z.com1.z0.glb.clouddn.com');
        //Decode the image file
        Img = EncodingUtil.base64Encode(blo);
        Img = EncodingUtil.urlDecode(Img, 'GB2312');
        return null;
    }
}