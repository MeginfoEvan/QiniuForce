public with sharing class QiNiuUtil {
    //FINAL STRING SCOPE = 'qiniuforce';
    //FINAL STRING SECRETKEY = 'zUYHgWEqevP4uNwVKVDXux2NXW7PRI4Ijbs5rFXx';
    //FINAL STRING ACCESSKEY = 'ivEa4_Lh31WM-9XeuwPA-i4EaRiBpNLipUL5TdAg';

    FINAL STRING SCOPE = 'qtestbucket';
    FINAL STRING SECRETKEY = '6QTOr2Jg1gcZEWDQXKOGZh5PziC2MCV5KsntT70';
    FINAL STRING ACCESSKEY = 'iN7NgwM31j4-BZacMjPrOQBs34UG1maYCAQmhdCV';
    Long deadline;
    String returnUrl = 'http://www.baidu.com';
    String returnBody = '{"name": $(fname),"size": $(fsize),"w": $(imageInfo.width),"h": $(imageInfo.height),"hash": $(etag)}';
    
    public QiniuUtil(){}
    public String generateToken()
    {
        //deadline = DateTime.now().addHours(1).getTime()/1000;
        deadline = 1422244064;
        System.debug('################deadline' + deadline);
        PutPolicy putPolicy = new PutPolicy(SCOPE, deadline, returnUrl, returnBody);
        String policyToJson = JSON.serialize(putPolicy);
                System.debug('********1.policyToJson:' + policyToJson + '**********');
        String encodedPolicy = EncodingUtil.base64Encode(Blob.valueOf(policyToJson));
                System.debug('********2.encodedPolicy:' + encodedPolicy + '**********');
        Blob sign = crypto.generateMac('hmacSHA1', Blob.valueOf(encodedPolicy), Blob.valueOf(SECRETKEY));
                System.debug('********3.sign:' + sign + '**********');
        String encodedSign = EncodingUtil.base64Encode(sign);
                System.debug('********4.encodedSign:' + encodedSign + '**********');
        String uploadToken = ACCESSKEY + ':' + encodedSign + ':' + encodedPolicy;
                System.debug('********5.uploadToken:' + uploadToken + '**********');
        return uploadToken;
    }

    //public String returnJSON(String scope, Long deadline, String returnBody)
    //{
    //    returnBody = JSON.serialize(obj);
    //    return '{"scope":"' + scope + '","deadline":' + deadline + ',' + returnBody.remove('{').remove(' ');
    //}

    class PutPolicy
    {
        String scope;
        Long deadline;
        String returnUrl;
        String returnBody;
        PutPolicy(String scope, Long deadline, String returnUrl, String returnBody)
        {
            this.scope = scope;
            this.deadline = deadline;
            this.returnUrl = returnUrl;
            this.returnBody = returnBody;
        }  
    }

    public String FileName { get; set; }
}