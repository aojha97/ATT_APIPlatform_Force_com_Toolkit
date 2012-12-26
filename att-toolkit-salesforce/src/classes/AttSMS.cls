/*
 * @description AttSMS represents one SMS message for AT&T SMS send service.
 */
 public virtual class AttSMS {
    
    /*
    * @description The destination phone number 
    */
    public String phoneNumber { get; set; }
    
    /*
    * @description The text of the message being sent. Must be less than 4096 characters.
    */    
    public String messageText { get; set; }
}