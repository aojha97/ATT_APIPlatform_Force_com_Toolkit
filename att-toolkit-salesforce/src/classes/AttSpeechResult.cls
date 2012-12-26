/**
* @description Represents AT&T speech service respose body (JSON).
*/
public virtual class AttSpeechResult {

	/**
	* @description Property for setting/getting Recognition instance.
	*/
	public Recognition recognition { get; set; }

	/**
	* @description Represents Recognition structure (see AT&T speech service reference documentation).
	*/
	public class Recognition {
		
		/**
	  	 * @description Specifies the response identifier.
		 */
		public String responseId { get; set; }
		
		/**
	  	 * @description Specifies the results of the transcription.
		 */		
		public List<NBest> nBest { get; set; }
	}

	/**
	* @description Represents NBest structure (see AT&T speech service reference documentation).
	*/
	public class NBest {
		
		/**
	  	 * @description Specifies the confidence scores for each of the values in the Words parameter.
		 */		
		public List<Double> wordScores { get; set; }
		
		/**
	  	 * @description Specifies the confidence value of the Hypothesis parameter.
		 */		
		public Double confidence { get; set; }
		
		/**
	  	 * @description Specifies the assessment of utterance or result quality and the recommended treatment of the Hypothesis parameter value in a machine readable format. 
		 */		
		public String Grade { get; set; }
		
		/**
	  	 * @description Specifies the resulting text according to the output domain of the app package. 
		 */		
		public String ResultText { get; set; }
		
		/**
	  	 * @description Specifies the words of the ResultText parameter separated into strings.
		 */		
		public List<String> Words { get; set; }
		
		/**
	  	 * @description Specifies the language used to decode the Hypothesis parameter value.
		 */		
		public String LanguageId { get; set; }
		
		/**
	  	 * @description Specifies the transcription of the audio.
		 */		
		public String Hypothesis { get; set; }
	}
	
	/**
	* @description Parses AT&T speech service respose body (JSON).
	* @param auth - String representation of responce (JSON).
	* @return AttSpeechResult instance.
	*/
	public static AttSpeechResult parse(String json) {
		return (AttSpeechResult) System.JSON.deserialize(json, AttSpeechResult.class);
	}
}