#!/bin/sh

# required command
JAR_CMD=`which jar`

# directories
CWD=`dirname $0`
CWD=`cd $CWD && pwd -P`

BUILD_DIR="${CWD}/gradle_build"
LIBS_DIR="${BUILD_DIR}/libs"
JAVA_DIR="${BUILD_DIR}/src/main/java"
BIN_DIR="${CWD}/bin"
UNITY_SRC_DIR="${JAVA_DIR}/com/unity3d/player"

# options
MODE="Release"
SCRIPTING_BACKEND="il2cpp"
UNITY="/Applications/Unity/Hub/Editor/2019.4.26f1"

for OPT in $*; do
  case $OPT in
    '--release' )
      MODE="Release";;
    '--develop' )
      MODE="Develop";;
    '--il2cpp' )
      SCRIPTING_BACKEND="il2cpp";;
    '--mono' )
      SCRIPTING_BACKEND="mono";;
    '--unity' )
      UNITY=$2
      shift 2
      ;;
  esac
  shift
done

UNITY_JAVA_LIB="${UNITY}/PlaybackEngines/AndroidPlayer/Variations/${SCRIPTING_BACKEND}/${MODE}/Classes/classes.jar"
UNITY_JAVA_SRC="${UNITY}/PlaybackEngines/AndroidPlayer/Source/com/unity3d/player/UnityPlayerActivity.java"

# clean
rm -rf ${JAVA_DIR}/*
rm -rf ${LIB_DIR}
rm -f ${BUILD_DIR}/src/main/AndroidManifest.xml
rm -f ${BUILD_DIR}/src/main/com/unity3d/player/UnityPlayerActivity.java

pushd $CWD

# build
mkdir -p ${LIBS_DIR}
mkdir -p ${BIN_DIR}
mkdir -p ${JAVA_DIR}
mkdir -p ${UNITY_SRC_DIR}

cp ${UNITY_JAVA_LIB} ${LIBS_DIR}
cp ${UNITY_JAVA_SRC} ${UNITY_SRC_DIR}
cp -r src-nofragment/net ${JAVA_DIR}
cp AndroidManifest.xml ${BUILD_DIR}/src/main

./gradlew clean
./gradlew assembleRelease
cp ${BUILD_DIR}/build/outputs/aar/*.aar ${BIN_DIR}/WebViewPlugins.aar

# install
DEST_DIR='../../build/Packager/Assets/Plugins/Android'
mkdir -p ${DEST_DIR}
cp ${BIN_DIR}/WebViewPlugins.aar ${DEST_DIR}/WebViewPlugin.aar

popd # $BUILD_DIR
