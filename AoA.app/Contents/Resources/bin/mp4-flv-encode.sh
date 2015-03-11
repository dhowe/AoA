#!/bin/sh

#DEST_DIR=c\\Documents and Settings\\dhowe\\My Documents\\Flex Builder 3\\AoA\\src\\assets\\clips\\
DEST_DIR="flvs/"

# ffmpeg.exe -y -i in.mp4 -f flv -qscale 5 -r 25 -ar 44100 -ab 96 -s 500x374 out.flv

if [ $# == 1 ]
then
  DEST_DIR=$1;
fi
echo DD=${DEST_DIR}
#ls *.mp4 | while read file; do
ls *[0][0-9][0-9]*.mp4 | while read file; do
   echo processing $file
   #ffmpeg -y -i "$file" -an -f flv -qscale 5 "${file%.mp4}.flv"
   ffmpeg -y -i "$file" -an -f flv "${file%.mp4}.flv"
   #echo moving "${file%.mp4}.flv"
   mv "${file%.mp4}.flv" "${DEST_DIR}" 
done
