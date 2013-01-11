
AT&T Speech Module Build and Installation Process

=======================Project structure 
=======================
This section describes application source structure. Project root folder contains resources, webapp subfolders.• resources – this folder contains 4 subfolders, each subfolder contains platform specific PhoneGap project template. Each template folder contains actual template files (PhoneGapTemplate folder), build script and output folder in which build process results will be placed for uploading to mobile devices. To find more information about PhoneGap platform specifics please navigate to (http://docs.phonegap.com/en/2.2.0/guide_getting-started_index.md.html )• webapp – this folder contains all IA application source files such as HTML pages, JavaScript files, CSS files, images and JSON stub data filesProject build algorithm

=================================================Default build process will contain next steps
=================================================
• Clear work directory• Update source code from SVN in work directory• Start building script. This script will do the following activities: - Copy web resources from webapp folder in special folder in project template - Compiling project  - Copy build artifacts into the ‘output’ folder=========================iOS - Prerequisites
=========================
• Intel-based computer with Mac OS X Lion or greater (10.7+)• Xcode 4.x• Necessary for installing on device: - Apple iOS device (iPhone, iPad, iPod Touch) - iOS developer certificateNote: identity folder in the resources\iphone\identity path contains developer’s certificate, mobile profile for device and password keeper file. The folder with resources\iphone\identity_release path contains distribution certificate, distribution profile and the proper password keeper file.

============================Build process description
============================
• For retrieving the DEBUG build, which can be installed on the iOS device, execute resources\iphone\script.sh.• Navigate to the resources\iphone\output\. Here you’ll see compiled iOS application (ATTSpeech.ipa) for OS version >= 4.0.• For installing the application on iOS device iTunes tools should be used. --END--