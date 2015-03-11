#!/bin/sh

# Script to start AoA audio loop and java server
# Takes 2 (optional) args: event-freq & events-per-mode
# These can be left to the default in most cases

# Java cmd
JAVA=/usr/bin/java

# Toggle aiff/mp3
USE_AIFF=0 # 0 if using .mp3, else 1 for .aiff

# VLC-Player cmd
VLC_PLAYER=/Applications/VLC.app/Contents/MacOS/VLC

##################################################

AUDIO_FILE=AoA.mp3
if [ $USE_AIFF = 1 ]
then	
  AUDIO_FILE=AoA.aiff
fi


# Start the java server
$JAVA -classpath "bin:lib/jetty-6.1.3.jar:lib/jetty-util-6.1.3.jar:lib/servlet-api-2.5-6.1.3.jar" aoa.server.AoACommandServer $1 $2  &

# Start the audio
#"$VLC_PLAYER" -d -I dummy --loop $AUDIO_FILE  # -d for daemon
