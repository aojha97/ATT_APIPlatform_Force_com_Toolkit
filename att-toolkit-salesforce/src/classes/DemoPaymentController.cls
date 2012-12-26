virtual public class DemoPaymentController {
    
    public String chosenBookId{ get; set; }
    public String mTransactionId{ get; set; }
    public boolean testExceptionMode { get; set; }
    
    private static final String merchantIdParamName = 'merchantTrId';
    private AttClientCredentialsAuthorization auth;
     
    public class Book {
        public String name { get; set; }
        public String author { get; set; }
        public Decimal price { get; set; }
        public String imageFileName { get; set; }
        public String productId { get; set; }
        public String description { get; set; }
        
        public Book(String name, String author, Decimal price, String imageFileName, String productId, String description){
            this.name = name;
            this.author = author;
            this.price = price;
            this.imageFileName = imageFileName;
            this.productId = productId;
            this.description = description;
        }
    } 
    
    public DemoPaymentController(){
        auth = new AttClientCredentialsAuthorization(ServiceConstants.ScopeType.PAYMENT);
    }
    
    public void addTransactionCode(){
    	String transactionAuthCode;
    	try {
            transactionAuthCode = AttSinglePaymentTransaction.handleRedirectUrlForAuthorizationCode();    
        } catch (AttException ex) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(msg);
            return;
        }  
    	String merchantId = ApexPages.currentPage().getParameters().get(merchantIdParamName);
        try {
            DemoSinglepayHistory__c paymentRecord = [SELECT AuthCode__c FROM DemoSinglepayHistory__c  WHERE MerchantTransactionId__c = :merchantId LIMIT 1];
            if (paymentRecord !=null && String.isNotBlank(transactionAuthCode) && String.isBlank(paymentRecord.AuthCode__c)) {
                paymentRecord.AuthCode__c = transactionAuthCode;
                update paymentRecord; 
            } 
            
        } catch (Exception ex) {
        }
    } 
    
    public List<Book> getBooks(){
        List<Book> books = new List<Book>();
        books.add(new Book('Concrete Mathematics: A Foundation for Computer Science (2nd Edition)', 'Ronald L. Graham, Donald E. Knuth, Oren Patashnik',
                1.99, 'ConcrMathCover.jpg', 'PID001', 'Concrete Mathematics'));
        books.add(new Book('Art of Computer Programming, Volume 1: Fundamental Algorithms (3rd Edition)', 'Donald E. Knuth', 0.99, 'ArtOfCompCover.jpg', 'PID002', 'Art of Computer'));
        books.add(new Book('Selected Papers on the Analysis of Algorithms', 'Donald E. Knuth', 3.99, 'SelectedPapersOnTheAnalysisOfAlgorithmsCover.jpg', 'PID003', 'Selected Papers'));
        books.add(new Book('Literate Programming (Center for the Study of Language and Information - Lecture Notes) ', 'Donald E. Knuth', 0.98, 'Literate_Programming_book_cover.jpg', 'PID004', 'Literate Programming'));
        books.add(new Book('Selected Papers on Computer Science (Center for the Study of Language and Information - Lecture Notes)', 'Donald E. Knuth', 26.00, 'SelectedPapers.jpg', 'PID005', 'S.P. on Computer Science'));     
        return books;
    }
    
    public Pagereference buyBook() {
        PageReference pageRef;
        Book chosenBook;
        for (Book curBook : getBooks()) {
                if (chosenBookId.equals(curBook.productId)) {
                        chosenBook = curBook;
                }               
        }
        AttPayload bookPayload = new AttPayload();
        
        mTransactionId = 'MerchTransId' + Math.roundToLong(Math.random() * 1000000000) + 'item' + Math.roundToLong(Math.random() * 1000000000);
        
        bookPayload.Amount = chosenBook.price;
        bookPayload.Description = chosenBook.description;
        bookPayload.MerchantProductId = chosenBook.productId;
        bookPayload.Category = 1;
        bookPayload.MerchantTransactionId = mTransactionId;
        Map<String, String> params = new Map<String, String> {merchantIdParamName => mTransactionId};        
        if (!Test.isRunningTest()) {
        	bookPayload.MerchantPaymentRedirectUrl = UtilityFactory.getUtils().addParametersToUrl(Url.getCurrentRequestUrl().toExternalForm(), params, false);
        }
        
        try {
                AttSinglePaymentTransaction singlePaymentTransaction = new AttSinglePaymentTransaction(bookPayload, auth);
                pageRef =  singlePaymentTransaction.start();
        } catch (AttException ex) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
        ApexPages.addMessage(msg);            
        return null; 
        }    
        
        saveToOrderHistory(mTransactionId, chosenBook);
        return pageRef;
    }
    
    private void saveToOrderHistory(String mTransactionId, Book book){
        DemoSinglepayHistory__c paymentRecord = new DemoSinglepayHistory__c();
        paymentRecord.MerchantTransactionID__c = mTransactionId;
        paymentRecord.TransactionDate__c = Datetime.now();
        paymentRecord.Price__c = book.price;
        paymentRecord.Product__c = book.name;
        insert paymentRecord;        
    }  
    
    public Pagereference redirectToOrderHistory(){
        return Page.att_single_payment_history_demo_page;
    }
    
    public static testmethod void testController() {
        DemoPaymentController controller = new DemoPaymentController();
        controller.chosenBookId = 'PID002';
        
        AttPayload payload = new AttPayload();
        payload.Amount = 3.1;
        payload.Category = 1;
        payload.Description = 'Some product';
        payload.MerchantTransactionId = '11111';
        payload.MerchantProductId = '22222';
        payload.MerchantPaymentRedirectUrl = 'http://localhost';
        AttSinglePaymentTransaction trans = new AttSinglePaymentTransaction(payload, TestHttpMockFactory.getCCAuthMock());
        TestHttpMockFactory.SingleRequestMock redirect = new TestHttpMockFactory.SingleRequestMock(302, 'OK', Blob.valueOf('test'), new Map<String, String>{
            'Location' => 'http://att.com'
        });
        SecurityTokenProvider tokenProvider = UtilityFactory.getSecurityTokenProvider();
        Att_Application_Security_Key__c applicationKey = tokenProvider.getApplicationKey();
        String params =  '?SignedPaymentDetail=' + 'JTdCJTIyU2lnbmVkczMzQ5NjIlN0QlN0Q' + 
                '&Signature=' + 'kczMzQ5NjIlN' + '&clientid=' + applicationKey.API_Key__c;
        
        HttpCalloutMock multimock = new TestHttpMockFactory.MultiRequestMock(new Map<String,HttpCalloutMock>{
            ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.NOTARY) =>   TestHttpMockFactory.getSuccessfulCreatedHttpMock('{"SignedDocument": "JTdCJTIyU2lnbmVkczMzQ5NjIlN0QlN0Q","Signature": "kczMzQ5NjIlN"}'),
            ServiceConstants.getUrlByServiceType(ServiceConstants.ServiceType.NEW_TRANSACTION) + params =>   redirect  
        });
        
        Test.setMock(HttpCalloutMock.class, multimock);
        PageReference reference = controller.buyBook();
        System.assertEquals('http://att.com', reference.getUrl());
        
        ApexPages.currentPage().getParameters().put('success', 'true');
        ApexPages.currentPage().getParameters().put('TransactionAuthCode', 'testTransactionAuthCode');
        ApexPages.currentPage().getParameters().put(merchantIdParamName, '001122');
        DemoSinglepayHistory__c paymentRecord = new DemoSinglepayHistory__c();
        paymentRecord.MerchantTransactionID__c = '001122';
        paymentRecord.TransactionDate__c = Datetime.now();
        paymentRecord.Price__c = 1.99;
        paymentRecord.Product__c = 'Art of Computer';
        insert paymentRecord; 
        controller.addTransactionCode();
        
        ApexPages.currentPage().getParameters().clear();
        ApexPages.currentPage().getParameters().put('success', 'false');
        ApexPages.currentPage().getParameters().put('faultCode', 'testFaultCode');
        ApexPages.currentPage().getParameters().put('faultDescription', 'testFaultDescription');
        ApexPages.currentPage().getParameters().put('faultMessage', 'testFaultMessage');
        controller.addTransactionCode();
        System.assertEquals(ApexPages.getMessages().size(), 1);
        System.assertNotEquals(ApexPages.getMessages().get(0), null);
        System.assertEquals(ApexPages.getMessages().get(0).getSummary(), 'Fault code: testFaultCode Fault Description: testFaultDescription Fault Message: testFaultMessage');
        
        controller.redirectToOrderHistory();
    }
}