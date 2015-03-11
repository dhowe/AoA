#!/bin/sh

AOA_HOME=/Applications/AoA.app/
VLC_PLAYER=/Applications/VLC.app/Contents/MacOS/VLC

APP_RES=$AOA_HOME/Contents/Resources/
AOA_AIFF=$APP_RES/assets/AoA.aiff
AOA_MP3=$APP_RES/assets/AoA.mp3
APP_BIN=$APP_RES/bin/
APP_DIR=$AOA_HOME/Contents/MacOS/

#ADL_PATH=/Applications/Adobe\ Flex\ Builder\ 3/sdks/3.2.0/bin
#SERVER_DIR=/Users/dhowe/Documents/eclipse-workspace/AoAServer/bin
#AIR_RUNTIME=/Applications/Adobe\ Flex\ Builder\ 3/sdks/3.2.0/runtimes/air/mac/

#cd "$SERVER_DIR"
#/run-server.sh $1 $2

open $AOA_HOME &
"$VLC_PLAYER" -I dummy --loop $AOA_MP3  # -d for daemon
#"$ADL_PATH/adl" -runtime "$AIR_RUNTIME" AoAMain-app.xml &
