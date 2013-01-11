//Used to set a timeout for the request. The timeout period starts at the point the $.ajax call is made.
var REQUEST_TIMEOUT = 1 * 60 * 1000;// in milliseconds

//service for development
var SERVICE_URL = "https://endpoint-developer-edition.na14.force.com/services/apexrest/SpeechMobileApp";
//Old service
//var SERVICE_URL = "https://ryabchenko-developer-edition.na9.force.com/services/apexrest/ContactsMobileApp";
//Stage - for PRODACTION ONLY
//var SERVICE_URL = "https://att-forcecom-sdk-developer-edition.na9.force.com/services/apexrest/SpeechMobileApp";
var SERVICE_URL_DELAULT = SERVICE_URL;

function ajaxRequest() {
    $j.ajax({
        url: SERVICE_URL,
        cache: false,
        type: 'POST',
        async: true,
        data: readAsDataURL,
        contentType: "audio/wav",
        crossDomain: true,
        dataType: "json",
        xhrFields: {
            withCredentials: true
        },
        success: function(response) {
           	if (response.grade === "accept") {
               	setStatus("Status: recognized text from SF is '" + response.hypothesis + "'");
           	} else {
               	setStatus("Status: " + response.resultText);
           	}
           	$j("#search-field").val(response.hypothesis);
        	if (response.hypothesis != "") {
        		searchContacts(response.hypothesis);
        	}
        },
        error: function(response, textStatus) {
        	logToConsole("error");
        	logToConsole("textStatus   " + textStatus);
        	logToConsole("response.txt " + response.responseText);
        	setStatus("Status: Server error. " + response.responseText);
        },
        complete: function() {
        },
        timeout: REQUEST_TIMEOUT
    });
};