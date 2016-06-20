#!/bin/bash

# This file contains parts from the scripts taken from the Open GApps Project by mfonville.
#
# The Open GApps scripts are free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Pretty ascii art
echo ".+-+.+-+.+-+.+-+.+-+.+-+.+-+.+-+.+-+";
echo ".|P|.|u|.|r|.|e|.|N|.|e|.|x|.|u|.|s|";
echo ".+-+.+-+.+-+.+-+.+-+.+-+.+-+.+-+.+-+";
echo ".|D|.|y|.|n|.|a|.|m|.|i|.|c|........";
echo ".+-+.+-+.+-+.+-+.+-+.+-+.+-+........";
echo ".|G|.|A|.|p|.|p|.|s|................";
echo ".+-+.+-+.+-+.+-+.+-+................";

# Define paths && variables
APPDIRS="facelock/arm/app/FaceLock
         camera/arm/app/GoogleCamera
         camera/arm64/app/GoogleCamera
         hangouts/arm/app/Hangouts
         hangouts/arm64/app/Hangouts
         photos/arm/app/Photos
         photos/arm64/app/Photos
         prebuiltbugle/arm/app/PrebuiltBugle
         prebuiltbugle/arm64/app/PrebuiltBugle
         prebuiltgmscore/arm/priv-app/PrebuiltGmsCore
         prebuiltgmscore/arm64/priv-app/PrebuiltGmsCore
         setupwizard/phone/priv-app/SetupWizard
         setupwizard/tablet/priv-app/SetupWizard
         velvet/arm/priv-app/Velvet
         velvet/arm64/priv-app/Velvet
         system/app/CalendarGooglePrebuilt
         system/app/Chrome
         system/app/ChromeBookmarksSyncAdapter
         system/app/GoogleContactsSyncAdapter
         system/app/GoogleTTS
         system/app/PrebuiltDeskClockGoogle
         system/app/talkback
         system/priv-app/GoogleBackupTransport
         system/priv-app/GoogleFeedback
         system/priv-app/GoogleLoginService
         system/priv-app/GoogleOneTimeInitializer
         system/priv-app/GooglePartnerSetup
         system/priv-app/GoogleServicesFramework
         system/priv-app/HotwordEnrollment
         system/priv-app/Phonesky"
TARGETDIR=$(realpath .)
GAPPSDIR="$TARGETDIR"/files
TOOLSDIR="$TARGETDIR"/tools
STAGINGDIR="$TARGETDIR"/staging
FINALDIR="$TARGETDIR"/out
ZIPNAMETITLE=PureNexus_Dynamic_GApps
ZIPNAMEVERSION=6.x.x
ZIPNAMEDATE=$(date +%-m-%-e-%-y)
ZIPNAME="$ZIPNAMETITLE"_"$ZIPNAMEVERSION"_"$ZIPNAMEDATE".zip
JAVAHEAP=3072m
SIGNAPK="$TOOLSDIR"/signapk.jar
MINSIGNAPK="$TOOLSDIR"/minsignapk.jar
TESTKEYPEM="$TOOLSDIR"/testkey.x509.pem 
TESTKEYPK8="$TOOLSDIR"/testkey.pk8

dcapk() {
  TARGETDIR=$(realpath .)
  TARGETAPK="$TARGETDIR"/$(basename "$TARGETDIR").apk
  unzip -q -o "$TARGETAPK" -d "$TARGETDIR" "lib/*"
  zip -q -d "$TARGETAPK" "lib/*"
  cd "$TARGETDIR"
  zip -q -r -D -Z store -b "$TARGETDIR" "$TARGETAPK" "lib/"
  rm -rf "${TARGETDIR:?}"/lib/
  mv -f "$TARGETAPK" "$TARGETAPK".orig
  zipalign -f -p 4 "$TARGETAPK".orig "$TARGETAPK"
  rm -f "$TARGETAPK".orig
}

# Define beginning time
BEGIN=$(date +%s)

# Begin the magic
export PATH="$TOOLSDIR":$PATH
cp -rf "$GAPPSDIR"/* "$STAGINGDIR"

for dirs in $APPDIRS; do
  cd "$STAGINGDIR/${dirs}";
  dcapk 1> /dev/null 2>&1;
done

7za a -tzip -x!placeholder -r "$STAGINGDIR"/"$ZIPNAME" "$STAGINGDIR"/./* 1> /dev/null 2>&1
java -Xmx"$JAVAHEAP" -jar "$SIGNAPK" -w "$TESTKEYPEM" "$TESTKEYPK8" "$STAGINGDIR"/"$ZIPNAME" "$STAGINGDIR"/"$ZIPNAME".signed
rm -f "$STAGINGDIR"/"$ZIPNAME"
zipadjust "$STAGINGDIR"/"$ZIPNAME".signed "$STAGINGDIR"/"$ZIPNAME".fixed 1> /dev/null 2>&1
rm -f "$STAGINGDIR"/"$ZIPNAME".signed
java -Xmx"$JAVAHEAP" -jar "$MINSIGNAPK" "$TESTKEYPEM" "$TESTKEYPK8" "$STAGINGDIR"/"$ZIPNAME".fixed "$STAGINGDIR"/"$ZIPNAME"
rm -f "$STAGINGDIR"/"$ZIPNAME".fixed
mv -f "$STAGINGDIR"/"$ZIPNAME" "$FINALDIR"
find "$STAGINGDIR"/* ! -name "placeholder" -exec rm -rf {} +

# Define ending time
END=$(date +%s)

# All done
echo " "
echo "All done creating GApps!"
echo "Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}') ($(echo "$END - $BEGIN" | bc) seconds)"
echo "Completed GApps zip located in the "$FINALDIR" directory"
cd
