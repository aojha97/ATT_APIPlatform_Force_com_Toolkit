@isTest
public class TestSecurityTokenProvider extends SecurityTokenProviderImpl {

    private String json;

    public TestSecurityTokenProvider(String json) {
        this.json = json;
    }

    public static testmethod void testGetShortcodeByName() {
        TestSecurityTokenProvider provider = new TestSecurityTokenProvider('');
        String shortcode = provider.getShortcodeByName('Default');

        System.assert(shortcode != null);
    }

}