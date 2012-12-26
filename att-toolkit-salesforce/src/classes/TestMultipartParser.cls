@isTest
public class TestMultipartParser {
	public static testmethod void testParseRecursive() {
		String t;
		/*
			'Content-Type: multipart/related; type="text/xml"; start="<rootpart@api.att.com>"; boundary="MIMEBoundary_a9b1d81c790c90ac6520a984a9e404cedce0f820564bd221"\n' +
			'Content-Transfer-Encoding: 8bit\n' +
			'Content-ID: <rootpart@api.att.com>\n' +
			'Content-Type: text/xml; charset=UTF-8\n' +
			'\n'
		*/
		t = '--MIMEBoundary_a9b1d81c790c90ac6520a984a9e404cedce0f820564bd221\n' +
			'Content-Transfer-Encoding: 8bit\n' +
			'Content-ID: <rootpart@beta-api.att.com>\n' +
			'Content-Type: text/xml; charset=UTF-8\n' + 
			'\n' +
			'<InboundMmsMessage>\n' +
			'<SenderAddress>tel:+18588228604</SenderAddress>\n' +
			'<Priority>Normal</Priority>\n' +
			'<Subject></Subject>\n' +
			'</InboundMmsMessage>\n' +
			'--MIMEBoundary_a9b1d81c790c90ac6520a984a9e404cedce0f820564bd221\n' +
			'Content-Type: multipart/related; Type="application/smil"; Start=0.smil; boundary="Nokia-mm-messageHandler-BoUnDaRy-=_-861381851"\n' +
			'Content-Transfer-Encoding: binary\n' +
			'Content-ID: <#1Attachment>\n' +
			'\n' +
			'--Nokia-mm-messageHandler-BoUnDaRy-=_-861381851\n' +
			'Content-Type: application/smil\n' +
			'Content-ID: 0.smil\n' +
			'Content-Transfer-Encoding: BASE64\n' +
			'\n' +
			/*'PHNtaWw+PGhlYWQ+PGxheW91dD48cm9vdC1sYXlvdXQgd2lkdGg9IjI0MCIgaGVpZ2h0PSIzMjAi' +
			'Lz48cmVnaW9uIGlkPSJJbWFnZSIgbGVmdD0iMCIgdG9wPSIwIiB3aWR0aD0iMjQwIiBoZWlnaHQ9' +
			'IjIyMCIgZml0PSJtZWV0Ii8+PHJlZ2lvbiBpZD0iVGV4dCIgbGVmdD0iMCIgdG9wPSIyMjAiIHdp' +
			'ZHRoPSIyNDAiIGhlaWdodD0iMTAwIiBmaXQ9Im1lZXQiLz48L2xheW91dD48L2hlYWQ+PGJvZHk+' +
			'PHBhciBkdXI9IjUwMDBtcyI+PHRleHQgc3JjPSJ0ZXh0XzAudHh0IiByZWdpb249IlRleHQiLz48' +
			'aW1nIHNyYz0iY2lkOjEwME1FRElBX0lNQUcwMDExLmpwZyIgcmVnaW9uPSJJbWFnZSIvPjwvcGFy' +
			'PjwvYm9keT48L3NtaWw+\n' +*/
			
			'cXFxcXFxcXFxcXFxcXFxcXFxcXFxcXFxcXFxcXFxcXE=\n' +
			'\n' +
			'--Nokia-mm-messageHandler-BoUnDaRy-=_-861381851\n' +
			'Content-Type: image/jpeg; Name=IMG_7118.jpg\n' +
			'Content-Disposition: Attachment; Filename=IMG_7118.jpg\n' +
			'Content-ID: 1\n' +
			'Content-Location: IMG_7118.jpg\n' +
			'Content-Transfer-Encoding: BASE64\n' +
			'\n' +
			'U3VwZXI=\n' +
			'\n' +
			'--Nokia-mm-messageHandler-BoUnDaRy-=_-861381851\n' +
			'Content-Type: text/plain; Charset=US-ASCII\n' +
			'Content-Disposition: Attachment; Filename=text_0002.txt; Charset=US-ASCII\n' +
			'Content-ID: 2\n' +
			'Content-Location: text_0002.txt\n' +
			'Content-Transfer-Encoding: BASE64\n' +
			'\n' +
			'TG9yZW0gaXBzdW0=\n';
			
		MultipartParser.ParseResult rez = MultipartParser.parseHttpBody(t, 'MIMEBoundary_a9b1d81c790c90ac6520a984a9e404cedce0f820564bd221');
		System.assertEquals(3, rez.attachments.size());
		System.assertEquals('Lorem ipsum', rez.attachments.get(2).content.toString());
		System.assertEquals('text/plain', rez.attachments.get(2).mimeType);
		System.assertEquals('IMG_7118.jpg', rez.attachments.get(1).fileName);
		
		System.assertEquals('application/smil', rez.attachments.get(0).mimeType);
		System.debug('\n\n\n\n' + rez.attachments.get(0).content.toString());
	}
	
	
	public static testmethod void testContentTypeParse() {
		String t = 'Content-Type: multipart/related; type="text/xml"; start="<rootpart@api.att.com>"; boundary="MIMEBoundary_a9b1d81c790c90ac6520a984a9e404cedce0f820564bd221" \n'+
		           'Content-Transfer-Encoding: 8bit \n' +
		           'Content-ID: <rootpart@api.att.com>';
		MultipartParser.ContentType rez = MultipartParser.extractContentType(t);
		System.assertEquals('multipart/related', rez.mainType);
		System.assertEquals('text/xml', rez.subType);
		System.assertEquals('MIMEBoundary_a9b1d81c790c90ac6520a984a9e404cedce0f820564bd221', rez.boundary);
		
		t = 'Content-Type: multipart/related; Type="application/smil"; Start=0.smil; boundary="Nokia-mm-messageHandler-BoUnDaRy-=_-861381851"\n';
		rez = MultipartParser.extractContentType(t);
		System.assertEquals('multipart/related', rez.mainType);
		System.assertEquals('application/smil', rez.subType);
		System.assertEquals('Nokia-mm-messageHandler-BoUnDaRy-=_-861381851', rez.boundary);
	}
	
