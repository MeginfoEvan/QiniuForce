@isTest(SeeAllData=true)
public class QiNiuUtilTest {
	/*
	@isTest static void test_method_one() {
		QiNiuUtil qiniu = new QiNiuUtil();
		String s = qiniu.testEncodedHMAC('eyJzY29wZSI6Im15LWJ1Y2tldDpzdW5mbG93ZXIuanBnIiwiZGVhZGxpbmUiOjE0NTE0OTEyMDAsInJldHVybkJvZHkiOiJ7XCJuYW1lXCI6JChmbmFtZSksXCJzaXplXCI6JChmc2l6ZSksXCJ3XCI6JChpbWFnZUluZm8ud2lkdGgpLFwiaFwiOiQoaW1hZ2VJbmZvLmhlaWdodCksXCJoYXNoXCI6JChldGFnKX0ifQ==','MY_SECRET_KEY');
		System.assertEquals('wQ4ofysef1R7IKnrziqtomqyDvI=',s);
	}

	@isTest static void testGenerateToken()
	{
		String token;
		QiNiuUtil upCtrl = new QiNiuUtil();
		token = upCtrl.generateToken();
		System.assertEquals('iN7NgwM31j4-BZacMjPrOQBs34UG1maYCAQmhdCV:LTIDlLIX6XSVFbOZNbtfQbfctCg=:eyJzY29wZSI6InF0ZXN0YnVja2V0IiwicmV0dXJuVXJsIjoiaHR0cDovL3d3dy5iYWlkdS5jb20iLCJyZXR1cm5Cb2R5Ijoie1wibmFtZVwiOiAkKGZuYW1lKSxcInNpemVcIjogJChmc2l6ZSksXCJ3XCI6ICQoaW1hZ2VJbmZvLndpZHRoKSxcImhcIjogJChpbWFnZUluZm8uaGVpZ2h0KSxcImhhc2hcIjogJChldGFnKX0iLCJkZWFkbGluZSI6MTQyMjI0ODU4M30=',token);
	}
	*/
	@isTest static void testSendRequest()
	{
		QiniuUtil q = new QiniuUtil();
		String a = q.sendRequest();
		System.assert(a != null);
	}
}