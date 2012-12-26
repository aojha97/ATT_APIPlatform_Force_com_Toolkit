@isTest
public class TestUtilsImpl {
	
	static testmethod void testUrlUtils() {
		
		// test empty parameters
		Map<String, String> params = new Map<String, String> {
			'param1' => '',
			'param2' => null
		};
		String paramsStr = UtilityFactory.getUtils().convertMapToParametersString(params);
		System.assertEquals('', paramsStr);
		String urlStr = UtilityFactory.getUtils().createUrlParametersString(params);
		System.assertEquals('', urlStr);
		String urlWithParams = UtilityFactory.getUtils().addParametersToUrl('https://api.att.com', params);
		System.assertEquals('https://api.att.com', urlWithParams);
		
		// test single parameter
		params.put('param4', 'value4');
		paramsStr = UtilityFactory.getUtils().convertMapToParametersString(params);
		System.assertEquals('param4=value4', paramsStr);
		urlStr = UtilityFactory.getUtils().createUrlParametersString(params);
		System.assertEquals('?param4=value4', urlStr);
		urlWithParams = UtilityFactory.getUtils().addParametersToUrl('https://api.att.com', params);
		System.assertEquals('https://api.att.com?param4=value4', urlWithParams);
		String urlWithEncodedParams = UtilityFactory.getUtils().addParametersToUrl('https://api.att.com', params, true);
		System.assertEquals('https://api.att.com' + Encodingutil.urlEncode('?param4=value4', 'UTF-8'), urlWithEncodedParams);
		
		// test multiple parameters
		params.put('param5', 'value5');
		paramsStr = UtilityFactory.getUtils().convertMapToParametersString(params);
		System.assert(paramsStr.contains('param4=value4'));
		System.assert(paramsStr.contains('param5=value5'));
		urlStr = UtilityFactory.getUtils().createUrlParametersString(params);
		System.assert(urlStr.startsWith('?'));
		System.assert(urlStr.contains('param4=value4'));
		System.assert(urlStr.contains('param5=value5'));
		urlWithParams = UtilityFactory.getUtils().addParametersToUrl('https://api.att.com', params);
		System.assert(urlWithParams.startsWith('https://api.att.com?'));
		System.assert(urlWithParams.contains('param4=value4'));
		System.assert(urlWithParams.contains('param5=value5'));
		urlWithEncodedParams = UtilityFactory.getUtils().addParametersToUrl('https://api.att.com', params, true);
		System.assert(urlWithEncodedParams.contains(Encodingutil.urlEncode('param4=value4', 'UTF-8')));
		System.assert(urlWithEncodedParams.contains(Encodingutil.urlEncode('param5=value5', 'UTF-8')));
	}
	
	static testmethod void testHttpCallUtils() {
		Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock(''));
		UtilityFactory.getUtils().execute(new HttpRequest());
	}
}