@isTest
public class TestAttMIMMessageHeaders {

	static testmethod void testParse() {		
		String json = '{"MessageHeadersList":{"IndexCursor":"S:5:,t:4:,r:32:,I:1:,","Headers":[{"Favorite":true,"MessageId":"S6","Subject":"","Type":"MMS","To":["test@exadel.com"],"Received":"2012-10-12T11:27:06","Read":true,"MmsContent":[{"PartNumber":"0","ContentName":"template.smil","ContentType":"APPLICATION/SMIL"},{"PartNumber":"1","ContentName":"file0","ContentType":"IMAGE/JPEG"},{"PartNumber":"2","ContentName":"file1","ContentType":"AUDIO/X-WAVE"},{"PartNumber":"3","ContentName":"TEXTPART","ContentType":"TEXT/PLAIN"}],"From":"+16508631130","Direction":"OUT"},{"Favorite":false,"Text":"TimeTrack:1:aB9WjZghvWjRU/6MBQ==","MessageId":"r33","Type":"SMSTEXT","To":["+16508631130"],"Received":"2012-10-12T10:33:29","Read":false,"Direction":"IN","From":"28873569"}],"HeaderCount":"2"}}'; 
		AttMIMMessageHeaders mimHeaders = AttMIMMessageHeaders.parse(json);
		
		AttMIMMessageHeaders.MessageHeadersList headersList = mimHeaders.messageHeadersList;		
		System.assertEquals(headersList.headers.size(), 2);
		System.assertEquals(headersList.headerCount, 2);
		System.assertEquals(headersList.indexCursor, 'S:5:,t:4:,r:32:,I:1:,');
		
		AttMIMMessageHeaders.Headers firstHeader = headersList.headers.get(0);
		System.assertEquals(firstHeader.messageId, 'S6');
		System.assertEquals(firstHeader.fromAddress, '+16508631130');		
		System.assertEquals(firstHeader.to, new List<String>{'test@exadel.com'});
		System.assertEquals(firstHeader.subject, '');		
		System.assertEquals(firstHeader.received, Datetime.valueOf('2012-10-12 11:27:06'));
		System.assertEquals(firstHeader.text, null);
		System.assertEquals(firstHeader.favorite, true);
		System.assertEquals(firstHeader.read, true);
		System.assertEquals(firstHeader.messageType, 'MMS');		
		System.assertEquals(firstHeader.direction, 'OUT');
		
		List<AttMIMMessageHeaders.MmsContent> mssContent = firstHeader.mmsContent;
		System.assertEquals(mssContent.size(), 4);		
		System.assertEquals(mssContent.get(0).contentType, 'APPLICATION/SMIL');
		System.assertEquals(mssContent.get(0).contentName, 'template.smil');
		System.assertEquals(mssContent.get(0).partNumber, '0');
		System.assertEquals(mssContent.get(1).contentType, 'IMAGE/JPEG');
		System.assertEquals(mssContent.get(1).contentName, 'file0');
		System.assertEquals(mssContent.get(1).partNumber, '1');
		System.assertEquals(mssContent.get(2).contentType, 'AUDIO/X-WAVE');
		System.assertEquals(mssContent.get(2).contentName, 'file1');
		System.assertEquals(mssContent.get(2).partNumber, '2');
		System.assertEquals(mssContent.get(3).contentType, 'TEXT/PLAIN');
		System.assertEquals(mssContent.get(3).contentName, 'TEXTPART');
		System.assertEquals(mssContent.get(3).partNumber, '3');
		
		AttMIMMessageHeaders.Headers secondHeader = headersList.headers.get(1);
		System.assertEquals(secondHeader.messageId, 'r33');
		System.assertEquals(secondHeader.fromAddress, '28873569');		
		System.assertEquals(secondHeader.to, new List<String>{'+16508631130'});
		System.assertEquals(secondHeader.subject, null);		
		System.assertEquals(secondHeader.received, Datetime.valueOf('2012-10-12 10:33:29'));
		System.assertEquals(secondHeader.text, 'TimeTrack:1:aB9WjZghvWjRU/6MBQ==');
		System.assertEquals(secondHeader.favorite, false);
		System.assertEquals(secondHeader.read, false);
		System.assertEquals(secondHeader.messageType, 'SMSTEXT');		
		System.assertEquals(secondHeader.direction, 'IN');
		
		System.assertEquals(secondHeader.mmsContent, null);
	}
}