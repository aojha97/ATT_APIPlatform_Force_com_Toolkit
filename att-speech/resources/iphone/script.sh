#!/bin/bash
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin
# Initialize variables
SLAVE_USER_PWD=test
CURRENT_DIR=`pwd`
# Initialize build script variables
cd ../../
pwd
WSP=`pwd`
echo $WSP

OUTPUT=$WSP/resources/iphone/output/
echo $OUTPUT

IA_WEBAPPS_PATH=$WSP/webapp/

IPHONE_WWW_PATH=$WSP/resources/iphone/ATTSpeech/www/

PASSWORD_FILENAME="password.txt"
CERT_FILENAME="certificate.p12"
PROFILE_FILENAME="profile.mobileprovision"

CONFIG=AdHoc

# Create the OUTPUT dir for building artifacts.
mkdir -p $OUTPUT

rm -fr $IPHONE_WWW_PATH
# Copy webapps files into www folder of project template
rsync -arv $IA_WEBAPPS_PATH $IPHONE_WWW_PATH --exclude=\*.svn\*
cp -f $CURRENT_DIR/cordova/* $IPHONE_WWW_PATH"lib/cordova/"
#####sh $CURRENT_DIR/pack.sh $IPHONE_WWW_PATH $IPHONE_WWW_PATH"assets/js/"
#####sh $CURRENT_DIR/compile.sh $IPHONE_WWW_PATH"assets/js/"

security unlock-keychain -p $SLAVE_USER_PWD $HOME/Library/Keychains/login.keychain

#import identity
pwd
cd resources/iphone
pwd
cd identity
PASSWORD=$(head -n 1 ./$PASSWORD_FILENAME | tr -d "\n\r");
security import ./$CERT_FILENAME -k login.keychain -t agg -f pkcs12 -P $PASSWORD -A
cp -f ./$PROFILE_FILENAME $HOME/Library/MobileDevice/Provisioning\ Profiles/

#build the app
cd ../
xcodebuild -target ATTSpeech -configuration $CONFIG -sdk iphoneos CONFIGURATION_BUILD_DIR=$OUTPUT clean
xcodebuild -target ATTSpeech -configuration $CONFIG -sdk iphoneos CONFIGURATION_BUILD_DIR=$OUTPUT build

#pack the ipa
FULLAPPNAME=$(find $OUTPUT -name '*.app')
APPNAMEWITHEXT=${FULLAPPNAME##*/}

APPNAME=${APPNAMEWITHEXT%%.*}

#copy iTunesArtwork in app ROOT
cp iTunesArtwork "$OUTPUT/$APPNAME.app"

cd identity

#get the certificate's name for signing the ipa
RAW_IDENTITY_NAME=$(openssl pkcs12 -in ./$CERT_FILENAME -passin file:./$PASSWORD_FILENAME -nokeys | head -n 2 | tail -n 1);
export IDENTITY_NAME=${RAW_IDENTITY_NAME#*": "}

BUILDNAME="ATTSpeech"
xcrun -sdk iphoneos PackageApplication "$OUTPUT/$APPNAME.app" -o "$OUTPUT/$BUILDNAME.ipa" --sign "$IDENTITY_NAME" --embed ./$PROFILE_FILENAME