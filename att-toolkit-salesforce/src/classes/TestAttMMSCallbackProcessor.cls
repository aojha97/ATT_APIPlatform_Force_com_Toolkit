@IsTest
public class TestAttMMSCallbackProcessor {
		
	public static testmethod void testExtractMMSInfo() {
		String t = '<InboundMmsMessage>\r\n' +
					'<SenderAddress>tel:+18588228604</SenderAddress>\r\n' +
					'<Priority>Normal</Priority>\r\n' +
					'<Subject>Lorem ipsum</Subject>\r\n' +
					'</InboundMmsMessage>\r\n';
					
		AttMMS mms = AttMMSCallbackProcessor.extractMMSInfo(t);			
		System.assertEquals('+18588228604', mms.phoneNumber);
		System.assertEquals('Lorem ipsum', mms.subject);
		System.assertEquals('Normal', mms.priority);
	}
	
	public static testmethod void testParseRecursive() {
		String t;
		
		t = '--MIMEBoundary_a9b1d81c790c90ac6520a984a9e404cedce0f820564bd221\r\n' +
			'Content-Transfer-Encoding: 8bit\r\n' +
			'Content-ID: <rootpart@beta-api.att.com>\r\n' +
			'Content-Type: text/xml; charset=UTF-8\r\n' +
			'\r\n' +
						
			'<InboundMmsMessage>\r\n' +
			'<SenderAddress>tel:+18588228604</SenderAddress>\r\n' +
			'<Priority>Normal</Priority>\r\n' +
			'<Subject></Subject>\r\n' +
			'</InboundMmsMessage>\r\n' +
			'--MIMEBoundary_a9b1d81c790c90ac6520a984a9e404cedce0f820564bd221\r\n' +
			'Content-Type: multipart/related; Type="application/smil"; Start=0.smil; boundary="Nokia-mm-messageHandler-BoUnDaRy-=_-861381851"\r\n' +
			'Content-Transfer-Encoding: binary\r\n' +
			'Content-ID: <#1Attachment>\r\n' +
			'\r\n' +
			'--Nokia-mm-messageHandler-BoUnDaRy-=_-861381851\r\n' +
			'Content-Type: application/smil\r\n' +
			'Content-ID: 0.smil\r\n' +
			'Content-Transfer-Encoding: BASE64\r\n' +
			'\r\n' +
			'PHNtaWw+CjxoZWFkPgo8bGF5b3V0PgogPHJvb3QtbGF5b3V0Lz4KPHJlZ2lvbiBpZD0iVGV4dCIg' +
			'dG9wPSI3MCUiIGxlZnQ9IjAlIiBoZWlnaHQ9IjMwJSIgd2lkdGg9IjEwMCUiIGZpdD0ic2Nyb2xs' +
			'Ii8+CjxyZWdpb24gaWQ9IkltYWdlIiB0b3A9IjAlIiBsZWZ0PSIwJSIgaGVpZ2h0PSI3MCUiIHdp' +
			'ZHRoPSIxMDAlIiBmaXQ9Im1lZXQiLz4KPC9sYXlvdXQ+CjwvaGVhZD4KPGJvZHk+CjxwYXIgZHVy' +
			'PSIxMHMiPgo8aW1nIHNyYz0iSU1HXzcxMTguanBnIiByZWdpb249IkltYWdlIi8+Cjx0ZXh0IHNy' +
			'Yz0idGV4dF8wMDAyLnR4dCIgcmVnaW9uPSJUZXh0Ii8+CjwvcGFyPgo8L2JvZHk+Cjwvc21pbD4K\r\n' +
			'\r\n' +
			'--Nokia-mm-messageHandler-BoUnDaRy-=_-861381851\r\n' +
			'Content-Type: image/jpeg; Name=IMG_7118.jpg\r\n' +
			'Content-Disposition: Attachment; Filename=IMG_7118.jpg\r\n' +
			'Content-ID: 1\r\n' +
			'Content-Location: IMG_7118.jpg\r\n' +
			'Content-Transfer-Encoding: BASE64\r\n' +
			'\r\n' +
			'U3VwZXI=\r\n' +
			'\r\n' +
			'--Nokia-mm-messageHandler-BoUnDaRy-=_-861381851\r\n' +
			'Content-Type: text/plain; Charset=US-ASCII\r\n' +
			'Content-Disposition: Attachment; Filename=text_0002.txt; Charset=US-ASCII\r\n' +
			'Content-ID: 2\r\n' +
			'Content-Location: text_0002.txt\r\n' +
			'Content-Transfer-Encoding: BASE64\r\n' +
			'\r\n' +
			'TG9yZW0gaXBzdW0=\r\n';
			
		AttMMS rez = AttMMSCallbackProcessor.parseRequest(t, 'MIMEBoundary_a9b1d81c790c90ac6520a984a9e404cedce0f820564bd221');
		System.assertEquals(3, rez.attachments.size());
		System.assertEquals('Lorem ipsum', rez.attachments.get(2).content.toString());
		System.assertEquals('text/plain', rez.attachments.get(2).mimeType);
		System.assertEquals('IMG_7118.jpg', rez.attachments.get(1).fileName);
		
					
		System.assertEquals('+18588228604', rez.phoneNumber);
		System.assertEquals('', rez.subject);
		System.assertEquals('Normal', rez.priority);
	}
	
