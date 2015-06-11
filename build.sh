#/bin/bash
set -euo pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BUILD_DIR=$DIR/_tmp

echo \* Building to $BUILD_DIR

mkdir _dl || true

rm -rf _tmp || true
mkdir _tmp

if [ -f _dl/jdk-8u45-windows-i586.exe ];
then
	echo "OSX JDK already downloaded, skipping"
else
	wget -P _dl --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
		http://download.oracle.com/otn-pub/java/jdk/8u45-b15/jdk-8u45-windows-i586.exe
fi

if [ -f _dl/electron-v0.28.0-win32-ia32.zip ];
then
	echo "Electron Shell already downloaded, skipping"
else
	wget -P _dl https://github.com/atom/electron/releases/download/v0.28.0/electron-v0.28.0-win32-ia32.zip
fi

cd _tmp

echo ====================
echo Extracting Win32 JDK
echo ====================
echo

echo Extracting outer exe
7z -y x ../_dl/jdk*.exe >> log
echo Extracting tools.zip
7z -y -ojdk x tools.zip >> log

echo
echo ===================
echo Extracting Electron
echo ===================
echo

echo Extracting Electron Shell
7z -y -opackage/electron x ../_dl/electron*.zip >> log

echo Moving JRE
mv jdk/jre package/java

cd package/java

# We want the javaw executable
find bin -type f -not -name 'javaw.exe' | xargs rm

# Remove the javaws/plugin cruft 
rm -rf lib/deploy/
rm -rf lib/deploy.jar
rm -rf lib/javaws.jar
rm -rf lib/libdeploy.dll
rm -rf lib/libnpjp2.dll
rm -rf lib/plugin.jar
rm -rf lib/security/javaws.policy

cd $BUILD_DIR

# echo Installing native code
mkdir -p package/lib/node

cd $DIR/orbital

# export npm_config_disturl=https://atom.io/download/atom-shell
# export npm_config_target=0.25.0
# export npm_config_arch=x64
npm install >> $BUILD_DIR/log

cd $DIR
cp -aR orbital $BUILD_DIR/package/lib/node/orbital
