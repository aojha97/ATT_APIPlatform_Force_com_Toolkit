/**
 * @description Base interface for all authorization types, provides common methods to obtain authorization data.
 */
public interface AttAuthorization {
	
	/**
	 * @description Returns access token obtained from AT&T OAuth service.
	 * Throws AttException when AT&T OAuth service exception occurs, or access token cannot be returned.
	 * @return access token value.
	 */
	String getAccessToken();
}