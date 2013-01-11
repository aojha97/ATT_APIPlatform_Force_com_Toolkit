//Used to set a timeout for the request. The timeout period starts at the point the $.ajax call is made.
var REQUEST_TIMEOUT = 1 * 60 * 1000;// in milliseconds

//code for Hybrid REST Explorer
function regLinkClickHandlers() {

	$j('#link_audio_record_start').click(function() {
		recordStartAudio();
	});
	$j('#link_audio_record_stop').click(function() {
		recordStopAudio();
	});
	$j('#link_audio_record_send').click(function() {
		sendAudioRecord();
	});
	$j('#link_audio_play_start').click(function() {
		playAudio();
	});

	$j('#link_reset').click(function() {
		logToConsole("link_reset clicked");
		$j("#div_device_contact_list").html("");
		$j("#div_sfdc_contact_list").html("");
		$j("#div_sfdc_account_list").html("");
		$j("#console").html("");
		logToConsole("link_reset clicked");
	});
	
	$j('#link_contacts_search').click(function() {
		sendTextField();
	});

	$j('#link_logout').click(function() {
		logToConsole("link_logout clicked");
		var sfOAuthPlugin = cordova.require("salesforce/plugin/oauth");
		sfOAuthPlugin.logout();
	});

	$j('#link_settings, #link_settings_cancel').click(function() {
		logToConsole("link_settings/cancel clicked");
		
		setSettingsApiURL(SERVICE_URL);
		toggleSettingsDiv();
	});
	$j('#link_settings_save').click(function() {
		logToConsole("link_save clicked");
		
		SERVICE_URL = $j('#settings_URL').val();
		setSettingsApiURL(SERVICE_URL);
		hideSettingsDiv();
	});
	$j('#link_settings_default').click(function() {
		logToConsole("link_settings_default clicked");
		
		SERVICE_URL = SERVICE_URL_DELAULT;
		setSettingsApiURL(SERVICE_URL);
		hideSettingsDiv();
	});
	
}

// Start Recording audio
function recordStartAudio() {
	disableBtn($j("#link_audio_record_start"));
	disableBtn($j("#link_audio_record_send"));
	disableBtn($j("#link_audio_play_start"));

	logToConsole("recordStartAudio()");
	setStatus("Status: record button pressed");
	getFileSystem(onSuccessFSCreateFile);
}

function recordNow() {
    // Record audio
	if (mediaObj) {
		mediaObj.startRecord();
		setStatus("Status: recording audio...");
		logToConsole("Status: recording");
		enableBtn($j("#link_audio_record_stop"));
	} else {
		alert("Can't start recording: Media Object not initialized");
	}
}

//Stop Recording audio
function recordStopAudio() {
	logToConsole("=recordStopAudio()");

	disableBtn($j("#link_audio_record_stop"));
	enableBtn($j("#link_audio_record_start"));
	enableBtn($j("#link_audio_play_start"));

	if (mediaObj) {
    	mediaObj.stopRecord();
    	logToConsole("=mediaObj.stopRecord();");
    	setStatus("Status: stop recording");
		
		getPureDataUrlEncodedString();
    }
}

// Play audio
function playAudio() {
    if (mediaObj == null) {
        // Create Media object from src
    	logToConsole("mediaObj = new Media(...);");
        mediaObj = new Media(mediaSrc, onSuccess, onError);
    } // else play current audio
    // Play audio
    mediaObj.play();
	setStatus("Status: start playing audio...");

    // Update mediaObj position every second
    if (mediaTimer == null) {
        mediaTimer = setInterval(function() {
            // get mediaObj position
            mediaObj.getCurrentPosition(
                // success callback
                function(position) {
                    if (position > -1) {
                        setStatus("Status: playing (" + position + " sec) ...");
                    } else {
                    	//setStatus("Status: end of the audio record");
                    }
                },
                // error callback
                function(e) {
                    logToConsole("Error getting pos=" + e);
                    setStatus("Status: playing error. Error getting pos=" + e);
                }
            );
        }, 1000);
    };

}

function sendAudioRecord() {
	setStatus("Status: sending audio record to SF...");
	logToConsole("sending audio record...");
	ajaxRequest();
}

function sendTextField() {
	var searchField = $j("#search-field").val();
	setStatus("Status: sending text '" + searchField + "' to SF...");
	logToConsole("sending text field'" + searchField + "' to SF...");
	searchContacts(searchField);
}
