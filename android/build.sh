#!/bin/bash
# Colony APK build — requires Android SDK (platform-33, build-tools 33.0.2)
BT=${ANDROID_BUILD_TOOLS:-/tmp/android-sdk/build-tools/33.0.2}
PF=${ANDROID_PLATFORM:-/tmp/android-sdk/platforms/android-33/android.jar}
cd "$(dirname "$0")/app"
rm -rf obj dexout base.apk unsigned.apk aligned.apk
mkdir -p obj dexout
javac -source 8 -target 8 -bootclasspath "$PF" -d obj src/com/erogian/colony/*.java
"$BT/d8" --release --lib "$PF" --output dexout obj/com/erogian/colony/*.class
"$BT/aapt2" compile --dir res -o compiled.zip
"$BT/aapt2" link -o base.apk -I "$PF" --manifest AndroidManifest.xml -R compiled.zip
cp base.apk unsigned.apk
python3 -c "import zipfile; z=zipfile.ZipFile('unsigned.apk','a',zipfile.ZIP_DEFLATED); z.write('dexout/classes.dex','classes.dex'); z.close()"
"$BT/zipalign" -f 4 unsigned.apk aligned.apk
"$BT/apksigner" sign --ks ../colony.keystore --ks-pass pass:colony2026 --out ../Colony.apk aligned.apk
echo "Built: android/Colony.apk"
