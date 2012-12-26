public class DemoSpeechController {
        
    // File extensions
	private static String UPLOADED_FILE_TYPE_WAV = '.wav';
    private static String UPLOADED_FILE_TYPE_AMR = '.amr';
    
    public String debugBody {get; set;}
    
    public String clientToken {get; set; }
    
    public String fileName {get; set;}
    
    public String fileNameReal {get; set;}
    
    public Blob fileBlob {get; set;}
    
    // binding result values to page controls
    public String resGrade { get; set; }
    
    public String resConfidence { get; set; }
    
    public String resLanguageId { get; set; }
    
    public String resHypothesis { get; set; }
    
    public String resResultText { get; set; }
    
    public String resWordScores { get; set; }
    
    public AttClientCredentialsAuthorization auth { get; set; }
    
    private final System.Type TEST_CLASS = TestDemoSpeechController.class;

	/**
	*
	* Default constructor.
	*
	*/
	public DemoSpeechController () {
		init();
    	auth = new AttClientCredentialsAuthorization(ServiceConstants.ScopeType.SPEECH);
	}
	
	private void init() {
		fileName = '';
		fileNameReal = '';
		fileBlob = null;
	}
	
	private void clearControlsValue() {
		debugBody = '';
		
    	resGrade = '';
    	resConfidence = '';
    	resLanguageId = '';
    	resHypothesis = '';
    	resResultText = '';
    	resWordScores = '';
	}
    
    public void testAttServiceSpeech() {
    	clearControlsValue();
    	
    	if (fileNameReal == ''){
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select file before send request...');
    		ApexPages.addMessage(msg);
    		init();
    		return;
    	}

    	AttSpeech.FileType fileType = null;
		if (fileNameReal.toLowerCase().endsWith(UPLOADED_FILE_TYPE_WAV)) {
			fileType = AttSpeech.FileType.WAV;
		} else if (fileNameReal.toLowerCase().endsWith(UPLOADED_FILE_TYPE_AMR)) {
			fileType = AttSpeech.FileType.AMR;
		} else {
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Speech service support only \'wav\' and \'amr\' audio files.');
    		ApexPages.addMessage(msg);
    		init();
    		return;
		}

		if (fileBlob.size() > 3000000) {
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'File size must be not greater than 3,000,000 bytes.');
    		ApexPages.addMessage(msg);
    		init();
    		return;
		}
    	
    	AttSpeech speech = new AttSpeech(auth);
		speech.speechContext = AttSpeech.SpeechContext.GENERIC;
    	speech.fileType = fileType;
    	speech.fileBlob = fileBlob;
    	
    	AttSpeechResult response = null;
    	
    	try {
   			response = speech.convert();
		    debugBody = 'fileName=' + fileNameReal + 
		    	'\r\ncontentLegth=' + fileBlob.size() + '\r\n\r\n' + response;
    	} catch(Exception ex) {
    		System.debug(Logginglevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString());
	   		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
    		init();
    		return;
    	}
    	
		AttSpeechResult.Recognition recogn = response.Recognition;
		
		AttSpeechResult.NBest nbest = recogn.NBest[0];
    	
    	resGrade = nbest.Grade;
    	resConfidence = '' + nbest.Confidence;
    	resLanguageId = nbest.LanguageId;
    	resHypothesis = nbest.Hypothesis;
    	resResultText = nbest.ResultText;
    	
    	List<Double> scores = nbest.WordScores;
    	String resultScores = '';
    	for(Double value: scores){
    		resultScores += '' + value + ', ';
    	} 
    	resWordScores = resultScores;

        init();
    }	
}