/**
 * @description Handles AT&T REST services response errors.
 */
public interface RestErrorHandler {
	
	/**
	 * @description Checks for responce errors and throw AttException with errors description.
	 * @param response HTTP responce object.
	 */
	void checkResponseCode(HttpResponse response);
	
	/**
     * @description Checks for responce service errors if success is false and throw AttException with errors description.
     * @param response HTTP responce object.
     */
	void checkServiceErrorResponce(HttpResponse response);
}