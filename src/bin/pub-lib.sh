#!/bin/sh

if [ $# != 1 ]
then
  echo
	echo "tag or version required" 
  echo "usage: pub-lib.sh [tag]"
  exit
fi

export ZIP_DIR="/var/www/html/rita/"
export ZIP_FILE="RiTa$1.zip"
export ZIP_TTS_FILE="RiTaTTS$1.zip"

#./make-lib.sh $1 -t

cat $ZIP_TTS_FILE | /usr/bin/ssh dchowe@${RED} "(cd ${ZIP_DIR} && /bin/rm -f $ZIP_TTS_FILE && cat - > $ZIP_TTS_FILE && ln -fs $ZIP_TTS_FILE RiTaTTS.zip)" 

cat $ZIP_FILE | /usr/bin/ssh dchowe@${RED} "(cd ${ZIP_DIR} && /bin/rm -f $ZIP_FILE && cat - > $ZIP_FILE && ln -fs $ZIP_FILE RiTa.zip && ls -l)" 

mv $ZIP_FILE $ZIP_TTS_FILE zips