	public static testmethod void testFileNameExtract() {
		String t;
		t = 'Content-Type: image/jpeg; Name=IMG_7118.jpg \n' +
		    'Content-Disposition: Attachment; Filename=IMG_7118.jpg \n' +
		    'Content-ID: 1\n\n';
		System.assertEquals('IMG_7118.jpg', MultipartParser.extractFileName(t));
		
		t = 'Content-Type: image/jpeg; name=IMG_7118.jpg; asdfgafads \n' +
		    'Content-Disposition: Attachment; filename=IMG_7118.jpg; dfdfg \n' +
		    'Content-ID: 1\n\n';
		System.assertEquals('IMG_7118.jpg', MultipartParser.extractFileName(t));
	}
	
	public static testmethod void testBodyExtract() {
		String t = 'Content-Type: application/smil Content-ID: 0.smil Content-Transfer-Encoding: BASE64\n' +
			'\n' + 
			'PHNtaWw+CjxoZWFkPgo8bGF5b3V0PgogPHJvb3QtbGF5b3V0Lz4KPHJlZ2lvbiBpZD0iVGV4dCIg\n' +
			'dG9wPSI3MCUiIGxlZnQ9IjAlIiBoZWlnaHQ9IjMwJSIgd2lkdGg9IjEwMCUiIGZpdD0ic2Nyb2xs\n' +
			'PSIxMHMiPgo8aW1nIHNyYz0iSU1HXzcxMTguanBnIiByZWdpb249IkltYWdlIi8+Cjx0ZXh0IHNy\n' +
			'Yz0idGV4dF8wMDAyLnR4dCIgcmVnaW9uPSJUZXh0Ii8+CjwvcGFyPgo8L2JvZHk+Cjwvc21pbD4K\n\n';
		
		String body = MultipartParser.extractBody(t);
		
		System.assertEquals('PHNta', body.substring(0, 5));
		System.assertEquals('pbD4K', body.substring(body.length() - 5, body.length()));
		
		System.assertEquals(2, 'asd\n\nasda'.split('\n\n').size());
	}
}