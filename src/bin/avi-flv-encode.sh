#!/bin/sh

#DEST_DIR=c\\Documents and Settings\\dhowe\\My Documents\\Flex Builder 3\\AoA\\src\\assets\\clips\\
DEST_DIR="/cygdrive/c/Documents and Settings/dhowe/My Documents/Flex Builder 3/AoA/src/assets/clips/"

# ffmpeg.exe -y -i in.avi -f flv -qscale 5 -r 25 -ar 44100 -ab 96 -s 500x374 out.flv

if [ $# == 1 ]
then
  DEST_DIR=$1;
fi
echo DD=${DEST_DIR}
ls *.avi | while read file; do
   echo processing $file
   #ffmpeg -y -i "$file" -an -f flv -qscale 5 "${file%.avi}.flv"
   ffmpeg -y -i "$file" -an -f flv "${file%.avi}.flv"
   echo moving "${file%.avi}.flv"
   mv "${file%.avi}.flv" "${DEST_DIR}" 
done
