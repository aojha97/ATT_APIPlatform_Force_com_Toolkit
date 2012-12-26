@isTest
public class TestAttPayload{
	
	public static MultiStaticResourceCalloutMock mock;
    
    static {
        Test.setMock(HttpCalloutMock.class, TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"SignedDocument": "JTdCJTIyU2lnbmVkczMzQ5NjIlN0QlN0Q","Signature": "kczMzQ5NjIlN"}'));
    }

    public static testmethod void testSign() {
        AttPayload payload = new AttPayload();
        AttSignedPayload signedPayload = payload.sign();
        System.assert(signedPayload != null);
        System.assert(signedPayload.SignedDocument == 'JTdCJTIyU2lnbmVkczMzQ5NjIlN0QlN0Q');
        System.assert(signedPayload.Signature == 'kczMzQ5NjIlN');
    }
}