	public static testmethod void testExtractRealBoundary() {
		String realCTHeader = 'multipart/related; type="text/xml"; start="<rootpart@beta-api.att.com>"; boundary="MIMEBoundary_bfcaf1d20ac690b5d6af848238eec12d854e797f8a0575ce"';
		MultipartParser.ContentType ctype = MultipartParser.extractContentType('Content-Type: ' + realCTHeader);
		System.assertEquals('MIMEBoundary_bfcaf1d20ac690b5d6af848238eec12d854e797f8a0575ce', ctype.boundary);
	}
	
	public static testmethod void testParseRealRequest() {
		String t;
		
		t = '--MIMEBoundary_bfcaf1d20ac690b5d6af848238eec12d854e797f8a0575ce\r\n'+
			'Content-Transfer-Encoding: 8bit\r\n' + 
			'Content-ID: <rootpart@beta-api.att.com>\r\n' + 
			'Content-Type: text/xml; charset=UTF-8\r\n' + 
			'\r\n' + 
			'<InboundMmsMessage>\r\n' + 
			'<SenderAddress>tel:+16505754427</SenderAddress><Priority>Normal</Priority><Subject></Subject>\r\n' + 
			'</InboundMmsMessage>\r\n' + 
			'--MIMEBoundary_bfcaf1d20ac690b5d6af848238eec12d854e797f8a0575ce\r\n' + 
			'Content-Type: multipart/related; Start="<smil>"; Type="application/smil"; boundary="Nokia-mm-messageHandler-BoUnDaRy-=_-1721484296"\r\n' + 
			'Content-Transfer-Encoding: 7bit\r\n' + 
			'Content-ID: <2C86T930-C198-4V92M404>\r\n' + 
			'\r\n' + 
			'\r\n' + 
			'--Nokia-mm-messageHandler-BoUnDaRy-=_-1721484296\r\n' + 
			'Content-Type: application/smil; Name=smil.xml\r\n' + 
			'Content-ID: <smil>\r\n' + 
			'Content-Location: smil.xml\r\n' + 
			'Content-Transfer-Encoding: BASE64\r\n' + 
			'\r\n' + 
			'PHNtaWw+PGhlYWQ+PGxheW91dD48cm9vdC1sYXlvdXQgd2lkdGg9IjI0MCIgaGVpZ2h0PSIzMjAi' + 
			'Lz48cmVnaW9uIGlkPSJJbWFnZSIgbGVmdD0iMCIgdG9wPSIwIiB3aWR0aD0iMjQwIiBoZWlnaHQ9' +
			'IjIyMCIgZml0PSJtZWV0Ii8+PHJlZ2lvbiBpZD0iVGV4dCIgbGVmdD0iMCIgdG9wPSIyMjAiIHdp' +
			'ZHRoPSIyNDAiIGhlaWdodD0iMTAwIiBmaXQ9Im1lZXQiLz48L2xheW91dD48L2hlYWQ+PGJvZHk+' +
			'PHBhciBkdXI9IjUwMDBtcyI+PGltZyBzcmM9ImNpZDpfZXh0ZXJuYWxfaW1hZ2VzX21lZGlhXzEk' +
			'SU1BRzAwMDEuanBnIiByZWdpb249IkltYWdlIi8+PHRleHQgc3JjPSJ0ZXh0XzAudHh0IiByZWdp' +
			'b249IlRleHQiLz48L3Bhcj48L2JvZHk+PC9zbWlsPg==\r\n' +
			'\r\n' +
			'--Nokia-mm-messageHandler-BoUnDaRy-=_-1721484296\r\n' +
			'Content-Type: image/jpeg; Name=IMAG0001.jpg\r\n' +
			'Content-ID: <_external_images_media_1$IMAG0001.jpg>\r\n' +
			'Content-Location: IMAG0001.jpg\r\n' +
			'Content-Transfer-Encoding: BASE64\r\n' +
			'\r\n' +
			'/9j/4SCHRXhpZgAATU0AKgAAAAgACAEPAAIAAAAESFRDAAEQAAIAAAAKAAAAbgEaAAUAAAABAAAA' +
			'eAEbAAUAAAABAAAAgAEoAAMAAAABAAIAAAITAAMAAAABAAEAAIdpAAQAAAABAAAAiIglAAQAAAAB' +
			'XvdFRimhmKU4pCeaMcVd0yfQKQnFL2pOp6UStqTqOHJpSaQUY5p3i27o01SVgB5oYUbcmkIOaStq' +
			'ThisImageIsBrokenSinceMostPartOfItIsRemovedddddddddddddddddddddddddddddddddd' +
			'+amk1pLoKw3PNKAWNLwKUcDNXqtBpK4H0ppzmjkml71KWonZiEE0oGBRilz2p3e62DTqFDUlJzml' +
			'9kOJGKaADSUGmkkDlzajguaYRk4qROBTThWzUqTV0OSWgBT3pcChn3fSkPTNappqzIk1HRC8Dig/' +
			'Smg5pxbis5aaDuNOT0pQDikzg0pOKHqJPrcOh5pc03rTwMCqfRMa1YgOaCaQ9aRetJ2vdBrsxQMm' +
			'jGDSE80daFdonTYcy5GaVVJ+lNz2p/mFVxVK0XqUmnqxGXFNweuKU5Io3Hb7VdTVsXurR6Bv46UZ' +
			'zSfe6CgjisugSbYD5TQxyaApY04qRxSvdabkrX3Wf//Z\r\n' +
			'\r\n' +
			'--Nokia-mm-messageHandler-BoUnDaRy-=_-1721484296\r\n' +
			'Content-Type: text/plain; Name=text_0.txt; Charset=UTF-8\r\n' +
			'Content-ID: <text_0>\r\n' +
			'Content-Location: text_0.txt\r\n' +
			'Content-Transfer-Encoding: BASE64\r\n' +
			'\r\n' +
			'TG9yZW0gaXBzdW0=\r\n' +
			'\r\n' +
			'--Nokia-mm-messageHandler-BoUnDaRy-=_-1721484296--\r\n' +
			'\r\n' +
			'--MIMEBoundary_bfcaf1d20ac690b5d6af848238eec12d854e797f8a0575ce--';
			
		AttMMS rez = AttMMSCallbackProcessor.parseRequest(t, 'MIMEBoundary_bfcaf1d20ac690b5d6af848238eec12d854e797f8a0575ce');
		System.assertEquals(3, rez.attachments.size());
		System.assertEquals('Lorem ipsum', rez.attachments.get(2).content.toString());
		System.assertEquals('text/plain', rez.attachments.get(2).mimeType);
		System.assertEquals('IMAG0001.jpg', rez.attachments.get(1).fileName);
		
					
		System.assertEquals('+16505754427', rez.phoneNumber);
		System.assertEquals('', rez.subject);
		System.assertEquals('Normal', rez.priority);
	}
}