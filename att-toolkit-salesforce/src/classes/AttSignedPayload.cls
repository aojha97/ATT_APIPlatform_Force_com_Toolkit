/*
 * @description AttSignedPayload holds signed payload document for AT&T Payment service.
 */
public virtual class AttSignedPayload {
	
	/**
     * @description Signed document of the payload.
     */
	public String SignedDocument;
	
	/**
     * @description Signature of the payload.
     */
	public String Signature;

	
    /*
     * @description Parses JSON string into class fields.
     * @param json string with AT&T Signed Payload service JSON response data.
     * @return instance of AttSignedPayload class with data from JSON string.
     */
	public static AttSignedPayload parse(String json) {
		return (AttSignedPayload) System.JSON.deserialize(json, AttSignedPayload.class);
	}
	
	public static testMethod void testParse() {
		AttSignedPayload obj;
		String json = '{'+
		'"SignedDocument": "JTdCJTIyU2lnbmVkRG9jdW1lbnQlMjIlM0ElN0IlMjJQYXlslMjJub25jZSUyMiUzQTMyMTczMzQ5NjIlN0QlN0Q",'+
		'"Signature": "K2ElRUYlQkYlQkQlMjMlRUYlQkYlQkRKJUVGJUJGJUJE"'+
		'}';
		obj = parse(json);
		System.assert(obj != null);
        System.assertEquals('JTdCJTIyU2lnbmVkRG9jdW1lbnQlMjIlM0ElN0IlMjJQYXlslMjJub25jZSUyMiUzQTMyMTczMzQ5NjIlN0QlN0Q', obj.SignedDocument);
        System.assertEquals('K2ElRUYlQkYlQkQlMjMlRUYlQkYlQkRKJUVGJUJGJUJE', obj.Signature);
	}
}