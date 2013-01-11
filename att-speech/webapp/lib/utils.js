function init() {
	disableBtn($j("#link_audio_record_stop"));
	disableBtn($j("#link_audio_play_start"));
	disableBtn($j("#link_audio_record_send"));
	enableBtn($j("#link_audio_record_start"));
	enableBtn($j("#link_contacts_search"));
	enableBtn($j("#search-field"));

	setSettingsApiURL(SERVICE_URL);
}

function setStatus(statusText) {
	$j('#status').html(statusText);
}
function disableBtn($Btn) {
	$Btn.attr('disabled', 'disabled').addClass('ui-disabled');
}

function enableBtn($Btn) {
	$Btn.removeAttr("disabled").removeClass('ui-disabled');
}

//onSuccess Callback
function onSuccess() {
    logToConsole("Audio Success");
}

// onError Callback 
function onError(error) {
    alert('code: '    + error.code    + '\n' + 
          'message: ' + error.message + '\n');
}


function getFileSystem(onSuccess) {
	window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, onSuccess, function() {
		alert("Failed in creating media file in FileSystem");
	});
}
function onSuccessFSCreateFile(fileSystem) {
	logToConsole("=onSuccessFSCreateFile");
   	fileSystem.root.getFile(mediaRecFile, { create: true, exclusive: false }, onOK_CreateFile, fileFail);
}

function onOK_CreateFile(fileEntry) {
	logToConsole("=onOK_GetFile()");
	// specific for iOS device: recording start here in call-back function
	// create media object using full media file name
	fileEntrySrc = fileEntry.fullPath;
	logToConsole("onOK_GetFile() fileEntry.fullPath = " + fileEntry.fullPath);
	
	mediaObj = new Media(fileEntry.fullPath, 
            // success callback
            function () {
    			logToConsole("recordAudio():Audio Success");
            },
            // error callback
            function (err) {
            	alert("Audio Error: " + err.message);
            });
	recordNow();
}

function getPureDataUrlEncodedString() {
	logToConsole("=getPureDataUrlEncodedString");
	getFileSystem(onSuccessFSGetFile);
}

function onSuccessFSGetFile(fileSystem) {
	logToConsole("=onSuccessFSGetFile");
	logToConsole("mediaRecFile=" + mediaRecFile);
   	fileSystem.root.getFile(mediaRecFile, { create: false, exclusive: false }, gotFileEntry, fileFail);
}

function fileFail(error) {
	logToConsole("***test: failed getting media file " + error.code);
};

function gotFileEntry(fileEntry) {
	logToConsole("=gotFileEntry(fileEntry)");
	logToConsole("fileEntry.file(readDataUrl=" + readDataUrl);
	fileEntry.file(readDataUrl, function(){alert("fileEntry.file(gotFile...");});
}

function readDataUrl(file) {
	logToConsole("=readDataUrl(file)");
    var reader = new FileReader();
    reader.onloadend = function(evt) {
    	readAsDataURL = evt.target.result;
    	enableBtn($j("#link_audio_record_send"));

    	if (readAsDataURL.indexOf('base64,') > 0) {
    	    logToConsole("readAsDataURL with    base64 ============== " + readAsDataURL.substring(0,80));
    	    readAsDataURL = readAsDataURL.split('base64,')[1];
    	    logToConsole("readAsDataURL without base64 ============== " + readAsDataURL.substring(0,80));
    	}
    	
    	setStatus("Status: audio file already ancoded");
    };
    logToConsole("readDataUrl(file)" + file);
    reader.readAsDataURL(file);
}

function searchContacts(searchField) {
	if(searchField  === "") {
		forcetkClient.query("SELECT Name FROM Contact", onSuccessSfdcContacts, onErrorSfdc);
	} else {
		forcetkClient.query("SELECT Name FROM Contact WHERE Name like '%" + searchField + "%'", onSuccessSfdcContacts, onErrorSfdc);
	}

}

function onSuccessSfdcContacts(response) {
    logToConsole("onSuccessSfdcContacts: received " + response.totalSize + " contacts");
    setStatus("Status: received " + response.totalSize + " contacts");
    
    $j("#div_sfdc_contact_list").html("");
    var ul = $j('<ul data-role="listview" data-inset="true" data-theme="a" data-dividertheme="a"></ul>');
    $j("#div_sfdc_contact_list").append(ul);
    
    ul.append($j('<li data-role="list-divider">Salesforce Contacts: ' + response.totalSize + '</li>'));
    $j.each(response.records, function(i, contact) {
           var newLi = $j("<li><a href='#'>" + (i+1) + " - " + contact.Name + "</a></li>");
           ul.append(newLi);
           });
    
    $j("#div_sfdc_contact_list").trigger( "create" );
}

function onErrorSfdc(error) {
	logToConsole("onErrorSfdc: " + JSON.stringify(error));
}

function setSettingsApiURL(url) {
	$j('#settings_URL').val(url);
}

function toggleSettingsDiv() {
	$j(".settings").animate({height: "toggle", opacity: "toggle"
	}, { duration: "slow" });
}
function hideSettingsDiv() {
	$j(".settings").animate({height: "toggle", opacity: "toggle"
	}, { duration: "slow" });
}