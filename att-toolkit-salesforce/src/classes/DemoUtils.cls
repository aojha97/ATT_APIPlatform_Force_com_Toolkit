public class DemoUtils {
	public static Pattern EMAIL_REGEXP_PATTERN = Pattern.compile('[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})');
	
	public static testmethod void test() {
    	Matcher emailAddrMatcher = DemoUtils.EMAIL_REGEXP_PATTERN.matcher('asdasdf asdf asdf.wwe@mail.com ');
    	System.assert(emailAddrMatcher.find());
    	System.assertEquals('asdf.wwe@mail.com', emailAddrMatcher.group(0).trim());
    }
}